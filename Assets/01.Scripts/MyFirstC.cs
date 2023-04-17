using UnityEngine;
using System;

class/* 标识符*/ MyFirstC : MonoBehaviour
{
    #region 成员类型
    public enum color
    {
        white = 1,
        black,
        yellow,
        red,
        green,
        blue
    }

    public color c = color.blue;//枚举初始化

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


    //public int[] number = new int[2];  //声明一个一维整型数组,并在实例化时写明长度，长度一旦确定就不会再变了（无法改变）
    //public int[,] number2 = new int[2, 3];  //声明一个二维整型数组（通过,分割），但是在面板上是看不见的
    //public int[, ,] number3 = new int[2, 3, 4];  //声明一个二维整型数组（通过,分割），但是在面板上是看不见的
    //public int[] number4 = new int[2] {0, 1};  //声明一个一维整型数组,并在实例化后初始化
    //public int[] number44 = {0, 1};  //声明一个一维整型数组,并在实例化后初始化的第二种方法
    //public int[,] number5 = new int[2, 3] 
    //{
    //    {8, 1, 5 },
    //    {4, 5, 16}
    //};  //声明一个二维整型数组,并在实例化后初始化

    #endregion

    #region [Start]
    private void Start()
    {
        //switch (c)
        //{
        //    case  color.white:
        //        Debug.LogError("白色");
        //        break;
        //    case color.black:
        //        Debug.LogError("黑色");
        //        break;
        //    default:
        //        Debug.LogError("彩色");
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