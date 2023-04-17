Shader "ZTY/ImageEffect/Vignette"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}

        _VignetteColor("Vignette Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _VignetteWidth("Vignette Width", float) = 2.0
        _VignetteHigh("Vignette High", float) = 2.0
        _VignetteSpread("Vignette Spread", Range(1.0 , 100)) = 30.0
        _VignetteContrast("Vignette Contrast", Range(0.1, 10.0)) = 1.0
        _VignetteIntensity("Vignette Intensity", Range(0.0, 1.0)) = 1.0
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screen_pos : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screen_pos = o.pos;
                o.screen_pos.y = o.pos.y * _ProjectionParams.x;
                return o;
            }

            sampler2D _MainTex;

            float3 _VignetteColor;
            float _VignetteWidth;
            float _VignetteHigh;
            float _VignetteSpread;
            float _VignetteContrast;
            float _VignetteIntensity;

            float4 frag (v2f i) : SV_Target
            {
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w); // [-1,1]
                screen_uv = (screen_uv + 1.0) * 0.5; // [0,1]
                float3 maincol = tex2D(_MainTex, screen_uv).rgb;

                float2 vignette = float2(_VignetteWidth, _VignetteHigh);
                screen_uv = pow(abs(screen_uv - 0.5) * vignette, _VignetteSpread);
                float vignettemask = saturate(pow(length(screen_uv), _VignetteContrast)) * _VignetteIntensity;

                float3 finalRGB = lerp(maincol, _VignetteColor, vignettemask);
                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
}
