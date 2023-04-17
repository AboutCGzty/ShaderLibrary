Shader "ZTY/Strive/Head"
{
    Properties
    {
        [Header(Texture Sampler _________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [NoScaleOffset]_Base("Base", 2D) = "white" {}
        _LightThreshold("Light Threshold", Range(-2.0, 2.0)) = 0.0
        [NoScaleOffset]_Shadow("Shadow", 2D) = "white" {}
        _ShadowAOOffset("Shadow AO Offset", Range(0.01, 0.99)) = 0.5
        [NoScaleOffset]_Light("Light", 2D) = "black" {}
        [NoScaleOffset]_Line("Line", 2D) = "black" {}
        _LineIntensity("Line Intensity", Range(0.0, 1.0)) = 1.0

        [Header(Specular ________________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _SpecularPower("Specular Power", Range(1.0, 10.0)) = 1.0
        _SpecularIntensity("Specular Intensity", Range(0.0, 1.0)) = 1.0

        [Header(StepRim _________________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _RimWidth("Rim Width", Range(0.0, 1.0)) = 0.5
        _RimIntensity("Rim Intensity", Range(0.0, 1.0)) = 0.5

        [Header(Outline _________________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _OutlineColor("Outline Color", Color) = (1.0, 1.0, 1.0, 0.0)
        _OutlineWidth("Outline Width", Range(0.1, 1.0)) = 0.1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv_mesh : TEXCOORD0;
                float3 normal : NORMAL;
                float3 Color : COLOR;
                float4 tangent : TANGENT;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv_mesh : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 nDirWS : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 vertexcolor : TEXCOORD4; 
            };

            float3 _FaceShadowColor;
            sampler2D _Base, _Shadow, _Light, _Line;
            float _LightThreshold, _ShadowAOOffset, _FaceShadowIntensity, _LineIntensity, _RimWidth, _RimIntensity, _SpecularPower, _SpecularIntensity;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv_mesh = v.uv_mesh;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.vertexcolor = v.Color;
                o.tangent = UnityObjectToWorldDir(v.tangent);
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                // Texture Sample =============================================================================//
                float3 basemap = tex2D(_Base, i.uv_mesh).rgb;       // ����ɫ
                float3 shadowmap = tex2D(_Shadow, i.uv_mesh).rgb;   // ��ӰȾɫ

                float4 lightmask = tex2D(_Light, i.uv_mesh);        // ����
                float specularType = lightmask.r;                   // �߹�����
                float rampOffset = lightmask.g;                     // rampƫ��ֵ
                float specularIntensityMask = lightmask.b;          // �߹�ǿ������
                float innerLineMask = lightmask.a;                  // �ڹ�������

                float4 linemask = tex2D(_Line, i.uv_mesh);          // ĥ����
                float shadowAOMask = i.vertexcolor.r;               // �̶���Ӱ����
                float faceFactor = i.vertexcolor.g;                 // �沿��ͷ������

                // Vector Ready ===============================================================================//
                float3 N = normalize(i.nDirWS);                                 // ���߷���
                float3 L = normalize(_WorldSpaceLightPos0.xyz);                 // �ƹⷽ��
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);   // �ӽǷ���
                float3 H = normalize(L + V);                                    // ��Ƿ���
                float3 T = normalize(i.tangent);                                // ���߷���

                // NPR Attibute ===============================================================================//
                //�ñ������䡾StepDiffuse��
                float halfNL = dot(N, L) * 0.5 + 0.5;
                float threshold = step(1.0 - _LightThreshold, halfNL) + rampOffset;
                threshold *= (shadowAOMask > _ShadowAOOffset);
                basemap *= innerLineMask;
                basemap = lerp(basemap, basemap * linemask, _LineIntensity);
                float3 diffusecolor_bright = basemap;
                float3 diffusecolor_dark = basemap * shadowmap;
                float3 stepdiffuse = lerp(diffusecolor_dark, diffusecolor_bright, threshold);

                //�ñ߱�Ե�⡾StepRim��
                float3 tangentVS = normalize(mul((float3x3)UNITY_MATRIX_V, T));
                float steprim = step(1.0 - _RimWidth, abs(tangentVS.x)) * _RimIntensity;
                float3 stepRimColor = steprim * basemap;
                stepRimColor = lerp(stepRimColor, 0.0, saturate(threshold)) * saturate(threshold);

                //Blin-Phong�߹�
                float NH = dot(N, H) * 0.5 + 0.5;
                float bpspecularMask = saturate(pow(NH, _SpecularPower) * _SpecularIntensity) * specularIntensityMask;
                float3 specularColor = max(0.0, bpspecularMask * basemap);

                // Final Output ===============================================================================//
                float3 finalRGB = stepdiffuse + specularColor + stepRimColor;
                return float4(finalRGB, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "Outline"

            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
                float3 color : color;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float3 tangent : TEXCOORD0;
                float3 vertexcolor : TEXCOORD1;
            };

            float3 _OutlineColor;
            float _OutlineWidth;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertexcolor = v.color;
                v.vertex.xyz += v.tangent.xyz * _OutlineWidth * 0.01 * o.vertexcolor.b;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                return float4(_OutlineColor, 1.0);
            }
            ENDCG
        }
    }
}