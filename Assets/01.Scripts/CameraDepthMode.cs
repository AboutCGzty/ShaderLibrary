using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// [ExecuteInEditMode]
public class CameraDepthMode : MonoBehaviour
{
    void Start()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
        Camera.main.depthTextureMode |= DepthTextureMode.DepthNormals;
    }
}
