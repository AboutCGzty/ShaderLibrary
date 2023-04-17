using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

[ExecuteInEditMode]
public class IE_GuassianBlur : MonoBehaviour
{
    #region ģ������

    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Header("Material")]
    public Material BlurMat;
    [Header("--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")]
    [Range(1.0f, 4.0f)]
    public float BlurRadius = 2.0f;

    [Range(1, 10)]
    public int BlurIteration = 2;

    [Range(1, 8)]
    public int DownSample = 2;

    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        BlurMat.SetFloat("_BlurRadius", BlurRadius);

        // ����Դͼ����,������һ��������ֵ�������Ż�
        int width = source.width / DownSample;
        int height = source.height / DownSample;
        //���� RenderTexture
        RenderTexture RT1 = RenderTexture.GetTemporary(width, height);
        RenderTexture RT2 = RenderTexture.GetTemporary(width, height);
        // ��Դͼ�񸲸�RT1
        Graphics.Blit(source, RT1, BlurMat, 0);
        // ����forѭ�����ϵ�������
        for (int i = 0; i < BlurIteration; i++)
        {
            Graphics.Blit(RT1, RT2, BlurMat, 0);
            Graphics.Blit(RT2, RT1, BlurMat, 1);
        }
        // ��������Ľ�������Ŀ��ͼ��
        Graphics.Blit(RT1, destination , BlurMat, 0);

        // �ͷ��ڴ棬��������ڴ�й©
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}
