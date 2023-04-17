using UnityEngine;
using UnityEditor;

public class SimpleCalculator : EditorWindow
{
    #region ��ֵ��Ա
    private string NumberLabel = "0";
    private float Number01, Number02;
    private string op/*op���������*/;
    #endregion

    // ���ߴ���·��
    [MenuItem("��������/SimpleCalculate(���׼�����) #&C", false, 1)]

    static void Open()
    {
        var window = GetWindow(typeof(SimpleCalculator), false, "���׼�����");
        //window.maximized = true;
        //window.minSize = new Vector2(475, 578);
        //window.maxSize = new Vector2(475, 578);  //ͨ������Ҫ�������ߴ�
        //window.position = new Rect();  //Windowsƽ̨����������Ͻǣ�ƻ������֧�ִ˷������Բ���ʾ����
        //window.position = new Rect(800, 100, 100, 200);  //ֻ���趨��ʱ���ֵ�λ�����С
        Texture tex = AssetDatabase.LoadAssetAtPath<Texture>("Assets/ArtPackage/00.ArtTools/ZTYTools/Calculator/ss.png");
        window.titleContent = new GUIContent("ţ�Ƶļ��׼�����", tex);  //������ӱ�������ͼ��
        //window.titleContent = new GUIContent("ţ�Ƶļ��׼�����", "������������һ");  //���Ը�������GetWindow�����еı�����
        window.Show();  //�����/��С�ߴ����ʱ�����Ŵ��ڵĹ��ܾ�ʧЧ�� 
    }

    private void OnGUI()
    {
        //GUIStyle _style01 = new GUIStyle(/*��дUnity���÷���*/EditorStyles.textField);
        ////�޸ķ��
        //_style01.fontSize = 50;//�������ִ�С
        //_style01.wordWrap = true;//����Ϊtrue���ı��Ż���ݴ�С������ʾ����

        //GUIStyle _style02 = new GUIStyle(/*��дUnity���÷���*/EditorStyles.textField);
        ////�޸ķ��
        //_style02.fontSize = 50;//�������ִ�С

        var skin = /*ǿ��ת����*/(GUISkin)EditorGUIUtility.Load("Assets/00.ArtTools/Calculator/Editor/Calculator.guiskin");
        //Debug.LogError(skin);

        EditorGUILayout.LabelField(NumberLabel, skin.textField);
        GUILayout.BeginHorizontal();
        {
            GUILayout.BeginVertical(skin.box);
            {
                GUILayout.BeginHorizontal();//���ܵ������ڣ��п�ʼ��Ҫ�н���
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
                GUILayout.EndHorizontal();//����ˮƽ��

                GUILayout.BeginHorizontal();//���ܵ������ڣ��п�ʼ��Ҫ�н���
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
                GUILayout.EndHorizontal();//����ˮƽ��

                GUILayout.BeginHorizontal();//���ܵ������ڣ��п�ʼ��Ҫ�н���
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
                GUILayout.EndHorizontal();//����ˮƽ��

                GUILayout.BeginHorizontal();//���ܵ������ڣ��п�ʼ��Ҫ�н���
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
                GUILayout.EndHorizontal();//����ˮƽ��
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
