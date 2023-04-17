Shader "Hidden/CustomTemplate/FXTemplate"
{
    Properties
    {
        [Header(Rendering Settings ____________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _CullMode("CullMode", int) = 2
        [Toggle]_ZWrite("ZWrite", int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTest("ZTest", int) = 4
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendSrc("Src", int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendDst("Dst", int) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _BlendOp("Op", int) = 0

        [Header(Color Settings ________________________________________________________________________________________________________________________________________________________________________)]
        [Space(10)]
        _BaseColor("BaseColor", Color) = (1.0, 1.0, 1.0, 0.0)
        _MainTex ("MainTex", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            Name "FX"

            Tags
            {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
                "ForceNoShadowCasting" = "True"
                "IgnoreProjector" = "True"
                "PerformanceChecks" = "True"
            }

            Cull [_CullMode]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            BlendOp [_BlendOp]
            Blend [_BlendSrc] [_BlendDst]
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 posCS : SV_POSITION;
            };

            half3 _BaseColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.posCS = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (VertexOutput i) : SV_Target
            {
                half3 col = tex2D(_MainTex, i.uv).rgb;
                col*= _BaseColor.rgb;

                return half4(col, 1.0);
            }
            ENDCG
        }
    }
}
