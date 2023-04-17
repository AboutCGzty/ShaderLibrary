using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.Linq;
using System.IO;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using UnityEngine.Profiling;
using System.Reflection;

public class AssetAnalysisWindow : EditorWindow
{
	private Object m_source;
	private Dictionary<Object,int> m_objDic;
	private Dictionary<Object, Dictionary<Object,int>> m_referenceDic;
	private Vector2 obj_scrollPos;
	private Vector2 ref_scrollPos;
	private Object curSelection;

	void OnEnable()
	{
		titleContent = new GUIContent("资源性能分析");
	}

	void OnGUI()
	{
		GUILayout.BeginHorizontal();
		m_source = EditorGUILayout.ObjectField("目录/预设", m_source, typeof(Object), false,GUILayout.Width(300));
		if (m_source != null)
			DisplayButtons();
		GUILayout.EndHorizontal();

		EditorGUI.DrawRect(new Rect(0, 50, position.width, 2), Color.green);
		EditorGUI.DrawRect(new Rect(0, 350, position.width, 2), Color.green);

		GUILayout.BeginVertical();
		DisplayPerfabList();
		DisplayReferences();
		GUILayout.EndVertical();
	}

	private void DisplayButtons()
	{
		if (GUILayout.Button("Refresh", GUILayout.Width(150)))
			FindReference(m_source);
	}

	private void DisplayPerfabList()
	{
		if (m_objDic != null && m_objDic.Count > 0)
		{
			GUILayout.Space(10);
			GUILayout.Label("预设列表（只显示大于256K的资源）");
			obj_scrollPos = EditorGUILayout.BeginScrollView(obj_scrollPos,GUILayout.Height(300));
			var dicSort = from objDic in m_objDic orderby objDic.Value descending select objDic;
			foreach (var kvp in dicSort)
			{
				EditorGUILayout.BeginHorizontal();
				if (GUILayout.Button(kvp.Key.name, GUILayout.Width(250)))
					SelectObject(kvp.Key);
				GUILayout.Space(50);
				GUILayout.Label(MemoryAnalysis.GetMemoriesString(kvp.Value));
				GUILayout.FlexibleSpace();
				EditorGUILayout.EndHorizontal();
			}
			GUILayout.Space(20);
			EditorGUILayout.EndScrollView();
		}
	}

	private void DisplayReferences()
	{
		if (curSelection != null && m_referenceDic != null)
		{
			if (m_referenceDic.ContainsKey(curSelection))
			{
				GUILayout.Label("引用资源列表");
				ref_scrollPos = EditorGUILayout.BeginScrollView(ref_scrollPos);
				var curRefList = m_referenceDic[curSelection];
				var dicSort = from objDic in curRefList orderby objDic.Value descending select objDic;
				foreach (var kvp in dicSort)
				{
					EditorGUILayout.BeginHorizontal();
					GUILayout.Box((kvp.Key as Texture), GUILayout.Width(40), GUILayout.Height(40));
					if (GUILayout.Button(kvp.Key.name, GUILayout.Width(250)))
						Selection.objects = new Object[] { kvp.Key };
					GUILayout.Space(50);
					GUILayout.Label(MemoryAnalysis.GetMemoriesString(kvp.Value));
					GUILayout.FlexibleSpace();
					EditorGUILayout.EndHorizontal();
				}
				EditorGUILayout.EndScrollView();
			}
		}
	}

	void SelectObject(Object selectedObject)
	{
		Selection.objects = new Object[] { selectedObject };
		curSelection = selectedObject;
	}

	private void FindReference(Object resource)
	{
		InitDictionary();
		var fullPath = AssetDatabase.GetAssetPath(resource);
		if (Directory.Exists(fullPath))
		{
			var files = Directory.GetFiles(fullPath,"*",SearchOption.AllDirectories);
			int count = 0;
			foreach (var path in files)
			{
				count++;
				if(EditorUtility.DisplayCancelableProgressBar("正在处理",path,(float)count/(float)files.Length))
				{
					EditorUtility.ClearProgressBar();
					InitDictionary();
					return;
				}

				DoAssetAnalyse(path);
			}
			EditorUtility.ClearProgressBar();
		}
		if ((resource as GameObject))
		{
			DoAssetAnalyse(fullPath);    
		}
		GUIUtility.ExitGUI();
	}

	private void DoAssetAnalyse(string path)
	{
		var _prefab = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject));
		if (_prefab != null)
		{
			var dependencies = EditorUtility.CollectDependencies(new UnityEngine.Object[] { _prefab });
			var refList = new Dictionary<Object, int>();
			int sumSize = 0;
			foreach (var obj in dependencies)
			{
				var tex = obj as Texture;
				if (tex)
				{
					int memSize = (int)Profiler.GetRuntimeMemorySizeLong(tex) / 2;
					sumSize += memSize;
					refList.Add(tex, memSize);
				}
			}
			if ((sumSize / 1024) > 256) //大于256K
			{
				if (!m_referenceDic.ContainsKey(_prefab))
					m_referenceDic.Add(_prefab, refList);

				if (!m_objDic.ContainsKey(_prefab))
					m_objDic.Add(_prefab, sumSize);
			}
		}
	}

	private void InitDictionary()
	{
		m_objDic = new Dictionary<Object,int>();
		m_referenceDic = new Dictionary<Object, Dictionary<Object,int>>();
	}
}