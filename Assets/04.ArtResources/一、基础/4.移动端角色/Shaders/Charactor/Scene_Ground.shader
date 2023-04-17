Shader "Scene/Ground"
{
    Properties
    {
        [Header(Ground Settings ____________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _GroundColor("Ground Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_GroundTex("Ground Tex", 2D) = "white"{}
        _GroundTilling("Ground Tilling", float) = 1.0

        [Header(Reflection Settings ____________________________________________________________________________________________________________________________________________________________________)]
		[NoScaleOffset]_ReflectionTex("ReflectionTex", 2D) = "white" {}
        _PlanarReflectionIntensity("Planar Reflection Intensity", Range(0.0, 1.0)) = 0.5
        _PlanarReflectionPow("Planar Reflection Pow", Range(1.0, 10.0)) = 3.0
        _PlanarReflectionBais("Planar Reflection Bais", Range(0.0, 1.0)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Back
        ZWrite On
        ZTest LEqual

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "../Include/ZTYCginc.cginc"
            #pragma multi_compile_fog

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
                float3 normal_WS : TEXCOORD3;
                UNITY_FOG_COORDS(5)
            };

            half3 _GroundColor;
            sampler2D _GroundTex;
            half _GroundTilling;

			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
            UNITY_DECLARE_TEX2D_NOSAMPLER(_ReflectionTex);
			SamplerState sampler_ReflectionTex;
            half _PlanarReflectionIntensity;
            half _PlanarReflectionPow;
            half _PlanarReflectionBais;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
				o.posSS = ComputeScreenPos(o.pos);
                o.normal_WS = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o, o.pos);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Ground
                half4 groundtex = tex2D(_GroundTex, i.uv * _GroundTilling);
                half3 groundcolor = groundtex.rgb * _GroundColor;
                half groundrefmask = groundtex.a;

                // PIDI
                half3 view_world = normalize(_WorldSpaceCameraPos - i.posWS.xyz);
                half3 normal_world = normalize(i.normal_WS);
                half fresnel = saturate(pow(abs(1.0 - dot(normal_world, _WorldSpaceLightPos0.xyz)), _PlanarReflectionPow) + _PlanarReflectionBais);
				float4 screenPos = normalize(i.posSS);
				screenPos /= screenPos.w;
				screenPos.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? screenPos.z : screenPos.z * 0.5 + 0.5;
				
				half3 PIDI = SAMPLE_TEXTURE2D( _ReflectionTex, sampler_ReflectionTex, (screenPos).xy).xyz;
                PIDI *= _PlanarReflectionIntensity * groundrefmask;

                // Final
                half3 finalcol = lerp(groundcolor, PIDI, fresnel);
                UNITY_APPLY_FOG(i.fogCoord, finalcol);

                return half4(finalcol, 1.0);
            }
            ENDCG
        }
    }
}
