Shader "ZTY/FX/TextureAnimation/Fire"
{
    Properties
    {
        [HDR]_TintColor("Tint Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        [NoScaleOffset]_FireNoise("Fire Noise", 2D) = "black" {}
        _FlowIntensity("Flow Intensity", Range(0.1, 3.0)) = 1.0
        _FlowSpeed("Flow Speed", float) = 0.2
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

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
            };
    
            float3 _TintColor;
            sampler2D _MainTex;
            float _FlowIntensity;
            sampler2D _FireNoise;
            float _FlowSpeed;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                float2 flowUV = float2(i.uv.x, i.uv.y + frac(-_Time.y * _FlowSpeed));
                float firenoise = tex2D(_FireNoise, flowUV).r * 10.0 * _FlowIntensity;

                float2 fireUV = lerp(i.uv, firenoise, 0.01);
                float3 finalcol = tex2D(_MainTex, fireUV).rgb * _TintColor;

                float op = tex2D(_MainTex, fireUV).r;

                return float4(finalcol, op);
            }
            ENDCG
        }
    }
}
