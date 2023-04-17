using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ArtToolEditorWindow : EditorWindow
{
    #region 【数据成员】

    // 参数数组
    private string[] typeName = { "角色", "场景", "U  I", "特效", "T  A", "其他"};
    private int selectionID;
    private const string selectionIDKey = "selectionID";

    #endregion

    #region 【界面打开】

    [MenuItem("美术工具/美术工具集")]
    static void Open()
    {
        var window = GetWindow(typeof(ArtToolEditorWindow), false, "美术工具集");
        window.Show();
    }

    #endregion

    #region 【实例化】

    private ArtToolTA artTA;
    private void OnEnable()
    {
        artTA = new ArtToolTA();// 实例化类
        // 输入key，在最后得到的时Value
        //持久化数据实现下一次打开时保持上一次选中界面功能
        //selectionID = EditorPrefs.GetInt(selectionIDKey);
        selectionID = EditorPrefs.HasKey(selectionIDKey) ? EditorPrefs.GetInt(selectionIDKey) : 0;
    }

    #endregion

    #region 【窗口关闭】

    private void OnDisable()
    {
        // 关闭窗口时记录
        EditorPrefs.SetInt(selectionIDKey, selectionID);
    }

    #endregion

    #region 【OnGUI】

    private void OnGUI()
    {
        var skin = (GUISkin)EditorGUIUtility.Load("Assets/00.ArtTools/ArtToolsExtend/Editor/ArtTool Skin.guiskin");
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.BeginVertical(skin.box);
            {
                // 将SelectionGrid选中的selectionID返回的值重新赋给selectionID，类似内循环的意思
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

        // 测试按钮
        if (GUILayout.Button("Test Only"))
        {
            #region 【GameObject go】
            //GameObject go = Selection.activeGameObject;
            //go.SetActive(!go.activeSelf);//显示隐藏功能
            //Undo.RecordObject(go, "name");// 撤回功能
            //go.name = "xxx";// 代码修改名字（写死）
            //StaticEditorFlags flags = StaticEditorFlags.ContributeGI | StaticEditorFlags.BatchingStatic | StaticEditorFlags.ReflectionProbeStatic;
            //GameObjectUtility.SetStaticEditorFlags(go, flags);
            //go.tag = "EditorOnly";// 可作为专门测试用的标签
            //go.layer = 1; // 通过整数值对应
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
            //    Debug.LogError("当前没有选中具有【Light】组件的对象！！");
            //}
            #endregion

            #region 【添加组件】
            //var goo = GameObject.CreatePrimitive(PrimitiveType.Cube);
            //goo.name = "Test Cube";
            //goo.tag = "TestOnly";
            //var light2 = goo.AddComponent(typeof(Light)) as Light;// 将添加的Light组件返回成名叫light2的值，就可以取到灯光强度等参数
            //light2.intensity = 3;
            #endregion

            //Print<int> P = new Print<int>(); // 泛类型需要前后都需要在<>中写明参数类型
            var P = new Print<int>(); // 第二种写法
            P.Value = 4;
            P.Log();
        }

        // 版本标记
        GUILayout.Label("Version [ 2023.03.07 ] -- by 赵天玉", EditorStyles.centeredGreyMiniLabel);
    }
    #endregion
}
