Shader "Unlit/NewUnlitShader"                                   // Shader路径与名称
{
    Properties                                                  // 暴露在Inspector面板的参数
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader                                                   // 第一个表面着色器，可以有多个
    {
        Tags { "RenderType"="Opaque" }                          // 定义标签

        Pass                                                    // 第一个Pass，可以有多个
        {
            CGPROGRAM                                           // 开始CG代码
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexInput                                  // 顶点输入结构体
            {
                float4 vertex    : POSITION;                    // 获取模型空间顶点坐标信息
                float2 uv        : TEXCOORD0;                   // 获取模型uv坐标信息
            };

            struct VertexOutput                                 // 顶点输出结构体
            {
                float2 uv        : TEXCOORD0;                   // 输出模型uv坐标信息
                float4 vertex    : SV_POSITION;                 // 输出模型空间顶点坐标信息
            };

            sampler2D _MainTex;                                 // 声明主纹理
            float4 _MainTex_ST;                                 // 声明主纹理采样信息

            VertexOutput vert (VertexInput v)                   // 顶点Shader
            {
                VertexOutput o;                                 // 声明一个顶点Shader“o”
                o.vertex = UnityObjectToClipPos(v.vertex);      // 将模型顶点坐标转从本地空间换至齐次裁剪空间
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);           // 将模型uv与主纹理进行坐标映射
                return o;                                       // 返回“o”
            }

            half4 frag (VertexOutput i) : SV_Target             // 片元Shader
            {
                half4 finalcolor = tex2D(_MainTex, i.uv);       // 采样一张主纹理
                return finalcolor;                              // 返回最终颜色
            }
            ENDCG                                               // 结束CG代码
        }
    }
}
