using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

[ExecuteInEditMode]
public class IE_DualAverageBlur : MonoBehaviour
{
    #region ģ������

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

        // ����Դͼ����,������һ��������ֵ�������Ż�
        int width = source.width / DownSample;
        int height = source.height / DownSample;
        //���� RenderTexture
        RenderTexture RT1 = RenderTexture.GetTemporary(width, height);
        RenderTexture RT2 = RenderTexture.GetTemporary(width, height);
        // ��Դͼ�񸲸�RT1
        Graphics.Blit(source, RT1, BlurMat, 0);

        // �������� = ��Сͼ������forѭ�����ϵ�������
        for (int i = 0; i < BlurIteration; i++)
        {
            // ��Ϊ������������RT2������Ҫ���ͷ��ڴ�
            RenderTexture.ReleaseTemporary(RT2);
            width /= 2;
            height /= 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, BlurMat, 0);

            // ��Ϊ������������RT1������Ҫ���ͷ��ڴ�
            RenderTexture.ReleaseTemporary(RT1);
            width /= 2;
            height /= 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, BlurMat, 0);
        }

        // �������� = �Ŵ�ͼ������forѭ�����ϵ�������
        for (int i = 0; i < BlurIteration; i++)
        {
            // ��Ϊ������������RT2������Ҫ���ͷ��ڴ�
            RenderTexture.ReleaseTemporary(RT2);
            width *= 2;
            height *= 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, BlurMat, 0);

            // ��Ϊ������������RT1������Ҫ���ͷ��ڴ�
            RenderTexture.ReleaseTemporary(RT1);
            width /= 2;
            height /= 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, BlurMat, 0);
        }

        // ��������Ľ�������Ŀ��ͼ��
        Graphics.Blit(RT1, destination , BlurMat, 0);

        // �ͷ��ڴ棬��������ڴ�й©
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}
