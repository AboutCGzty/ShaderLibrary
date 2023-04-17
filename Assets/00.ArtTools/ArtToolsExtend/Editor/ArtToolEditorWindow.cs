using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ArtToolEditorWindow : EditorWindow
{
    #region �����ݳ�Ա��

    // ��������
    private string[] typeName = { "��ɫ", "����", "U  I", "��Ч", "T  A", "����"};
    private int selectionID;
    private const string selectionIDKey = "selectionID";

    #endregion

    #region ������򿪡�

    [MenuItem("��������/�������߼�")]
    static void Open()
    {
        var window = GetWindow(typeof(ArtToolEditorWindow), false, "�������߼�");
        window.Show();
    }

    #endregion

    #region ��ʵ������

    private ArtToolTA artTA;
    private void OnEnable()
    {
        artTA = new ArtToolTA();// ʵ������
        // ����key�������õ���ʱValue
        //�־û�����ʵ����һ�δ�ʱ������һ��ѡ�н��湦��
        //selectionID = EditorPrefs.GetInt(selectionIDKey);
        selectionID = EditorPrefs.HasKey(selectionIDKey) ? EditorPrefs.GetInt(selectionIDKey) : 0;
    }

    #endregion

    #region �����ڹرա�

    private void OnDisable()
    {
        // �رմ���ʱ��¼
        EditorPrefs.SetInt(selectionIDKey, selectionID);
    }

    #endregion

    #region ��OnGUI��

    private void OnGUI()
    {
        var skin = (GUISkin)EditorGUIUtility.Load("Assets/00.ArtTools/ArtToolsExtend/Editor/ArtTool Skin.guiskin");
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.BeginVertical(skin.box);
            {
                // ��SelectionGridѡ�е�selectionID���ص�ֵ���¸���selectionID��������ѭ������˼
                selectionID = GUILayout.SelectionGrid(selectionID, typeName, 1, skin.button);
            }
            EditorGUILayout.EndVertical();

            EditorGUILayout.BeginVertical();
            {
                switch (selectionID)
                {
                    case 0:
                        GUILayout.TextField("0", skin.textField);
                        break;
                    case 1:
                        GUILayout.TextField("1", skin.textField);
                        break;
                    case 2:
                        break;
                    case 3:
                        break;
                    case 4:
                        artTA.Draw();
                        break;
                    case 5:
                        break;
                }
            }
            EditorGUILayout.EndVertical();
        }
        EditorGUILayout.EndHorizontal();

        // ���԰�ť
        if (GUILayout.Button("Test Only"))
        {
            #region ��GameObject go��
            //GameObject go = Selection.activeGameObject;
            //go.SetActive(!go.activeSelf);//��ʾ���ع���
            //Undo.RecordObject(go, "name");// ���ع���
            //go.name = "xxx";// �����޸����֣�д����
            //StaticEditorFlags flags = StaticEditorFlags.ContributeGI | StaticEditorFlags.BatchingStatic | StaticEditorFlags.ReflectionProbeStatic;
            //GameObjectUtility.SetStaticEditorFlags(go, flags);
            //go.tag = "EditorOnly";// ����Ϊר�Ų����õı�ǩ
            //go.layer = 1; // ͨ������ֵ��Ӧ
            // Transform
            //go.transform.position = new Vector3(1,2,3);
            //go.transform.eulerAngles = new Vector3(45.0f, 0.0f, 0.0f);
            //go.transform.localScale = new Vector3(2,3,5);
            // Component
            //var Light = go.GetComponent<Light>();
            //Light light;
            //if (go.TryGetComponent<Light>(out light))
            //{
            //    light.intensity = 3;
            //    Debug.LogError(light.intensity);
            //}
            //else
            //{
            //    Debug.LogError("��ǰû��ѡ�о��С�Light������Ķ��󣡣�");
            //}
            #endregion

            #region ����������
            //var goo = GameObject.CreatePrimitive(PrimitiveType.Cube);
            //goo.name = "Test Cube";
            //goo.tag = "TestOnly";
            //var light2 = goo.AddComponent(typeof(Light)) as Light;// ����ӵ�Light������س�����light2��ֵ���Ϳ���ȡ���ƹ�ǿ�ȵȲ���
            //light2.intensity = 3;
            #endregion

            //Print<int> P = new Print<int>(); // ��������Ҫǰ����Ҫ��<>��д����������
            var P = new Print<int>(); // �ڶ���д��
            P.Value = 4;
            P.Log();
        }

        // �汾���
        GUILayout.Label("Version [ 2023.03.07 ] -- by ������", EditorStyles.centeredGreyMiniLabel);
    }
    #endregion
}
