using UnityEngine;
using UnityEditor;

public class SimpleCalculator : EditorWindow
{
    #region 数值成员
    private string NumberLabel = "0";
    private float Number01, Number02;
    private string op/*op代表运算符*/;
    #endregion

    // 工具创建路径
    [MenuItem("美术工具/SimpleCalculate(简易计算器) #&C", false, 1)]

    static void Open()
    {
        var window = GetWindow(typeof(SimpleCalculator), false, "简易计算器");
        //window.maximized = true;
        //window.minSize = new Vector2(475, 578);
        //window.maxSize = new Vector2(475, 578);  //通常不需要限制最大尺寸
        //window.position = new Rect();  //Windows平台会出现在左上角，苹果机不支持此方法所以不显示窗口
        //window.position = new Rect(800, 100, 100, 200);  //只是设定打开时出现的位置与大小
        Texture tex = AssetDatabase.LoadAssetAtPath<Texture>("Assets/ArtPackage/00.ArtTools/ZTYTools/Calculator/ss.png");
        window.titleContent = new GUIContent("牛逼的简易计算器", tex);  //可以添加标题栏的图标
        //window.titleContent = new GUIContent("牛逼的简易计算器", "这个计算器雕得一");  //可以覆盖上面GetWindow方法中的标题名
        window.Show();  //当最大/最小尺寸相等时，缩放窗口的功能就失效了 
    }

    private void OnGUI()
    {
        //GUIStyle _style01 = new GUIStyle(/*填写Unity内置方法*/EditorStyles.textField);
        ////修改风格
        //_style01.fontSize = 50;//设置文字大小
        //_style01.wordWrap = true;//设置为true后文本才会根据大小缩放显示区域

        //GUIStyle _style02 = new GUIStyle(/*填写Unity内置方法*/EditorStyles.textField);
        ////修改风格
        //_style02.fontSize = 50;//设置文字大小

        var skin = /*强制转换符*/(GUISkin)EditorGUIUtility.Load("Assets/00.ArtTools/Calculator/Editor/Calculator.guiskin");
        //Debug.LogError(skin);

        EditorGUILayout.LabelField(NumberLabel, skin.textField);
        GUILayout.BeginHorizontal();
        {
            GUILayout.BeginVertical(skin.box);
            {
                GUILayout.BeginHorizontal();//不能单独存在，有开始就要有结束
                if (GUILayout.Button("7", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "7" : NumberLabel + "7";
                }
                if (GUILayout.Button("8", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "8" : NumberLabel + "8";
                }
                if (GUILayout.Button("9", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "9" : NumberLabel + "9";
                }
                GUILayout.EndHorizontal();//结束水平组

                GUILayout.BeginHorizontal();//不能单独存在，有开始就要有结束
                if (GUILayout.Button("4", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "4" : NumberLabel + "4";
                }
                if (GUILayout.Button("5", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "5" : NumberLabel + "5";
                }
                if (GUILayout.Button("6", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "6" : NumberLabel + "6";
                }
                GUILayout.EndHorizontal();//结束水平组

                GUILayout.BeginHorizontal();//不能单独存在，有开始就要有结束
                if (GUILayout.Button("1", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "1" : NumberLabel + "1";
                }
                if (GUILayout.Button("2", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "2" : NumberLabel + "2";
                }
                if (GUILayout.Button("3", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "3" : NumberLabel + "3";
                }
                GUILayout.EndHorizontal();//结束水平组

                GUILayout.BeginHorizontal();//不能单独存在，有开始就要有结束
                if (GUILayout.Button("0", skin.button))
                {
                    NumberLabel = NumberLabel == "0" ? "0" : NumberLabel + "0";
                }
                if (GUILayout.Button("C", skin.button))
                {
                    NumberLabel = "0";
                }
                if (GUILayout.Button("=", skin.button))
                {
                    Number02 = float.Parse(NumberLabel);
                    if (op == "+")
                    {
                        float r = Number01 + Number02;
                        NumberLabel = r.ToString();
                    }
                    else if (op == "-")
                    {
                        float r = Number01 - Number02;
                        NumberLabel = r.ToString();
                    }
                    else if (op == "*")
                    {
                        float r = Number01 * Number02;
                        NumberLabel = r.ToString();
                    }
                    else if (op == "/")
                    {
                        if (Number02 != 0)
                        {
                            float r = Number01 / Number02;
                            NumberLabel = r.ToString();
                        }
                        else
                        {
                            NumberLabel = "0";
                        }
                    }
                }
                GUILayout.EndHorizontal();//结束水平组
            }
            GUILayout.EndVertical();

            GUILayout.BeginVertical(skin.box);
            {
                if (GUILayout.Button("+", skin.button))
                {
                    Number01 = float.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "+";
                }
                if (GUILayout.Button("-", skin.button))
                {
                    Number01 = float.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "-";
                }
                if (GUILayout.Button("*", skin.button))
                {
                    Number01 = float.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "*";
                }
                if (GUILayout.Button("/", skin.button))
                {
                    Number01 = float.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "/";
                }
            }
            GUILayout.EndVertical();
        }
        GUILayout.EndHorizontal();


    }
}
