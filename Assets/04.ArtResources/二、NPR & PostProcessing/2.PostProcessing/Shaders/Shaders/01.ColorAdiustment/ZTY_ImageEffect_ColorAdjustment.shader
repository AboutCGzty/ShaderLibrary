Shader "ZTY/ImageEffect/ColorAdjustment"
{
    Properties
    {
        [HideInInspector]_MainTex("Texture", 2D) = "white" {}

        _Hue("Hue", Range(-1.0, 1.0)) = 0.0
        _Saturation("Saturation", Range(-1.0, 1.0)) = 0.0
        _Brightness("Brightness", Range(0.0, 3.0)) = 1.0
        _Exposure("Exposure", Range(0.0, 3.0)) = 1.0
        _Contrast("Contrast", Range(0.0, 2.0)) = 1.0
        _RedMixer("Red Mixer", Range(0.0, 10.0)) = 0.0
        _GreenMixer("Green Mixer", Range(0.0, 10.0)) = 1.0
        _BlueMixer("Blue Mixer", Range(0.0, 10.0)) = 1.0
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
            #pragma shader_feature_local _ACES

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

            float3 ACES_Tonemapping(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				float3 encode_color = saturate((x * (a * x + b)) / (x * (c * x + d) + e));
				return encode_color;
			};

            float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

            float3 HSVToRGB( float3 c )
			{
				float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
				float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
				return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
			}

            sampler2D _MainTex;

            float _Hue;
            float _Saturation;
            float _Brightness;
            float _Exposure;
            float _Contrast;
            float _RedMixer;
            float _GreenMixer;
            float _BlueMixer;

            float4 frag (v2f i) : SV_Target
            {
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w); // [-1,1]
                screen_uv = (screen_uv + 1.0) * 0.5; // [0,1]

                #ifdef _ACES
                float3 screencol = ACES_Tonemapping(tex2D(_MainTex, screen_uv).rgb);
                #else
                float3 screencol = tex2D(_MainTex, screen_uv).rgb;
                #endif

                float3 postcol = RGBToHSV(screencol);
                float hue = postcol.x + _Hue;
                float saturate = postcol.y;
                float value = postcol.z * _Exposure;
                float3 hsv = float3(hue, saturate, value);
                hsv = HSVToRGB(hsv);

                float desaturate = dot( hsv, float3(0.299, 0.587, 0.114));
				float3 desaturatecol = lerp(hsv, desaturate, (_Saturation * -1.0));

                float3 finalRGB = lerp(0.5, desaturatecol, _Contrast) * _Brightness;
                finalRGB.r *= _RedMixer;
                finalRGB.g *= _GreenMixer;
                finalRGB.b *= _BlueMixer;

                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
}
