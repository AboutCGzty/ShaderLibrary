using UnityEngine;

[ExecuteAlways]
[ExecuteInEditMode]

public class PPGlitch : MonoBehaviour
{
    //后处理材质接口
    public Material GlitchMat;

    #region 故障参数

    public bool GlitchOn;

    [Range(0.0f, 0.1f)]
    public float GlitchIntensity = 0.01f;

    public float GlitchSeedSpeed = 10f;

    [Range(1, 10)]
    public int GlitchPI = 2;

    [Range(1, 100)]
    public int GlitchSeedTilling1 = 8;

    [Range(1, 100)]
    public int GlitchSeedTilling2 = 5;

    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (GlitchOn)
        {
            GlitchMat.SetFloat("_GlitchOn", 1);
        }
        else
        {
            GlitchMat.SetFloat("_GlitchOn", 0);
        }

        GlitchMat.SetFloat("_GlitchIntensity", GlitchIntensity);
        GlitchMat.SetFloat("_GlitchSeedSpeed", GlitchSeedSpeed);
        GlitchMat.SetInt("_GlitchPI", GlitchPI);
        GlitchMat.SetInt("_GlitchSeedTilling1", GlitchSeedTilling1);
        GlitchMat.SetInt("_GlitchSeedTilling2", GlitchSeedTilling2);

        Graphics.Blit(source , destination , GlitchMat);
    }
}
