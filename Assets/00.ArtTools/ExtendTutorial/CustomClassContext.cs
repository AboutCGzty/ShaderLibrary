using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomClassContext : MonoBehaviour
{
    [ContextMenuItem("变量上的测试脚本", "ContextFunction")]
    public string Name;

    [ContextMenu("测试脚本")]
    void ContextFunction()
    {
        Debug.LogError(name);
    }
}
