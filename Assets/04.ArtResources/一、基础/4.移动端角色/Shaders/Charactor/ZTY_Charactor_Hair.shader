Shader "ZTY/Charactor/Hair"
{
    Properties
    {
        [Header(DirectLighting ____________________________________________________________________________________________________________________________________________________________________)]
        [Header(DirectDiffuse)]
        [Space(10)]
        _BaseColor("BaseColor", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_Albedo("Albedo", 2D) = "white" {}
        [NoScaleOffset]_NormalTex("Normal", 2D) = "bump" {}
        _NormalIntensity("Normal Intensity", Range(0.0, 1.0)) = 1.0

        [Header(DirectSpecular)]
        [Space(10)]
        [NoScaleOffset]_AnisoNoise("Aniso Noise", 2D) = "white"{}
        _AnisoTilling("Aniso Tilling", float) = 1.0
        [Header(Aniso1)]
        _AnisoSpecularColor1("Aniso Specular Color 1", Color) = (1.0, 1.0, 1.0, 0.0)
        _AnisoSpread1("Aniso Spread 1", Range(0.01, 1.0)) = 0.5
        _AnisoOffset1("Aniso Offset 1", Range(-1, 1)) = 0
        _AnisoIntensity1("Aniso Intensity 1", Range(0.01, 1.0)) = 1.0
        [Header(Aniso2)]
        _AnisoSpecularColor2("Aniso Specular Color 2", Color) = (1.0, 1.0, 1.0, 0.0)
        _AnisoSpread2("Aniso Spread 2", Range(0.01, 1.0)) = 0.5
        _AnisoOffset2("Aniso Offset 2", Range(-1, 1)) = 0
        _AnisoIntensity2("Aniso Intensity 2", Range(0.01, 1.0)) = 1.0

        [Header(IndirectLighting ____________________________________________________________________________________________________________________________________________________________________)]
        [Header(IndirectSpecular)]
        [Space(10)]
        [NoScaleOffset]_ReflectionTex("ReflectionTex", Cube) = "black"{}
        [NoScaleOffset]_Roughness("Roughness", Range(1.0, 4.0)) = 2.0
        [NoScaleOffset]_ReflectionIntensity("Reflection Intensity", Range(0.01, 0.5)) = 0.2
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
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase
            #pragma skip_variants DIRLIGHTMAP_COMBINED LIGHTMAP_ON LIGHTPROBE_SH VERTEXLIGHT_ON SHADOWS_SHADOWMASK LIGHTMAP_SHADOW_MIXING DYNAMICLIGHTMAP_ON
            #include "../Include/ZTYCginc.cginc"
            #pragma target 3.0

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv_mesh : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv_mesh : TEXCOORD0;
                float3 posWS : TEXCOORD1;
                float3 nDirWS : TEXCOORD2;
                float3 tDirWS : TEXCOORD3;
                float3 bDirWS : TEXCOORD4;
                UNITY_SHADOW_COORDS(5)
            };

            half3 _BaseColor, _AnisoSpecularColor1, _AnisoSpecularColor2;
            sampler2D _Albedo, _NormalTex, _AnisoNoise;
            half _NormalIntensity, _Roughness, _AnisoTilling, _AnisoSpread1, _AnisoOffset1, _AnisoIntensity1, _AnisoSpread2, _AnisoOffset2, _AnisoIntensity2, _SpecularRange1, _SpecularRange2, _ReflectionIntensity, _ReflectionRoughness;
            samplerCUBE _ReflectionTex;

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

            half4 frag (VertexOutput i) : SV_Target
            {
                //============================================================== Get Shadow ==================//
                UNITY_LIGHT_ATTENUATION(atten, i, i.posWS);

                //============================================================== Texture Sample ==============//
                half3 albedomap = tex2D(_Albedo, i.uv_mesh);

                //============================================================== Vector Ready ================//
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                half3 normalmap = UnpackNormalWithScale(tex2D(_NormalTex, i.uv_mesh), _NormalIntensity);
                half3 nDirWS2 = normalize(mul(normalmap, TBN));
                half3 lDirWS = normalize(_WorldSpaceLightPos0.xyz);
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 hDirWS = normalize(lDirWS + vDirWS);
                half3 tangent = i.tDirWS;
                half3 bitangent = i.bDirWS;
                half tdoth = dot(tangent, hDirWS);
                half ndoth = dot(nDirWS2, hDirWS);
                half ndotl = max(0.0, dot(nDirWS2, lDirWS));
                half halflambert = dot(nDirWS2, lDirWS) * 0.5 + 0.5;
                half ndotv = max(0.0, dot(nDirWS2, vDirWS));

                //============================================================== DirectLighting Diffuse ======//
                half3 basecolor = albedomap * _BaseColor;
                half3 DirectDiffuse = basecolor * ndotl * atten * _LightColor0.rgb + 0.01;

                //============================================================== DirectLighting Specular =====//
                half aniso_term = saturate(sqrt(max(0.0, halflambert / ndotv))) * atten;
                float2 hairnoiseUV = float2(i.uv_mesh.x * _AnisoTilling, i.uv_mesh.y);
                half hairnoise = tex2D(_AnisoNoise, hairnoiseUV).r;
                
                // KK1
                half3 speccolor1 = _AnisoSpecularColor1 + basecolor;
                float3 anisooffset1 = nDirWS2 * (_AnisoOffset1 + (hairnoise - 0.5) * _AnisoIntensity1);
                float3 bitangent1 = normalize(bitangent + anisooffset1);
                half BdotH1 = dot(bitangent1, hDirWS) / _AnisoSpread1;
                //float anisoKK1 = sqrt(1.0 - BdotH1 * BdotH1);
                //anisoKK1 = pow(max(0.0, anisoKK1), _AnisoSpread1 * 50.0) * ndotl;
                half spec_term1 = exp(-(tdoth * tdoth + BdotH1 * BdotH1) / (ndoth + 1.0));
                half3 anisoSpecular1 = spec_term1 * aniso_term * speccolor1 * _LightColor0.rgb;

                // KK2
                half3 speccolor2 = _AnisoSpecularColor2 + basecolor;
                float3 anisooffset2 = nDirWS2 * (_AnisoOffset2 + (hairnoise - 0.5) * _AnisoIntensity2);
                float3 bitangent2 = normalize(bitangent + anisooffset2);
                half BdotH2 = dot(bitangent2, hDirWS) / _AnisoSpread2;
                //float anisoKK2 = sqrt(1.0 - BdotH2 * BdotH2);
                //anisoKK2 = pow(max(0.0, anisoKK2), _AnisoSpread2 * 50.0) * ndotl;
                half spec_term2 = exp(-(tdoth * tdoth + BdotH2 * BdotH2) / (ndoth + 1.0));
                half3 anisoSpecular2 = spec_term2 * aniso_term * speccolor2 * _LightColor0.rgb;

                half3 DirectSpecular = anisoSpecular1 + anisoSpecular2;

                //============================================================== IndirectLighting Specular ===//
                float3 cubemapUV = normalize(reflect(-vDirWS, nDirWS2));
                half3 cubemap2 = texCUBElod(_ReflectionTex, float4(cubemapUV, _Roughness));
                half3 IndirectSpecular = cubemap2 * _ReflectionIntensity * hairnoise;

                //============================================================== Final Output ================//
                half3 DirectLighting = DirectDiffuse + DirectSpecular;
                half3 IndirectLighting = IndirectSpecular;

                half3 finalRGB = DirectLighting + IndirectLighting;
                finalRGB = ACES_Tonemapping(finalRGB);
                return half4(finalRGB, 1.0);
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

            half4 frag (VertexOutput i) : SV_TARGET
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}