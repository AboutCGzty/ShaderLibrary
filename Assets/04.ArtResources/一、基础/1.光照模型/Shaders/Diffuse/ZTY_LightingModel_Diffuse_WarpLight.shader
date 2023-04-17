Shader "ZTY/LightingModel/Diffuse/WarpLight"
{
    Properties
    {
        _WarpValue("WarpValue", float) = 1.0
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

            float _WarpValue;

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 worldnormal = normalize(i.normal_world);
                float3 worldlightdir = normalize(_WorldSpaceLightPos0.xyz);

                float nl = dot(worldnormal, worldlightdir);
                nl = pow(nl * _WarpValue + (1.0 - _WarpValue), 2.0);

                float3 finalcolor = nl * _LightColor0.rgb;

                return float4(finalcolor, 1.0);
            }
            ENDCG
        }
    }
}
