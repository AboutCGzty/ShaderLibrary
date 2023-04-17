Shader "ZTY/LightingModel/Specular/Phong"
{
    Properties
    {
        _PhongPower("Phong Power", Range(1.0, 100.0)) = 30.0
        _PhongIntensity("Phong Intensity", Range(0.0, 1.0)) = 1.0
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
                float3 normal_world : TEXCOORD0; 
                float4 postion_world : TEXCOORD1;
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = mul(unity_ObjectToWorld, v.normal);
                o.postion_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float _PhongPower;
            float _PhongIntensity;

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 worldnormal = normalize(i.normal_world);
                float3 worldlightdir = normalize(_WorldSpaceLightPos0.xyz);
                float3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.postion_world.xyz);
                float3 reflec_world = normalize(reflect(-worldlightdir, worldnormal));

                float phong = dot(reflec_world, view_world);
                phong = pow(phong, _PhongPower) * _PhongIntensity;

                float3 finalcolor = phong * _LightColor0.rgb;

                return float4(finalcolor, 1.0);
            }
            ENDCG
        }
    }
}
