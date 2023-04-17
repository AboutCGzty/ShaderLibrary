using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class IE_Bloom : MonoBehaviour
{
    #region 泛光参数

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Material")]
    public Material BloomMat;
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]

    [Header("Bloom")]
    [Range(0.0f, 10.0f)]
    public float BloomIntensity = 0.0f;

    [Range(0.0f, 10.0f)]
    public float BloomThreshold = 0.0f;

    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // 定义原图像宽高
        int width = source.width;
        int height = source.height;
        // 申请降采样RT 与 升采样RT
        RenderTexture RT1_down = RenderTexture.GetTemporary(width / 2, height / 2, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT2_down = RenderTexture.GetTemporary(width / 4, height / 4, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT3_down = RenderTexture.GetTemporary(width / 8, height / 8, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT4_down = RenderTexture.GetTemporary(width / 16, height / 16, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT5_up = RenderTexture.GetTemporary(width / 32, height / 32, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT4_up = RenderTexture.GetTemporary(width / 16, height / 16, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT3_up = RenderTexture.GetTemporary(width / 8, height / 8, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT2_up = RenderTexture.GetTemporary(width / 4, height / 4, 0, RenderTextureFormat.DefaultHDR);
        RenderTexture RT1_up = RenderTexture.GetTemporary(width / 2, height / 2, 0, RenderTextureFormat.DefaultHDR);
        // 定义一个RT数组，方便后面遍历
        RenderTexture[] RT_List = new RenderTexture[] { RT1_down, RT2_down, RT3_down, RT4_down, RT5_up, RT4_up, RT3_up, RT2_up, RT1_up };

        // 定义参数
        float Intensity = Mathf.Exp(BloomIntensity / 10.0f * 0.693f) - 1.0f;
        BloomMat.SetFloat("_BloomIntensity", Intensity);
        BloomMat.SetFloat("_BloomThreshold", BloomThreshold);

        // 亮度阈值
        Graphics.Blit(source, RT1_down, BloomMat, 0);

        // 降采样
        Graphics.Blit(RT1_down, RT2_down, BloomMat, 1);
        Graphics.Blit(RT2_down, RT3_down, BloomMat, 1);
        Graphics.Blit(RT3_down, RT4_down, BloomMat, 1);

        // 升采样
        BloomMat.SetTexture("_BloomTex", RT4_down);
        Graphics.Blit(RT5_up, RT4_up, BloomMat, 2);
        BloomMat.SetTexture("_BloomTex", RT3_down);
        Graphics.Blit(RT4_up, RT3_up, BloomMat, 2);
        BloomMat.SetTexture("_BloomTex", RT2_down);
        Graphics.Blit(RT3_up, RT2_up, BloomMat, 2);
        BloomMat.SetTexture("_BloomTex", RT1_down);
        Graphics.Blit(RT2_up, RT1_up, BloomMat, 2);

        // 合并
        BloomMat.SetTexture("_BloomTex", RT1_up);
        Graphics.Blit(source, destination, BloomMat, 3);

        // 释放内存【RT】
        for (int i = 0; i < RT_List.Length; i++)
        {
            RenderTexture.ReleaseTemporary(RT_List[i]);
        }
    }
}
