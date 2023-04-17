Shader "ZTY/ImageEffect/Distortion/Ripple"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}

        [Toggle(_ONEWAY_ON)]_OneWay("One Way", int) = 0
        _RippleTilling("Ripple Tilling", float) = 1.0
        _RippleSpeed("Ripple Speed", float) = 0.1
        _RippleIntensity("Ripple Intensity", Range(0.0, 1.0)) = 0.5
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
            #pragma shader_feature_local _ONEWAY_ON

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

			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
            float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}

            sampler2D _MainTex;

            int _OneWay;

            float _RippleTilling;
            float _RippleSpeed;
            float _RippleIntensity;

            float4 frag (v2f i) : SV_Target
            {
                float2 screen_uv = i.screen_pos.xy / max(0.00001, i.screen_pos.w); // [-1,1]
                screen_uv = (screen_uv + 1.0) * 0.5; // [0,1]

                #ifdef _ONEWAY_ON
                float2 flowspeed1 = float2(0.0, (_RippleSpeed * _Time.y * 0.1)); 
                float2 flow_uv1 = screen_uv * _RippleTilling + flowspeed1;
                float ripplemask1 = snoise(flow_uv1);
                float2 ripple_uv = float2(0.0, ripplemask1);
                float2 main_uv = lerp(screen_uv, ripple_uv, _RippleIntensity * 0.1);

                #else
                float2 flowspeed1 = float2((_RippleSpeed * _Time.y * 0.1), (_RippleSpeed * _Time.y * 0.1)); 
                float2 flow_uv1 = screen_uv * _RippleTilling + flowspeed1;
                float ripplemask1 = snoise(flow_uv1);
                float2 flowspeed2 = float2((_RippleSpeed * _Time.y * -0.1), (_RippleSpeed * _Time.y * -0.1)); 
                float2 flow_uv2 = screen_uv * _RippleTilling + flowspeed2;
                float ripplemask2 = snoise(flow_uv2);
                float2 ripple_uv = float2(ripplemask1, ripplemask2);
                float2 main_uv = lerp(screen_uv, ripple_uv, _RippleIntensity * 0.1);
                #endif

                float3 finalRGB = tex2D(_MainTex, main_uv).rgb;

                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
}
