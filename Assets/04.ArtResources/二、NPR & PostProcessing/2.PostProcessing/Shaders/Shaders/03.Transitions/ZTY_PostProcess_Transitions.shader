// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ZTY/PostProcess/Transitions"
{
	Properties
	{
		[HideInInspector][NoScaleOffset][SingleLineTexture]_MainTex("_MainTex", 2D) = "white" {}
		[KeywordEnum(Scan,Louver,Polar,Grid)] _TransitionsType("TransitionsType", Float) = 0
		_TransitionsAmount("Transitions Amount", Range( 0 , 1)) = 0
		_LuminanceIntensity("Luminance Intensity", Range( 0.5 , 3)) = 1
		_ScanEdgeColor("ScanEdge Color", Color) = (1,1,1,0)
		[Toggle]_ScanEdgeOn("ScanEdge On", Float) = 0
		_ScanEdgeWidth("ScanEdgeWidth", Range( 0 , 1)) = 0.2
		_ScanNoiseIntensity("ScanNoise Intensity", Range( 0 , 0.1)) = 0
		_ScanNoiseTilling("ScanNoise Tilling", Float) = 5
		[IntRange]_LouverNumber("Louver Number", Range( 0 , 10)) = 2
		[IntRange]_GridTilling("Grid Tilling", Range( 1 , 100)) = 10
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

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#pragma shader_feature_local _TRANSITIONSTYPE_SCAN _TRANSITIONSTYPE_LOUVER _TRANSITIONSTYPE_POLAR _TRANSITIONSTYPE_GRID


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

			uniform float _LuminanceIntensity;
			uniform sampler2D _MainTex;
			uniform float _ScanNoiseTilling;
			uniform float _ScanNoiseIntensity;
			uniform float _TransitionsAmount;
			uniform float _ScanEdgeWidth;
			uniform float _ScanEdgeOn;
			uniform float4 _ScanEdgeColor;
			uniform float _LouverNumber;
			uniform float _GridTilling;
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
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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
				float2 uv_MainTex1 = i.ase_texcoord1.xy;
				float4 MainTexture104 = tex2D( _MainTex, uv_MainTex1 );
				float luminance201 = Luminance(MainTexture104.rgb);
				float Luminance244 = ( _LuminanceIntensity * luminance201 );
				float4 temp_cast_1 = (Luminance244).xxxx;
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult32 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenUV45 = appendResult32;
				float simplePerlin2D72 = snoise( ScreenUV45*( _ScanNoiseTilling * 0.2 ) );
				simplePerlin2D72 = simplePerlin2D72*0.5 + 0.5;
				float lerpResult71 = lerp( (ScreenUV45).x , simplePerlin2D72 , _ScanNoiseIntensity);
				float ScanNoise286 = saturate( lerpResult71 );
				float TransAmount239 = _TransitionsAmount;
				float ScanMask89 = ( 1.0 - step( ScanNoise286 , TransAmount239 ) );
				float4 lerpResult205 = lerp( temp_cast_1 , MainTexture104 , ScanMask89);
				float4 ScanTrans212 = ( lerpResult205 + ( saturate( ( step( ScanNoise286 , ( TransAmount239 + ( _ScanEdgeWidth * 0.01 ) ) ) - step( ScanNoise286 , TransAmount239 ) ) ) * _ScanEdgeOn * _ScanEdgeColor ) );
				float4 temp_cast_2 = (Luminance244).xxxx;
				float LouverMask227 = saturate( step( frac( (( ScreenUV45 * _LouverNumber )).x ) , TransAmount239 ) );
				float4 lerpResult230 = lerp( MainTexture104 , temp_cast_2 , LouverMask227);
				float4 LouverTrans232 = lerpResult230;
				float4 temp_cast_3 = (Luminance244).xxxx;
				float2 CenteredUV15_g8 = ( ScreenUV45 - float2( 0.5,0.5 ) );
				float2 break17_g8 = CenteredUV15_g8;
				float2 appendResult23_g8 = (float2(( length( CenteredUV15_g8 ) * 1.0 * 2.0 ) , ( atan2( break17_g8.x , break17_g8.y ) * ( 1.0 / 6.28318548202515 ) * 1.0 )));
				float PolarMask260 = saturate( step( (0.0 + ((appendResult23_g8).y - -0.5) * (1.0 - 0.0) / (0.5 - -0.5)) , TransAmount239 ) );
				float4 lerpResult261 = lerp( MainTexture104 , temp_cast_3 , PolarMask260);
				float4 PolarTrans264 = lerpResult261;
				float4 temp_cast_4 = (Luminance244).xxxx;
				float2 break301 = ( floor( ( ScreenUV45 * _GridTilling ) ) / _GridTilling );
				float2 temp_cast_5 = (( ( break301.x + 0.01 ) * ( break301.y + 0.01 ) )).xx;
				float dotResult4_g6 = dot( temp_cast_5 , float2( 12.9898,78.233 ) );
				float lerpResult10_g6 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g6 ) * 43758.55 ) ));
				float GridMask311 = saturate( step( lerpResult10_g6 , TransAmount239 ) );
				float4 lerpResult312 = lerp( MainTexture104 , temp_cast_4 , GridMask311);
				float4 GridTrans315 = lerpResult312;
				#if defined(_TRANSITIONSTYPE_SCAN)
				float4 staticSwitch236 = ScanTrans212;
				#elif defined(_TRANSITIONSTYPE_LOUVER)
				float4 staticSwitch236 = LouverTrans232;
				#elif defined(_TRANSITIONSTYPE_POLAR)
				float4 staticSwitch236 = PolarTrans264;
				#elif defined(_TRANSITIONSTYPE_GRID)
				float4 staticSwitch236 = GridTrans315;
				#else
				float4 staticSwitch236 = ScanTrans212;
				#endif
				
				
				finalColor = staticSwitch236;
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
Node;AmplifyShaderEditor.CommentaryNode;274;-5435.349,338.9297;Inherit;False;633.6284;257;ScreenUV;3;31;32;45;;0,0,0,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;31;-5385.349,388.9297;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;32;-5180.349,416.9298;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;317;-5438.422,2172.558;Inherit;False;2447.048;387.1118;GridTrans;18;298;297;299;300;296;301;303;302;304;308;309;307;310;311;313;314;312;315;;0,0,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-5029.721,411.7797;Inherit;False;ScreenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;293;-5436.475,606.0827;Inherit;False;2412.028;748.6707;ScanTrans;30;212;290;205;284;89;283;245;200;282;280;207;275;278;100;277;287;249;286;281;276;279;76;71;93;70;72;62;94;39;295;;0,0,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-5386.475,807.808;Inherit;False;Property;_ScanNoiseTilling;ScanNoise Tilling;10;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;-5288.421,2264.425;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;298;-5388.422,2340.425;Inherit;False;Property;_GridTilling;Grid Tilling;12;1;[IntRange];Create;True;0;0;0;False;0;False;10;0;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;-5075.421,2295.425;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-5178.709,812.2548;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-5212.307,709.0481;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;300;-4920.481,2295.353;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-5080.404,904.907;Inherit;False;Property;_ScanNoiseIntensity;ScanNoise Intensity;9;0;Create;True;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;72;-4998.266,784.0639;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;70;-5005.293,708.9839;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;215;-4788.858,340.2133;Inherit;False;569.6511;255;MainTexture;2;104;1;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;248;-4588.716,89.29535;Inherit;False;581;165;TransAmount;2;238;239;;0,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;296;-4780.479,2321.353;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;251;-5437.952,1371.57;Inherit;False;1823.372;369.4418;LouverTrans;13;221;225;224;223;240;226;242;228;227;250;231;230;232;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;266;-5439.233,1754.532;Inherit;False;1930.919;405.734;PolarTrans;11;253;255;258;256;257;259;262;263;260;261;264;;0,0,0,1;0;0
Node;AmplifyShaderEditor.LerpOp;71;-4747.497,766.5759;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.04;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-4531.721,139.2954;Inherit;False;Property;_TransitionsAmount;Transitions Amount;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-4738.858,390.2132;Inherit;True;Property;_MainTex;_MainTex;0;3;[HideInInspector];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;301;-4640.134,2321.041;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;221;-5289.952,1521.419;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;239;-4235.716,139.2954;Inherit;False;TransAmount;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-5387.952,1599.419;Inherit;False;Property;_LouverNumber;Louver Number;11;1;[IntRange];Create;True;0;0;0;False;0;False;2;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;253;-5389.233,1878.267;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-4436.207,390.5407;Inherit;False;MainTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;76;-4583.497,766.5759;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;279;-4822.883,1077.332;Inherit;False;Property;_ScanEdgeWidth;ScanEdgeWidth;8;0;Create;True;0;0;0;False;0;False;0.2;0.4342429;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;247;-5434.26,88.59357;Inherit;False;832.1714;238.4152;Luminance;5;243;201;210;209;244;;0,0,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;-4437.217,761.509;Inherit;False;ScanNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;-4601.883,953.332;Inherit;False;239;TransAmount;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-5384.26,211.6752;Inherit;False;104;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;-4546.972,1081.937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;303;-4474.134,2383.041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-4474.134,2284.041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;-5073.953,1553.419;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-4428.512,835.7;Inherit;False;239;TransAmount;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;277;-4342.883,1058.332;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;-4317.363,2322.67;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;255;-4956.234,1878.267;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-4392.192,929.6851;Inherit;False;286;ScanNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;223;-4923.953,1548.419;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-5299.881,138.5936;Inherit;False;Property;_LuminanceIntensity;Luminance Intensity;5;0;Create;True;0;0;0;False;0;False;1;0;0.5;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;308;-4177.363,2444.67;Inherit;False;239;TransAmount;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;-4785.796,1626.011;Inherit;False;239;TransAmount;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;278;-4146.883,1034.332;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-4993.882,167.5934;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;226;-4716.953,1553.419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;275;-4146.883,934.332;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;309;-4165.363,2322.67;Inherit;False;Random Range;-1;;6;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;-4747.234,2045.266;Inherit;False;239;TransAmount;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;100;-4178.963,791.0129;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;307;-3938.364,2378.67;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;207;-4050.733,791.1511;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;242;-4552.796,1580.011;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;257;-4479.234,1960.266;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-4830.088,162.2729;Inherit;False;Luminance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;280;-3974.883,975.3319;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-4230.29,709.1299;Inherit;False;104;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-3889.092,786.444;Inherit;False;ScanMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;283;-3888.113,1144.674;Inherit;False;Property;_ScanEdgeColor;ScanEdge Color;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5773503,0.5773503,0.5773503,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;259;-4333.521,1960.367;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;228;-4415.279,1579.921;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;310;-3797.119,2378.558;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;282;-3821.972,975.9369;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;295;-3851.847,1066.938;Inherit;False;Property;_ScanEdgeOn;ScanEdge On;7;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-4152.853,1880.532;Inherit;False;244;Luminance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;205;-3655.323,691.835;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;-3644.119,2373.558;Inherit;False;GridMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-4254.014,1421.57;Inherit;False;104;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-3621.119,2298.558;Inherit;False;244;Luminance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;-4267.662,1575.104;Inherit;False;LouverMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;250;-4245.757,1498.478;Inherit;False;244;Luminance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;-4175.853,1955.532;Inherit;False;PolarMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-4161.853,1804.532;Inherit;False;104;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-3631.119,2222.558;Inherit;False;104;MainTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;-3638.112,1048.674;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;312;-3406.119,2280.558;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;261;-3917.853,1862.532;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;290;-3401.285,860.9619;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;230;-4021.57,1480.331;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;-3840.582,1475.029;Inherit;False;LouverTrans;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;-3736.315,1857.625;Inherit;True;PolarTrans;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-3253.128,855.8401;Inherit;False;ScanTrans;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;-3219.375,2275.815;Inherit;False;GridTrans;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;220;-4206.767,277.6644;Inherit;False;1698.683;316.929;WhiteNoise;11;193;190;191;202;195;197;194;189;196;199;203;;0,0,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-4156.768,403.6642;Inherit;False;Property;_SeedTilling;Seed Tilling;2;1;[IntRange];Create;True;0;0;0;False;0;False;1;0;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;195;-3399.826,374.5932;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;202;-2888.085,422.0712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;196;-3076.825,422.5932;Inherit;False;Random Range;-1;;7;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;193;-3688.827,358.5932;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-4056.767,327.6643;Inherit;False;45;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;194;-3548.825,384.5932;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;-3224.826,422.5932;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-3547.825,479.5932;Inherit;False;Property;_TransitionsSpread;Transitions Spread;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-2736.084,417.0712;Inherit;False;WhiteNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-3843.767,358.6643;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;236;-2767.912,1639.937;Inherit;False;Property;_TransitionsType;TransitionsType;3;0;Create;True;0;0;0;True;0;False;0;0;0;True;;KeywordEnum;4;Scan;Louver;Polar;Grid;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;245;-3867.012,656.0829;Inherit;False;244;Luminance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LuminanceNode;201;-5181.288,217.0087;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;24;-2465.606,1646.525;Float;False;True;-1;2;ASEMaterialInspector;100;5;ZTY/PostProcess/Transitions;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;;True;False;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;7;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;-3069.891,1574.743;Inherit;False;212;ScanTrans;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-3081.377,1653.126;Inherit;False;232;LouverTrans;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;-3070.874,1730.502;Inherit;False;264;PolarTrans;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-3066.285,1806.202;Inherit;False;315;GridTrans;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;256;-4736.234,1883.267;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;318;-5200.757,1883.218;Inherit;False;Polar Coordinates;-1;;8;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
WireConnection;32;0;31;1
WireConnection;32;1;31;2
WireConnection;45;0;32;0
WireConnection;299;0;297;0
WireConnection;299;1;298;0
WireConnection;94;0;39;0
WireConnection;300;0;299;0
WireConnection;72;0;62;0
WireConnection;72;1;94;0
WireConnection;70;0;62;0
WireConnection;296;0;300;0
WireConnection;296;1;298;0
WireConnection;71;0;70;0
WireConnection;71;1;72;0
WireConnection;71;2;93;0
WireConnection;301;0;296;0
WireConnection;239;0;238;0
WireConnection;104;0;1;0
WireConnection;76;0;71;0
WireConnection;286;0;76;0
WireConnection;281;0;279;0
WireConnection;303;0;301;1
WireConnection;302;0;301;0
WireConnection;224;0;221;0
WireConnection;224;1;225;0
WireConnection;277;0;276;0
WireConnection;277;1;281;0
WireConnection;304;0;302;0
WireConnection;304;1;303;0
WireConnection;255;0;318;0
WireConnection;223;0;224;0
WireConnection;278;0;287;0
WireConnection;278;1;277;0
WireConnection;209;0;210;0
WireConnection;209;1;201;0
WireConnection;226;0;223;0
WireConnection;275;0;287;0
WireConnection;275;1;276;0
WireConnection;309;1;304;0
WireConnection;100;0;286;0
WireConnection;100;1;249;0
WireConnection;307;0;309;0
WireConnection;307;1;308;0
WireConnection;207;0;100;0
WireConnection;242;0;226;0
WireConnection;242;1;240;0
WireConnection;257;0;256;0
WireConnection;257;1;258;0
WireConnection;244;0;209;0
WireConnection;280;0;278;0
WireConnection;280;1;275;0
WireConnection;89;0;207;0
WireConnection;259;0;257;0
WireConnection;228;0;242;0
WireConnection;310;0;307;0
WireConnection;282;0;280;0
WireConnection;205;0;245;0
WireConnection;205;1;200;0
WireConnection;205;2;89;0
WireConnection;311;0;310;0
WireConnection;227;0;228;0
WireConnection;260;0;259;0
WireConnection;284;0;282;0
WireConnection;284;1;295;0
WireConnection;284;2;283;0
WireConnection;312;0;314;0
WireConnection;312;1;313;0
WireConnection;312;2;311;0
WireConnection;261;0;262;0
WireConnection;261;1;263;0
WireConnection;261;2;260;0
WireConnection;290;0;205;0
WireConnection;290;1;284;0
WireConnection;230;0;231;0
WireConnection;230;1;250;0
WireConnection;230;2;227;0
WireConnection;232;0;230;0
WireConnection;264;0;261;0
WireConnection;212;0;290;0
WireConnection;315;0;312;0
WireConnection;195;0;194;0
WireConnection;195;1;194;0
WireConnection;202;0;196;0
WireConnection;196;1;199;0
WireConnection;193;0;190;0
WireConnection;194;0;193;0
WireConnection;194;1;191;0
WireConnection;199;0;195;0
WireConnection;199;1;197;0
WireConnection;203;0;202;0
WireConnection;190;0;189;0
WireConnection;190;1;191;0
WireConnection;236;1;187;0
WireConnection;236;0;184;0
WireConnection;236;2;265;0
WireConnection;236;3;316;0
WireConnection;201;0;243;0
WireConnection;24;0;236;0
WireConnection;256;0;255;0
WireConnection;318;1;253;0
ASEEND*/
//CHKSM=48B8F426E3C5179C267092A0CA93C9AF4A5FB840