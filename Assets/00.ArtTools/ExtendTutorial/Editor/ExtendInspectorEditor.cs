using UnityEngine;
using UnityEditor;

/// <summary>
/// ������ԣ��޸�Transform���
/// </summary>
//[CustomEditor(typeof(Transform))]

public class ExtendInspectorEditor : Editor
{
    //private Transform trans;
    ///// <summary>
    ///// OnEnable()�����÷������ڴ��뼤��ʱִֻ��һ��
    ///// </summary>
    //void OnEnable()
    //{
    //    trans = (Transform)target;
    //}

    ///// <summary>
    ///// OnInspectorGUI������һ���鷽����Ҫ��ӹؼ��֡�override�����и�д
    ///// </summary>
    //override public void OnInspectorGUI()
    //{
    //    var skin = (GUISkin)EditorGUIUtility.Load("Assets/ArtPackage/00.ArtTools/ZTYTools/ExtendTutorial/Editor/TransformSkin.guiskin");

    //    #region �����꡿
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("����", skin.button))
    //        {
    //            trans.position = new Vector3(0.00f, 0.00f, 0.00f);
    //        }
    //        // ����ռ�����
    //        trans.position = EditorGUILayout.Vector3Field("����", trans.position);
    //    }
    //    EditorGUILayout.EndHorizontal();
    //    #endregion

    //    #region ����ת��
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("����", skin.button))
    //        {
    //            trans.localEulerAngles = new Vector3(0.00f, 0.00f, 0.00f);
    //        }
    //        // ����ռ���ת
    //        trans.localEulerAngles = EditorGUILayout.Vector3Field("��ת", trans.localEulerAngles);
    //    }
    //    EditorGUILayout.EndHorizontal();
    //    #endregion

    //    #region �����š�
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("����", skin.button))
    //        {
    //            trans.localScale = new Vector3(1.00f, 1.00f, 1.00f);
    //        }
    //        // ����ռ�����
    //        trans.localScale = EditorGUILayout.Vector3Field("����", trans.localScale);
    //    }
    //    EditorGUILayout.EndHorizontal();
    //    #endregion

    //    #region ȫ������
    //    EditorGUILayout.BeginHorizontal(skin.box);
    //    {
    //        if (GUILayout.Button("ȫ������", skin.button))
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
