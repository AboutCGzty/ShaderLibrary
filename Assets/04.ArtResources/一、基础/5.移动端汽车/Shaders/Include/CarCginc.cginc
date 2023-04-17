#ifndef ZTYCGINC
#define ZTYCGINC

//球谐函数
float3 SHCOLOR (float3 normal_dir, half4 SHAr, half4 SHAg, half4 SHAb, half4 SHBr, half4 SHBg, half4 SHBb, half4 SHC, float intensity)
{
    float4 normalForSH = float4(normal_dir, 1.0);
    //SHEvalLinearL0L1
    half3 x;
    x.r = dot(SHAr, normalForSH);
    x.g = dot(SHAg, normalForSH);
    x.b = dot(SHAb, normalForSH);
    
    //SHEvalLinearL2
    half3 x1, x2;

    // 4 of the quadratic (L2) polynomials
    half4 vB = normalForSH.xyzz * normalForSH.yzzx;
    x1.r = dot(SHBr, vB);
    x1.g = dot(SHBg, vB);
    x1.b = dot(SHBb, vB);
    
    // Final (5th) quadratic (L2) polynomial
    half vC = normalForSH.x * normalForSH.x - normalForSH.y * normalForSH.y;
    x2 = SHC.rgb * vC;
    
    float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
    sh = pow(sh, 1.0 / 2.2) * intensity;
    
    return sh;
}

//ACES-Tonemapping 色调映射
float3 ACES_Tonemapping(float3 color_input)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    float3 encode_color = saturate((color_input * (a * color_input + b)) / (color_input * (c * color_input + d) + e));

    return encode_color;
}

//Angle To Radian 角度转弧度
float3 ROTATE_Dir(float rot, float3 reflec_dir)
{
    float rad = rot * UNITY_PI / 180.0;
    float2x2 m_rotat = float2x2(cos(rad), -sin(rad), 
                                sin(rad), cos(rad));
    float2 rotDir = mul(m_rotat, reflec_dir.xz);
    reflec_dir = float3(rotDir.x, reflec_dir.y, rotDir.y);

    return reflec_dir;
}

//Local Reflection 修复立方体反射
float3 LocalReflection(float3 pos_world, float3 reflec_world, float3 center, float3 size)
{
    float3 pos1 = -size - pos_world;
    float3 pos2 = size - pos_world;
    float3 ref1 = pos1 / reflec_world;
    float3 ref2 = pos2 / reflec_world;
    float3 ref3 = max(ref1, ref2);
    float3 pos3 = min(min(ref3.x, ref3.y), ref3.z) * reflec_world;
    float3 pos4 = pos3 + center + pos_world;

    return pos4;
}

//BoxMask 矩形遮罩
float BOXMASK(float3 pos_world, float3 center, float3 size)
{
    float box_mask = 1.0 - saturate(distance(max(abs(pos_world - center) - size, 0.0), 0.0)) / 0.01;

    return box_mask;
}

#endif //逻辑就是如果没有包含ZTYCGINC，就定义一个ZTYCGINC；   如果已经包含ZTYCGINC，就不会再定义