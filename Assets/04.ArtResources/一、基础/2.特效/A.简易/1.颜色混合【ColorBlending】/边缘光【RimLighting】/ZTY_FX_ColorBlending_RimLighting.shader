Shader "ZTY/FX/ColorBlending/RimLighting"
{
    Properties
    {
        _RimColor("OutLine Color", Color) = (1.0, 1.0, 1.0, 0.0)
        _RimPower("Rim Power", Range(1.0, 10.0)) = 3.0
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
                float3 normal : NORMAL;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD0;
                float3 nDir : TEXCOORD1;
            };

            float3 _RimColor;
            float _RimPower;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDir = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 N = normalize(i.nDir);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float NV = 1.0 - saturate(abs(dot(N, V)));
                NV = saturate(pow(NV, _RimPower));

                float3 finalcolor = _RimColor * NV;

                return float4(finalcolor, NV);
            }
            ENDCG
        }
    }
}
