using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

[ExecuteInEditMode]
public class IE_DualAverageBlur : MonoBehaviour
{
    #region 模糊参数

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Material")]
    public Material BlurMat;
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]

    [Header("Blur")]
    [Range(0.0f, 10.0f)]
    public float BlurRadius = 0.0f;

    [Range(1, 10)]
    public int BlurIteration = 2;

    [Range(1, 8)]
    public int DownSample = 2;

    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        BlurMat.SetFloat("_BlurRadius", BlurRadius);

        // 设置源图像宽高,并除以一个降采样值，用于优化
        int width = source.width / DownSample;
        int height = source.height / DownSample;
        //申请 RenderTexture
        RenderTexture RT1 = RenderTexture.GetTemporary(width, height);
        RenderTexture RT2 = RenderTexture.GetTemporary(width, height);
        // 将源图像覆盖RT1
        Graphics.Blit(source, RT1, BlurMat, 0);

        // 【降采样 = 缩小图像】利用for循环不断迭代次数
        for (int i = 0; i < BlurIteration; i++)
        {
            // 因为即将重新申请RT2，所以要先释放内存
            RenderTexture.ReleaseTemporary(RT2);
            width /= 2;
            height /= 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, BlurMat, 0);

            // 因为即将重新申请RT1，所以要先释放内存
            RenderTexture.ReleaseTemporary(RT1);
            width /= 2;
            height /= 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, BlurMat, 0);
        }

        // 【升采样 = 放大图像】利用for循环不断迭代次数
        for (int i = 0; i < BlurIteration; i++)
        {
            // 因为即将重新申请RT2，所以要先释放内存
            RenderTexture.ReleaseTemporary(RT2);
            width *= 2;
            height *= 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, BlurMat, 0);

            // 因为即将重新申请RT1，所以要先释放内存
            RenderTexture.ReleaseTemporary(RT1);
            width /= 2;
            height /= 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, BlurMat, 0);
        }

        // 将迭代后的结果输出到目标图像
        Graphics.Blit(RT1, destination , BlurMat, 0);

        // 释放内存，避免造成内存泄漏
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}
