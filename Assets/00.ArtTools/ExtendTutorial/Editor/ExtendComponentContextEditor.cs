using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ExtendComponentContextEditor
{
    //#region �������ת��
    //[MenuItem("CONTEXT/Transform/�����ת")]
    //public static void RandomRotation(MenuCommand cmd)
    //{
    //    Transform trans = (Transform)cmd.context;
    //    trans.rotation = Random.rotation;
    //}

    //[MenuItem("CONTEXT/Transform/�����ת", true)]
    //public static bool OnRandomRotationValidate(MenuCommand cmd)
    //{
    //    Transform trans = (Transform)cmd.context;
    //    return trans.localEulerAngles == Vector3.zero;
    //}
    //#endregion

    //#region �����������չ��
    //[MenuItem("CONTEXT/BoxCollider/��չ����")]
    //public static void OtherClass(MenuCommand cmd)
    //{
    //    Debug.LogError("111");
    //}
    //#endregion

    //#region ���Զ��������չ��
    //[MenuItem("CONTEXT/CustomClassContext/��չ����")]
    //public static void CustomClassExtend(MenuCommand cmd)
    //{
    //    CustomClassContext customClass = (CustomClassContext)cmd.context;
    //}
    //#endregion
}
