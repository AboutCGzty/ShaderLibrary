Shader "ZTY/LightingModel/Diffuse/CheapSSS"
{
    Properties
    {
        _CheapSSSSpread("CheapSSS Spread", float) = 0.0
        _CheapSSSPower("CheapSSS Power", Range(1.0, 10.0)) = 1.0
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
                float4 postion_world : TEXCOORD0;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = mul(unity_ObjectToWorld, v.normal);
                o.postion_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float _CheapSSSSpread;
            float _CheapSSSPower;

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 worldnormal = normalize(i.normal_world) * _CheapSSSSpread;
                float3 worldlightdir = normalize(_WorldSpaceLightPos0.xyz);
                float3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.postion_world.xyz);

                float nl = dot(-normalize(worldnormal + worldlightdir), view_world);
                nl = pow(nl, _CheapSSSPower);

                float3 finalcolor = nl * _LightColor0.rgb;

                return float4(finalcolor, 1.0);
            }
            ENDCG
        }
    }
}
