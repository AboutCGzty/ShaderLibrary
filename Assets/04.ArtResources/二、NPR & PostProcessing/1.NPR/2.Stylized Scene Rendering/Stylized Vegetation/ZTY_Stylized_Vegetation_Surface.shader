Shader "ZTY/Stylized/Vegetation/Surface"
{
    Properties
    {
        [Header(Water Color _______________________________________________________________________________________________________)]
        [Space(10)]
        _ShallowColor("Shallow Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _DeepColor("Deep Color", Color) = (1.0, 1.0, 1.0, 0.0)

        [Header(Ripple and Wave _______________________________________________________________________________________________________)]
        [Header(Ripple)]
        [Space(10)]
        [Normal][NoScaleOffset]_RippleNormal("Ripple Normal", 2D) = "bump"{}
        _RippleTilling("Ripple Tilling", Range(0.0, 1.0)) = 0.5
        _RippleIntensity("Ripple Intensity", Range(0.0, 1.0)) = 0.5
        _RippleSpeed("Ripple Speed", float) = 0.1
        [Header(Wave)]
        [Space(10)]
        _WaveDirection("Wave Direction", Vector) = (0.0, 0.0, 0.0, 0.0)
        _WaveTilling("Wave Tilling", Range(0.0, 1.0)) = 0.5
        _WaveIntensity("Wave Intensity", Range(0.0, 1.0)) = 0.5
        _WaveSpeed("Wave Speed", float) = 0.1

        [Header(PlanarReflection and Refraction _______________________________________________________________________________________________________)]
        [Header(PlanarReflection)]
        [Space(10)]
        [NoScaleOffset]_ReflectionTexture("PlanarReflection Texture", 2D) = "black"{}
        _PlanarReflectionIntensity("PlanarReflection Intensity", Range(0.0, 1.0)) = 0.5
        _ReflectionArea("PlanarReflection Area", Range(1.0, 10.0)) = 3.0

        [Header(Refraction)]
        [Space(10)]
        _RefractionIntensity("Refraction Intensity", Range(0.0, 1.0)) = 0.5
        _RefractionArea("Refraction Area", Range(1.0, 10.0)) = 3.0

        [Header(Foam ________________________________________________________________________________________________________________)]
        [Space(10)]
        _FoamColor("Foam Color", Color) = (1.0, 1.0, 1.0, 0.0)
        _FoamIntensity("Foam Intensity", Range(0.0, 1.0)) = 0.5
        _FoamArea("Foam Area", Range(1.0, 10.0)) = 3.0

        [Header(Caustics ________________________________________________________________________________________________________________)]
        [Space(10)]
        [NoScaleOffset]_CausticsTexture("Caustics Texture", 2D) = "black"{}
        _CausticsIntensity("Caustics Intensity", Range(0.0, 1.0)) = 0.5
        _CausticsArea("Foam Area", Range(1.0, 10.0)) = 3.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IngornProjector" = "true"
        }

        Pass
        {
            ZWrite Off ZTest LEqual Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return float4(1,1,1, 0.5);
            }
            ENDCG
        }
    }
}
