Shader "ZTY/FX/TextureAnimation/Scanning"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        [HDR]_ScanColor("Scan Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_ScanMask("Scan Mask", 2D) = "black" {}
        _ScanPower("Scan Power", Range(1.0, 10.0)) = 3.0
        _ScanSpeed("Scan Speed", float) = 0.2
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Cull Back
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 posWS : TEXCOORD1;
            };
    
            sampler2D _MainTex;
            float3 _ScanColor;
            sampler2D _ScanMask;
            float _ScanPower;
            float _ScanSpeed;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 albedo = tex2D(_MainTex, i.uv);

                float2 scanUV = float2(i.posWS.x, i.posWS.y + frac(_Time.y * _ScanSpeed));
                float3 scancolor = saturate(pow(tex2D(_ScanMask, scanUV), _ScanPower));
                scancolor *= saturate(i.posWS.y) * _ScanColor;

                float3 finalcol = albedo + scancolor;
                return float4(finalcol, 1.0);
            }
            ENDCG
        }
    }
}
