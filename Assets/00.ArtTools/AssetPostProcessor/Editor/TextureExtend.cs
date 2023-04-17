using UnityEditor;
using UnityEngine;

public static class TextureExtend
{
    #region 【纹理设置】

    /// <summary>
    /// 判断是否法线
    /// </summary>
    /// <param name="teximporter"></param>
    /// <param name="isnormal"></param>
    public static void SetTextureType(this TextureImporter teximporter, bool isnormal)
    {
        if (isnormal)
        {
            teximporter.textureType = TextureImporterType.NormalMap;
        }
        else
        {
            teximporter.textureType = TextureImporterType.Default;
        }
    }

    /// <summary>
    /// 判断是否为Cubemap
    /// 判断是否有颜色
    /// </summary>
    /// <param name="teximporter"></param>
    /// <param name="iscube"></param>
    /// <param name="iscolor"></param>
    public static void SetTextureCommon(this TextureImporter teximporter, bool iscube, bool iscolor)
    {
        if (iscube)
        {
            teximporter.textureShape = TextureImporterShape.TextureCube;
        }
        else
        {
            teximporter.textureShape = TextureImporterShape.Texture2D;
        }

        if (iscolor)
        {
            teximporter.sRGBTexture = true;
        }
        else
        {
            teximporter.sRGBTexture = false;
        }

        teximporter.ignorePngGamma = false;
        teximporter.wrapMode = TextureWrapMode.Repeat;
        if (iscube)
        {
            teximporter.filterMode = FilterMode.Trilinear;
        }
        else
        {
            teximporter.filterMode = FilterMode.Bilinear;
        }
        teximporter.anisoLevel = 1;
    }

    /// <summary>
    /// 判断是否带Alpha
    /// </summary>
    /// <param name="teximporter"></param>
    public static void SetTextureAlpha(this TextureImporter teximporter)
    {
        if (teximporter.DoesSourceTextureHaveAlpha())
        {
            teximporter.alphaSource = TextureImporterAlphaSource.FromInput;
            teximporter.alphaIsTransparency = true;
        }
        else
        {
            teximporter.alphaSource = TextureImporterAlphaSource.None;
            teximporter.alphaIsTransparency = false;
        }
    }

    /// <summary>
    /// 修改Cubemap的高级参数
    /// </summary>
    /// <param name="teximporter"></param>
    /// <param name="iscube"></param>
    public static void SetTextureAdvance(this TextureImporter teximporter, bool iscube)
    {
        teximporter.npotScale = TextureImporterNPOTScale.ToNearest;
        teximporter.isReadable = false;
        teximporter.streamingMipmaps = false;
        teximporter.vtOnly = false;
        if (iscube)
        {
            teximporter.mipmapEnabled = true;
            teximporter.borderMipmap = false;
            teximporter.mipmapFilter = TextureImporterMipFilter.BoxFilter;
            teximporter.mipMapsPreserveCoverage = false;
            teximporter.fadeout = false;
        }
        else
        {
            teximporter.mipmapEnabled = false;
        }
    }

    /// <summary>
    /// Apple平台压缩设置
    /// </summary>
    /// <param name="teximporter"></param>
    public static void SetTextureApple(this TextureImporter teximporter)
    {
        TextureImporterPlatformSettings platformstandalone = teximporter.GetPlatformTextureSettings("iPhone");
        platformstandalone.overridden = true;
        platformstandalone.maxTextureSize = 2048;
        platformstandalone.resizeAlgorithm = TextureResizeAlgorithm.Mitchell;
        platformstandalone.format = TextureImporterFormat.ASTC_6x6;
        platformstandalone.textureCompression = TextureImporterCompression.CompressedHQ;
        platformstandalone.crunchedCompression = true;
        teximporter.SetPlatformTextureSettings(platformstandalone);
    }

    #endregion
}
