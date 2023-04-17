// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Skybox/ProcedualSky"
{
	Properties
	{
		[Header(Sky Color)][Space(10)]_HorizonColor("HorizonColor", Color) = (0,0,0,0)
		_ZenithColor("ZenithColor", Color) = (0,0,0,0)
		_HorizonFalloff("HorizonFalloff", Float) = 0
		_HorizonOffset("HorizonOffset", Float) = 0
		_HorizonTilt("HorizonTilt", Float) = 0
		[Header(Sun Color)][Space(10)]_SunDirection("Sun Direction", Vector) = (0,0,0,0)
		_SunColor("SunColor", Color) = (1,1,1,0)
		_SunIntensity("Sun Intensity", Float) = 1
		_SunRadius("Sun Radius", Float) = 0.002
		_SunBloom("Sun Bloom", Float) = 0.04
		_SunScattering("Sun Scattering", Float) = 0.3
		[Header(Moon Color)][Space(10)]_MoonDirection("MoonDirection", Vector) = (0,0,0,0)
		_MoonTex("MoonTex", 2D) = "white" {}
		_MoonColor("MoonColor", Color) = (0,0,0,0)
		_MoonIntensity("MoonIntensity", Float) = 0
		_MoonSize("Moon Size", Range( 0.1 , 1)) = 0.5
		_MoonBloom("Moon Bloom", Float) = 0.04
		_MoonScattering("Moon Scattering", Float) = 0.3
		[Header(Static Background)][Space(10)]_BackGroundTex("BackGround Tex", 2D) = "black" {}
		_CloudsBackgroundColor("Clouds Background Color", Color) = (0,0,0,0)
		_CloudsBackgroundBrightness("Clouds Background Brightness", Float) = 1
		_StarsColor("Stars Color", Color) = (0,0,0,0)
		_StarsIntensity("Stars Intensity", Float) = 10

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Background" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		
		
		
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
			#include "UnityStandardBRDF.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
			#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
			#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex.SampleBias(samplerTex,coord,bias)
			#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex.SampleGrad(samplerTex,coord,ddx,ddy)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
			#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex2Dlod(tex,float4(coord,0,lod))
			#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex2Dbias(tex,float4(coord,0,bias))
			#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex2Dgrad(tex,coord,ddx,ddy)
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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _SunColor;
			uniform float _SunIntensity;
			uniform float _SunBloom;
			uniform float3 _SunDirection;
			uniform float _SunRadius;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_MoonTex);
			uniform half3 _MoonDirection;
			uniform half _MoonSize;
			SamplerState sampler_MoonTex;
			uniform float4 _MoonColor;
			uniform float _MoonIntensity;
			uniform float _MoonBloom;
			uniform float4 _ZenithColor;
			uniform float4 _HorizonColor;
			uniform float _HorizonTilt;
			uniform float _HorizonFalloff;
			uniform float _HorizonOffset;
			uniform float _SunScattering;
			uniform float _MoonScattering;
			uniform float4 _StarsColor;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_BackGroundTex);
			SamplerState sampler_BackGroundTex;
			uniform float _StarsIntensity;
			uniform float4 _CloudsBackgroundColor;
			uniform float _CloudsBackgroundBrightness;
			float2 ConvertLocalPosToUV149( float3 LocalPos )
			{
				return float2(-atan2(LocalPos.z, LocalPos.x), -acos(LocalPos.y)) / float2(2.0 * UNITY_PI, 0.5 * UNITY_PI);
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				half3 MoonDirection167 = _MoonDirection;
				float3 temp_output_166_0 = cross( MoonDirection167 , half3(0,1,0) );
				float3 normalizeResult171 = normalize( temp_output_166_0 );
				float dotResult172 = dot( normalizeResult171 , v.vertex.xyz );
				float3 normalizeResult170 = normalize( cross( MoonDirection167 , temp_output_166_0 ) );
				float dotResult173 = dot( normalizeResult170 , v.vertex.xyz );
				float2 appendResult174 = (float2(dotResult172 , dotResult173));
				float lerpResult177 = lerp( 20.0 , 2.0 , _MoonSize);
				float2 vertexToFrag181 = (( appendResult174 * lerpResult177 )*0.5 + 0.5);
				o.ase_texcoord1.xy = vertexToFrag181;
				
				o.ase_texcoord2 = v.vertex;
				
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
				float3 SunTintColor113 = (_SunColor).rgb;
				float3 normalizeResult50 = normalize( _SunDirection );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float dotResult18 = dot( normalizeResult50 , ase_worldViewDir );
				float SunDotV104 = dotResult18;
				float3 temp_output_62_0 = ( ( ( SunTintColor113 * _SunIntensity ) * ( _SunBloom * 0.01 ) ) / sqrt( max( ( (-SunDotV104*0.5 + 0.5) - ( _SunRadius * 0.01 ) ) , 0.0002 ) ) );
				float3 SunColor66 = ( temp_output_62_0 * temp_output_62_0 );
				float2 vertexToFrag181 = i.ase_texcoord1.xy;
				half3 MoonDirection167 = _MoonDirection;
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult230 = dot( MoonDirection167 , ase_worldViewDir );
				float4 temp_output_298_0 = ( SAMPLE_TEXTURE2D( _MoonTex, sampler_MoonTex, vertexToFrag181 ) * saturate( dotResult230 ) );
				float3 MoonTexture300 = (temp_output_298_0).rgb;
				float3 MoonTintColor252 = (_MoonColor).rgb;
				float dotResult254 = dot( _MoonDirection , ase_worldViewDir );
				float MoonDotV256 = dotResult254;
				float3 temp_output_278_0 = ( ( MoonTintColor252 * _MoonBloom * 0.01 ) / sqrt( max( (-MoonDotV256*0.5 + 0.5) , 0.0002 ) ) );
				float MoonMask236 = (temp_output_298_0).a;
				float3 MoonBloom302 = ( temp_output_278_0 * temp_output_278_0 * ( 1.0 - ( MoonMask236 * 0.5 ) ) );
				float3 MoonColor192 = ( ( MoonTexture300 * MoonTintColor252 * _MoonIntensity * 10.0 ) + MoonBloom302 );
				float3 SunDirection103 = normalizeResult50;
				float3 break88 = ( SunDirection103 * _HorizonTilt );
				float3 appendResult87 = (float3(break88.x , _HorizonFalloff , break88.z));
				float dotResult34 = dot( -appendResult87 , ase_worldViewDir );
				float clampResult39 = clamp( ( ( 1.0 - dotResult34 ) + _HorizonOffset ) , 0.0 , 1.0 );
				float temp_output_40_0 = ( clampResult39 * clampResult39 );
				float4 lerpResult44 = lerp( _ZenithColor , _HorizonColor , ( temp_output_40_0 * temp_output_40_0 ));
				float3 SkyColor45 = (lerpResult44).rgb;
				float temp_output_19_0 = max( SunDotV104 , 0.0 );
				float temp_output_20_0 = ( temp_output_19_0 * temp_output_19_0 );
				float3 SunScattering115 = ( SunTintColor113 * ( ( ( temp_output_20_0 * temp_output_20_0 ) * _SunScattering ) * 0.5 ) );
				float saferPower259 = abs( max( MoonDotV256 , 0.0 ) );
				float3 MoonScattering249 = ( MoonTintColor252 * ( ( pow( saferPower259 , 30.0 ) * _MoonScattering ) * 0.5 ) );
				float3 LocalPos149 = i.ase_texcoord2.xyz;
				float2 localConvertLocalPosToUV149 = ConvertLocalPosToUV149( LocalPos149 );
				float4 tex2DNode100 = SAMPLE_TEXTURE2D( _BackGroundTex, sampler_BackGroundTex, localConvertLocalPosToUV149 );
				float StarTex201 = tex2DNode100.g;
				float temp_output_207_0 = ( StarTex201 * StarTex201 );
				float StarNoise202 = tex2DNode100.b;
				float mulTime212 = _Time.y * 0.5;
				float3 StarsColor220 = ( (_StarsColor).rgb * ( temp_output_207_0 * temp_output_207_0 ) * ( sin( ( ( ( StarNoise202 * 3.0 ) + mulTime212 ) * ( 2.0 * UNITY_PI ) ) ) + 1.0 ) * _StarsIntensity );
				float3 CloudsColor194 = ( (_CloudsBackgroundColor).rgb + SunScattering115 + MoonScattering249 );
				float CloudTex200 = tex2DNode100.r;
				float clampResult140 = clamp( ( ( CloudTex200 * CloudTex200 ) * _CloudsBackgroundBrightness ) , 0.0 , 1.0 );
				float CloudsMask195 = clampResult140;
				float3 lerpResult197 = lerp( ( SkyColor45 + SunScattering115 + MoonScattering249 + StarsColor220 ) , CloudsColor194 , CloudsMask195);
				
				
				finalColor = float4( ( SunColor66 + MoonColor192 + lerpResult197 ) , 0.0 );
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
Node;AmplifyShaderEditor.CommentaryNode;111;-2623.431,-2163.069;Inherit;False;1403.053;417.4444;Sun&Moon Direction;11;104;18;10;103;50;12;164;167;255;256;254;Sun&Moon Direction;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;185;-2617.62,-829.9435;Inherit;False;3193.6;1573.555;MoonColor;12;192;295;305;301;190;260;189;252;253;188;303;306;MoonColor;0,0.47821,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;164;-1815.156,-2108.14;Half;False;Property;_MoonDirection;MoonDirection;11;1;[Header];Create;True;1;Moon Color;0;0;False;1;Space(10);False;0,0,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;306;-2570.394,-705.1395;Inherit;False;3071.174;600.4603;Moon Texture;25;250;300;191;236;299;298;231;187;181;230;179;228;178;177;174;184;173;172;169;171;170;168;166;186;165;Moon Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;-1559.156,-2108.14;Half;False;MoonDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-2520.394,-633.5712;Inherit;False;167;MoonDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;165;-2484.365,-487.3349;Half;False;Constant;_Vector3;Vector 3;9;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;166;-2191.364,-500.3349;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;168;-1999.364,-628.3345;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;12;-2597.431,-2117.781;Inherit;False;Property;_SunDirection;Sun Direction;5;1;[Header];Create;True;1;Sun Color;0;0;False;1;Space(10);False;0,0,0;12,-25,20;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;170;-1807.363,-628.3345;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;171;-1999.364,-500.3349;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;169;-1943.364,-362.3353;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;50;-2390.087,-2111.683;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2636.665,858.8269;Inherit;False;2465.722;625.627;Sky Gradient Color;20;120;43;98;97;41;40;39;33;92;87;84;109;89;90;88;44;42;96;34;45;Sky Gradient Color;0.6874552,0,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;184;-1642.056,-319.6335;Half;False;Property;_MoonSize;Moon Size;15;0;Create;True;0;0;0;False;0;False;0.5;0.1;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-2096.076,-2113.068;Inherit;False;SunDirection;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;173;-1615.363,-628.3345;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;172;-1615.363,-500.3349;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-2585.461,1158.911;Inherit;False;103;SunDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-2586.665,1237.156;Inherit;False;Property;_HorizonTilt;HorizonTilt;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;177;-1331.48,-363.2695;Inherit;False;3;0;FLOAT;20;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;174;-1455.362,-628.3345;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;205;-2644.221,2346.827;Inherit;False;1145.206;345;Static BackGround;6;202;201;200;100;158;149;Static BackGround;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-2380.665,1169.157;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-1144.85,-626.3345;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-2557.17,-1925.625;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;250;-768.1603,-292.6794;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;179;-986.9105,-627.3345;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-2248.508,-1952.962;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;255;-1808.53,-1931.577;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;88;-2229.236,1171.731;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;84;-2286.236,1307.731;Inherit;False;Property;_HorizonFalloff;HorizonFalloff;2;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;-793.4545,-381.845;Inherit;False;167;MoonDirection;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;254;-1565.53,-1949.577;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;181;-771.9104,-626.3345;Inherit;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-2076.378,-1953.984;Inherit;False;SunDotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;-2052.239,1173.731;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;230;-498.9824,-377.976;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;118;-2652.598,1654.299;Inherit;False;1523.42;541.8441;SunScattering;11;26;24;27;22;19;20;110;21;23;114;115;SunScattering;1,0.9445122,0,1;0;0
Node;AmplifyShaderEditor.SamplerNode;100;-2191.571,2410.609;Inherit;True;Property;_BackGroundTex;BackGround Tex;18;1;[Header];Create;True;1;Static Background;0;0;False;1;Space(10);False;-1;None;12efe520b1378514aac3e7149583b5cf;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;33;-1938.911,1290.425;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;303;-2563.232,-35.34071;Inherit;False;1469.237;667.9401;MoonBloom;16;280;279;302;263;284;278;287;275;274;277;283;273;288;294;293;307;MoonBloom;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;237;-1036.654,1660.841;Inherit;False;1523.42;541.8441;MoonScattering;10;248;247;246;244;242;241;239;238;259;249;MoonScattering;0,1,0.8507535,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-1430.53,-1953.577;Inherit;False;MoonDotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;92;-1917.239,1175.731;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-2603.67,1866.715;Inherit;False;104;SunDotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;231;-348.4744,-379.354;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;187;-516.6052,-655.1395;Inherit;True;Property;_MoonTex;MoonTex;12;0;Create;True;0;0;0;False;0;False;-1;None;3c9af0316e0e3454194166cec67eb59e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;34;-1720.221,1265.659;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-2512.232,282.6333;Inherit;False;256;MoonDotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-161.9481,-648.1054;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;188;-763.6064,209.125;Inherit;False;Property;_MoonColor;MoonColor;13;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;238;-999.1718,1843.828;Inherit;False;256;MoonDotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;-1852.015,2561.827;Inherit;False;StarNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;-2621.476,-1676.689;Inherit;False;2125.946;748.4448;SunColor;21;292;291;63;99;59;66;65;62;61;64;57;55;289;113;290;56;60;108;29;296;297;SunColor;1,0.5181768,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;223;-1379.773,2829.582;Inherit;False;1494.444;617.04;StarsColor;18;220;219;221;222;217;214;216;212;215;211;208;218;210;209;207;206;225;227;StarsColor;1,0.3160377,0.7846898,1;0;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;19;-2402.054,1867.35;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;299;99.85195,-653.405;Inherit;False;FLOAT;3;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;239;-797.5547,1851.461;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-2253.366,1867.474;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-1303.826,3259.697;Inherit;False;Constant;_Float2;Float 2;19;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;253;-534.7648,211.1749;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;293;-2323.923,288.8288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-2270,-1615;Inherit;False;Property;_SunColor;SunColor;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,0.962043,0.9025157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;208;-1321.619,3185.451;Inherit;False;202;StarNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-1562.221,1378.168;Inherit;False;Property;_HorizonOffset;HorizonOffset;3;0;Create;True;0;0;0;False;0;False;0;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;96;-1555.939,1266.003;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;-383.5642,210.1738;Inherit;False;MoonTintColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2077.833,1866.543;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;60;-2024,-1615;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;259;-641.252,1854.869;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;30;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-1129.828,3193.697;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;236;244.3026,-655.0457;Inherit;False;MoonMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;294;-2177.923,295.8288;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;212;-1158.057,3347.589;Inherit;False;1;0;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2127.46,1996.049;Inherit;False;Property;_SunScattering;Sun Scattering;10;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-2565.685,-1290.115;Inherit;False;104;SunDotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-1350.221,1287.568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-527.2546,1986.033;Inherit;False;Property;_MoonScattering;Moon Scattering;17;0;Create;True;0;0;0;False;0;False;0.3;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1889.381,1996.127;Inherit;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;288;-2027.826,516.5993;Inherit;False;Constant;_Float9;Float 9;24;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;242;-283.5236,2049.933;Inherit;False;Constant;_Float5;Float 5;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-2047.957,427.7162;Inherit;False;236;MoonMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-2076.909,113.0714;Inherit;False;Property;_MoonBloom;Moon Bloom;16;0;Create;True;0;0;0;False;0;False;0.04;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;296;-2401.139,-1285.411;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;277;-1982.337,295.3635;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.0002;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2325.991,-1163.339;Inherit;False;Property;_SunRadius;Sun Radius;8;0;Create;True;0;0;0;False;0;False;0.002;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;280;-2096.211,14.65929;Inherit;False;252;MoonTintColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;39;-1186.891,1287.951;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1927.987,1866.007;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-1864,-1615;Inherit;False;SunTintColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;244;-327.7821,1854.919;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;211;-937.6799,3196.69;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;216;-966.3491,3350.881;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-2067.777,187.3393;Inherit;False;Constant;_Float0;Float 0;23;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-1850.015,2472.827;Inherit;False;StarTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;-2327.308,-1061.518;Inherit;False;Constant;_Float10;Float 10;23;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;-119.5237,1869.932;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-1864.907,80.07154;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;-176.6485,1766.089;Inherit;False;252;MoonTintColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;275;-1850.86,292.2404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-815.79,3091.595;Inherit;False;201;StarTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-1775.852,1775.103;Inherit;False;113;SunTintColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-2158.308,-1126.518;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-1849.015,2387.827;Inherit;False;CloudTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1025.89,1285.951;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1722.944,1868.146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;-782.8093,3198.155;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;297;-2229.139,-1286.411;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;196;-2655.774,2812.377;Inherit;False;1147.442;628.0047;Clouds Color;12;195;194;102;140;163;132;135;101;130;204;203;282;Clouds Color;0.6179246,0.9168098,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;287;-1847.827,461.5991;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;221;-730.3151,2882.065;Inherit;False;Property;_StarsColor;Stars Color;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;214;-628.4885,3200.008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;292;-1607,-1401;Inherit;False;Constant;_Float11;Float 11;23;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-594.5668,3077.581;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;284;-1702.108,460.3492;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;55;-1988.492,-1280.839;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;62.47617,1843.932;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-1831,-1497;Inherit;False;Property;_SunIntensity;Sun Intensity;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1537.726,1853.947;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;278;-1680.007,169.5715;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;-2577.965,3220.518;Inherit;False;200;CloudTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1607,-1481;Inherit;False;Property;_SunBloom;Sun Bloom;9;0;Create;True;0;0;0;False;0;False;0.04;1.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;-1093.506,908.8265;Inherit;False;Property;_ZenithColor;ZenithColor;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0.6014151,0.8773585,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;43;-1094.506,1086.827;Inherit;False;Property;_HorizonColor;HorizonColor;0;1;[Header];Create;True;1;Sky Color;0;0;False;1;Space(10);False;0,0,0,0;0.745283,0.5640867,0.3984217,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;218;-633.6013,3301.02;Inherit;False;Constant;_Float4;Float 4;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-887.8893,1280.951;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;191;91.17526,-426.9902;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;57;-1806.394,-1281.185;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.0002;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-445.0719,3073.456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;276.78,-427.5062;Inherit;False;MoonTexture;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;101;-2600.869,2918.701;Inherit;False;Property;_CloudsBackgroundColor;Clouds Background Color;19;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9339623,0.9339623,0.9339623,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;44;-660.7383,1233.224;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-437.0722,3359.456;Inherit;False;Property;_StarsIntensity;Stars Intensity;22;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;-2481.169,3331.251;Inherit;False;Property;_CloudsBackgroundBrightness;Clouds Background Brightness;20;0;Create;True;0;0;0;False;0;False;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1607,-1609;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-2392.06,3214.463;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-1447,-1449;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;279;-1475.209,169.7715;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;249;224.4621,1840.661;Inherit;False;MoonScattering;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;217;-446.505,3201.794;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;222;-491.6405,2881.34;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-1377.958,1850.761;Inherit;False;SunScattering;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-380.812,301.3375;Inherit;False;Property;_MoonIntensity;MoonIntensity;14;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;260;-352.813,375.1369;Inherit;False;Constant;_Float6;Float 6;21;0;Create;True;0;0;0;False;0;False;10;8.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-2356.273,3043.518;Inherit;False;115;SunScattering;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1271.092,-1609.389;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-236.6114,3056.754;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;132;-2328.426,2919.744;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;282;-2358.73,3122.295;Inherit;False;249;MoonScattering;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;120;-504.2328,1230.932;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-2192.633,3211.352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;61;-1653.617,-1279.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-388.7547,115.3982;Inherit;False;300;MoonTexture;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;302;-1317.994,164.7001;Inherit;False;MoonBloom;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-2045.764,2925.372;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-135.2405,193.9778;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;305;-135.4597,379.0397;Inherit;False;302;MoonBloom;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;-1118.091,-1309.189;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-348.0604,1233.376;Inherit;False;SkyColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;220;-76.95462,3050.32;Inherit;False;StarsColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;140;-2038.88,3211.479;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;1487.569,805.8033;Inherit;False;45;SkyColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-1870.174,2918.54;Inherit;False;CloudsColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;1477.457,1051.621;Inherit;False;220;StarsColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;1431.851,887.3933;Inherit;False;115;SunScattering;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;295;65.4821,187.6409;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-1848.047,3200.339;Inherit;False;CloudsMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;1421.455,975.2903;Inherit;False;249;MoonScattering;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-931.2909,-1317.188;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;1716.253,1189.897;Inherit;False;195;CloudsMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;208.8492,182.4408;Inherit;False;MoonColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;1720.719,930.8494;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-762.2911,-1320.188;Inherit;False;SunColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;1678.253,1100.897;Inherit;False;194;CloudsColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;1927.489,730.5933;Inherit;False;66;SunColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;285;1920.507,837.8573;Inherit;False;192;MoonColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;197;1944.251,930.8973;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;2199.947,819.1354;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;80;2343.363,818.9744;Float;False;True;-1;2;ASEMaterialInspector;100;5;Skybox/ProcedualSky;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;3;False;;True;False;0;False;;0;False;;True;2;RenderType=Opaque=RenderType;Queue=Background=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;True;0
Node;AmplifyShaderEditor.PosVertexDataNode;158;-2612.421,2439.123;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;149;-2409.751,2439.036;Inherit;False;return float2(-atan2(LocalPos.z, LocalPos.x), -acos(LocalPos.y)) / float2(2.0 * UNITY_PI, 0.5 * UNITY_PI)@;2;Create;1;True;LocalPos;FLOAT3;0,0,0;In;;Inherit;False;ConvertLocalPosToUV;True;False;0;;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
WireConnection;167;0;164;0
WireConnection;166;0;186;0
WireConnection;166;1;165;0
WireConnection;168;0;186;0
WireConnection;168;1;166;0
WireConnection;170;0;168;0
WireConnection;171;0;166;0
WireConnection;50;0;12;0
WireConnection;103;0;50;0
WireConnection;173;0;170;0
WireConnection;173;1;169;0
WireConnection;172;0;171;0
WireConnection;172;1;169;0
WireConnection;177;2;184;0
WireConnection;174;0;172;0
WireConnection;174;1;173;0
WireConnection;89;0;109;0
WireConnection;89;1;90;0
WireConnection;178;0;174;0
WireConnection;178;1;177;0
WireConnection;179;0;178;0
WireConnection;18;0;50;0
WireConnection;18;1;10;0
WireConnection;88;0;89;0
WireConnection;254;0;164;0
WireConnection;254;1;255;0
WireConnection;181;0;179;0
WireConnection;104;0;18;0
WireConnection;87;0;88;0
WireConnection;87;1;84;0
WireConnection;87;2;88;2
WireConnection;230;0;228;0
WireConnection;230;1;250;0
WireConnection;100;1;149;0
WireConnection;256;0;254;0
WireConnection;92;0;87;0
WireConnection;231;0;230;0
WireConnection;187;1;181;0
WireConnection;34;0;92;0
WireConnection;34;1;33;0
WireConnection;298;0;187;0
WireConnection;298;1;231;0
WireConnection;202;0;100;3
WireConnection;19;0;110;0
WireConnection;299;0;298;0
WireConnection;239;0;238;0
WireConnection;20;0;19;0
WireConnection;20;1;19;0
WireConnection;253;0;188;0
WireConnection;293;0;263;0
WireConnection;96;0;34;0
WireConnection;252;0;253;0
WireConnection;21;0;20;0
WireConnection;21;1;20;0
WireConnection;60;0;29;0
WireConnection;259;0;239;0
WireConnection;209;0;208;0
WireConnection;209;1;210;0
WireConnection;236;0;299;0
WireConnection;294;0;293;0
WireConnection;97;0;96;0
WireConnection;97;1;98;0
WireConnection;296;0;108;0
WireConnection;277;0;294;0
WireConnection;39;0;97;0
WireConnection;22;0;21;0
WireConnection;22;1;23;0
WireConnection;113;0;60;0
WireConnection;244;0;259;0
WireConnection;244;1;241;0
WireConnection;211;0;209;0
WireConnection;211;1;212;0
WireConnection;201;0;100;2
WireConnection;247;0;244;0
WireConnection;247;1;242;0
WireConnection;274;0;280;0
WireConnection;274;1;273;0
WireConnection;274;2;307;0
WireConnection;275;0;277;0
WireConnection;289;0;56;0
WireConnection;289;1;290;0
WireConnection;200;0;100;1
WireConnection;40;0;39;0
WireConnection;40;1;39;0
WireConnection;24;0;22;0
WireConnection;24;1;26;0
WireConnection;215;0;211;0
WireConnection;215;1;216;0
WireConnection;297;0;296;0
WireConnection;287;0;283;0
WireConnection;287;1;288;0
WireConnection;214;0;215;0
WireConnection;207;0;206;0
WireConnection;207;1;206;0
WireConnection;284;0;287;0
WireConnection;55;0;297;0
WireConnection;55;1;289;0
WireConnection;248;0;246;0
WireConnection;248;1;247;0
WireConnection;27;0;114;0
WireConnection;27;1;24;0
WireConnection;278;0;274;0
WireConnection;278;1;275;0
WireConnection;41;0;40;0
WireConnection;41;1;40;0
WireConnection;191;0;298;0
WireConnection;57;0;55;0
WireConnection;227;0;207;0
WireConnection;227;1;207;0
WireConnection;300;0;191;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;44;2;41;0
WireConnection;59;0;113;0
WireConnection;59;1;99;0
WireConnection;130;0;203;0
WireConnection;130;1;203;0
WireConnection;291;0;64;0
WireConnection;291;1;292;0
WireConnection;279;0;278;0
WireConnection;279;1;278;0
WireConnection;279;2;284;0
WireConnection;249;0;248;0
WireConnection;217;0;214;0
WireConnection;217;1;218;0
WireConnection;222;0;221;0
WireConnection;115;0;27;0
WireConnection;63;0;59;0
WireConnection;63;1;291;0
WireConnection;219;0;222;0
WireConnection;219;1;227;0
WireConnection;219;2;217;0
WireConnection;219;3;225;0
WireConnection;132;0;101;0
WireConnection;120;0;44;0
WireConnection;163;0;130;0
WireConnection;163;1;204;0
WireConnection;61;0;57;0
WireConnection;302;0;279;0
WireConnection;102;0;132;0
WireConnection;102;1;135;0
WireConnection;102;2;282;0
WireConnection;190;0;301;0
WireConnection;190;1;252;0
WireConnection;190;2;189;0
WireConnection;190;3;260;0
WireConnection;62;0;63;0
WireConnection;62;1;61;0
WireConnection;45;0;120;0
WireConnection;220;0;219;0
WireConnection;140;0;163;0
WireConnection;194;0;102;0
WireConnection;295;0;190;0
WireConnection;295;1;305;0
WireConnection;195;0;140;0
WireConnection;65;0;62;0
WireConnection;65;1;62;0
WireConnection;192;0;295;0
WireConnection;138;0;136;0
WireConnection;138;1;137;0
WireConnection;138;2;257;0
WireConnection;138;3;224;0
WireConnection;66;0;65;0
WireConnection;197;0;138;0
WireConnection;197;1;198;0
WireConnection;197;2;199;0
WireConnection;67;0;68;0
WireConnection;67;1;285;0
WireConnection;67;2;197;0
WireConnection;80;0;67;0
WireConnection;149;0;158;0
ASEEND*/
//CHKSM=CAF8ACAEC1A75AEC627E4D74ADD531927BA2015C