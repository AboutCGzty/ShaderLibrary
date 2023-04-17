using System;
using System.Runtime.Serialization;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
[ExecuteInEditMode]

public class PPTransitions : MonoBehaviour
{
    //������ʽӿ�
    public Material TransitionsMat;

    #region ת������

    public enum TransitionsType 
    {
        Scan,
        Louver,
        Polar,
        Grid,
    }
    public TransitionsType TransitionsTypeControl = TransitionsType.Scan;
    [Range(0.0f, 1.0f)]
    public float TransitionsAmount = 0.0f;
    [Range(0.5f, 3.0f)]
    public float LuminanceIntensity = 1f;
    public bool ScanEdgeOn;
    [Range(0.0f, 1.0f)]
    public float ScanEdgeWidth = 0.1f;
    [Range(0.0f, 0.1f)]
    public float ScanNoiseIntensity = 0.0f;
    public float ScanNoiseTilling = 5.0f;
    [Range(0, 10)]
    public int LouverNumber = 2;
    [Range(1, 100)]
    public int GridTilling = 10;

    #endregion

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        #region ����ɨ���߿�

        if (ScanEdgeOn)
        {
            TransitionsMat.SetFloat("_ScanEdgeOn", 1);
        }
        else
        {
            TransitionsMat.SetFloat("_ScanEdgeOn", 0);
        }

        #endregion

        TransitionsMat.SetFloat("_TransitionsAmount", TransitionsAmount);
        TransitionsMat.SetFloat("_LuminanceIntensity", LuminanceIntensity);

        TransitionsMat.SetFloat("_ScanEdgeWidth", ScanEdgeWidth);
        TransitionsMat.SetFloat("_ScanNoiseIntensity", ScanNoiseIntensity);
        TransitionsMat.SetFloat("_ScanNoiseTilling", ScanNoiseTilling);
        TransitionsMat.SetInt("_LouverNumber", LouverNumber);
        TransitionsMat.SetInt("_GridTilling", GridTilling);

        #region �˵�����

        //����ɨ�����
        if (TransitionsTypeControl==TransitionsType.Scan)
        {
            TransitionsMat.EnableKeyword("_TRANSITIONSTYPE_SCAN");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_GRID");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_LOUVER");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_POLAR");
        }
        //������Ҷ������
        if (TransitionsTypeControl==TransitionsType.Louver)
        {
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_SCAN");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_GRID");
            TransitionsMat.EnableKeyword("_TRANSITIONSTYPE_LOUVER");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_POLAR");
        }
        //����������ת��
        if (TransitionsTypeControl==TransitionsType.Polar)
        {
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_SCAN");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_GRID");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_LOUVER");
            TransitionsMat.EnableKeyword("_TRANSITIONSTYPE_POLAR");
        }
        //��������ת��
        if (TransitionsTypeControl==TransitionsType.Grid)
        {
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_SCAN");
            TransitionsMat.EnableKeyword("_TRANSITIONSTYPE_GRID");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_LOUVER");
            TransitionsMat.DisableKeyword("_TRANSITIONSTYPE_POLAR");
        }

        #endregion

        Graphics.Blit(source , destination , TransitionsMat);
    }
}
