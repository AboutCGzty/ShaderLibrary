Shader "ZTY/ImageEffect/Blur/Guassian"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _BlurRadius("Blur Radius", Range(0.0, 4.0)) = 0.0
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

                // 采样水平像素坐标
                float2 Hblur_pos = float2(0.0, 1.0);

                // 水平方向坐标
                float2 uv1 = screen_uv + _MainTex_TexelSize.xy * Hblur_pos * -2.0 * _BlurRadius; // 向左两个坐标
                float2 uv2 = screen_uv + _MainTex_TexelSize.xy * Hblur_pos * -1.0 * _BlurRadius; // 向左一个坐标
                float2 uv3 = screen_uv; // 0点坐标
                float2 uv4 = screen_uv + _MainTex_TexelSize.xy * Hblur_pos * 1.0 * _BlurRadius; // 向右一个坐标
                float2 uv5 = screen_uv + _MainTex_TexelSize.xy * Hblur_pos * 2.0 * _BlurRadius; // 向右两个坐标

                // 偏移总量，用于累加
                float4 s1 = 0.0;
                // 叠加后乘以各自的权重值
                s1 += tex2D(_MainTex, uv1) * 0.06;
                s1 += tex2D(_MainTex, uv2) * 0.24;
                s1 += tex2D(_MainTex, uv3) * 0.40;
                s1 += tex2D(_MainTex, uv4) * 0.24;
                s1 += tex2D(_MainTex, uv5) * 0.06;

                return s1;
            }
            ENDCG
        }

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

                // 采样垂直像素坐标
                float2 Vblur_pos = float2(1.0, 0.0);
                // 水平方向坐标
                float2 uv1 = screen_uv + _MainTex_TexelSize.xy * Vblur_pos * -2.0 * _BlurRadius; // 向左两个坐标
                float2 uv2 = screen_uv + _MainTex_TexelSize.xy * Vblur_pos * -1.0 * _BlurRadius; // 向左一个坐标
                float2 uv3 = screen_uv; // 0点坐标
                float2 uv4 = screen_uv + _MainTex_TexelSize.xy * Vblur_pos * 1.0 * _BlurRadius; // 向右一个坐标
                float2 uv5 = screen_uv + _MainTex_TexelSize.xy * Vblur_pos * 2.0 * _BlurRadius; // 向右两个坐标

                // 偏移总量，用于累加
                float4 s1 = 0.0;
                // 叠加后乘以各自的权重值
                s1 += tex2D(_MainTex, uv1) * 0.06;
                s1 += tex2D(_MainTex, uv2) * 0.24;
                s1 += tex2D(_MainTex, uv3) * 0.40;
                s1 += tex2D(_MainTex, uv4) * 0.24;
                s1 += tex2D(_MainTex, uv5) * 0.06;

                return s1;
            }
            ENDCG
        }
    }
}
