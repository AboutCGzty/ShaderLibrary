using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ArtToolTA
{
    #region �����ݳ�Ա��

    private bool isJumpFolder = false;

    #endregion

    public void Draw()
    {
        // �۵��鹦��
        isJumpFolder = EditorGUILayout.BeginFoldoutHeaderGroup(isJumpFolder, "��λ������Ŀ¼");
        {
            if (isJumpFolder)
            {
                if (GUILayout.Button("ArtTools"))
                {
                    // Ŀ¼��ת
                    string path = "Assets/ArtPackage/00.ArtTools/ZTYTools";
                    string[] guids = AssetDatabase.FindAssets("t: Object", new string[] { path });
                    if (guids.Length > 1)
                    {
                        string subpath = AssetDatabase.GUIDToAssetPath(guids[0]);
                        object o = AssetDatabase.LoadAssetAtPath(subpath, typeof(object));
                        Selection.activeObject = (Object)o;
                    }
                    else
                    {
                        object o = AssetDatabase.LoadAssetAtPath(path, typeof(object));
                        Selection.activeObject = (Object)o;
                    }
                }
            }
        }
        EditorGUILayout.EndFoldoutHeaderGroup();
    }
}
