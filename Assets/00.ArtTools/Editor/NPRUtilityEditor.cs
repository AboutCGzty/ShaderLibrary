using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class NPRUtilityEditor
{
    [MenuItem("美术工具/平滑法线/写入顶点颜色")]
    public static void WirteAverageNormalToVertexColor()
    {
        MeshFilter[] meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();
        foreach (var meshFilter in meshFilters)
        {
            Mesh mesh = meshFilter.sharedMesh;
            WriteAverageNormalToVertexColor(mesh);
        }
        
        SkinnedMeshRenderer[] skinMeshRenders = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinMeshRender in skinMeshRenders)
        {
            Mesh mesh = skinMeshRender.sharedMesh;
            WriteAverageNormalToVertexColor(mesh);
        }
        Debug.Log("Done:平滑法线写入顶点颜色成功");
    }
    
    [MenuItem("美术工具/平滑法线/写入切线")]
    public static void WirteAverageNormalToTangent()
    {
        MeshFilter[] meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();
        foreach (var meshFilter in meshFilters)
        {
            Mesh mesh = meshFilter.sharedMesh;
            WriteSmoothNormalToTangent(mesh);
        }

        SkinnedMeshRenderer[] skinMeshRenders = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinMeshRender in skinMeshRenders)
        {
            Mesh mesh = skinMeshRender.sharedMesh;
            WriteSmoothNormalToTangent(mesh);
        }
        Debug.Log("Done:平滑法线写入切线成功");
    }
    
    /// <summary>
    /// 将平滑法线写入 顶点色的GB通道，RA不变
    /// </summary>
    /// <param name="mesh"></param>
    private static void WriteAverageNormalToVertexColor(Mesh mesh)
    {
        Dictionary<Vector3, Vector3> vertexNormalDic = new Dictionary<Vector3, Vector3>();
        for (int i = 0; i < mesh.vertexCount; i++)
        {
            if (!vertexNormalDic.ContainsKey(mesh.vertices[i]))
            {
                vertexNormalDic.Add(mesh.vertices[i],mesh.normals[i]);
            }
            else
            {
                vertexNormalDic[mesh.vertices[i]] += mesh.normals[i];
            }
        }

        Color[] colors = null;
        bool hasVertexColor = mesh.colors.Length == mesh.vertexCount;
        if (hasVertexColor)
        {
            colors = mesh.colors;
        }
        else
        {
            colors = new Color[mesh.vertexCount];
        }
        // length =1
        // 1 = sart(x*x +y*y+z*z);
        for (int i = 0; i < mesh.vertexCount; i++)
        {
            Vector3 averageNormal = vertexNormalDic[mesh.vertices[i]].normalized;
            //colors[i] = new Color(averageNormal.x*0.5f+0.5f,averageNormal.y*0.5f+0.5f,averageNormal.z*0.5f+0.5f, hasVertexColor? colors[i].a:1.0f);
            colors[i] = new Color( averageNormal.x*0.5f+0.5f,averageNormal.y*0.5f+0.5f,hasVertexColor? colors[i].b:1.0f, hasVertexColor? colors[i].a:1.0f);
        }
        mesh.colors = colors;
        SaveMesh(mesh, mesh.name+"_SmoothNormalToVertexColor",true,true);
    }
    
    /// <summary>
    /// 平滑法线，即是求出一个顶点 所在的所有三角面的法线的平均值
    /// </summary>
    /// <param name="mesh"></param>
    private static void WriteSmoothNormalToTangent(Mesh mesh)
    {
        //建立一个 Position到Nomral 的索引字典
        //将相同Position所对应的所有法线求和
        //将求和后的法线normalize即得到平滑法线
        //将平滑法线写入Tangent
        Dictionary<Vector3, Vector3> vertexNormalDic = new Dictionary<Vector3, Vector3>();
        
        for (int i = 0; i < mesh.vertexCount; i++)
        {
            if (!vertexNormalDic.ContainsKey(mesh.vertices[i]))
            {
                vertexNormalDic.Add(mesh.vertices[i],mesh.normals[i]);
            }
            else
            {
                vertexNormalDic[mesh.vertices[i]] += mesh.normals[i];//将相同 Position的所有法线求和
            }
        }

        Vector4[] tangents = null;
        bool hasTangent = mesh.tangents.Length == mesh.vertexCount;
        if (hasTangent)
        {
            tangents = mesh.tangents;
        }
        else
        {
            tangents = new Vector4[mesh.vertexCount];
        }
        
        for (int i = 0; i < mesh.vertexCount; i++)
        {
            Vector3 averageNormal = vertexNormalDic[mesh.vertices[i]].normalized;//将求和后的法线normalize即得到平滑法线
            tangents[i] = new Vector4(averageNormal.x,averageNormal.y,averageNormal.z, 0f);//如果写入到顶点色需要将值映射到[0,1]，再在Shader中重新映射到[-1,1]
        }
        mesh.tangents = tangents;
        
        SaveMesh(mesh, mesh.name+"_SmoothNormalToTangent",true,true);
    }

    private static void SaveMesh(Mesh mesh,string Path)
    {
        
    }
    
    public static void SaveMesh (Mesh mesh, string name, bool makeNewInstance, bool optimizeMesh) 
    {
        string path = EditorUtility.SaveFilePanel("Save Separate Mesh Asset", "Assets/", name, "asset");
        if (string.IsNullOrEmpty(path)) return;
        
        path = FileUtil.GetProjectRelativePath(path);

        Mesh meshToSave = (makeNewInstance) ? Object.Instantiate(mesh) as Mesh : mesh;
		
        if (optimizeMesh) MeshUtility.Optimize(meshToSave);
        
        AssetDatabase.CreateAsset(meshToSave, path);
        AssetDatabase.SaveAssets();
    }
    
}