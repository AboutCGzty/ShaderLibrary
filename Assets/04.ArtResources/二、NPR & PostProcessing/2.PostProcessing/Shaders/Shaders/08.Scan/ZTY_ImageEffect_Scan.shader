Shader "ZTY/ImageEffect/Scan"
{
	Properties
	{
		_ScanColor("Scan Color", Color) = (1.0, 1.0, 1.0, 0.0)
		_ScanDistance("Scan Distance", float) = 50.0
		_ScanIntensity("Scan Intensity", Range(0.0, 1.0)) = 1.0
		_ScanSpread("Scan Spread", Range(1.0, 10.0)) = 3.0
		_Return("Return", Range(0.0, 1.0)) = 0.0
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		
		Pass
		{
			Cull Off ZWrite Off ZTest Always

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma target 3.0

			struct appdata
			{
				float4 vertex : POSITION;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 pos_screen : TEXCOORD0;
			};

			sampler2D _MainTex, _CameraDepthTexture;
			float _ScanDistance, _ScanSpread, _ScanIntensity, _Return;
			float4 _ScanColor, _CameraDepthTexture_TexelSize;

			v2f vert ( appdata v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos_screen = ComputeScreenPos(o.pos); // 计算屏幕UV
				o.pos_screen /= o.pos_screen.w; // 透视除法
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float depth_screen = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.pos_screen.xy); // 屏幕UV[0, 1] 采样深度图[0, 1]
				float3 ndcPos = float3(i.pos_screen.x, i.pos_screen.y, (1.0 - depth_screen)) * 2.0 - 1.0; // 转换为NDC坐标 [0, 1] 并重映射至 [-1, 1]

				float4 pos_clip = mul(unity_CameraInvProjection, float4(ndcPos, 1.0));
				pos_clip.xyz /= pos_clip.w;
				pos_clip = float4(pos_clip.xyz , 1.0);
				
				float4 depthToWorldPos = mul(unity_CameraToWorld, pos_clip);

				float viewdistancemask = length(depthToWorldPos.xyz - _WorldSpaceCameraPos.xyz) / _ScanDistance;
				viewdistancemask = saturate(pow(viewdistancemask, _ScanSpread));
				float scenemask = step(viewdistancemask, 0.9);
				float scanlinemask = saturate(pow((1.0 - length(viewdistancemask - 0.9)), 50.0));
				float3 scanlinecolor = scanlinemask * _ScanColor * _ScanIntensity;

				float3 maincolor = tex2D(_MainTex, i.pos_screen.xy).rgb;
				float scancolor = dot(maincolor, float3(0.299, 0.587, 0.114));

				float3 finalcolor = lerp(maincolor, scancolor, scenemask + scanlinemask) + scanlinecolor;
				finalcolor = lerp(finalcolor, maincolor, _Return);

				return float4(finalcolor, 1.0);
			}
			ENDCG
		}
	}
}