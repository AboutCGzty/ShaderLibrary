Shader "ZTY/Charactor/Body"
{
    Properties
    {
        [Header(DirectLighting ____________________________________________________________________________________________________________________________________________________________________)]
        [Header(DirectDiffuse)]
        [Space(10)]
        _BaseColor("BaseColor", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_Albedo("Albedo", 2D) = "white" {}
        [NoScaleOffset]_LutTex("LutTex", 2D) = "black" {}
        _LutOffset("Lut Offset", Range(0.0, 1.0)) = 0.0
        _LutCurv("Lut Curv", Range(0.0, 1.0)) = 1.0
        [NoScaleOffset]_NormalTex("Normal", 2D) = "bump" {}
        _NormalIntensity("Normal Intensity", Range(0.0, 1.0)) = 1.0

        [Header(DirectSpecular)]
        [Space(10)]
        [NoScaleOffset]_Mask("Mask", 2D) = "gray" {}
        _SpecularIntensity("Specular Intensity", Range(0.0, 3.0)) = 1.0
        _SpecularRange("SpecularRange", Range(1.0, 10.0)) = 1.0
        _SkinHightLightIntensity("SkinHightLight Intensity", Range(0.0, 0.1)) = 0.1
        [HDR]_EmissionColor("Emission Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_Emission("Emission", 2D) = "black" {}

        [Header(IndirectLighting ____________________________________________________________________________________________________________________________________________________________________)]
        [Header(IndirectDiffuse)]
        [Space(10)]
        _SHIntensity("SH Intensity", Range(0.0, 1.0)) = 0.1
        custom_SHAr("Custom SHAr", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHAg("Custom SHAg", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHAb("Custom SHAb", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHBr("Custom SHBr", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHBg("Custom SHBg", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHBb("Custom SHBb", Vector) = (0.0, 0.0, 0.0, 0.0)
		custom_SHC("Custom SHC", Vector) = (0.0, 0.0, 0.0, 1.0)
        
        [Header(IndirectSpecular)]
        [Space(10)]
        [NoScaleOffset]_ReflectionTex("ReflectionTex", Cube) = "black"{}
        [NoScaleOffset]_ReflectionRoughness("Reflection Roughness", Range(1.0, 4.0)) = 2.0
        [NoScaleOffset]_ReflectionIntensity("Reflection Intensity", Range(1.0, 5.0)) = 1.0
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

            half3 _BaseColor, _EmissionColor;
            sampler2D _Albedo, _LutTex, _NormalTex, _Mask, _Emission;
            samplerCUBE _ReflectionTex;
            half _LutOffset, _LutCurv, _NormalIntensity, _Smoothness, _SpecularIntensity, _SpecularRange, _SkinHightLightIntensity, _ReflectionIntensity, _ReflectionRoughness, _SHIntensity;
            half4 custom_SHAr, custom_SHAg, custom_SHAb, custom_SHBr, custom_SHBg, custom_SHBb, custom_SHC;

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

                ////============================================================== Texture Sample ==============//
                half3 albedomap = tex2D(_Albedo, i.uv_mesh);
                half3 albedo = albedomap * _BaseColor;

                half3 mask = tex2D(_Mask, i.uv_mesh);
                half rough = mask.r;
                half metal = mask.g;
                half skin_mask = saturate(1.0 - mask.b);

                half3 emiss = tex2D(_Emission, i.uv_mesh);
                emiss *= _EmissionColor;

                ////============================================================== Vector Ready ================//
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                half3 normalmap = UnpackNormalWithScale(tex2D(_NormalTex, i.uv_mesh), _NormalIntensity);
                half3 nDirWS2 = normalize(mul(normalmap, TBN));
                half3 lDirWS = normalize(_WorldSpaceLightPos0.xyz);
                half3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                half3 hDirWS = normalize(lDirWS + vDirWS);

                ////============================================================== DirectLighting Diffuse ======//
                half3 basecolor = albedo * (1.0 - metal);//固有色
                half ndotl = max(0.0, dot(nDirWS2, lDirWS));
                half halflambert = (dot(nDirWS2, lDirWS) + 1.0) * 0.5;
                half3 commonDiffuse = basecolor * ndotl * atten;

                float2 lutUV = float2(ndotl * atten + _LutOffset, _LutCurv);
                half3 lutTex = tex2D(_LutTex, lutUV);
                half3 diffuse_SSS = lutTex * basecolor * halflambert;

                half3 DirectDiffuse = lerp(commonDiffuse, diffuse_SSS, skin_mask) * _LightColor0.rgb;
                //============================================================== DirectLighting Specular =====//
                half3 specularcolor = lerp(0.03, albedo, metal);//高光颜色
                half ndoth = max(0.0, dot(nDirWS2, hDirWS));

                half smoothness = saturate(1.0 - rough);
                half smooth = lerp(1.0, _SpecularRange, smoothness);
                half specularpow = saturate(pow(ndoth, smooth * smoothness));

                half3 skinSpecular = lerp(specularcolor, _SkinHightLightIntensity, skin_mask);

                half3 DirectSpecular = specularpow * skinSpecular * _SpecularIntensity * ndotl * atten * _LightColor0.rgb;

                //============================================================== IndirectLighting Diffuse ====//
                half3 SH = SHCOLOR(nDirWS2, custom_SHAr, custom_SHAg, custom_SHAb,
                                            custom_SHBr, custom_SHBg, custom_SHBb,
                                            custom_SHC,_SHIntensity);
                SH = SH * basecolor;

                //============================================================== IndirectLighting Specular ===//
                half mipmap = lerp(rough * (1.70 - 0.70 * rough) * 6.0, _ReflectionRoughness, metal);
                mipmap = lerp(mipmap, 5.0, skin_mask);
                float3 cubemapUV = normalize(reflect(-vDirWS, nDirWS2));
                half3 cubemap = texCUBElod(_ReflectionTex, float4(cubemapUV, mipmap));
                half3 IndirectSpecular = cubemap * skinSpecular * _ReflectionIntensity;

                //============================================================== Final Output ================//
                half3 DirectLighting = DirectDiffuse + DirectSpecular;
                half3 IndirectLighting = SH + IndirectSpecular;

                half3 finalRGB = DirectLighting + IndirectLighting;
                finalRGB = ACES_Tonemapping(finalRGB) + emiss;
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