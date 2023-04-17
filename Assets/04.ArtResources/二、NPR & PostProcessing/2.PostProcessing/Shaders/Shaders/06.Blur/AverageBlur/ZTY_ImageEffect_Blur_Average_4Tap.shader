Shader "ZTY/ImageEffect/Blur/Average/4Tap"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}

        _BlurRadius("Blur Radius", float) = 0.0
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

            sampler2D _MainTex; // 1920 * 1080
            float4 _MainTex_TexelSize; // (x = 1 / width), (y = 1 / height), (z = width), (w = height)
            float _BlurRadius;

            float4 frag (v2f i) : SV_Target
            {
                // 计算屏幕坐标
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w); // [-1,1]
                screen_uv = (screen_uv + 1.0) * 0.5; // [0,1]

                // 采样像素坐标
                float4 blur_pos = float4(1, -1, 1, -1) * _BlurRadius;

                // 偏移总量，用于累加
                float4 s1 = 0.0; // 也可以认为是0点
                // 四个角坐标
                s1 += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xz); // [1,1]
                s1 += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xy); // [1,-1]
                s1 += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yw); // [-1,-1]
                s1 += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yz); // [-1,1]
                s1 *= 0.25; // 取四个像素的平均值

                return s1;
            }
            ENDCG
        }
    }
}
