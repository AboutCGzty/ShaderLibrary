Shader "ZTY/Strive/Decal"
{
    Properties
    {
        [Header(Texture Sampler ________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _DecalColor("Decal Color", Color) = (1.0, 1.0, 1.0, 0.0)
        [NoScaleOffset]_Decal("Decal", 2D) = "black" {}
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
            Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }

            Cull Back
            ZTest LEqual
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv_decal : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv_decal : TEXCOORD0;
            };

            sampler2D _Decal;
            float3 _DecalColor;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv_decal = v.uv_decal;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                float decalmask = tex2D(_Decal, i.uv_decal).r;

                float3 finalRGB = decalmask * _DecalColor;
                float finalAlpha = saturate((0.5 - decalmask) * 2.0);

                return float4(finalRGB, finalAlpha);
            }
            ENDCG
        }
    }
}