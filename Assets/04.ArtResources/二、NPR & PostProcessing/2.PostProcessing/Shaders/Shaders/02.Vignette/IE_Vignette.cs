using System;
using UnityEngine;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class IE_Vignette : MonoBehaviour
{
    //后处理材质接口
    public Material VignetteMat;

    #region 晕影参数
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Vignette")]
    public Color VignetteColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);

    [Range(0.0f, 1.0f)]
    public float VignetteIntensity = 0.8f;

    public float VignetteWidth = 2.0f;

    public float VignetteHigh = 2.0f;

    [Range(1.0f, 100.0f)]
    public float VignetteSpread = 20.0f;

    [Range(0.1f, 10.0f)]
    public float VignetteContrast = 0.1f;
    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        VignetteMat.SetColor("_VignetteColor", VignetteColor);
        VignetteMat.SetFloat("_VignetteIntensity", VignetteIntensity);
        VignetteMat.SetFloat("_VignetteWidth", VignetteWidth);
        VignetteMat.SetFloat("_VignetteHigh", VignetteHigh);
        VignetteMat.SetFloat("_VignetteSpread", VignetteSpread);
        VignetteMat.SetFloat("_VignetteContrast", VignetteContrast);

        Graphics.Blit(source , destination , VignetteMat, 0);
    }
}
