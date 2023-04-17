// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZTY/PostProcess/Glitch"
{
	Properties
	{
		[HideInInspector][NoScaleOffset][SingleLineTexture]_MainTex("_MainTex", 2D) = "white" {}
		[Toggle]_GlitchOn("Glitch On", Float) = 0
		_GlitchIntensity("Glitch Intensity", Range( 0 , 0.1)) = 0
		_GlitchSeedSpeed("GlitchSeed Speed", Float) = 10
		[IntRange]_GlitchPI("Glitch PI", Range( 1 , 10)) = 1
		[IntRange]_GlitchSeed1Tilling("GlitchSeed1 Tilling", Range( 1 , 100)) = 1
		[IntRange]_GlitchSeed2Tilling("GlitchSeed2 Tilling", Range( 1 , 100)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 5.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest Always
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#define ASE_USING_SAMPLING_MACROS 1


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
			#endif//ASE Sampling Macros
			


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex);
			uniform float _GlitchSeed1Tilling;
			uniform float _GlitchSeedSpeed;
			uniform float _GlitchPI;
			uniform float _GlitchSeed2Tilling;
			uniform float _GlitchIntensity;
			uniform float _GlitchOn;
			SamplerState sampler_MainTex;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult32 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenUV45 = appendResult32;
				float2 temp_output_194_0 = ( floor( ( ScreenUV45 * _GlitchSeed1Tilling ) ) / _GlitchSeed1Tilling );
				float dotResult195 = dot( temp_output_194_0 , temp_output_194_0 );
				float mulTime276 = _Time.y * _GlitchSeedSpeed;
				float Speed318 = mulTime276;
				float2 temp_cast_0 = (( dotResult195 * floor( ( Speed318 % 1000.0 ) ) )).xx;
				float dotResult4_g12 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g12 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g12 ) * 43758.55 ) ));
				float WhiteNoise203 = saturate( lerpResult10_g12 );
				float saferPower286 = abs( WhiteNoise203 );
				float PI321 = ( _GlitchPI * UNITY_PI );
				float2 temp_output_304_0 = ( floor( ( ScreenUV45 * _GlitchSeed2Tilling ) ) / _GlitchSeed2Tilling );
				float dotResult305 = dot( temp_output_304_0 , temp_output_304_0 );
				float2 temp_cast_1 = (( dotResult305 * floor( ( Speed318 % 1000.0 ) ) )).xx;
				float dotResult4_g11 = dot( temp_cast_1 , float2( 12.9898,78.233 ) );
				float lerpResult10_g11 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g11 ) * 43758.55 ) ));
				float WhiteNoise312 = saturate( lerpResult10_g11 );
				float saferPower313 = abs( WhiteNoise312 );
				float GlitchNoise324 = ( saturate( ( pow( saferPower286 , PI321 ) + pow( saferPower313 , PI321 ) ) ) * _GlitchIntensity * _GlitchOn );
				float2 temp_cast_2 = (GlitchNoise324).xx;
				float2 temp_output_331_0 = ( ScreenUV45 - temp_cast_2 );
				float2 uv_MainTex1 = i.ase_texcoord2.xy;
				float2 temp_cast_3 = (GlitchNoise324).xx;
				float3 appendResult334 = (float3(SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, temp_output_331_0 ).r , SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, uv_MainTex1 ).g , SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, temp_output_331_0 ).b));
				float3 MainTexture104 = appendResult334;
				
				
				finalColor = float4( MainTexture104 , 0.0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19002
601.3334;384.6667;1878;812.3334;6143.596;-601.8183;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;274;-5435.349,338.9297;Inherit;False;633.6284;257;ScreenUV;3;31;32;45;;0,0,0,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;31;-5385.349,388.9297;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;337;-4793.656,338.654;Inherit;False;760.9399;241.7205;GlobalAmount;6;285;276;318;292;289;321;;0,0,0,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-5180.349,416.9298;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-4743.656,389.143;Inherit;False;Property;_GlitchSeedSpeed;GlitchSeed Speed;3;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;336;-5435.072,609.6835;Inherit;False;2604.567;540.7674;Noise;36;189;191;298;297;299;190;301;320;193;319;194;304;281;303;305;306;284;195;307;283;308;296;202;309;322;203;323;312;313;286;315;317;291;316;324;340;;0,0,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-5029.721,411.7797;Inherit;False;ScreenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;276;-4538.586,393.8354;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;-5284.65,866.118;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-5385.072,735.6833;Inherit;False;Property;_GlitchSeed1Tilling;GlitchSeed1 Tilling;5;1;[IntRange];Create;True;0;0;0;False;0;False;1;0;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-5285.072,659.6835;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;298;-5384.651,942.1179;Inherit;False;Property;_GlitchSeed2Tilling;GlitchSeed2 Tilling;6;1;[IntRange];Create;True;0;0;0;False;0;False;1;0;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;-5071.65,897.1182;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-5072.072,690.6835;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;-4350.474,388.654;Inherit;False;Speed;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-4980.384,806.2354;Inherit;False;318;Speed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;301;-4916.711,897.0469;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;-4981.918,1011.88;Inherit;False;318;Speed;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;193;-4917.131,690.6123;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleRemainderNode;303;-4791.936,1017.451;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;281;-4792.357,811.0168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;194;-4777.13,716.6123;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;304;-4776.708,923.0469;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;305;-4627.709,913.0469;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;284;-4624.566,810.7246;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;195;-4628.131,706.6123;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;306;-4624.146,1017.159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-4462.936,954.4512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;292;-4743.029,465.3745;Inherit;False;Property;_GlitchPI;Glitch PI;4;1;[IntRange];Create;True;0;0;0;False;0;False;1;0;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-4463.357,748.0166;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;308;-4322.708,954.0469;Inherit;False;Random Range;-1;;11;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;296;-4323.13,747.6123;Inherit;False;Random Range;-1;;12;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;289;-4459.029,470.3745;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;-4260.716,465.0081;Inherit;False;PI;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;202;-4139.39,748.0903;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;309;-4138.968,954.5249;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;-3993.968,949.5249;Inherit;False;WhiteNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-3963.963,820.5608;Inherit;False;321;PI;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-3994.389,743.0903;Inherit;False;WhiteNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;323;-3963.499,1028.526;Inherit;False;321;PI;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;313;-3750.232,979.2537;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;286;-3750.655,775.8191;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;315;-3527.962,867.9424;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;340;-3389.813,1037.178;Inherit;False;Property;_GlitchOn;Glitch On;1;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;291;-3385.883,867.996;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;317;-3518.016,963.0583;Inherit;False;Property;_GlitchIntensity;Glitch Intensity;2;0;Create;True;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;316;-3216.884,944.9615;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;324;-3065.507,940.2686;Inherit;False;GlitchNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;338;-5433.579,1163.37;Inherit;False;1253.046;657.9998;Append;8;335;331;1;333;334;330;104;329;;0,0,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;-5383.579,1490.529;Inherit;False;324;GlitchNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;330;-5375.989,1416.028;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;331;-5160.449,1445.901;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-4908.182,1401.743;Inherit;True;Property;_MainTex;_MainTex;0;3;[HideInInspector];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;335;-4907.664,1213.37;Inherit;True;Property;_TextureSample1;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;333;-4906.664,1591.37;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;334;-4568.169,1429.526;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-4408.533,1425.025;Inherit;False;MainTexture;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;-4112.813,1361.233;Inherit;False;104;MainTexture;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;24;-3915.449,1366.076;Float;False;True;-1;2;ASEMaterialInspector;100;3;ZTY/PostProcess/Glitch;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;;True;False;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;7;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;True;0
WireConnection;32;0;31;1
WireConnection;32;1;31;2
WireConnection;45;0;32;0
WireConnection;276;0;285;0
WireConnection;299;0;297;0
WireConnection;299;1;298;0
WireConnection;190;0;189;0
WireConnection;190;1;191;0
WireConnection;318;0;276;0
WireConnection;301;0;299;0
WireConnection;193;0;190;0
WireConnection;303;0;320;0
WireConnection;281;0;319;0
WireConnection;194;0;193;0
WireConnection;194;1;191;0
WireConnection;304;0;301;0
WireConnection;304;1;298;0
WireConnection;305;0;304;0
WireConnection;305;1;304;0
WireConnection;284;0;281;0
WireConnection;195;0;194;0
WireConnection;195;1;194;0
WireConnection;306;0;303;0
WireConnection;307;0;305;0
WireConnection;307;1;306;0
WireConnection;283;0;195;0
WireConnection;283;1;284;0
WireConnection;308;1;307;0
WireConnection;296;1;283;0
WireConnection;289;0;292;0
WireConnection;321;0;289;0
WireConnection;202;0;296;0
WireConnection;309;0;308;0
WireConnection;312;0;309;0
WireConnection;203;0;202;0
WireConnection;313;0;312;0
WireConnection;313;1;323;0
WireConnection;286;0;203;0
WireConnection;286;1;322;0
WireConnection;315;0;286;0
WireConnection;315;1;313;0
WireConnection;291;0;315;0
WireConnection;316;0;291;0
WireConnection;316;1;317;0
WireConnection;316;2;340;0
WireConnection;324;0;316;0
WireConnection;331;0;330;0
WireConnection;331;1;329;0
WireConnection;335;1;331;0
WireConnection;333;1;331;0
WireConnection;334;0;335;1
WireConnection;334;1;1;2
WireConnection;334;2;333;3
WireConnection;104;0;334;0
WireConnection;24;0;332;0
ASEEND*/
//CHKSM=DD9BD5BF91FB8CFA72E6A0EC6656FCC7141D047F