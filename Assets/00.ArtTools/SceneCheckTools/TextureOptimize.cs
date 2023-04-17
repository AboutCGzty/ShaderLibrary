using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Linq;
/// <summary>
/// 优化贴图
/// </summary>
class TextureOptimize : EditorWindow
{
    static string CheckPath,
        DesPath;

    static int potBase = 4;

    public class Choice
    {

        public int width
        {
            get; private set;
        }
        public int height
        {
            get; private set;
        }

        public Choice(int x, int y)
        {
            this.width = x * potBase;
            this.height = y * potBase;
        }
        public void OnGUI()
        {
            var msg = string.Format("调整至{0},{1}", width, height);
            GUILayout.Label(msg);
        }

        public override string ToString()
        {
            return string.Format("x,y", width, height);
        }
    }

    [MenuItem("美术工具/贴图检测/导出非4N图片")]
    static void Init()
    {
        // Get existing open window or if none, make a new one:
        TextureOptimize window = (TextureOptimize)EditorWindow.GetWindow(typeof(TextureOptimize), false, "贴图优化");

        window.ShowPopup();
    }


    private void OnSelectionChange()
    {
    }


    private void OnGUI()
    {
        if (GUILayout.Button("搜索非4的倍数尺寸图片"))
        {
            CheckPath = Application.dataPath;
            //保存的目标目录
            DesPath = Application.dataPath;
            var index = DesPath.LastIndexOf(@"/Assets");
            DesPath = DesPath.Substring(0, index);
            DesPath = Path.Combine(DesPath, "NPOTS");

            string withExtensions = "*.jpg*.png";//*.asset
            string[] files = Directory.GetFiles(CheckPath,
                "*", SearchOption.AllDirectories)
                .Where(s => withExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
            var startIndex = 0;

            EditorApplication.update = delegate ()
            {
                bool isCancel = false;
                if (files.Length > 0)
                {
                    string file = files[startIndex];
                    file = FileUtil.GetProjectRelativePath(file);

                    isCancel = EditorUtility.DisplayCancelableProgressBar("搜索中", file,
                        (float)startIndex / (float)files.Length);

                    var tex = AssetDatabase.LoadAssetAtPath<Texture>(file);
                    if (tex == null) return;
                    var w_left = tex.width % potBase;
                    var h_right = tex.height % potBase;
                    bool isNPOT = w_left != 0 || h_right != 0;
                    if (isNPOT)
                    {
                        var saveFile = DesPath+file;
                        saveFile=saveFile.Replace("\\", @"/");
                        var srcPath = Path.GetFullPath(file);
                        var savePath = Path.GetDirectoryName(saveFile);
                        if (!Directory.Exists(savePath))
                            Directory.CreateDirectory(savePath);
                        File.Copy(srcPath, saveFile,true);
                    }

                    //isCancel = true;
                }

                startIndex++;

                if (isCancel || startIndex >= files.Length)
                {
                    EditorUtility.ClearProgressBar();
                    EditorApplication.update = null;
                    startIndex = 0;
                    Debug.Log("已导出贴图至" + DesPath + "Assets");

                }
            };
        }
    }

    public static void CopyDirContentIntoDestDirectory(string srcdir, string dstdir, bool overwrite)
    {
        if (!Directory.Exists(dstdir))
            Directory.CreateDirectory(dstdir);

        foreach (var s in Directory.GetFiles(srcdir))
            File.Copy(s, Path.Combine(dstdir, Path.GetFileName(s)), overwrite);

        foreach (var s in Directory.GetDirectories(srcdir))
            CopyDirContentIntoDestDirectory(s, Path.Combine(dstdir, Path.GetFileName(s)), overwrite);
    }
}