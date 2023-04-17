using UnityEngine;

[ExecuteAlways]
[ExecuteInEditMode]

public class PPBrokenScreen : MonoBehaviour
{
    //后处理材质接口
    public Material BrokenScreenMat;

    #region 破碎参数

    public Color BrokenColor = new(1.0f , 1.0f, 1.0f, 1.0f);

    public Vector4 BrokenScreenUV = new(1, 1, 0, 0);

    public Texture2D BrokenScreen_Mask;

    public Texture2D BrokenScreen_Normal;

    [Range(0.0f , 1.0f)]
    public float BrokenScreenIntensity = 1.0f;

    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        BrokenScreenMat.SetColor("_BrokenColor", BrokenColor);
        BrokenScreenMat.SetVector("_BrokenScreenUV", BrokenScreenUV);
        BrokenScreenMat.SetTexture("_BrokenScreen_Mask", BrokenScreen_Mask);
        BrokenScreenMat.SetTexture("_BrokenScreen_Normal", BrokenScreen_Normal);

        BrokenScreenMat.SetFloat("_BrokenScreenIntensity", BrokenScreenIntensity);

        Graphics.Blit(source , destination , BrokenScreenMat);
    }
}
