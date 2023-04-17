using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.Linq;
using System.IO;
using System.Text.RegularExpressions;
using System.Globalization;
using System.Reflection;
using System.Text;

public class TextureCheck : EditorWindow
{
    private GUILayoutOption[] Option1 = new GUILayoutOption[] { GUILayout.MaxWidth(100), GUILayout.MinWidth(50), GUILayout.ExpandWidth(true) };

    static string [] GetAllFiles(string path)
    {
        path = GetAssetPath(path);
        return System.IO.Directory.GetFiles(path, "*", System.IO.SearchOption.AllDirectories).Where(s => s.EndsWith(".png")).ToArray();
    }

    private enum CheckType
    {
        SizeIsTrue = 1,
        SizeIsMax = 2
    }
    private static CheckType _checkType = CheckType.SizeIsTrue;
    private string folderPath = "Assets";
    private static float checkSize = 256;
    //private static bool isCloseMipmap = true;

    [MenuItem("美术工具/贴图检测/检测贴图Size是否规范")]
    static void TextureSizeIsTrue()
    {
        _checkType = CheckType.SizeIsTrue;
        GetWindow(typeof(TextureCheck), true, "检测贴图Size是否规范").Show();
    }

    [MenuItem("美术工具/贴图检测/检测贴图是否超大")]
    static void TextureSizeIsMax()
    {
        _checkType = CheckType.SizeIsMax;
        checkSize = 512;
        GetWindow(typeof(TextureCheck), true, "检测贴图是否超大").Show();
    }
    public void OnGUI()
    {
        if (GUILayout.Button("选择文件夹"))
        {
            folderPath = EditorUtility.OpenFolderPanel("选择文件夹", folderPath, "");
        }
        EditorGUILayout.LabelField("文件夹路径：" + folderPath);
        if (_checkType != CheckType.SizeIsTrue)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("检测边界值：");
            checkSize = EditorGUILayout.FloatField("", checkSize, Option1);
            EditorGUILayout.EndHorizontal();
        }
        if (GUILayout.Button("开始检测"))
        {
            if (_checkType == CheckType.SizeIsTrue)
            {
                FindTextureErrorSizeData(folderPath);
            }
            else if(_checkType == CheckType.SizeIsMax)
            {
                FindTextureMaxSize(folderPath, checkSize);
            }
        }
    }

    private static string GetAssetPath(string path)
    {
        int idx = path.IndexOf("Assets");
        string assetRelativePath = path.Substring(idx);
        return assetRelativePath;
    }
    private static void FindTextureErrorSizeData(string path)
    {
        Debug.Log("开始检查数据");
        string[] files = GetAllFiles(path);
        for (int i = 0 ; i < files.Length ; i++)
        {
            Texture2D _texture = AssetDatabase.LoadAssetAtPath(files[i], typeof(Texture2D)) as Texture2D;
            if (_texture == null)
            {
                continue;
            }
            
            if (GetMaxMipLevel(_texture.width) == -1 || GetMaxMipLevel(_texture.height) == -1)
            {
                LogData(files[i], _texture);
            }
        }
        Debug.Log("检查完毕\n\n\n");
    }

    private static void FindTextureMaxSize(string path, float maxSize)
    {
        Debug.Log("开始检查贴图数据");
        string[] files = GetAllFiles(path);
        for (int i = 0 ; i < files.Length ; i++)
        {
            Texture2D _texture = AssetDatabase.LoadAssetAtPath(files[i], typeof(Texture2D)) as Texture2D;
            if (_texture == null)
            {
                continue;
            }

            int _maxSize = _texture.width > _texture.height ? _texture.width : _texture.height;
            if (_maxSize > maxSize)
            {
                LogData(files[i], _texture);
            }
        }
        Debug.Log("检查完毕\n\n\n");
    }
    private static void LogData(string file, Texture2D texture)
    {
        Debug.Log(file + " mipmapCount = " + texture.mipmapCount + " w = " + texture.width + " h = " + texture.height, texture);
    }

    private static int GetMaxMipLevel(int size)
    {
        int sum = 1;
        for (int i = 1 ;i <= size ; i ++)
        {
            sum = sum * 2;
            if (sum == size)
            {
                return i + 1;
            }
            if (sum > size)
            {
                break;
            }
        }
        return -1;
    }
}
