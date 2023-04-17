using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.YamlDotNet.Core.Tokens;
using UnityEngine;

public class Print<T>
{
    public T Value;

    public void Log()
    {
        Debug.LogError(Value);
    }
}