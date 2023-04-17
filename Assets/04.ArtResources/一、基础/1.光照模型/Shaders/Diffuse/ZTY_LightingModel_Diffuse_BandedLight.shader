Shader "ZTY/LightingModel/Diffuse/BandedLight"
{
    Properties
    {
        [IntRange]_BandedLevel("Banded Level", Range(2.0, 5.0)) = 2.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float3 normal_world : NORMAL; 
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = mul(unity_ObjectToWorld, v.normal);
                return o;
            }

            int _BandedLevel;

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 worldnormal = normalize(i.normal_world);
                float3 worldlightdir = normalize(_WorldSpaceLightPos0.xyz);

                float nl = dot(worldnormal, worldlightdir) * 0.5 + 0.5;
                nl = floor(nl * _BandedLevel) / _BandedLevel;

                float3 finalcolor = nl * _LightColor0.rgb;

                return float4(finalcolor, 1.0);
            }
            ENDCG
        }
    }
}
