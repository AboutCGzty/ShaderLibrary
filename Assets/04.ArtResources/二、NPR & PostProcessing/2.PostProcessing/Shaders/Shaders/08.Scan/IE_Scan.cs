using System;
using UnityEngine;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class IE_Scan : MonoBehaviour
{
    //后处理材质接口
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Material")]
    public Material ScanMat;

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Scan")]
    public Color ScanColor = new Color(1.0f, 1.0f, 1.0f, 0.0f);

    [Range(0.0f, 100.0f)]
    public float ScanDistance = 20.0f;

    [Range(0.0f, 1.0f)]
    public float ScanIntensity = 1.0f;

    [Range(1.0f, 10.0f)]
    public float ScanSpread = 3.0f;

    [Range(0.0f, 1.0f)]
    public float Return = 0.0f;



    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        ScanMat.SetColor("_ScanColor", ScanColor);
        ScanMat.SetFloat("_ScanDistance", ScanDistance);
        ScanMat.SetFloat("_ScanIntensity", ScanIntensity);
        ScanMat.SetFloat("_ScanSpread", ScanSpread);
        ScanMat.SetFloat("_Return", Return);
        Graphics.Blit(source , destination , ScanMat, 0);
    }
}
