// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZTY/PostProcess/Distortion/BrokenScreen"
{
	Properties
	{
		[HideInInspector][NoScaleOffset][SingleLineTexture]_MainTex("_MainTex", 2D) = "white" {}
		_BrokenColor("Broken Color", Color) = (1,1,1,0)
		_BrokenScreenUV("BrokenScreenUV", Vector) = (2,1,-0.5,0)
		[NoScaleOffset]_BrokenScreen_Mask("BrokenScreen_Mask", 2D) = "white" {}
		_BrokenScreen_Normal("BrokenScreen_Normal", 2D) = "bump" {}
		_BrokenScreenIntensity("BrokenScreen Intensity", Range( 0 , 1)) = 1

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
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
			#endif//ASE Sampling Macros
			


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex);
			UNITY_DECLARE_TEX2D_NOSAMPLER(_BrokenScreen_Normal);
			uniform float4 _BrokenScreenUV;
			SamplerState sampler_BrokenScreen_Normal;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_BrokenScreen_Mask);
			SamplerState sampler_BrokenScreen_Mask;
			uniform float _BrokenScreenIntensity;
			SamplerState sampler_MainTex;
			uniform float4 _BrokenColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
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
				float2 ScreenUV217 = appendResult32;
				float2 appendResult211 = (float2(_BrokenScreenUV.x , _BrokenScreenUV.y));
				float2 appendResult212 = (float2(_BrokenScreenUV.z , _BrokenScreenUV.w));
				float2 BrokenUV45 = ( ( ScreenUV217 * appendResult211 ) + appendResult212 );
				float3 tex2DNode193 = UnpackNormal( SAMPLE_TEXTURE2D( _BrokenScreen_Normal, sampler_BrokenScreen_Normal, BrokenUV45 ) );
				float2 appendResult216 = (float2(tex2DNode193.r , tex2DNode193.g));
				float4 tex2DNode194 = SAMPLE_TEXTURE2D( _BrokenScreen_Mask, sampler_BrokenScreen_Mask, BrokenUV45 );
				float BrokenMask223 = ( tex2DNode194.r * _BrokenScreenIntensity );
				float2 lerpResult220 = lerp( ScreenUV217 , appendResult216 , BrokenMask223);
				float4 MainTexture104 = SAMPLE_TEXTURE2D( _MainTex, sampler_MainTex, lerpResult220 );
				float4 BrokenColor228 = ( tex2DNode194.r + ( BrokenMask223 * _BrokenColor ) );
				float4 lerpResult230 = lerp( MainTexture104 , BrokenColor228 , BrokenMask223);
				
				
				finalColor = lerpResult230;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;218;-4433.167,-367.5811;Inherit;False;1253.141;407.4516;BrokenUV;9;210;211;212;209;31;32;217;207;45;;0,0,0,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;31;-4383.167,-317.5811;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;210;-4173.734,-193.5837;Inherit;False;Property;_BrokenScreenUV;BrokenScreenUV;2;0;Create;True;0;0;0;False;0;False;2,1,-0.5,0;2,1,-0.5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;32;-4140.844,-289.7288;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;217;-3991.449,-294.5795;Inherit;False;ScreenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;211;-3926.65,-185.1295;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-3738.307,-248.2018;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;212;-3926.65,-93.12952;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;209;-3541.737,-115.258;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.85,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;235;-4433.537,53.73061;Inherit;False;1538.208;432.4951;BrokenColor;9;213;38;225;223;227;226;231;194;228;;0,0,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-3408.026,-119.9079;Inherit;False;BrokenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;-4383.537,126.67;Inherit;False;45;BrokenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;234;-4433.32,498.8764;Inherit;False;1558.414;337.2742;MainTexture;8;222;193;224;219;216;220;1;104;;0,0,0,1;0;0
Node;AmplifyShaderEditor.SamplerNode;194;-4197.596,103.7306;Inherit;True;Property;_BrokenScreen_Mask;BrokenScreen_Mask;3;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;0c88ce0cc567f614bac68dc356210808;0c88ce0cc567f614bac68dc356210808;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-4175.365,293.9852;Inherit;False;Property;_BrokenScreenIntensity;BrokenScreen Intensity;5;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-4383.32,620.0916;Inherit;False;45;BrokenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-3845.009,203.2258;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;193;-4195.154,597.5801;Inherit;True;Property;_BrokenScreen_Normal;BrokenScreen_Normal;4;0;Create;True;0;0;0;False;0;False;-1;0b9b0dd4263308b4098cb8174b2d5357;0b9b0dd4263308b4098cb8174b2d5357;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-3691.647,197.998;Inherit;False;BrokenMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;227;-3696.01,279.2258;Inherit;False;Property;_BrokenColor;Broken Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;219;-3875.081,548.8764;Inherit;False;217;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;216;-3836.31,625.1995;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;220;-3656.081,601.8764;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;-3441.01,231.2258;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;231;-3270.751,132.9776;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-3449.556,573.8738;Inherit;True;Property;_MainTex;_MainTex;0;3;[HideInInspector];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;228;-3123.329,128.2136;Inherit;False;BrokenColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-3102.904,573.2012;Inherit;False;MainTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;-2742.307,120.9749;Inherit;False;104;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-2740.667,198.0543;Inherit;False;228;BrokenColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-2738.306,272.8303;Inherit;False;223;BrokenMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;230;-2504.918,179.5357;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;24;-2323.206,179.9811;Float;False;True;-1;2;ASEMaterialInspector;100;5;ZTY/PostProcess/Distortion/BrokenScreen;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;;True;False;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;7;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;True;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;-3886.731,721.1507;Inherit;False;223;BrokenMask;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;32;0;31;1
WireConnection;32;1;31;2
WireConnection;217;0;32;0
WireConnection;211;0;210;1
WireConnection;211;1;210;2
WireConnection;207;0;217;0
WireConnection;207;1;211;0
WireConnection;212;0;210;3
WireConnection;212;1;210;4
WireConnection;209;0;207;0
WireConnection;209;1;212;0
WireConnection;45;0;209;0
WireConnection;194;1;213;0
WireConnection;225;0;194;1
WireConnection;225;1;38;0
WireConnection;193;1;222;0
WireConnection;223;0;225;0
WireConnection;216;0;193;1
WireConnection;216;1;193;2
WireConnection;220;0;219;0
WireConnection;220;1;216;0
WireConnection;220;2;224;0
WireConnection;226;0;223;0
WireConnection;226;1;227;0
WireConnection;231;0;194;1
WireConnection;231;1;226;0
WireConnection;1;1;220;0
WireConnection;228;0;231;0
WireConnection;104;0;1;0
WireConnection;230;0;188;0
WireConnection;230;1;229;0
WireConnection;230;2;233;0
WireConnection;24;0;230;0
ASEEND*/
//CHKSM=C9A973D40E50D98F6065386E388E0C63330FE7D5