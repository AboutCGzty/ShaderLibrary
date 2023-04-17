// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Toon_Scene"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Alpha("Alpha", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		ZTest LEqual
		CGPROGRAM
		#pragma target 3.0
		#pragma only_renderers d3d11 
		#pragma surface surf Unlit keepalpha noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Alpha;
		uniform float _Cutoff = 0.5;


		float3 ACESTonemap8( float3 linear_color )
		{
			float3 tonemapped_color = saturate((linear_color*(2.8 * linear_color + 0))/(linear_color*(2.0 * linear_color + 1.0) + 0.0));
			return tonemapped_color;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float3 linear_color8 = ( tex2DNode1 * tex2DNode1 ).rgb;
			float3 localACESTonemap8 = ACESTonemap8( linear_color8 );
			o.Emission = localACESTonemap8;
			o.Alpha = _Alpha;
			clip( tex2DNode1.a - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.SamplerNode;1;-776,79;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;None;37bcc6b3eaff0424cb0e075f58ad76b5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-356,-75;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-142,70;Inherit;False;Property;_Alpha;Alpha;2;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;365,-39;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Toon_Scene;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;1;False;;3;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Opaque;;AlphaTest;ForwardOnly;1;d3d11;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CustomExpressionNode;8;-26,-47;Inherit;False;float3 tonemapped_color = saturate((linear_color*(2.8 * linear_color + 0))/(linear_color*(2.0 * linear_color + 1.0) + 0.0))@$return tonemapped_color@;3;Create;1;True;linear_color;FLOAT3;0,0,0;In;;Inherit;False;ACESTonemap;True;False;0;;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
WireConnection;7;0;1;0
WireConnection;7;1;1;0
WireConnection;0;2;8;0
WireConnection;0;9;6;0
WireConnection;0;10;1;4
WireConnection;8;0;7;0
ASEEND*/
//CHKSM=CD71A01AFD31A835AE261A82FD2FEB28E0B4C962