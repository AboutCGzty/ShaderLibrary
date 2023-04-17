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

// 法线混合 算法
float3 NormalBlend(float3 normalA, float3 normalB)
{
    return normalize(float3(normalA.xy + normalB.xy, normalA.z * normalB.z));
}

// 线性雾
float LinearFogFactor(float Start, float End, float Distance)
{
    float a = End - Distance;
    float b = End - Start;
    float c = a / max(0.000001, b);

    return 1.0 - saturate(c);
}

// 颜色转换 算法 ===================================================================================================================================== //
float3 RGBToHSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
    float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
    float d = q.x - min( q.w, q.y );
    float e = 1.0e-10;
    return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 HSVToRGB( float3 c )
{
    float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
    float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
    return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
}
// -------------------------------------------------------------- //

// Noise 算法 ===================================================================================================================================== //
// sample2D ----------------------------------------------------- //
float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
float snoise( float2 v )
{
    const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
    float2 i = floor( v + dot( v, C.yy ) );
    float2 x0 = v - i + dot( i, C.xx );
    float2 i1;
    i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod2D289( i );
    float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
    float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
    m = m * m;
    m = m * m;
    float3 x = 2.0 * frac( p * C.www ) - 1.0;
    float3 h = abs( x ) - 0.5;
    float3 ox = floor( x + 0.5 );
    float3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;

    return 130.0 * dot( m, g );
}
// -------------------------------------------------------------- //

// gradient noise ----------------------------------------------- //
float2 GradientNoiseDir( float2 x )
{
    const float2 k = float2( 0.3183099, 0.3678794 );
    x = x * k + k.yx;

    return -1.0 + 2.0 * frac( 16.0 * k * frac( x.x * x.y * ( x.x + x.y ) ) );
}
			
float GradientNoise( float2 UV, float Scale )
{
    float2 p = UV * Scale;
    float2 i = floor( p );
    float2 f = frac( p );
    float2 u = f * f * ( 3.0 - 2.0 * f );

    return lerp( lerp( dot( GradientNoiseDir( i + float2( 0.0, 0.0 ) ), f - float2( 0.0, 0.0 ) ),
           dot( GradientNoiseDir( i + float2( 1.0, 0.0 ) ), f - float2( 1.0, 0.0 ) ), u.x ),
           lerp( dot( GradientNoiseDir( i + float2( 0.0, 1.0 ) ), f - float2( 0.0, 1.0 ) ),
           dot( GradientNoiseDir( i + float2( 1.0, 1.0 ) ), f - float2( 1.0, 1.0 ) ), u.x ), u.y );
}
// -------------------------------------------------------------- //


#endif //逻辑就是如果没有包含ZTYCGINC，就定义一个ZTYCGINC；   如果已经包含ZTYCGINC，就不会再定义