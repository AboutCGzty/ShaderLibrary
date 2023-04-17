Shader "ZTY/Stylized/GlobalFog"
{
    Properties
    {
        [Header(Mode _____________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [KeywordEnum(Linear, EXP, EXP2)]_FogMode("Fog Mode", int) = 0
        [KeywordEnum(Distance, Height, Global)]_FogType("Fog Type", int) = 0

        [Header(Color _____________________________________________________________________________________________________________________________________)]
        [Space(10)]
		_FogColor("FogColor", Color) = (1.0, 1.0, 1.0, 0.0)
		_FogIntensity("Fog Intensity", Range(0.0, 1.0)) = 0.5
        [Toggle(_ACES_ON)]_ACESOn("ACES On", int) = 0

        [Header(Distance and Height _______________________________________________________________________________________________________________________)]
        [Header((Distance))]
        [Space(5)]
		_FogDistanceStart("Fog Distance Start", float) = 25.0
		_FogDistanceEnd("Fog Distance End", float) = 150.0
        [Header((Height))]
        [Space(5)]
		_FogHeightStart("Fog Height Start", float) = 0.0
		_FogHeightEnd("Fog Height End", float) = 1000.0
        [Header((EXP))]
        [Space(5)]
		_FogExpDistance("Fog Exp Distance", Range(0.0, 1.0)) = 0.01
		_FogExpHeight("Fog Exp Height", Range(0.0, 1.0)) = 0.999
		_FogExpHeightPower("Fog Exp Height Power", Range(1.0, 10.0)) = 1.0
        [Header((EXP2))]
        [Space(5)]
		_FogExp2Distance("Fog Exp2 Distance", Range(0.0, 1.0)) = 0.01
		_FogExp2Height("Fog Exp2 Height", Range(0.0, 1.0)) = 0.999

        [Header(SunWeight _________________________________________________________________________________________________________________________________)]
        [Space(10)]
		_SunIntensity("Sun Fog Intensity", float) = 1.0
		_SunFogRange("Sun Fog Range", Range(1.0, 10.0)) = 1.0

        [Header(Noise _____________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [Toggle(_FOGNOISE_ON)]_FogNoiseOn("Fog Noise On", int) = 0
		_FogNoiseIntensity("Fog Noise Intensity", Range(0.0, 3.0)) = 1.0
		_FogNoiseScale("Fog Noise Scale", vector) = (1.0, 1.0, 1.0, 0.0)
        _FogNoiseSpeed("Fog Noise Speed", vector) = (1.0, 1.0, 1.0, 0.0)
    }

    SubShader
    {
// 标签设置 ------------------------------------------------------------------------------------------------------------------------- //
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+500"
            "IgnoreProjector" = "True"
        }
// ---------------------------------------------------------------------------------------------------------------------------------- //
        Pass
        {
// 渲染状态设置 --------------------------------------------------------------------------------------------------------------------- //
            Cull Front ZWrite Off ZTest Always
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
// ---------------------------------------------------------------------------------------------------------------------------------- //
// CG代码片段 ----------------------------------------------------------------------------------------------------------------------- //
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma shader_feature_local _FOGMODE_LINEAR _FOGMODE_EXP _FOGMODE_EXP2
            #pragma shader_feature_local _FOGTYPE_DISTANCE _FOGTYPE_HEIGHT _FOGTYPE_GLOBAL
            #pragma shader_feature_local _ACES_ON
            #pragma shader_feature_local _FOGNOISE_ON
// ---------------------------------------------------------------------------------------------------------------------------------- //
            struct appdata
            {
                float4 vertex : POSITION;
            };
// ---------------------------------------------------------------------------------------------------------------------------------- //
            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 pos_screen : TEXCOORD0;
                float4 pos_world : TEXCOORD1;
            };
// ---------------------------------------------------------------------------------------------------------------------------------- //
// 顶点Shader ----------------------------------------------------------------------------------------------------------------------- //
            v2f vert (appdata v)
            {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex);
                // 计算屏幕空间坐标
				o.pos_screen = ComputeScreenPos(o.pos);
				return o;
            }
// ---------------------------------------------------------------------------------------------------------------------------------- //
// 自定义方法 ----------------------------------------------------------------------------------------------------------------------- //
            // 线性雾
            float LinearFogFactor(float Start, float End, float Distance)
            {
                float a = End - Distance;
                float b = End - Start;
                float c = a / max(0.000001, b);

                return 1.0 - saturate(c);
            }
            // 指数雾1
            float EXPFogFactor(float density, float Distance)
            {
                float expfog = saturate(exp2(-density * Distance));
                return expfog;
            }
            // 指数雾2
            float EXP2FogFactor(float density, float Distance)
            {
                float den = density * Distance;
                float exp2fog = saturate(exp2(-den * den));
                return exp2fog;
            }
            // 3D噪声算法
            float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }
		    float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }
		    float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }
		    float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }
		    float snoise( float3 v )
		    {
			    const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			    float3 i = floor( v + dot( v, C.yyy ) );
			    float3 x0 = v - i + dot( i, C.xxx );
			    float3 g = step( x0.yzx, x0.xyz );
			    float3 l = 1.0 - g;
			    float3 i1 = min( g.xyz, l.zxy );
			    float3 i2 = max( g.xyz, l.zxy );
			    float3 x1 = x0 - i1 + C.xxx;
			    float3 x2 = x0 - i2 + C.yyy;
			    float3 x3 = x0 - 0.5;
			    i = mod3D289( i);
			    float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			    float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			    float4 x_ = floor( j / 7.0 );
			    float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			    float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			    float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			    float4 h = 1.0 - abs( x ) - abs( y );
			    float4 b0 = float4( x.xy, y.xy );
			    float4 b1 = float4( x.zw, y.zw );
			    float4 s0 = floor( b0 ) * 2.0 + 1.0;
			    float4 s1 = floor( b1 ) * 2.0 + 1.0;
			    float4 sh = -step( h, 0.0 );
			    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			    float3 g0 = float3( a0.xy, h.x );
			    float3 g1 = float3( a0.zw, h.y );
			    float3 g2 = float3( a1.xy, h.z );
			    float3 g3 = float3( a1.zw, h.w );
			    float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			    g0 *= norm.x;
			    g1 *= norm.y;
			    g2 *= norm.z;
			    g3 *= norm.w;
			    float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			    m = m* m;
			    m = m* m;
			    float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			    return 42.0 * dot( m, px);
		    }
            // ACESTonemapping
            float3 ACES_Tonemapping(float3 color_input)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                float3 encode_color = saturate((color_input * (a * color_input + b)) / (color_input * (c * color_input + d) + e));

                return encode_color;
            }
