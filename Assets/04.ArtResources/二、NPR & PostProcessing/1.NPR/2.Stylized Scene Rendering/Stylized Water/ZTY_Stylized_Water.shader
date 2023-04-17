Shader "ZTY/Stylized/Water"
{
    Properties
    {
        [Header(Water Color _______________________________________________________________________________________________________)]
        [Space(10)]
        _ShallowColor("Shallow Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _DeepColor("Deep Color", Color) = (1.0, 1.0, 1.0, 0.0)
        _DeepRange("Deep Range", Range(0.0, 1.0)) = 0.2
		_DeepOpacity("Deep Opacity", Range(0.0, 1.0)) = 1.0
        [Toggle(_ACES_ON)]_ACESON("ACES On", int) = 1

        [Header(Ripple and Wave _______________________________________________________________________________________________________)]
        [Header((Ripple))]
        [Space(5)]
        [Normal][NoScaleOffset]_SmallRipple("Small Ripple", 2D) = "bump"{}
        [Header(Tilling(XY) Intensity(Z) Speed(W))]
        [Space(5)]
        _SmallRippleProperties("Small Ripple Properties", Vector) = (0.5, 0.5, 0.5, 0.1)
        [Normal][NoScaleOffset]_BigRipple("Big Ripple", 2D) = "bump"{}
        [Header(Tilling(XY) Intensity(Z) Speed(W))]
        [Space(5)]
        _BigRippleProperties("Big Ripple Properties", Vector) = (0.5, 0.5, 0.5, 0.1)
//        [Header((Wave))]
//        [Space(5)]
//        _WaveDirection("Wave Direction", Vector) = (0.0, 0.0, 0.0, 0.0)
//        _WaveTilling("Wave Tilling", Range(0.0, 1.0)) = 0.5
//        _WaveIntensity("Wave Intensity", Range(0.0, 1.0)) = 0.5
//        _WaveSpeed("Wave Speed", float) = 0.1

        [Header(Fresnel _______________________________________________________________________________________________________)]
        [Space(10)]
        _FresnelColor("Fresnel Color", Color) = (1.0, 1.0, 1.0, 0.0)
        _FresnelIntensity("Fresnel Intensity", Range(0.0, 1.0)) = 0.2

        [Header(PlanarReflection and Refraction _______________________________________________________________________________________________________)]
        [Header((PlanarReflection))]
        [Space(5)]
        [NoScaleOffset]_ReflectionTex("PlanarReflection Texture", 2D) = "black"{}
        _PlanarReflectionIntensity("PlanarReflection Intensity", Range(0.0, 1.0)) = 0.5
        _PlanarReflectionArea("PlanarReflection Area", Range(1.0, 10.0)) = 3.0
        _PlanarReflectionBias("PlanarReflection Bias", Range(0.0, 1.0)) = 0.0
        _ReflectionDisortDistance("PlanarReflection Disort Distance", float) = 0.3
        //[Header((Refraction))]
        //[Space(5)]
        //_RefractionIntensity("Refraction Intensity", Range(0.0, 1.0)) = 0.5
        //_RefractionArea("Refraction Area", Range(1.0, 10.0)) = 3.0

        [Header(Foam ________________________________________________________________________________________________________________)]
        [Space(10)]
        _FoamColor("Foam Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_FoamTexture("Foam Texture", 2D) = "black"{}
        [Header(Tilling(XY) Speed1(Z) Speed2(W))]
        [Space(5)]
        _FoamProperties("Foam Properties", Vector) = (1.0, 1.0, 1.0, 0.5)
        _FoamRange("Foam Range", Range(0.0, 1.0)) = 0.0
		_FoamOffset("Foam Offset", Range(0.0 , 1.0)) = 0.0
		_FoamIntensityadd("Foam Intensity Add", Range(0.0, 1.0)) = 0.0

        [Header(Caustics ________________________________________________________________________________________________________________)]
        [Space(10)]
        [NoScaleOffset]_CausticsTexture("Caustics Texture", 2D) = "black"{}
        [Header(Tilling(XY) Intensity(Z) Speed(W))]
        [Space(5)]
        _CausticsProperties("Caustics Properties", Vector) = (1.0, 1.0, 0.6, 0.1)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
			Cull Back ZWrite Off ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma shader_feature_local _ACES_ON

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 pos_screen : TEXCOORD0;
                float4 pos_world : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float3 tangent_world : TEXCOORD3;
                float3 binormal_world : TEXCOORD4;
            };

            v2f vert (appdata v)
            {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.tangent_world = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w);
                // 计算屏幕空间坐标
				o.pos_screen = ComputeScreenPos(o.pos);
				return o;
            }

            float3 NormalBlend(float3 normalA, float3 normalB)
            {
                return normalize(float3(normalA.xy + normalB.xy, normalA.z * normalB.z));
            }

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

            uniform sampler2D _CameraDepthTexture, _SmallRipple, _BigRipple, _ReflectionTex, _FoamTexture, _CausticsTexture;
			uniform float4 _CameraDepthTexture_TexelSize, _ShallowColor, _DeepColor, _FoamColor, _FresnelColor,
                           _SmallRippleProperties, _BigRippleProperties, _CausticsProperties, _FoamProperties;
            uniform float _DeepRange, _DeepOpacity, _FresnelIntensity, _PlanarReflectionIntensity, _PlanarReflectionArea,
                          _PlanarReflectionBias, _ReflectionDisortDistance, _CausticsTilling, _CausticsIntensity, _CausticsArea,
                          _FoamIntensity, _FoamRange, _FoamOffset, _FoamIntensityadd;

            float4 frag (v2f i) : SV_Target
            {
// Reconstruct World Position From Depth 【深度重建世界坐标】----------------------------------------------------------------------------------------- //
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
                // 浅水区/深水区遮罩
                float depth_water = saturate(i.pos_world.y - worldPosFromDepth.y);
                float depth_lerp = saturate(exp(-depth_water / _DeepRange));
                // 浅水区/深水区颜色
                float3 color_water = lerp(_DeepColor, _ShallowColor, depth_lerp);
                float alpha_water = lerp(0.0, _DeepOpacity, 1.0 - depth_lerp);
// -------------------------------------------------------------------------------------------------------------------------------- //
                // small tilling1(XY) intensity1(Z) speed1(W)
                float2 smallrippleUV = _SmallRippleProperties.xy * i.pos_world.xz;
                float smallrippleIntensity = _SmallRippleProperties.z * 0.01;
                float smallrippleSpeed = frac(_SmallRippleProperties.w * _Time.y);
                float3 smallnormal1 = UnpackNormalWithScale(tex2D(_SmallRipple, smallrippleUV + smallrippleSpeed), smallrippleIntensity);
                float3 smallnormal2 = UnpackNormalWithScale(tex2D(_SmallRipple, -smallrippleUV + smallrippleSpeed), smallrippleIntensity);
                float3 smallblend = NormalBlend(smallnormal1, smallnormal2);
                // big tilling1(XY) intensity1(Z) speed1(W)
                float2 bigrippleUV = _BigRippleProperties.xy * i.pos_world.xz;
                float bigrippleIntensity = _BigRippleProperties.z * 0.01;
                float bigrippleSpeed = frac(_BigRippleProperties.w * _Time.y);
                float3 bignormal1 = UnpackNormalWithScale(tex2D(_BigRipple, bigrippleUV + bigrippleSpeed), bigrippleIntensity);
                float3 bignormal2 = UnpackNormalWithScale(tex2D(_BigRipple, -bigrippleUV + bigrippleSpeed), bigrippleIntensity);
                float3 bigblend = NormalBlend(bignormal1, bignormal2);
                float3 normalblend = NormalBlend(smallblend, bigblend);
                // 构建 TBN 矩阵
                float3x3 matrix_TBN = float3x3(i.tangent_world, i.binormal_world, i.normal_world);
                float3 surfacenormal_world = normalize(mul(normalblend, matrix_TBN));
// -------------------------------------------------------------------------------------------------------------------------------- //
                // 菲涅尔
                float3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world.xyz);
                float fresnelfractor = 1.0 - abs(dot(surfacenormal_world, view_world));
                fresnelfractor = saturate(pow(fresnelfractor, _PlanarReflectionArea) * _PlanarReflectionIntensity + _PlanarReflectionBias);
                float3 color_fresnel = fresnelfractor * _FresnelColor * _FresnelIntensity;
// -------------------------------------------------------------------------------------------------------------------------------- //
                // 平面反射
                float2 pidiUV = screenPos.xy + lerp(float3(0.0, 0.0, 1.0), normalblend, saturate(fresnelfractor * _ReflectionDisortDistance)).xy;
                float3 pidi = tex2D(_ReflectionTex, pidiUV);
// -------------------------------------------------------------------------------------------------------------------------------- //
                // 泡沫 Foam
                // Foam tilling1(XY) speed1(Z) speed2(W)
                float2 foamUV = i.pos_world.xz * _FoamProperties.xy;
                float foamSpeed1 = frac(_FoamProperties.z * _Time.y * 0.1);
                float foamSpeed2 = frac(_FoamProperties.w * _Time.y * 0.1);
                float foam1 = tex2D(_FoamTexture, foamUV + foamSpeed1).r;
                float foam2 = tex2D(_FoamTexture, -foamUV + foamSpeed2).r;
                float foamFactor = max(0.01, min(foam1, foam2));
                float foamRange = 1.0 - saturate(depth_water / _FoamRange + _FoamOffset);
                float foamMask = saturate(step(foamFactor, foamRange) * (foamRange + _FoamIntensityadd));
                float3 color_foam = foamMask * _FoamColor * 2.0;
// -------------------------------------------------------------------------------------------------------------------------------- //
                // 焦散 Caustics
                // caustics tilling1(XY) intensity1(Z) speed1(W)
                float2 causticsUV = worldPosFromDepth.xz * _CausticsProperties.xy;
                float causticsIntensity = _CausticsProperties.z;
                float causticsSpeed = frac(_CausticsProperties.w * _Time.y);
                float3 caustics1 = tex2D(_CausticsTexture, causticsUV + causticsSpeed);
                float3 caustics2 = tex2D(_CausticsTexture, -causticsUV + causticsSpeed);
                float3 color_caustics = min(caustics1, caustics2) * causticsIntensity;
// -------------------------------------------------------------------------------------------------------------------------------- //
                // Final Color
                float3 color_top = lerp(color_water, color_fresnel + pidi, fresnelfractor) * _LightColor0.rgb * 0.5;
                float3 color_under = color_caustics * alpha_water;

                float ndotl = max(0.0, dot(surfacenormal_world, _WorldSpaceLightPos0.xyz));
                float3 finalcolor = lerp(color_top, color_under, depth_lerp) + color_foam;
                finalcolor *= ndotl;

                #ifdef _ACES_ON
                finalcolor = ACES_Tonemapping(finalcolor);
                #else
                finalcolor = finalcolor;
                #endif
// -------------------------------------------------------------------------------------------------------------------------------- //
				return float4(finalcolor, alpha_water);
            }
            ENDCG
        }
    }
}
