using UnityEngine;
using System;

class/* ��ʶ��*/ MyFirstC : MonoBehaviour
{
    #region ��Ա����
    public enum color
    {
        white = 1,
        black,
        yellow,
        red,
        green,
        blue
    }

    public color c = color.blue;//ö�ٳ�ʼ��

    public int a = 0;

    //public float a = 0.0f, b = 0.0f, c = 0.0f, d = 0.0f;
    //public int y = 10;
    //Calculator dd = new Calculator();
    //private string ssdda;
    //private string sddddddaf;
    //public bool SSSon;

    //public Vector2 xxx;
    //public Vector3 yyy;
    //public Vector4 zzz;
    //public Rect www;


    //public int[] number = new int[2];  //����һ��һά��������,����ʵ����ʱд�����ȣ�����һ��ȷ���Ͳ����ٱ��ˣ��޷��ı䣩
    //public int[,] number2 = new int[2, 3];  //����һ����ά�������飨ͨ��,�ָ��������������ǿ�������
    //public int[, ,] number3 = new int[2, 3, 4];  //����һ����ά�������飨ͨ��,�ָ��������������ǿ�������
    //public int[] number4 = new int[2] {0, 1};  //����һ��һά��������,����ʵ�������ʼ��
    //public int[] number44 = {0, 1};  //����һ��һά��������,����ʵ�������ʼ���ĵڶ��ַ���
    //public int[,] number5 = new int[2, 3] 
    //{
    //    {8, 1, 5 },
    //    {4, 5, 16}
    //};  //����һ����ά��������,����ʵ�������ʼ��

    #endregion

    #region [Start]
    private void Start()
    {
        //switch (c)
        //{
        //    case  color.white:
        //        Debug.LogError("��ɫ");
        //        break;
        //    case color.black:
        //        Debug.LogError("��ɫ");
        //        break;
        //    default:
        //        Debug.LogError("��ɫ");
        //        break;
        //}
        string a = "dadaadahhhgrdg";
        string b = "dadaada";
        Debug.LogError(a.Contains(b));
    }
    #endregion

    class TestClass
    {
        public const int value = 99;
    }
}