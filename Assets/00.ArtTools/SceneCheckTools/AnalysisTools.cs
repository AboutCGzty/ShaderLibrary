using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Reflection;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;

	public class AnalysisTools {
	
		[MenuItem("美术工具/场景检查/场景内存统计...", false, 0)]
		private static void SceneMemoryWindow() {
			SceneMemoryAnalysis window = (SceneMemoryAnalysis)EditorWindow.GetWindow(typeof(SceneMemoryAnalysis));
			window.InitData();
		}

		[MenuItem("美术工具/场景检查/检查设置", false, 2)]
		private static void SceneErrorCheckerWindow()
		{
			SceneErrorChecker window = (SceneErrorChecker)EditorWindow.GetWindow(typeof(SceneErrorChecker));
		}

		[MenuItem("美术工具/Prefab资源分析", false, 1)]
		private static void Init()
		{
			AssetAnalysisWindow window = (AssetAnalysisWindow)EditorWindow.GetWindow(typeof(AssetAnalysisWindow));

			//window.Show();
		}
        [MenuItem("美术工具/Shader相关/Shader引用查找")]
		private static void ProjectHelperWindow()
		{
            ProjectHelper window = (ProjectHelper)EditorWindow.GetWindow(typeof(ProjectHelper));
		}
		
}
