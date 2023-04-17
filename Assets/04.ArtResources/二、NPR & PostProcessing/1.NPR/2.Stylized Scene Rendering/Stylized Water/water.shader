// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "water"
{
	Properties
	{
		_ShallowColor("Shallow Color", Color) = (1,1,1,0)
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_DeepRange("Deep Range", Range( 0.1 , 1)) = 0.1
		_DeepOpacity("Deep Opacity", Range( 0 , 1)) = 0
		[NoScaleOffset][Normal]_RippleNormal("Ripple Normal", 2D) = "bump" {}
		[Header(xy(UV)z(intensity)w(speed))]_RippleTillingandOffset("Ripple Tilling and Offset", Vector) = (0.5,0.5,0.5,0.1)
		[NoScaleOffset][Normal]_LargeRippleNormal("Large Ripple Normal", 2D) = "bump" {}
		[Header(xy(UV)z(intensity)w(speed))]_Ripple2TillingandOffset("Ripple2 Tilling and Offset", Vector) = (0.5,0.5,0.5,0.1)
		_FresnelColor("Fresnel Color", Color) = (0,0,0,0)
		_FresnelIntensity("Fresnel Intensity", Range( 0 , 1)) = 0
		[NoScaleOffset]_ReflectionTex("ReflectionTex", 2D) = "black" {}
		_ReflectionIntensity("Reflection Intensity", Range( 0 , 1)) = 1
		_ReflectionPower("Reflection Power", Range( 1 , 10)) = 3
		_ReflectionBias("Reflection Bias", Range( 0 , 1)) = 0
		_ReflectionDisortDistance("Reflection Disort Distance", Float) = 1
		[NoScaleOffset]_Caustics("Caustics", 2D) = "black" {}
		_CausticsTilling("Caustics Tilling", Float) = 0.1
		_CausticsIntensity("Caustics Intensity", Range( 0 , 1)) = 0.5
		_FoamColor("Foam Color", Color) = (1,1,1,0)
		[NoScaleOffset]_Foam("Foam", 2D) = "white" {}
		_TillingXYSpeed1ZSpeed2W("Tilling(XY) Speed1(Z)Speed2(W)", Vector) = (1,1,1,1)
		_FoamRange("Foam Range", Range( 0 , 1)) = 0
		_FoamOffset("Foam Offset", Range( 0 , 1)) = 0
		_FoamIntensityadd("Foam Intensity add", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma only_renderers d3d11 
		#pragma surface surf Unlit keepalpha exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float4 _FoamColor;
		uniform sampler2D _Foam;
		uniform float4 _TillingXYSpeed1ZSpeed2W;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _FoamRange;
		uniform float _FoamOffset;
		uniform float _FoamIntensityadd;
		uniform float4 _DeepColor;
		uniform float4 _ShallowColor;
		uniform float _DeepRange;
		uniform sampler2D _ReflectionTex;
		uniform sampler2D _RippleNormal;
		uniform float4 _RippleTillingandOffset;
		uniform sampler2D _LargeRippleNormal;
		uniform float4 _Ripple2TillingandOffset;
		uniform float _ReflectionPower;
		uniform float _ReflectionIntensity;
		uniform float _ReflectionBias;
		uniform float _ReflectionDisortDistance;
		uniform float _FresnelIntensity;
		uniform float4 _FresnelColor;
		uniform sampler2D _Caustics;
		uniform float _CausticsTilling;
		uniform float _CausticsIntensity;
		uniform float _DeepOpacity;


		float2 UnStereo( float2 UV )
		{
			#if UNITY_SINGLE_PASS_STEREO
			float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
			UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
			#endif
			return UV;
		}


		float3 InvertDepthDir72_g1( float3 In )
		{
			float3 result = In;
			#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
			result *= float3(1,1,-1);
			#endif
			return result;
		}


		inline float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 PosWS200 = ase_worldPos;
			float2 appendResult250 = (float2(_TillingXYSpeed1ZSpeed2W.x , _TillingXYSpeed1ZSpeed2W.y));
			float2 FoamUV253 = ( (PosWS200).xz * appendResult250 );
			float mulTime255 = _Time.y * ( _TillingXYSpeed1ZSpeed2W.z * 0.1 );
			float FoamSpeed1275 = frac( mulTime255 );
			float mulTime287 = _Time.y * ( _TillingXYSpeed1ZSpeed2W.w * 0.1 );
			float FoamSpeed2289 = frac( mulTime287 );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 UV22_g3 = ase_screenPosNorm.xy;
			float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
			float2 break64_g1 = localUnStereo22_g3;
			float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
			#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
			#else
				float staticSwitch38_g1 = clampDepth69_g1;
			#endif
			float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
			float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
			float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
			float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
			float3 In72_g1 = temp_output_46_0_g1;
			float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
			float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));
			float3 WorldPosFromDepth3 = (mul( unity_CameraToWorld, appendResult49_g1 )).xyz;
			float WaterDepth7 = saturate( ( (PosWS200).y - (WorldPosFromDepth3).y ) );
			float FoamRange259 = ( WaterDepth7 / _FoamRange );
			float temp_output_233_0 = ( 1.0 - saturate( ( FoamRange259 + _FoamOffset ) ) );
			float4 FoamColor218 = ( _FoamColor * ( step( max( min( tex2D( _Foam, ( FoamUV253 + FoamSpeed1275 ) ).r , tex2D( _Foam, ( -FoamUV253 + FoamSpeed2289 ) ).r ) , 0.01 ) , temp_output_233_0 ) * ( temp_output_233_0 + _FoamIntensityadd ) ) );
			float DepthLerp21 = saturate( exp( ( -WaterDepth7 / _DeepRange ) ) );
			float4 lerpResult17 = lerp( _DeepColor , _ShallowColor , DepthLerp21);
			float4 WaterColor18 = lerpResult17;
			float2 appendResult354 = (float2(_RippleTillingandOffset.x , _RippleTillingandOffset.y));
			float2 RippleUV72 = ( appendResult354 * (PosWS200).xz );
			float mulTime58 = _Time.y * _RippleTillingandOffset.w;
			float Speed169 = frac( mulTime58 );
			float Ripple1Scale25 = ( _RippleTillingandOffset.z * 0.01 );
			float3 SmallNormal178 = UnpackScaleNormal( tex2D( _RippleNormal, ( RippleUV72 + Speed169 ) ), Ripple1Scale25 );
			float3 SmallNormal277 = UnpackScaleNormal( tex2D( _RippleNormal, ( -RippleUV72 + Speed169 ) ), Ripple1Scale25 );
			float3 SmallNormal382 = BlendNormals( SmallNormal178 , SmallNormal277 );
			float2 appendResult355 = (float2(_Ripple2TillingandOffset.x , _Ripple2TillingandOffset.y));
			float2 RippleUV2352 = ( appendResult355 * (PosWS200).xz );
			float mulTime357 = _Time.y * _Ripple2TillingandOffset.w;
			float Speed2358 = frac( mulTime357 );
			float Rilpple2Scale360 = ( _Ripple2TillingandOffset.z * 0.01 );
			float3 BigNormal1365 = UnpackScaleNormal( tex2D( _LargeRippleNormal, ( RippleUV2352 + Speed2358 ) ), Rilpple2Scale360 );
			float3 BigNormal2373 = UnpackScaleNormal( tex2D( _LargeRippleNormal, ( -RippleUV2352 + Speed2358 ) ), Rilpple2Scale360 );
			float3 BigNormal378 = BlendNormals( BigNormal1365 , BigNormal2373 );
			float3 normalizeResult381 = ASESafeNormalize( BlendNormals( SmallNormal382 , BigNormal378 ) );
			float3 SurfaceNormal28 = normalizeResult381;
			float3 WorldNormal93 = normalize( (WorldNormalVector( i , SurfaceNormal28 )) );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 V168 = ase_worldViewDir;
			float dotResult37 = dot( WorldNormal93 , V168 );
			float saferPower41 = abs( ( 1.0 - abs( dotResult37 ) ) );
			float FresnelMask49 = saturate( ( ( pow( saferPower41 , _ReflectionPower ) * _ReflectionIntensity ) + _ReflectionBias ) );
			float3 lerpResult300 = lerp( float3(0,0,1) , SurfaceNormal28 , saturate( ( FresnelMask49 * _ReflectionDisortDistance ) ));
			float4 ReflectionColor34 = ( tex2D( _ReflectionTex, ( (lerpResult300).xy + (ase_screenPosNorm).xy ) ) * FresnelMask49 );
			float4 FresnelColor342 = ( _FresnelIntensity * _FresnelColor * FresnelMask49 );
			float4 lerpResult315 = lerp( WaterColor18 , ( ReflectionColor34 + FresnelColor342 ) , FresnelMask49);
			float2 CausticsUV110 = ( (WorldPosFromDepth3).xz * _CausticsTilling );
			float4 CausticsColor85 = ( min( tex2D( _Caustics, ( CausticsUV110 + Speed169 ) ) , tex2D( _Caustics, ( -CausticsUV110 + Speed169 ) ) ) * _CausticsIntensity );
			float4 lerpResult91 = lerp( lerpResult315 , CausticsColor85 , DepthLerp21);
			float4 temp_output_182_0 = ( ( 2.0 * FoamColor218 ) + lerpResult91 );
			o.Emission = (temp_output_182_0).rgb;
			float lerpResult193 = lerp( 0.0 , _DeepOpacity , ( 1.0 - DepthLerp21 ));
			o.Alpha = lerpResult193;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.LerpOp;91;-748.5642,22.74982;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;193;-341.5568,324.394;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;-559.0585,416.7516;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-755.327,411.2511;Inherit;False;21;DepthLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;204;-201.0566,129.5127;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;234;361.0018,1956.714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;35.00191,2004.714;Inherit;False;Property;_FoamOffset;Foam Offset;25;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;236;494.0019,1956.714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;233;642.0018,1956.714;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-289.6537,1905.894;Inherit;False;7;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;232;-43.98747,1910.652;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;105.7753,1906.688;Inherit;False;FoamRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;254;177.8632,1556.919;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;277;168.729,1747.573;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-21.01318,1603.94;Inherit;False;275;FoamSpeed1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;280;-3.270996,1719.573;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;-189.271,1714.573;Inherit;False;253;FoamUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;250;196.439,1238.623;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;251;365.439,1167.623;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-5.938058,1162.892;Inherit;False;200;PosWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;223;185.0618,1162.892;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;241;946.0328,1933.645;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;1132.29,1934.288;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;244;1062.614,1765.472;Inherit;False;Property;_FoamColor;Foam Color;21;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;245;1338.614,1770.672;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;249;-122.561,1236.623;Inherit;False;Property;_TillingXYSpeed1ZSpeed2W;Tilling(XY) Speed1(Z)Speed2(W);23;0;Create;True;0;0;0;False;0;False;1,1,1,1;2,2,-1,0.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;364.062,1287.892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;271;507.7914,1288.003;Inherit;False;FLOAT;1;0;FLOAT;0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;255;646.3971,1287.789;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;274;828.7909,1288.003;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;285;364.5934,1379.204;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;286;508.3228,1379.315;Inherit;False;FLOAT;1;0;FLOAT;0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;287;646.9285,1379.101;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;288;829.3223,1379.315;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;278;-61.271,1790.573;Inherit;False;289;FoamSpeed2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;276;336.4461,1719.844;Inherit;True;Property;_Foam1;Foam;22;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;d11681584e42df34c9e335594adedd86;True;0;False;black;Auto;False;Instance;214;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;214;338.7381,1528.978;Inherit;True;Property;_Foam;Foam;22;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;d11681584e42df34c9e335594adedd86;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;237;945.0018,2027.714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;298;831.0171,1725.032;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;296;677.6865,1725.535;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;253;523.3971,1162.789;Inherit;False;FoamUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-1236.865,-127.5861;Inherit;False;18;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;315;-969.4402,-72.9207;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-577.0696,-233.4983;Inherit;False;99;NL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-261.2522,-229.1409;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-940.4412,-247.1955;Inherit;False;Constant;_Float1;Float 1;22;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;-758.4412,-187.1955;Inherit;False;2;2;0;FLOAT;1;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;219;-975.1208,-170.8554;Inherit;False;218;FoamColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-2550.032,2255.279;Inherit;False;85;CausticsColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-2277.032,2294.279;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;-2916.621,2507.749;Inherit;False;28;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition;123;-2937.374,2340.38;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-2668.621,2345.749;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;122;-2521.374,2341.38;Inherit;False;Global;_GrabScreen0;Grab Screen 0;14;0;Create;True;0;0;0;False;0;False;Object;-1;False;True;False;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2113.902,2288.53;Inherit;False;UnderColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-1547.44,-69.92068;Inherit;False;34;ReflectionColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;-1529.923,3.763702;Inherit;False;342;FresnelColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-1180.923,-42.23627;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;312;-1235.687,63.12524;Inherit;False;49;FresnelMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-678.5568,342.3939;Inherit;False;Property;_DeepOpacity;Deep Opacity;4;0;Create;True;0;0;0;False;0;False;0;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;350;-9127.564,-1089.471;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;-9308.164,-1089.371;Inherit;False;200;PosWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;351;-8918.484,-1106.7;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;352;-8765.572,-1111.249;Inherit;False;RippleUV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;355;-9115.768,-1182.991;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;347;-9621.516,-1210.813;Inherit;False;Property;_Ripple2TillingandOffset;Ripple2 Tilling and Offset;8;1;[Header];Create;True;1;xy(UV)z(intensity)w(speed);0;0;False;0;False;0.5,0.5,0.5,0.1;0.2,0.2,5,0.05;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;356;-9123.798,-1011.33;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;357;-9303.768,-1011.505;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-8982.023,-1016.618;Inherit;False;Speed2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;353;-8506.766,-1034.357;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;360;-8582.821,-943.0804;Inherit;False;Rilpple2Scale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;359;-8734.821,-938.0804;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-8945.821,-921.0804;Inherit;False;Constant;_Float3;Float 3;34;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;364;-9047.479,-950.2034;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;362;-8791.821,-944.0804;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;363;-9352.82,-967.0804;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;346;-8324.553,-1062.514;Inherit;True;Property;_LargeRippleNormal;Large Ripple Normal;7;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;-1;None;03acb84d1a5645d4389745b5c949902b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;369;-8729.145,-804.8403;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;368;-8930.145,-809.8403;Inherit;False;352;RippleUV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;371;-8768.145,-736.8403;Inherit;False;358;Speed2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;370;-8547.145,-753.8403;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;366;-8346.282,-780.8263;Inherit;True;Property;_TextureSample2;Texture Sample 2;7;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;346;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;365;-8010.329,-1062.758;Inherit;False;BigNormal1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;373;-8030.035,-781.0233;Inherit;False;BigNormal2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;372;-8615.31,-663.8993;Inherit;False;360;Rilpple2Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-8000.639,-970.0404;Inherit;False;365;BigNormal1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;-8004.639,-893.0404;Inherit;False;373;BigNormal2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;378;-7395.637,-949.0404;Inherit;False;BigNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;81;-7649.046,-1829.388;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-7858.047,-1783.388;Inherit;False;77;SmallNormal2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-7858.047,-1857.388;Inherit;False;78;SmallNormal1;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-7868.958,-2008.818;Inherit;False;SmallNormal1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;382;-7272.415,-1834.686;Inherit;False;SmallNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-8745.359,-1806.227;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-8567.359,-1875.226;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-8740.021,-2052.699;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-8339.898,-1981.973;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;23;-8173.391,-2009.181;Inherit;True;Property;_RippleNormal;Ripple Normal;5;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;-1;None;ed0a7594614aee14290d2411e05bd99e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;61;-9491.738,-2027.547;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-9287.956,-2032.669;Inherit;False;PosWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;27;-9019.21,-2033.407;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;121;-8726.962,-1661.316;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-8917.884,-1666.349;Inherit;False;72;RippleUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-8536.971,-1600.326;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;67;-8359.94,-1626.244;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Instance;23;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;76;-8595.604,-1502.603;Inherit;False;25;Ripple1Scale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;154;-9324.481,-2194.802;Inherit;False;Property;_RippleTillingandOffset;Ripple Tilling and Offset;6;1;[Header];Create;True;1;xy(UV)z(intensity)w(speed);0;0;False;0;False;0.5,0.5,0.5,0.1;0.4,0.4,3,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-8593.752,-2056.954;Inherit;False;RippleUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;354;-9008.334,-2165.938;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;59;-8725.252,-1959.924;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;58;-8905.223,-1960.099;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-8591.898,-1964.973;Inherit;False;Speed1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-8412.966,-1880.509;Inherit;False;Ripple1Scale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-8053.215,-1626.179;Inherit;False;SmallNormal2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;375;-7779.638,-944.0404;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;37;-8800.992,1043.816;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;39;-8660.992,1043.816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;40;-8528.993,1043.816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-8647.992,1113.816;Inherit;False;Property;_ReflectionPower;Reflection Power;15;0;Create;True;0;0;0;False;0;False;3;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;41;-8351.99,1066.816;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-8139.993,1106.816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-8473.992,1182.817;Inherit;False;Property;_ReflectionIntensity;Reflection Intensity;14;0;Create;True;0;0;0;False;0;False;1;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;38;-9222.991,1137.808;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-9042.378,1137.302;Inherit;False;V;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-9046.766,1039.127;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;342;-7256.205,974.8943;Inherit;False;FresnelColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-7950.993,1166.816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;-7813.993,1166.816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-7667.021,1162.23;Inherit;False;FresnelMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;341;-7691.205,998.8943;Inherit;False;Property;_FresnelColor;Fresnel Color;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.3882346,0.7490196,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;340;-7410.205,979.8943;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-9620.991,1038.816;Inherit;False;28;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;35;-9400.745,1043.762;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;47;-8275.991,1255.774;Inherit;False;Property;_ReflectionBias;Reflection Bias;16;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;345;-7741.933,923.8875;Inherit;False;Property;_FresnelIntensity;Fresnel Intensity;12;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;105;-8502.559,1787.761;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-8365.464,1782.5;Inherit;False;NL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-8904.876,1839.895;Inherit;False;L;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;170;-8712.752,2113.443;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;172;-8559.808,2108.133;Inherit;False;H;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;177;-8573.117,2379.07;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;179;-8414.446,2447.356;Inherit;False;Property;_SpecularColor;Specular Color;9;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;-8162.309,2379.475;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;174;-8908.116,2379.07;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;-9111.116,2397.07;Inherit;False;172;H;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;185;-9213.035,2469.411;Inherit;False;Property;_SpecularRange;Specular Range;10;0;Create;True;0;0;0;False;0;False;0;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-7663.074,-2939.879;Inherit;False;Property;_ShallowColor;Shallow Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.3450978,0.7843137,0.4191585,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;17;-7384.009,-2957.495;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-7201.794,-2962.167;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-8073.082,-2770.366;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;10;-7942.082,-2770.366;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;14;-7809.161,-2769.856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-7657.635,-2775.114;Inherit;False;DepthLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;-7664.984,-3106.894;Inherit;False;Property;_DeepColor;Deep Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1176467,0.6198249,0.7058823,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;13;-8232.081,-2770.365;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-8373.081,-2702.365;Inherit;False;Property;_DeepRange;Deep Range;3;0;Create;True;0;0;0;False;0;False;0.1;0.2;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-8427.313,-2775.706;Inherit;False;7;WaterDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;2;-8801.161,-2869.568;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;3;-8633.072,-2869.905;Inherit;False;WorldPosFromDepth;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;4;-8384.072,-2869.905;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;203;-8383.477,-2943.441;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-8579.476,-2943.441;Inherit;False;200;PosWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1;-9163.996,-2864.302;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;5;-8187.077,-2887.905;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;8;-8031.122,-2887.476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-7517.524,34.06659;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;33;-8228.395,-59.54752;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;31;-8228.916,21.30255;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-8041.916,-27.69742;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;30;-8434.214,21.51752;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;301;-8814.942,-179.2575;Inherit;False;Constant;_Vector0;Vector 0;22;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;300;-8575.155,-55.28207;Inherit;False;3;0;FLOAT3;0,0,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-8947.268,34.32074;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;308;-8793.269,34.32074;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-7903.294,-55.32639;Inherit;True;Property;_ReflectionTex;ReflectionTex;13;1;[NoScaleOffset];Create;True;0;0;0;True;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;50;-7795.524,133.0663;Inherit;False;49;FresnelMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;-9162.044,-21.87262;Inherit;False;49;FresnelMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-7352.89,29.39251;Inherit;False;ReflectionColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-9225.269,52.32073;Inherit;False;Property;_ReflectionDisortDistance;Reflection Disort Distance;17;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-8764.891,-1582.073;Inherit;False;69;Speed1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-8852.732,-37.98203;Inherit;False;28;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;-7759.403,-1447.767;Inherit;False;382;SmallNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;-7747.403,-1374.767;Inherit;False;378;BigNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;380;-7523.402,-1425.767;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;381;-7305.402,-1425.767;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-7130.684,-1430.978;Inherit;False;SurfaceNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-8656.908,2944.738;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-8881.906,2939.738;Inherit;False;CausticsUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-9043.202,2944.559;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-9285.201,2962.559;Inherit;False;Property;_CausticsTilling;Caustics Tilling;19;0;Create;True;0;0;0;False;0;False;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;84;-9249.201,2889.559;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;113;-8509.552,3107.961;Inherit;True;Property;_TextureSample1;Texture Sample 1;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;82;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-8645.703,3135.72;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMinOpNode;119;-8122.352,3025.042;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;120;-8815.352,3137.042;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-8124.322,3124.594;Inherit;False;Property;_CausticsIntensity;Caustics Intensity;20;0;Create;True;0;0;0;False;0;False;0.5;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-7831.321,3024.594;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;82;-8510.304,2916.798;Inherit;True;Property;_Caustics;Caustics;18;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;f42dc2ba4d2629a44a363c41bb6cf328;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;116;-8854.287,3204.807;Inherit;False;69;Speed1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-9005.938,3131.918;Inherit;False;110;CausticsUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-9498.855,2889.734;Inherit;False;3;WorldPosFromDepth;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-8851.906,3011.738;Inherit;False;69;Speed1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-7672.046,3019.239;Inherit;False;CausticsColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-1006.357,111.9348;Inherit;False;85;CausticsColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-7877.452,-2892.392;Inherit;False;WaterDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-987.5642,189.7498;Inherit;False;21;DepthLerp;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1175.958,174.4833;Inherit;False;129;UnderColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;289;966.7993,1373.666;Inherit;False;FoamSpeed2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;275;966.2679,1283.354;Inherit;False;FoamSpeed1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;198;-379.0435,1981.943;Inherit;False;Property;_FoamRange;Foam Range;24;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;521.0018,2045.714;Inherit;False;Property;_FoamIntensityadd;Foam Intensity add;26;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-9.013184,1529.94;Inherit;False;253;FoamUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;1500.807,1764.801;Inherit;False;FoamColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;141.2458,72.36624;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;water;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;False;Back;2;False;;3;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;ForwardOnly;1;d3d11;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;2;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-9140.116,2321.07;Inherit;False;28;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;395;-694.6318,214.7129;Inherit;False;181;SpecularColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-8919.035,2474.411;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-8927.3,2084.766;Inherit;False;168;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;96;-9154.464,1845.5;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;184;-8733.035,2379.411;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-8411.116,2374.07;Inherit;False;Blinphong;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;95;-8667.464,1787.5;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-8895.463,1757.5;Inherit;False;28;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-8928.36,2158.054;Inherit;False;167;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;-8321.297,2036.837;Inherit;False;28;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;396;-8086.586,1989.164;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;400;-7906.297,1985.837;Inherit;False;r;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;402;-7873.297,2075.837;Inherit;False;168;V;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;401;-7624.297,2025.837;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;404;-7468.297,2025.837;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;33.98;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;406;-7859.731,2172.49;Inherit;False;Constant;_Vector1;Vector 1;27;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;408;-7216.731,2172.49;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;407;-7504.731,2248.49;Inherit;False;Constant;_Float2;Float 2;27;0;Create;True;0;0;0;False;0;False;20.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;399;-8440.297,1943.837;Inherit;False;167;L;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;409;-8248.731,1939.49;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;-7024.227,2171.088;Inherit;False;SpecularColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;182;-469.926,-13.18257;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;91;0;315;0
WireConnection;91;1;384;0
WireConnection;91;2;92;0
WireConnection;193;1;194;0
WireConnection;193;2;22;0
WireConnection;22;0;20;0
WireConnection;204;0;182;0
WireConnection;234;0;259;0
WireConnection;234;1;235;0
WireConnection;236;0;234;0
WireConnection;233;0;236;0
WireConnection;232;0;207;0
WireConnection;232;1;198;0
WireConnection;259;0;232;0
WireConnection;254;0;283;0
WireConnection;254;1;284;0
WireConnection;277;0;280;0
WireConnection;277;1;278;0
WireConnection;280;0;279;0
WireConnection;250;0;249;1
WireConnection;250;1;249;2
WireConnection;251;0;223;0
WireConnection;251;1;250;0
WireConnection;223;0;222;0
WireConnection;241;0;298;0
WireConnection;241;1;233;0
WireConnection;239;0;241;0
WireConnection;239;1;237;0
WireConnection;245;0;244;0
WireConnection;245;1;239;0
WireConnection;226;0;249;3
WireConnection;271;0;226;0
WireConnection;255;0;271;0
WireConnection;274;0;255;0
WireConnection;285;0;249;4
WireConnection;286;0;285;0
WireConnection;287;0;286;0
WireConnection;288;0;287;0
WireConnection;276;1;277;0
WireConnection;214;1;254;0
WireConnection;237;0;233;0
WireConnection;237;1;238;0
WireConnection;298;0;296;0
WireConnection;296;0;214;1
WireConnection;296;1;276;1
WireConnection;253;0;251;0
WireConnection;315;0;19;0
WireConnection;315;1;344;0
WireConnection;315;2;312;0
WireConnection;107;0;101;0
WireConnection;107;1;182;0
WireConnection;247;0;248;0
WireConnection;247;1;219;0
WireConnection;127;0;128;0
WireConnection;127;1;122;0
WireConnection;125;0;123;0
WireConnection;125;1;126;0
WireConnection;122;0;125;0
WireConnection;129;0;127;0
WireConnection;344;0;316;0
WireConnection;344;1;343;0
WireConnection;350;0;349;0
WireConnection;351;0;355;0
WireConnection;351;1;350;0
WireConnection;352;0;351;0
WireConnection;355;0;347;1
WireConnection;355;1;347;2
WireConnection;356;0;357;0
WireConnection;357;0;347;4
WireConnection;358;0;356;0
WireConnection;353;0;352;0
WireConnection;353;1;358;0
WireConnection;360;0;359;0
WireConnection;359;0;362;0
WireConnection;359;1;361;0
WireConnection;364;0;363;0
WireConnection;362;0;364;0
WireConnection;363;0;347;3
WireConnection;346;1;353;0
WireConnection;346;5;360;0
WireConnection;369;0;368;0
WireConnection;370;0;369;0
WireConnection;370;1;371;0
WireConnection;366;1;370;0
WireConnection;366;5;372;0
WireConnection;365;0;346;0
WireConnection;373;0;366;0
WireConnection;378;0;375;0
WireConnection;81;0;79;0
WireConnection;81;1;80;0
WireConnection;78;0;23;0
WireConnection;382;0;81;0
WireConnection;64;0;154;3
WireConnection;64;1;65;0
WireConnection;54;0;354;0
WireConnection;54;1;27;0
WireConnection;68;0;72;0
WireConnection;68;1;69;0
WireConnection;23;1;68;0
WireConnection;23;5;25;0
WireConnection;200;0;61;0
WireConnection;27;0;200;0
WireConnection;121;0;74;0
WireConnection;73;0;121;0
WireConnection;73;1;71;0
WireConnection;67;1;73;0
WireConnection;67;5;76;0
WireConnection;72;0;54;0
WireConnection;354;0;154;1
WireConnection;354;1;154;2
WireConnection;59;0;58;0
WireConnection;58;0;154;4
WireConnection;69;0;59;0
WireConnection;25;0;64;0
WireConnection;77;0;67;0
WireConnection;375;0;374;0
WireConnection;375;1;376;0
WireConnection;37;0;93;0
WireConnection;37;1;168;0
WireConnection;39;0;37;0
WireConnection;40;0;39;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;44;0;41;0
WireConnection;44;1;45;0
WireConnection;168;0;38;0
WireConnection;93;0;35;0
WireConnection;342;0;340;0
WireConnection;46;0;44;0
WireConnection;46;1;47;0
WireConnection;43;0;46;0
WireConnection;49;0;43;0
WireConnection;340;0;345;0
WireConnection;340;1;341;0
WireConnection;340;2;49;0
WireConnection;35;0;36;0
WireConnection;105;0;95;0
WireConnection;99;0;105;0
WireConnection;167;0;96;0
WireConnection;170;0;169;0
WireConnection;170;1;171;0
WireConnection;172;0;170;0
WireConnection;177;0;184;0
WireConnection;180;0;178;0
WireConnection;180;1;179;0
WireConnection;174;0;176;0
WireConnection;174;1;173;0
WireConnection;17;0;15;0
WireConnection;17;1;16;0
WireConnection;17;2;21;0
WireConnection;18;0;17;0
WireConnection;11;0;13;0
WireConnection;11;1;12;0
WireConnection;10;0;11;0
WireConnection;14;0;10;0
WireConnection;21;0;14;0
WireConnection;13;0;9;0
WireConnection;2;0;1;0
WireConnection;3;0;2;0
WireConnection;4;0;3;0
WireConnection;203;0;202;0
WireConnection;5;0;203;0
WireConnection;5;1;4;0
WireConnection;8;0;5;0
WireConnection;51;0;29;0
WireConnection;51;1;50;0
WireConnection;33;0;300;0
WireConnection;31;0;30;0
WireConnection;32;0;33;0
WireConnection;32;1;31;0
WireConnection;300;0;301;0
WireConnection;300;1;66;0
WireConnection;300;2;308;0
WireConnection;306;0;299;0
WireConnection;306;1;307;0
WireConnection;308;0;306;0
WireConnection;29;1;32;0
WireConnection;34;0;51;0
WireConnection;380;0;383;0
WireConnection;380;1;379;0
WireConnection;381;0;380;0
WireConnection;28;0;381;0
WireConnection;111;0;110;0
WireConnection;111;1;112;0
WireConnection;110;0;86;0
WireConnection;86;0;84;0
WireConnection;86;1;87;0
WireConnection;84;0;83;0
WireConnection;113;1;115;0
WireConnection;115;0;120;0
WireConnection;115;1;116;0
WireConnection;119;0;82;0
WireConnection;119;1;113;0
WireConnection;120;0;114;0
WireConnection;88;0;119;0
WireConnection;88;1;89;0
WireConnection;82;1;111;0
WireConnection;85;0;88;0
WireConnection;7;0;8;0
WireConnection;289;0;288;0
WireConnection;275;0;274;0
WireConnection;218;0;245;0
WireConnection;0;2;204;0
WireConnection;0;9;193;0
WireConnection;186;0;185;0
WireConnection;184;0;174;0
WireConnection;184;1;186;0
WireConnection;178;0;177;0
WireConnection;95;0;94;0
WireConnection;95;1;167;0
WireConnection;396;0;409;0
WireConnection;396;1;397;0
WireConnection;400;0;396;0
WireConnection;401;0;400;0
WireConnection;401;1;402;0
WireConnection;404;0;401;0
WireConnection;408;0;404;0
WireConnection;408;1;407;0
WireConnection;409;0;399;0
WireConnection;181;0;408;0
WireConnection;182;0;247;0
WireConnection;182;1;91;0
ASEEND*/
//CHKSM=A5A3F11AEEBD9AB829C67AE88C04A57FA78A97C6