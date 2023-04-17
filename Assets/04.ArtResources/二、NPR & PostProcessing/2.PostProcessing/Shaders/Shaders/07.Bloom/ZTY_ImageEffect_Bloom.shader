Shader "ZTY/ImageEffect/Bloom"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _BloomThreshold("Bloom Threshold", Range(0.0, 10.0)) = 1.0
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        // 0 抠出Bloom区域
        Pass
        {
            Name "Threshold"
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
            float4 _MainTex_TexelSize;
            float _BloomThreshold;

            float4 frag (v2f i) : SV_Target
            {
                // 计算屏幕坐标
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w);
                screen_uv = (screen_uv + 1.0) * 0.5;

                float4 blur_pos = float4(1, -1, 1, -1);
                float4 color = 0.0;
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xz);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xy);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yw);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yz);
                color *= 0.25;

                float brightness = max(max(color.r, color.g), color.b);
                brightness = max(0.0, brightness - _BloomThreshold) / max(0.000001, brightness);
                color *= brightness;

                return float4(color.rgb, 1);
            }
            ENDCG
        }

        // 1 降采样模糊
        Pass
        {
            Name "DownSample"
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
            float4 _MainTex_TexelSize;

            float4 frag (v2f i) : SV_Target
            {
                // 计算屏幕坐标
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w);
                screen_uv = (screen_uv + 1.0) * 0.5;

                float4 blur_pos = float4(1, -1, 1, -1);
                float4 color = 0.0;
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xz);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xy);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yw);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yz);
                color *= 0.25;

                return color;
            }
            ENDCG
        }

        // 2 升采样模糊
        Pass
        {
            Name "UpSample"
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

            sampler2D _MainTex, _BloomTex;
            float4 _MainTex_TexelSize;

            float4 frag (v2f i) : SV_Target
            {
                // 计算屏幕坐标
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w);
                screen_uv = (screen_uv + 1.0) * 0.5;

                float4 blur_pos = float4(1, -1, 1, -1);
                float4 color = 0.0;
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xz);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.xy);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yw);
                color += tex2D(_MainTex, screen_uv + _MainTex_TexelSize.xy * blur_pos.yz);
                color *= 0.25;

                float4 color2 = tex2D(_BloomTex, screen_uv);
                color2 += color;

                return color2;
            }
            ENDCG
        }

        // 3 合并
        Pass
        {
            Name "Combine"
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

            sampler2D _MainTex, _BloomTex;
            float4 _MainTex_TexelSize;
            float _BloomIntensity;

            float4 frag (v2f i) : SV_Target
            {
                // 计算屏幕坐标
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w);
                screen_uv = (screen_uv + 1.0) * 0.5;

                float4 maincolor = tex2D(_MainTex, screen_uv);
                float4 bloomcol = tex2D(_BloomTex, screen_uv);

                float3 finalcol = maincolor.rgb + bloomcol.rgb * _BloomIntensity;

                return float4(finalcol, 1.0);
            }
            ENDCG
        }
    }
}
