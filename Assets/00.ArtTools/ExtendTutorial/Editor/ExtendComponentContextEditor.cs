using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ExtendComponentContextEditor
{
    //#region 【随机旋转】
    //[MenuItem("CONTEXT/Transform/随机旋转")]
    //public static void RandomRotation(MenuCommand cmd)
    //{
    //    Transform trans = (Transform)cmd.context;
    //    trans.rotation = Random.rotation;
    //}

    //[MenuItem("CONTEXT/Transform/随机旋转", true)]
    //public static bool OnRandomRotationValidate(MenuCommand cmd)
    //{
    //    Transform trans = (Transform)cmd.context;
    //    return trans.localEulerAngles == Vector3.zero;
    //}
    //#endregion

    //#region 【其他类的拓展】
    //[MenuItem("CONTEXT/BoxCollider/拓展测试")]
    //public static void OtherClass(MenuCommand cmd)
    //{
    //    Debug.LogError("111");
    //}
    //#endregion

    //#region 【自定义类的拓展】
    //[MenuItem("CONTEXT/CustomClassContext/拓展测试")]
    //public static void CustomClassExtend(MenuCommand cmd)
    //{
    //    CustomClassContext customClass = (CustomClassContext)cmd.context;
    //}
    //#endregion
}
