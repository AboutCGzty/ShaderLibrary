using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.PackageManager.UI;
using System.IO;
using System;

public class CustomShaderTemplate : EditorWindow
{
    /// <summary>
    /// 创建材质面板
    /// </summary>
    [MenuItem("美术工具/自定义Shader模板")]
    static void Open()
    {
        var window = GetWindow(typeof(CustomShaderTemplate), false, "Shader模板");
        window.Show();
    }

    private void OnGUI()
    {
        // 自定义面板样式文件路径
        var skin = (GUISkin)EditorGUIUtility.Load("Assets/00.ArtTools/CustomShaderTemplate/Editor/TemplateSkin.guiskin");
        EditorGUILayout.LabelField("模板选择", skin.textField);

        // 自定义按钮样式
        if (GUILayout.Button("（FX）特效模板", skin.button))
        {
            // 创建被获取的Shader模板路径
            /*方法一：写死路径*/
            //string oldPath = "Assets/ArtPackage/00.ArtTools/ZTYTools/CustomShaderTemplate/Editor/Template/FXTemplate.shader";
            /*方法二：通过GUID获取对象*/
            string shaderguid = "f0b36847e8e36704bb85016446957a79";
            string GUIDPath = AssetDatabase.GUIDToAssetPath(shaderguid);

            // 添加点击选中对象GUID，并转换成String类型的字符串
            var guid = Selection.assetGUIDs[0];
            string folder =  AssetDatabase.GUIDToAssetPath(guid);
            if (!AssetDatabase.IsValidFolder(folder))
            {
                folder = Path.GetDirectoryName(folder);
            }

            // 使用转换后的路径创建Shader文件
            string nwePath = folder + "/FX.shader";

            // 解决重复创建不断替换的问题
            nwePath = AssetDatabase.GenerateUniqueAssetPath(nwePath);
            AssetDatabase.CopyAsset(GUIDPath, nwePath);
            //Debug.LogError("创建 特效 Shader模板成功！！！");
        }
    }
}
