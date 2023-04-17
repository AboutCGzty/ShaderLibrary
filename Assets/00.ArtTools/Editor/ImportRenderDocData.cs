using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using UnityEngine.WSA;

namespace TA
{
    public class ImportRenderDocData : Editor
    {
        [MenuItem("美术工具/导入CSV模型/碧蓝幻想")]
        public static void ImportCSV_GBVS()
        {
            // string[] path = new string[]{   @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero1\sword.csv",
            //                                 @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero1\body.csv",
            //                                 @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero1\head.csv", 
            // };
            string[] path = new string[]
            {
                // @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero5\",
                // @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero6\",
                // @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero7\",
                // @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero8\",
                @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero9\",
                @"E:\Document\截帧\RenderDoc\碧蓝幻想Data\Hero10\",
            };
            Csv2Obj_GBVS.Parse(path);
        }

        [MenuItem("美术工具/导入CSV模型/罪恶装备Strive")]
        public static void ImportCSV_GGXStrive()
        {
            string[] path = new string[]
            {
                //@"E:\Document\截帧\罪恶装备Strive\罪恶装备Strive\Hero1\",
                 @"E:\Document\截帧\罪恶装备Strive\罪恶装备Strive\Hero2\",
                 @"E:\Document\截帧\罪恶装备Strive\罪恶装备Strive\Hero3\",
                 @"E:\Document\截帧\罪恶装备Strive\罪恶装备Strive\Hero4\",
            };
            Csv2Obj_GGXStrive.Parse(path);
        }
    }

    class MeshData
    {
        public List<int> VTX;
        public List<int> IDX;
        public List<int> Face;
        public List<Vector3> Position;
        public List<Vector3> Normal;
        public List<Vector4> Tangent;
        public List<Color> VertexColor;
        public List<Vector2> Texcoord0;
        public List<Vector2> Texcoord1;

        public MeshData()
        {
            this.VTX = new List<int>();
            this.IDX = new List<int>();
            this.Face = new List<int>();
            this.Position = new List<Vector3>();
            this.Normal = new List<Vector3>();
            this.Tangent = new List<Vector4>();
            this.VertexColor = new List<Color>();
            this.Texcoord0 = new List<Vector2>();
            this.Texcoord1 = new List<Vector2>();
        }
    }
    
    class Csv2Obj_GBVS
    {
        public static void Parse(string[] args)
        {
            Debug.ClearDeveloperConsole();
            foreach (string arg in args)
            {
                Debug.Log("Csv2Obj碧蓝幻想:   ");

                if (Directory.Exists(arg))
                {
                    Debug.Log("In Fold:   " + Path.GetFileNameWithoutExtension(arg));
                    string[] files = Directory.GetFiles(arg);
                    ParseFolder(files);
                }
                else if (File.Exists(arg) && arg.EndsWith(".csv"))
                {
                    Debug.Log("In csv:   " + Path.GetFileName(arg));
                    ParseFile(arg);
                }
            }
        }

        static void ParseFolder(string[] files)
        {
            foreach (var file in files)
            {
                ParseFile(file);
            }
        }

        static void ParseFile(string path)
        {
            if (!path.EndsWith(".csv")) return;

            string name = Path.GetFileName(path);

            Debug.Log("Parse:   " + Path.GetFileName(path));

            string[] lines = File.ReadAllLines(path);

            Debug.Log("Read:   " + Path.GetFileName(path));

            MeshData meshData = new MeshData();

            // List<Vector3> OptPosition = new List<Vector3>();
            // Dictionary<Vector3, int> PosIndexDic = new Dictionary<Vector3, int>();

            int nextIndex = 2;
            for (int i = 1; i < lines.Length; i++)
            {
                var line = lines[i];

                string[] words = line.Split(',');

                int index = 0;
                meshData.VTX.Add(int.Parse(words[index++]));
                meshData.IDX.Add(int.Parse(words[index++]));
                Vector3 Pos = new Vector3(float.Parse(words[index++]), float.Parse(words[index++]),
                    float.Parse(words[index++]));
                meshData.Position.Add(Pos);
                meshData.Normal.Add(new Vector3(float.Parse(words[index++]), float.Parse(words[index++]),
                    float.Parse(words[index++])));
                index++;
                // index++;
                // index++;
                // index++;
                meshData.Tangent.Add(new Vector4(float.Parse(words[index++]), float.Parse(words[index++]),
                    float.Parse(words[index++]), float.Parse(words[index++])));
                // index++; //skip bitangent 光滑法线
                meshData.Texcoord0.Add(new Vector2(float.Parse(words[index++]),
                    1.0f - float.Parse(words[index++]))); //uv颠倒了
                //meshData.Texcoord1.Add(new Vector2(float.Parse(words[index++]), float.Parse(words[index++])));//uv颠倒了
                meshData.VertexColor.Add(new Color(float.Parse(words[index++]), float.Parse(words[index++]),
                    float.Parse(words[index++]), float.Parse(words[index++])));
                // Debug.Log("ParsePercent:   " + ((float) i) / ((float) lines.Length));

                int j = (i - 1);
                if (nextIndex == j)
                {
                    nextIndex = j + 3;
                    //反转法线
                    int start = j;
                    meshData.Face.Add(start - 0);
                    meshData.Face.Add(start - 1);
                    meshData.Face.Add(start - 2);
                    Debug.Log((nextIndex + ": " + (start + 2) + " " + (start + 1) + " " + (start + 0)));
                }
            }

            Debug.Log(meshData.Position.Count + " " + meshData.Face.Count);
            Mesh mesh = new Mesh();
            mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
            mesh.vertices = meshData.Position.ToArray();
            mesh.uv = meshData.Texcoord0.ToArray();
            mesh.normals = meshData.Normal.ToArray();
            mesh.colors = meshData.VertexColor.ToArray();
            mesh.tangents = meshData.Tangent.ToArray();
            mesh.triangles = meshData.Face.ToArray();
            mesh.OptimizeIndexBuffers();
            mesh.OptimizeReorderVertexBuffer();
            mesh.Optimize();

            AssetDatabase.CreateAsset(mesh, "Assets/" + name + ".asset");

            // GameObject.Find()

            GameObject go = new GameObject(name);
            go.transform.position = Vector3.zero;
            go.AddComponent<MeshFilter>().mesh = mesh;
            go.AddComponent<MeshRenderer>().material = null;
        }
    }
    
    
    class Csv2Obj_GGXStrive
{
    public static void Parse(string[] args)
    {
        Debug.ClearDeveloperConsole();
        foreach (string arg in args)
        {
            Debug.Log("Csv2Obj罪恶装备Strive:   ");
            
            if (Directory.Exists(arg))
            {
                string current = Directory.GetParent(arg).ToString();
                string parent = Directory.GetParent(current).ToString().ToString();
                string modelName = current.Remove(0,parent.Length+1);
                
                Debug.Log("In Fold:   " + Path.GetFileNameWithoutExtension(arg));
                string[] files = Directory.GetFiles(arg);
                ParseFolder(files,modelName);
            }
            else if (File.Exists(arg) && arg.EndsWith(".csv"))
            {
                Debug.Log("In csv:   " + Path.GetFileName(arg));
                string modelName = Path.GetFileNameWithoutExtension(arg);
                ParseFile(arg,modelName);
            }
        }
    }

