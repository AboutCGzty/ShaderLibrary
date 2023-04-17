using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ArtToolTA
{
    #region 【数据成员】

    private bool isJumpFolder = false;

    #endregion

    public void Draw()
    {
        // 折叠组功能
        isJumpFolder = EditorGUILayout.BeginFoldoutHeaderGroup(isJumpFolder, "定位到工程目录");
        {
            if (isJumpFolder)
            {
                if (GUILayout.Button("ArtTools"))
                {
                    // 目录跳转
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
