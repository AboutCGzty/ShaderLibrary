Shader "ZTY/LightingModel/Specular/Gouraud"
{
    Properties
    {
        _GourardPower("Gourard Power", Range(1.0, 100.0)) = 30.0
        _GourardIntensity("Gourard Intensity", Range(0.0, 1.0)) = 1.0
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
                float4 gouraud : TEXCOORD2;
            };

            float _GourardPower;
            float _GourardIntensity;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = mul(unity_ObjectToWorld, v.normal);
                o.postion_world = mul(unity_ObjectToWorld, v.vertex);

                float3 worldnormal = normalize(o.normal_world);
                float3 worldlightdir = normalize(_WorldSpaceLightPos0.xyz);
                float3 view_world = normalize(_WorldSpaceCameraPos.xyz - o.postion_world.xyz);
                float3 reflec_world = normalize(reflect(-worldlightdir, worldnormal));

                float Gourard = dot(view_world, reflec_world);
                Gourard = pow(Gourard, _GourardPower) * _GourardIntensity;
                o.gouraud = Gourard;

                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                return float4(i.gouraud * _LightColor0.rgb, 1.0);
            }
            ENDCG
        }
    }
}
