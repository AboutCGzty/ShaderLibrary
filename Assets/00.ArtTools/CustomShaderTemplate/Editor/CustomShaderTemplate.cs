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
    /// �����������
    /// </summary>
    [MenuItem("��������/�Զ���Shaderģ��")]
    static void Open()
    {
        var window = GetWindow(typeof(CustomShaderTemplate), false, "Shaderģ��");
        window.Show();
    }

    private void OnGUI()
    {
        // �Զ��������ʽ�ļ�·��
        var skin = (GUISkin)EditorGUIUtility.Load("Assets/00.ArtTools/CustomShaderTemplate/Editor/TemplateSkin.guiskin");
        EditorGUILayout.LabelField("ģ��ѡ��", skin.textField);

        // �Զ��尴ť��ʽ
        if (GUILayout.Button("��FX����Чģ��", skin.button))
        {
            // ��������ȡ��Shaderģ��·��
            /*����һ��д��·��*/
            //string oldPath = "Assets/ArtPackage/00.ArtTools/ZTYTools/CustomShaderTemplate/Editor/Template/FXTemplate.shader";
            /*��������ͨ��GUID��ȡ����*/
            string shaderguid = "f0b36847e8e36704bb85016446957a79";
            string GUIDPath = AssetDatabase.GUIDToAssetPath(shaderguid);

            // ��ӵ��ѡ�ж���GUID����ת����String���͵��ַ���
            var guid = Selection.assetGUIDs[0];
            string folder =  AssetDatabase.GUIDToAssetPath(guid);
            if (!AssetDatabase.IsValidFolder(folder))
            {
                folder = Path.GetDirectoryName(folder);
            }

            // ʹ��ת�����·������Shader�ļ�
            string nwePath = folder + "/FX.shader";

            // ����ظ����������滻������
            nwePath = AssetDatabase.GenerateUniqueAssetPath(nwePath);
            AssetDatabase.CopyAsset(GUIDPath, nwePath);
            //Debug.LogError("���� ��Ч Shaderģ��ɹ�������");
        }
    }
}
