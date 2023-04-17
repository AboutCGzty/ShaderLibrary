using System;
using UnityEngine;

// ?????????งน??
[ExecuteInEditMode]
// ??Scene????????งน??
[ImageEffectAllowedInSceneView]

public class IE_ColorAdiustment : MonoBehaviour
{
    // ??????????????
    public enum ToneMappingType
    {
        None,
        ACES,
    }

    #region งต?????

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Material")]
    public Material ColorAdjustmentMat;

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("ToneMapping")]
    public ToneMappingType Mode = ToneMappingType.None;
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]

    [Header("Tone")]
    [Range(0.0f, 3.0f)]
    public float Exposure = 1.0f;
    [Range(-1.0f, 1.0f)]
    public float Hue = 0.0f;
    [Range(-1.0f, 1.0f)]
    public float Saturation = 0.0f;
    [Range(0.0f, 3.0f)]
    public float Brightness = 1.0f;
    [Range(0.0f, 2.0f)]
    public float Contrast = 1.0f;
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]

    [Header("Channel Mixer")]
    [Range(0.0f, 10.0f)]
    public float _RedMixer = 1.0f;
    [Range(0.0f, 10.0f)]
    public float _GreenMixer = 1.0f;
    [Range(0.0f, 10.0f)]
    public float _BlueMixer = 1.0f;

    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mode == ToneMappingType.None)
        {
            ColorAdjustmentMat.DisableKeyword("_ACES");
        }

        if (Mode == ToneMappingType.ACES)
        {
            ColorAdjustmentMat.EnableKeyword("_ACES");
        }
        // ????????
        ColorAdjustmentMat.SetFloat("_Exposure", Exposure);
        ColorAdjustmentMat.SetFloat("_Hue", Hue);
        ColorAdjustmentMat.SetFloat("_Saturation", Saturation);
        ColorAdjustmentMat.SetFloat("_Brightness", Brightness);
        ColorAdjustmentMat.SetFloat("_Contrast", Contrast);
        // ????????
        ColorAdjustmentMat.SetFloat("_RedMixer", _RedMixer);
        ColorAdjustmentMat.SetFloat("_GreenMixer", _GreenMixer);
        ColorAdjustmentMat.SetFloat("_BlueMixer", _BlueMixer);

        Graphics.Blit(source , destination , ColorAdjustmentMat);
    }
}
