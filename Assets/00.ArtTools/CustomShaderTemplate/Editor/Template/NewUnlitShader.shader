Shader "Unlit/NewUnlitShader"                                   // Shader·��������
{
    Properties                                                  // ��¶��Inspector���Ĳ���
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader                                                   // ��һ��������ɫ���������ж��
    {
        Tags { "RenderType"="Opaque" }                          // �����ǩ

        Pass                                                    // ��һ��Pass�������ж��
        {
            CGPROGRAM                                           // ��ʼCG����
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexInput                                  // ��������ṹ��
            {
                float4 vertex    : POSITION;                    // ��ȡģ�Ϳռ䶥��������Ϣ
                float2 uv        : TEXCOORD0;                   // ��ȡģ��uv������Ϣ
            };

            struct VertexOutput                                 // ��������ṹ��
            {
                float2 uv        : TEXCOORD0;                   // ���ģ��uv������Ϣ
                float4 vertex    : SV_POSITION;                 // ���ģ�Ϳռ䶥��������Ϣ
            };

            sampler2D _MainTex;                                 // ����������
            float4 _MainTex_ST;                                 // ���������������Ϣ

            VertexOutput vert (VertexInput v)                   // ����Shader
            {
                VertexOutput o;                                 // ����һ������Shader��o��
                o.vertex = UnityObjectToClipPos(v.vertex);      // ��ģ�Ͷ�������ת�ӱ��ؿռ任����βü��ռ�
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);           // ��ģ��uv���������������ӳ��
                return o;                                       // ���ء�o��
            }

            half4 frag (VertexOutput i) : SV_Target             // ƬԪShader
            {
                half4 finalcolor = tex2D(_MainTex, i.uv);       // ����һ��������
                return finalcolor;                              // ����������ɫ
            }
            ENDCG                                               // ����CG����
        }
    }
}
