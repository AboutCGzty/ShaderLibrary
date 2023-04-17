Shader "ZTY/FX/ColorBlending/EnergyBar"
{
    Properties
    {
        _OutLineColor("OutLine Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [HDR]_EnergyColor("Energy Color", Color) = (0.0, 0.0, 0.0, 0.0)
        [NoScaleOffset]_EnergyMask("Energy Mask", 2D) = "white" {}
        _EnergyScale("Energy Scale", Range(0.0, 1.0)) = 0.0
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float3 _OutLineColor;
            float3 _EnergyColor;
            sampler2D _EnergyMask;
            float _EnergyScale;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                float op = saturate(tex2D(_EnergyMask, i.uv).r);
                float lerpmask = saturate(tex2D(_EnergyMask, i.uv).g);
                float energyscalemask = saturate(tex2D(_EnergyMask, i.uv).b);
                float energy = saturate(step(i.uv.x, frac(_Time.y * 0.5))) * energyscalemask;
                float energymask = (1.0 - lerpmask) * energy * op;

                float3 energycolor = energymask * _EnergyColor;
                float3 finalcolor = lerp(energycolor, _OutLineColor, lerpmask);
                finalcolor *= op;

                return float4(finalcolor, op);
            }
            ENDCG
        }
    }
}
