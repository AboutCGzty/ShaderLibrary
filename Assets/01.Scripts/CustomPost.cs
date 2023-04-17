using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CustomPost : MonoBehaviour
{
    public Material PostMat;

    //public Color FogColor = new Color(1.0f, 1.0f, 1.0f, 0.0f);

    //[Range(0.0f, 100.0f)]
    //public float FogDistance = 20.0f;

    //[Range(1.0f, 10.0f)]
    //public float FogSpread = 3.0f;

    //[Range(0.0f, 1.0f)]
    //public float FogIntensity = 0.8f;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //PostMat.SetColor("_FogColor", FogColor);
        //PostMat.SetFloat("_FogDistance", FogDistance);
        //PostMat.SetFloat("_FogSpread", FogSpread);
        //PostMat.SetFloat("_FogIntensity", FogIntensity);
        Graphics.Blit(source, destination, PostMat, 0);
    }
}
