Shader "Scene/ReflectGround"
{
    Properties
    {
        [Header(Ground ____________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _GroundOutColor("Ground OutColor", Color) = (0.0, 0.0, 0.0, 0.0)
        _GroundInnerColor("Ground InnerColor", Color) = (1.0, 1.0, 1.0, 0.0)
        _GroundScale("Ground Scale", Range(0.0, 1.0)) = 0.01
        _GroundPower("Ground Power", Range(1.0, 10.0)) = 3.0

        [Header(Shadow ____________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _ShadowColor("Shadow Color", Color) = (0.0, 0.0, 0.0, 0.0)
        [NoScaleOffset]_ShadowMask("ShadowMask", 2D) = "white"{}
        _ShadowScale("Shadow Scale", float) = 17.0
        _ShadowIntensity("Shadow Intensity", Range(0.0, 0.3)) = 0.0

        [Header(Reflection ____________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [NoScaleOffset]_ReflectionTex("ReflectionTex", 2D) = "black" {}
        _PlanarReflectionIntensity("Planar Reflection Intensity", Range(0.0, 1.0)) = 0.5
        _ReflectionPow("Reflection Pow", Range(1.0, 10.0)) = 3.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Cull Back ZWrite On ZTest LEqual

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "../Include/CarCginc.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWS : TEXCOORD1;
                float4 posSS : TEXCOORD2;
                float3 nDirWS : TEXCOORD3;
            };

            half3 _GroundInnerColor;
            half3 _GroundOutColor;
            half _GroundScale;
            half _GroundPower;

            half3 _ShadowColor;
            sampler2D _ShadowMask;
            half _ShadowScale;
            half _ShadowIntensity;

			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
            UNITY_DECLARE_TEX2D_NOSAMPLER(_ReflectionTex);
			SamplerState sampler_ReflectionTex;
            half _PlanarReflectionIntensity;
            half _ReflectionPow;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
				o.posSS = ComputeScreenPos(o.pos);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 worldnormal = normalize(i.nDirWS);
                float3 view_world = normalize(_WorldSpaceCameraPos - i.posWS.xyz);
                float nv = saturate(pow(saturate(dot(worldnormal, view_world)), _ReflectionPow));

                // PIDI
				float4 screenPos = normalize(i.posSS);
				screenPos /= screenPos.w;
				screenPos.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? screenPos.z : screenPos.z * 0.5 + 0.5;
				
				float3 PIDI = SAMPLE_TEXTURE2D( _ReflectionTex, sampler_ReflectionTex, (screenPos).xy ).xyz;
                PIDI *= _PlanarReflectionIntensity * nv;

                // Ground
                float2 XZ = (i.posWS).xz;
                float groundmask = saturate(pow(saturate(1.0 - length(XZ) * _GroundScale), _GroundPower));
                float3 groundcol = lerp(_GroundOutColor, _GroundInnerColor, groundmask);

                // Shadow
                float2 shadowUV = (i.uv - 0.5) * _ShadowScale + 0.5;
                float shadowfactor = saturate(tex2D(_ShadowMask, shadowUV).r - _ShadowIntensity);


                float3 finalcol = lerp(_ShadowColor, groundcol, shadowfactor) + PIDI * shadowfactor;

                return float4(finalcol, 1.0);
            }
            ENDCG
        }
    }
}
