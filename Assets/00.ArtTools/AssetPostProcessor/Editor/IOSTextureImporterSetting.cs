using System.IO;
using UnityEditor;

public class IOSTextureImporterSetting : AssetPostprocessor
{
    /// <summary>
    /// 贴图资源路径设置
    /// </summary>
    const string texpath1 = "Assets/PBR/Textures/";
    const string texpath2 = "Assets/NPR/1.角色/tex";

    private void OnPreprocessTexture()
    {
        string filename = Path.GetFileName(assetPath);

        if (assetPath.Contains(texpath1))
        {
            TextureImporter teximporter = (TextureImporter)assetImporter;
            if (filename.Contains("_N"))
            {
                teximporter.SetTextureType(true);
            }
            else
            {
                teximporter.SetTextureType(false);
            }

            if (filename.Contains("_Ref"))
            {
                teximporter.SetTextureAdvance(true);
                teximporter.SetTextureCommon(true, true);
            }
            else
            {
                teximporter.SetTextureAdvance(false);
                teximporter.SetTextureCommon(false, true);
            }

            if (filename.Contains("_M"))
            {
                teximporter.SetTextureAdvance(false);
                teximporter.SetTextureCommon(false, false);
            }
            else
            {
                teximporter.SetTextureAdvance(false);
            }

            teximporter.SetTextureAlpha();
            teximporter.SetTextureAlpha();

            TextureImporterPlatformSettings format = teximporter.GetDefaultPlatformTextureSettings();
            format.maxTextureSize = 1024;
            format.resizeAlgorithm = TextureResizeAlgorithm.Mitchell;
            format.format = TextureImporterFormat.Automatic;
            format.textureCompression = TextureImporterCompression.Compressed;
            if (teximporter.crunchedCompression == true)
            {
                teximporter.compressionQuality = 50;
            }
            else
            {
                teximporter.crunchedCompression = false;
            }
            teximporter.SetPlatformTextureSettings(format);

            teximporter.SetTextureApple();
        }

        if (assetPath.Contains(texpath2))
        {
            TextureImporter teximporter = (TextureImporter)assetImporter;
            if (filename.Contains("_N"))
            {
                teximporter.SetTextureType(true);
            }
            else
            {
                teximporter.SetTextureType(false);
            }

            if (filename.Contains("_Ref"))
            {
                teximporter.SetTextureAdvance(true);
                teximporter.SetTextureCommon(true, true);
            }
            else
            {
                teximporter.SetTextureAdvance(false);
                teximporter.SetTextureCommon(false, true);
            }

            if (filename.Contains("_M"))
            {
                teximporter.SetTextureAdvance(false);
                teximporter.SetTextureCommon(false, false);
            }
            else
            {
                teximporter.SetTextureAdvance(false);
            }

            teximporter.SetTextureAlpha();
            teximporter.SetTextureAlpha();

            TextureImporterPlatformSettings format = teximporter.GetDefaultPlatformTextureSettings();
            format.maxTextureSize = 1024;
            format.resizeAlgorithm = TextureResizeAlgorithm.Mitchell;
            format.format = TextureImporterFormat.Automatic;
            format.textureCompression = TextureImporterCompression.Compressed;
            if (teximporter.crunchedCompression == true)
            {
                teximporter.compressionQuality = 50;
            }
            else
            {
                teximporter.crunchedCompression = false;
            }
            teximporter.SetPlatformTextureSettings(format);

            teximporter.SetTextureApple();
        }
    }
}
