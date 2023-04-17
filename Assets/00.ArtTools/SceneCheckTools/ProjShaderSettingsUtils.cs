using UnityEngine;
using UnityEditor;
using System.Linq;
using System.Reflection;
using System.IO;
using System.Collections.Generic;

public class ProjShaderSettingsUtils
{
    [MenuItem("美术工具/Shader相关/检索所有Shader的变体数量")]
    public static void CalcAllShadersVariants()
    {
        var unityEditor = Assembly.LoadFile(EditorApplication.applicationContentsPath + "/Managed/UnityEditor.dll");
        var shaderUtilType = unityEditor.GetType("UnityEditor.ShaderUtil");
        string[] files = Directory.GetFiles(Application.dataPath, "*.shader", SearchOption.AllDirectories);
        var shaderDic = new Dictionary<Object, int>();
        int progress = files.Length;
        int current = 0;
        foreach (var path in files)
        {
            current++;
            bool isCancel = EditorUtility.DisplayCancelableProgressBar("处理Shader中", path, (float)current / (float)progress);
            if(isCancel)
            {
                EditorUtility.ClearProgressBar();
                break;
            }
            string resPath = FileUtil.GetProjectRelativePath(path);
            var shaderAsset = AssetDatabase.LoadAssetAtPath<Shader>(resPath);
            if (shaderAsset != null)
            {
                MethodInfo setSearchType = shaderUtilType.GetMethod("GetVariantCount", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic); 
                object[] parameters = new System.Object[] { shaderAsset, true };
                var comboCount = setSearchType.Invoke(null, parameters);
                int varientCount = int.Parse(comboCount.ToString());
                shaderDic.Add(shaderAsset, varientCount);
            }
        }
        EditorUtility.ClearProgressBar();
        var sortArray = (from objDic in shaderDic
                         orderby objDic.Value descending
                         select objDic).ToDictionary(pair => pair.Key, pair => pair.Value);
        foreach (var kvp in sortArray)
        {
            Shader mshader = kvp.Key as Shader;
            string assetPath = AssetDatabase.GetAssetPath(kvp.Key);
            Debug.Log(string.Format(assetPath + ": {0}", kvp.Value), mshader);
        }
        Debug.Log(string.Format("共扫描{0}个结果", files.Length));
    }
}
