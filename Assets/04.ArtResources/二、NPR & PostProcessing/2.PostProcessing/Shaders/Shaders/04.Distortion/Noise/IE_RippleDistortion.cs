using UnityEngine;
using UnityEngine.Rendering;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class IE_RippleDistortion : MonoBehaviour
{
    private LocalKeyword Oneway;

    #region ²¨ÎÆ²ÎÊý

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Material")]
    public Material DistortionMat;

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Direction")]
    public bool OnewayOn;
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]

    [Header("Ripple")]
    [Range(1.0f, 20.0f)]
    public float RippleTilling = 5.0f;
    public float RippleSpeed = 2.0f;
    [Range(0.0f, 1.0f)]
    public float RippleIntensity = 0.1f;
    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (OnewayOn)
        {
            localkeyword();
            EnableKeyWord();
        }
        else
        {
            localkeyword();
            DisableKeyWord();
        }

        DistortionMat.SetFloat("_RippleIntensity", RippleIntensity);
        DistortionMat.SetFloat("_RippleTilling", RippleTilling);
        DistortionMat.SetFloat("_RippleSpeed", RippleSpeed);

        Graphics.Blit(source , destination , DistortionMat);
    }
    void localkeyword()
    {
        var shader = DistortionMat.shader;
        Oneway = new LocalKeyword(shader, "_ONEWAY_ON");
    }

    public void EnableKeyWord()
    {
        DistortionMat.EnableKeyword(Oneway);
    }
    public void DisableKeyWord()
    {
        DistortionMat.DisableKeyword(Oneway);
    }
}