    private static GameObject Parent = null;
    static void ParseFolder(string[] files,string modelName)
    {
        Parent = new GameObject(modelName);
        Parent.transform.position = Vector3.zero;
        
        foreach (var file in files)
        {
            ParseFile(file,modelName);
            
        }
        
        Parent.transform.Rotate(Vector3.right,-90f);
        
        Parent = null;
    }

    static void ParseFile(string path,string modelName)
    {
        if(!path.EndsWith(".csv"))return;
        
        string name = Path.GetFileName(path);

        Debug.Log("Parse:   " + Path.GetFileName(path));

        string[] lines = File.ReadAllLines(path);

        Debug.Log("Read:   " + Path.GetFileName(path));

        MeshData meshData = new MeshData();

        // List<Vector3> OptPosition = new List<Vector3>();
        // Dictionary<Vector3, int> PosIndexDic = new Dictionary<Vector3, int>();
        
        int nextIndex = 2;
        for (int i = 1; i < lines.Length; i++)
        {
            var line = lines[i];

            string[] words = line.Split(',');

            int index = 0;
            meshData.VTX.Add(int.Parse(words[index++]));
            meshData.IDX.Add(int.Parse(words[index++]));
            Vector3 Pos = new Vector3(float.Parse(words[index++]), float.Parse(words[index++]), float.Parse(words[index++]));
            meshData.Position.Add(Pos*0.1f);
            meshData.Normal.Add(new Vector3(float.Parse(words[index++]), float.Parse(words[index++]), float.Parse(words[index++])));
            index++;
            meshData.Tangent.Add(new Vector4(float.Parse(words[index++]), float.Parse(words[index++]), float.Parse(words[index++]) , float.Parse(words[index++])  ));
            // index++; //skip bitangent 光滑法线
            meshData.Texcoord0.Add(new Vector2(float.Parse(words[index++]), 1f-float.Parse(words[index++]))); //uv颠倒了
            meshData.Texcoord1.Add(new Vector2(float.Parse(words[index++]), 1f-float.Parse(words[index++])));//uv颠倒了
            meshData.VertexColor.Add(new Color(float.Parse(words[index++]), float.Parse(words[index++]), float.Parse(words[index++]), float.Parse(words[index++])));
            // Debug.Log("ParsePercent:   " + ((float) i) / ((float) lines.Length));
            
            //反转法线
            int j = (i-1); 
            if(nextIndex == j)
            {
                nextIndex = j+3;
                //反转法线
                int start = j;
                meshData.Face.Add(start - 0);
                meshData.Face.Add(start - 1);
                meshData.Face.Add(start - 2);
                Debug.Log((nextIndex+": "+ (start + 2)   +" "+ (start + 1) +" " + (start + 0 ))) ;
            }
        }
        
        Debug.Log( meshData.Position.Count +" " +  meshData.Face.Count) ;
        Mesh mesh = new Mesh();
        mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
        mesh.vertices = meshData.Position.ToArray();
        mesh.uv = meshData.Texcoord0.ToArray();
        mesh.normals = meshData.Normal.ToArray();
        mesh.colors = meshData.VertexColor.ToArray();
        mesh.tangents = meshData.Tangent.ToArray();
        
        mesh.triangles = meshData.Face.ToArray();
        // mesh.triangles = meshData.VTX.ToArray();
        
        mesh.OptimizeIndexBuffers();
        mesh.OptimizeReorderVertexBuffer();
        mesh.Optimize();

        AssetDatabase.CreateAsset(mesh,"Assets/"+modelName+"_"+name +".asset");

        // GameObject.Find()

        GameObject go = new GameObject(modelName+"_" + name);
        go.transform.position = Vector3.zero;
        go.AddComponent<MeshFilter>().mesh = mesh;
        go.AddComponent<MeshRenderer>().material = null;
        if (Parent != null)
        {
            go.transform.SetParent(Parent.transform);
        }
    }
}

}