Shader "ZTY/Strive/Cloth"
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

        [Header(CommonStepSpecular ______________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _CommonStepSpecularWidth("Common StepSpecular Width", Range(0.0, 1.0)) = 0.5
        _CommonStepSpecularIntensity("Common StepSpecular Intensity", Range(0.0, 1.0)) = 0.5

        [Header(LeatherStepSpecular _____________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _LeatherStepSpecularWidth("Leather StepSpecular Width", Range(0.0, 1.0)) = 0.5
        _LeatherStepSpecularIntensity("Leather StepSpecular Intensity", Range(0.0, 1.0)) = 0.5

        [Header(MetallicStepSpecular ____________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _MetallicStepSpecularWidth("Metallic StepSpecular Width", Range(0.0, 1.0)) = 0.5
        _MetallicStepSpecularIntensity("Metallic StepSpecular Intensity", Range(0.0, 1.0)) = 0.5

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

            sampler2D _Base, _Shadow, _Light, _Line;
            float _LightThreshold, _ShadowAOOffset, _LineIntensity, _RimWidth, _RimIntensity, _MetallicStepSpecularWidth, _MetallicStepSpecularIntensity,
                  _CommonStepSpecularWidth, _CommonStepSpecularIntensity, _LeatherStepSpecularWidth, _LeatherStepSpecularIntensity;

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

                // Vector Ready ===============================================================================//
                float3 N = normalize(i.nDirWS);                                 // ���߷���
                float3 L = normalize(_WorldSpaceLightPos0.xyz);                 // �ƹⷽ��
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);   // �ӽǷ���
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

                // Specular
                float layerMask = specularType * 255.0;
                float specularIntensity = specularIntensityMask * 255.0;
                float3 specularColor = 0.0;

                //�ñ߸߹⡾StepSpecular��
                if (layerMask > 0 && layerMask <= 60) /* ��ͨ���� �޸߹�*/
                { 
                    float NV = max(0.0, dot(N, V));
                    float specularIntensityFactor = float(specularIntensity > 0 && specularIntensity < 180);
                    float leatherStepSpecularMask = saturate(step(1.0 - _CommonStepSpecularWidth, NV) * _CommonStepSpecularIntensity * specularIntensityFactor);
                    float3 leatherStepSpecularColor = max(0.0, leatherStepSpecularMask * basemap); // ���ϰ�ȫ��
                    specularColor = lerp(specularColor, leatherStepSpecularColor, specularIntensityFactor);
                    specularColor += stepRimColor;
                }

                if (layerMask > 60 && layerMask < 190) /* Ƥ����� */
                { 
                    float NV = max(0.0, dot(N, V));
                    float specularIntensityFactor = float(specularIntensity > 180);
                    float leatherStepSpecularMask = saturate(step(1.0 - _LeatherStepSpecularWidth, NV) * _LeatherStepSpecularIntensity * specularIntensityFactor);
                    float3 leatherStepSpecularColor = max(0.0, leatherStepSpecularMask * basemap); // ���ϰ�ȫ��
                    leatherStepSpecularColor += specularColor;
                    specularColor = lerp(specularColor, leatherStepSpecularColor, specularIntensityFactor);
                    specularColor += stepRimColor;
                }

                if (layerMask >= 190) /* �������� �вñ߸߹⣨ViewSpace�� */
                { 
                    float metalStepViewSpecularMask = saturate(step(abs(tangentVS.x), _MetallicStepSpecularWidth) * _MetallicStepSpecularIntensity * specularIntensityMask);
                    float3 metalStepViewSpecularColor = max(0.0, metalStepViewSpecularMask * basemap); // ���ϰ�ȫ��
                    specularColor += metalStepViewSpecularColor;
                }

                // Final Output ===============================================================================//
                float3 finalRGB = stepdiffuse + specularColor;
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