// ---------------------------------------------------------------------------------------------------------------------------------- //
// 申明变量 ------------------------------------------------------------------------------------------------------------------------- //
            int _FogMode, _FogType;
            float _FogDistanceStart, _FogDistanceEnd, _FogHeightStart, _FogHeightEnd, _SunFogRange, _SunIntensity, _FogIntensity,
                  _FogNoiseIntensity, _FogExpDistance, _FogExpHeight, _FogExpHeightPower, _FogExp2Distance, _FogExp2Height;
            uniform sampler2D _CameraDepthTexture;
			uniform float4 _CameraDepthTexture_TexelSize, _FogColor, _FogNoiseScale, _FogNoiseSpeed;
// ---------------------------------------------------------------------------------------------------------------------------------- //
// 片元Shader ----------------------------------------------------------------------------------------------------------------------- //
            float4 frag (v2f i) : SV_Target
            {
// Reconstruct World Position From Depth 【深度重建世界坐标】------------------------------------------------------------------------ //
                // 计算屏幕坐标
				float4 screenPos = i.pos_screen;
                // 透视除法
				screenPos /= screenPos.w;
                // [-1,1] ---> [0,1]
				screenPos.z = screenPos.z * 0.5 + 0.5;
                // 用屏幕的xy分量作为屏幕UV[0,1] 采样深度图[0,1]
				float depth01 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPos.xy);
                // InverseZ 因为unity所以要翻转z值
                float invZ = 1.0 - depth01;
                // 裁剪空间下的视锥坐标
				float3 clipVec = float3(screenPos.x , screenPos.y , invZ);
                // 转换为NDC坐标 [0, 1] 并重映射至 [-1, 1]
				float3 ndcPos = clipVec * 2.0 - 1.0;
                // 由 裁切空间坐标 转换到 观察空间坐标
				float4 viewPos = mul(unity_CameraInvProjection, float4(ndcPos, 1.0));
                viewPos.xyz /= viewPos.w;
                // built-in需要如此计算（不知道为什么）
                viewPos.xyz *= float3(1.0, 1.0, -1.0);
                // 深度重建世界坐标结果
				float4 worldPosFromDepth = mul(unity_CameraToWorld, float4(viewPos.xyz, 1.0));
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 获取相机位置
                float3 cameraPos = _WorldSpaceCameraPos.xyz;
                // 计算雾的深度
                float z = length(worldPosFromDepth.xyz - cameraPos);
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 线性雾
                float fogDistance_Linear = LinearFogFactor(_FogDistanceStart, _FogDistanceEnd, z);
                float fogHeight_Linear = 1.0 - LinearFogFactor(_FogHeightStart, _FogHeightEnd, worldPosFromDepth.y);
                // 设置宏做模式判断
                float fogAlpha_Linear;
                #ifdef _FOGTYPE_DISTANCE
                fogAlpha_Linear = fogDistance_Linear;
                #elif _FOGTYPE_HEIGHT
                fogAlpha_Linear = fogHeight_Linear;
                #elif _FOGTYPE_GLOBAL
                fogAlpha_Linear = saturate(fogDistance_Linear * fogHeight_Linear);
                #endif
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 指数雾1
                float fogDistance_EXP = 1.0 - EXPFogFactor(_FogExpDistance, z);
                float fogHeight_EXP = EXPFogFactor(1.0 - _FogExpHeight, pow(worldPosFromDepth.y * 0.5 + 0.5, _FogExpHeightPower));
                // 设置宏做模式判断
                float fogAlpha_EXP;
                #ifdef _FOGTYPE_DISTANCE
                fogAlpha_EXP = fogDistance_EXP;
                #elif _FOGTYPE_HEIGHT
                fogAlpha_EXP = fogHeight_EXP;
                #elif _FOGTYPE_GLOBAL
                fogAlpha_EXP = saturate(fogDistance_EXP * fogHeight_EXP);
                #endif
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 指数雾2
                float fogDistance_EXP2 = 1.0 - EXP2FogFactor(_FogExp2Distance, z);
                float fogHeight_EXP2 = EXP2FogFactor(1.0 - _FogExp2Height, worldPosFromDepth.y);
                // 设置宏做模式判断
                float fogAlpha_EXP2;
                #ifdef _FOGTYPE_DISTANCE
                fogAlpha_EXP2 = fogDistance_EXP2;
                #elif _FOGTYPE_HEIGHT
                fogAlpha_EXP2 = fogHeight_EXP2;
                #elif _FOGTYPE_GLOBAL
                fogAlpha_EXP2 = saturate(fogDistance_EXP2 * fogHeight_EXP2);
                #endif
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 计算平行光在雾中的位置
                float3 fogSunPos = normalize(worldPosFromDepth.xyz - cameraPos);
                float3 fogSunDir = normalize(UnityWorldSpaceLightDir(i.pos_world));
                // 计算平行光在雾中的权重
                float fogSunWeight = dot(fogSunPos, fogSunDir) * 0.5 + 0.5;
                fogSunWeight = saturate(pow(fogSunWeight, _SunFogRange * 10.0) * _SunIntensity);
                float3 fogColor = lerp(_FogColor.rgb, _LightColor0.rgb, fogSunWeight).rgb;
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 最终颜色
                #ifdef _ACES_ON
                fogColor = ACES_Tonemapping(fogColor);
                #else
                fogColor = fogColor;
                #endif
                // 雾效Alpha
                #ifdef _FOGMODE_LINEAR
                float fogAlpha = fogAlpha_Linear;
                #elif _FOGMODE_EXP
                float fogAlpha = fogAlpha_EXP;
                #elif _FOGMODE_EXP2
                float fogAlpha = fogAlpha_EXP2;
                #endif
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 计算3D噪声UV
                float3 noise3D_UV = worldPosFromDepth.xyz / max(0.0, _FogNoiseScale.xyz);
                // 计算3D噪声速度
                float3 noise3D_Speed = _Time.y * _FogNoiseSpeed;
                // 计算3D噪声遮罩 并重映射至[0,1]
                float noise3D_Mask = snoise(noise3D_UV + noise3D_Speed) * 0.5 + 0.5;
                noise3D_Mask = lerp(1.0, noise3D_Mask, saturate(fogAlpha * _FogNoiseIntensity));
// ---------------------------------------------------------------------------------------------------------------------------------- //
                // 最终Alpha
                float finalAlpha;
                #ifdef _FOGNOISE_ON
                finalAlpha = saturate(fogAlpha * noise3D_Mask);
                #else
                finalAlpha = fogAlpha;
                #endif
// ---------------------------------------------------------------------------------------------------------------------------------- //
                return float4(fogColor, finalAlpha * _FogIntensity);
            }
            ENDCG
        }
    }
}
