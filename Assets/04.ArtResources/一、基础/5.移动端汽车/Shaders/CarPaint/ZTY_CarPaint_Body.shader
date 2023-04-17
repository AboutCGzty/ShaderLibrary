Shader "ZTY/CarPaint/Body"
{
    Properties
    {
        [Header(Color ________________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _BaseColor("Base Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_Albedo("Albedo", 2D) = "white"{}

        [Header(Normal _______________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [Normal][NoScaleOffset]_Normal("Normal", 2D) = "bump"{}
        _NormalIntensity("Normal Intensity", Range(0.0, 1.0)) = 1.0

        [Header(Reflection ___________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [NoScaleOffset]_Mask("Mask", 2D) = "white"{}
        _HighLightIntensity("HighLight Intensity", Range(1.0, 10.0)) = 1.0
        _HighLightRange("HighLightRange", Range(1.0, 100.0)) = 3.0
        _DSpecularIntensity("DirectSpecular Intensity", Range(0.01, 1.0)) = 1.0
        _IndDiffIntensity("IndirectDiffuse Intensity", Range(0.0, 1.0)) = 0.1
        [Header((SH))]
        [Space(5)]
        custom_SHAr("Custom SHAr", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHAg("Custom SHAg", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHAb("Custom SHAb", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHBr("Custom SHBr", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHBg("Custom SHBg", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHBb("Custom SHBb", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHC("Custom SHC", Vector) = (0.0, 0.0, 0.0, 1.0)

        [Header(Varnish ___________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [NoScaleOffset]_Varnish("Varnish", Cube) = "gray"{}
        _VarnishIntensity("Varnish Intensity", Range(0.01, 1.0)) = 0.5
        _VarnishLevel("Varnish Level", Range(0.01, 6.0)) = 0.5
        _VarnishRange("Varnish Range", Range(1.0, 10.0)) = 3.0

        [Header(Emission _____________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [HDR]_EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 0.0)
        [NoScaleOffset]_Emission("Emission", 2D) = "black"{}
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
            Name "FORWARDBASE"

            Tags { "LightMode" = "ForwardBase" }

            Cull Back ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase
            #pragma skip_variants DIRLIGHTMAP_COMBINED LIGHTMAP_ON LIGHTPROBE_SH VERTEXLIGHT_ON SHADOWS_SHADOWMASK LIGHTMAP_SHADOW_MIXING DYNAMICLIGHTMAP_ON
            #include "../Include/CarCginc.cginc"
            #pragma target 3.0

            samplerCUBE _Varnish;
            sampler2D _Albedo, _Normal, _Mask, _Emission;
            float _NormalIntensity, _HighLightIntensity, _HighLightRange, _DSpecularIntensity, _IndDiffIntensity,
                  _VarnishLevel, _VarnishIntensity, _VarnishRange;
            float3 _BaseColor, _EmissionColor;
            float4 custom_SHAr, custom_SHAg, custom_SHAb, custom_SHBr, custom_SHBg, custom_SHBb, custom_SHC;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv_mesh : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv_mesh : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 nDirWS : TEXCOORD2;
                float3 tDirWS : TEXCOORD3;
                float3 bDirWS : TEXCOORD4;
                UNITY_SHADOW_COORDS(6)
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv_mesh = v.uv_mesh;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);
                TRANSFER_SHADOW(o)
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
// 纹理采样 =====================================================================================================================================//
                float3 normalmap = UnpackNormalWithScale(tex2D(_Normal, i.uv_mesh), _NormalIntensity);
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 nDirWS2 = normalize(mul(normalmap, TBN));

                float3 maskmap = tex2D(_Mask, i.uv_mesh);
                float metallicmap = maskmap.r;
                float roughnessmap = maskmap.g;
                float aomap = maskmap.b;

                float3 albedomap = tex2D(_Albedo, i.uv_mesh);
                float3 basecolor = albedomap * _BaseColor * (1.0 - metallicmap);
                float3 specularcolor = lerp(0.04, basecolor, metallicmap);
// 直接光漫反射 =================================================================================================================================//
                float3 lDirWS = normalize(_WorldSpaceLightPos0.xyz);
                float NL = saturate(dot(nDirWS2, lDirWS));

                UNITY_LIGHT_ATTENUATION(shadowattenuation, i, i.posWS)
                float3 Direct_diffuse = basecolor * NL * _LightColor0.rgb * shadowattenuation;
// 直接光镜面反射 ===============================================================================================================================//
                float smoothness = 1.0 - roughnessmap;
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 hDirWS = normalize(lDirWS + vDirWS);
                float NH = saturate(pow(dot(nDirWS2, hDirWS), _HighLightRange * 10.0)) * smoothness;
                float3 HighLight = specularcolor * NH * _LightColor0.rgb * NL * _HighLightIntensity;

                float3 vDirVS = normalize(reflect(-vDirWS, nDirWS2));
                float3 Direct_specular = texCUBElod(_Varnish, float4(vDirVS, lerp(0.1, 6.0, smoothness)));
                Direct_specular *= NL * basecolor * _DSpecularIntensity;
                Direct_specular += HighLight;
// 间接光漫反射 =================================================================================================================================//
                float3 Indirect_diffuse = SHCOLOR(nDirWS2, custom_SHAr, custom_SHAg, custom_SHAb,
                                                  custom_SHBr, custom_SHBg, custom_SHBb,
                                                  custom_SHC,_IndDiffIntensity);
                Indirect_diffuse *= basecolor * (1.0 - metallicmap);
// 间接光镜面反射 ===============================================================================================================================//
                float NV = saturate(dot(nDirWS2, vDirWS));
                float fresnelfactor = saturate(pow(1.0 - NV, _VarnishRange)) * smoothness;
                float3 Indirect_specular = texCUBElod(_Varnish, float4(vDirVS, _VarnishLevel));
                Indirect_specular *= _VarnishIntensity * fresnelfactor;
// 自发光 =======================================================================================================================================//
                float3 emissmap = tex2D(_Emission, i.uv_mesh) * _EmissionColor;
// 最终结果 =====================================================================================================================================//
                float3 DirectLighting = Direct_diffuse + Direct_specular;
                float3 IndirectLighting = (Indirect_diffuse + Indirect_specular) * aomap;
                
                float3 finalcolor = DirectLighting + IndirectLighting + emissmap;
                finalcolor = ACES_Tonemapping(finalcolor);

                return float4(finalcolor, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "SHADOWCASTER"
			Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct VertexOutput
            {
                V2F_SHADOW_CASTER;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag (VertexOutput i) : SV_TARGET
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
