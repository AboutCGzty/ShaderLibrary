using UnityEngine;
using UnityEditor;

/// <summary>
/// 添加特性，修改Transform面板
/// </summary>
//[CustomEditor(typeof(Transform))]

public class ExtendInspectorEditor : Editor
{
    //private Transform trans;
    ///// <summary>
    ///// OnEnable()是内置方法，在代码激活时只执行一次
    ///// </summary>
    //void OnEnable()
    //{
    //    trans = (Transform)target;
    //}

    ///// <summary>
    ///// OnInspectorGUI本身是一个虚方法，要添加关键字【override】进行覆写
    ///// </summary>
    //override public void OnInspectorGUI()
    //{
    //    var skin = (GUISkin)EditorGUIUtility.Load("Assets/ArtPackage/00.ArtTools/ZTYTools/ExtendTutorial/Editor/TransformSkin.guiskin");

    //    #region 【坐标】
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("重置", skin.button))
    //        {
    //            trans.position = new Vector3(0.00f, 0.00f, 0.00f);
    //        }
    //        // 世界空间坐标
    //        trans.position = EditorGUILayout.Vector3Field("坐标", trans.position);
    //    }
    //    EditorGUILayout.EndHorizontal();
    //    #endregion

    //    #region 【旋转】
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("重置", skin.button))
    //        {
    //            trans.localEulerAngles = new Vector3(0.00f, 0.00f, 0.00f);
    //        }
    //        // 世界空间旋转
    //        trans.localEulerAngles = EditorGUILayout.Vector3Field("旋转", trans.localEulerAngles);
    //    }
    //    EditorGUILayout.EndHorizontal();
    //    #endregion

    //    #region 【缩放】
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("重置", skin.button))
    //        {
    //            trans.localScale = new Vector3(1.00f, 1.00f, 1.00f);
    //        }
    //        // 世界空间缩放
    //        trans.localScale = EditorGUILayout.Vector3Field("缩放", trans.localScale);
    //    }
    //    EditorGUILayout.EndHorizontal();
    //    #endregion

    //    #region 全部重置
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("全部重置", skin.button))
    //        {
    //            trans.position = new Vector3(0.00f, 0.00f, 0.00f);
    //            trans.localEulerAngles = new Vector3(0.00f, 0.00f, 0.00f);
    //            trans.localScale = new Vector3(1.00f, 1.00f, 1.00f);
    //        }
    //    }
    //    EditorGUILayout.EndHorizontal();
    //    #endregion
    //}
}
