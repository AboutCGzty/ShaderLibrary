using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomClassContext : MonoBehaviour
{
    [ContextMenuItem("�����ϵĲ��Խű�", "ContextFunction")]
    public string Name;

    [ContextMenu("���Խű�")]
    void ContextFunction()
    {
        Debug.LogError(name);
    }
}
