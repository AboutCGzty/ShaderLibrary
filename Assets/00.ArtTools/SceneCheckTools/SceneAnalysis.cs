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

public class MemoryAnalysis
{
	
	public class MeshInfo {
		public long memorySize;
		public long verticesTotal;
		public int usedCount;
	}

	static List<Transform> _allChildrenTransfroms = new List<Transform>();

	public Dictionary<Mesh, MeshInfo> _meshesCombined = new Dictionary<Mesh, MeshInfo>();
	public Dictionary<Mesh, MeshInfo> _meshesUncombined = new Dictionary<Mesh, MeshInfo>();
	public Dictionary<Texture, int> _activeTextures = new Dictionary<Texture, int>();

	public long CalcTextureMemories() {
		long memoryTotal = 0;
		foreach (KeyValuePair<Texture, int> kvp in _activeTextures)
			memoryTotal += kvp.Value;
		return memoryTotal;
	}

	public long CalcMeshesCombinedMemories() {
		long memoryTotal = 0;
		foreach (KeyValuePair<Mesh, MeshInfo> kvp in _meshesCombined)
			memoryTotal += kvp.Value.memorySize;
		return memoryTotal;
	}

	public long CalcMeshesUncombinedMemories() {
		long memoryTotal = 0;
		foreach (KeyValuePair<Mesh, MeshInfo> kvp in _meshesUncombined)
			memoryTotal += kvp.Value.memorySize;
		return memoryTotal;
	}

	public static string GetMemoriesString(long byteSize) {
		float byteToMB = byteSize / (1024.0f * 1024.0f);
		float byteToKB = byteSize / (1024.0f);
		string memorySizeStr = byteSize >= 1024 * 1024 ? byteToMB + "MB" : byteToKB +  "KB";
		return memorySizeStr;
	}

	void CleanBuffer() {
		_allChildrenTransfroms.Clear();
		_meshesCombined.Clear();
		_meshesUncombined.Clear();
		_activeTextures.Clear();
	}

	public void DoAnalyse(bool isScene) {
		CleanBuffer();

		if (isScene) {
			foreach (var root in GetAllRootGamObjects())
				GetAllChildren(root.transform);
		}
		DoMeshesAnalyse();
		DoTexturesAnalyse();
		if (isScene)
			DoEnvAnalyse();
	}

	//统计Mesh
	private void DoMeshesAnalyse() {
		foreach (Transform tr in _allChildrenTransfroms) {
			if (GameObjectUtility.AreStaticEditorFlagsSet(tr.gameObject, StaticEditorFlags.BatchingStatic)) {
				if (tr.gameObject.activeSelf)
				{
					MeshFilter meshFilter = tr.GetComponent<MeshFilter>();
					if (meshFilter)
					{
						AddMeshCombined(meshFilter.sharedMesh);
					}
					else
					{
						SkinnedMeshRenderer renderer = tr.GetComponent<SkinnedMeshRenderer>();
						if (renderer)
							AddMeshCombined(renderer.sharedMesh);
					}
				}
				else
				{ 
					//没激活的静态的Mesh不会占内存
				}
			}
			else 
			{  
				//不合并的mesh，无论是否激活都会占用内存
				MeshFilter meshFilter = tr.GetComponent<MeshFilter>();
				if (meshFilter) {
					AddMeshUncombined(meshFilter.sharedMesh);
				} else {
					SkinnedMeshRenderer renderer = tr.GetComponent<SkinnedMeshRenderer>();
					if (renderer)
						AddMeshUncombined(renderer.sharedMesh);
				}
			}
		}
	}

	//统计所有材质球上的Texture
	private void DoTexturesAnalyse() {
		List<Material> activeMaterials = new List<Material>();
		foreach (Transform tr in _allChildrenTransfroms) {
			Renderer renderer = tr.GetComponent<Renderer>();
			if (renderer) {  //无论是否激活贴图都会占用内存
				foreach (Material material in renderer.sharedMaterials) {
					if (!activeMaterials.Contains(material))
						activeMaterials.Add(material);
				}
			}
		}

		foreach (Material material in activeMaterials) {
			var dependencies = EditorUtility.CollectDependencies(new UnityEngine.Object[] { material });
			foreach (Object obj in dependencies) {
				Texture texture = obj as Texture;
				if (texture){
					AddTexture(texture);
				}
			}
		}
	}
	//统计场景环境Texture
	void DoEnvAnalyse() {
		//天空盒
		if (RenderSettings.skybox != null) {
			var dependencies = EditorUtility.CollectDependencies(new UnityEngine.Object[] { RenderSettings.skybox });
			foreach (Object obj in dependencies) {
				Texture texture = obj as Texture;
				if (texture){
					AddTexture(texture);
				}
			}
		}

		//自定义反射球
		if (RenderSettings.customReflection != null) {
			Texture texture = RenderSettings.customReflection;
			AddTexture(texture);
		}

		//Lightmap
		for (int i = 0; i < LightmapSettings.lightmaps.Length; i++) {
			Texture2D mlightmap = LightmapSettings.lightmaps[i].lightmapColor;
			if (mlightmap)
			{
				AddTexture(mlightmap);
			}
			Texture2D mlightDir = LightmapSettings.lightmaps[i].lightmapDir;
			if (mlightDir)
			{
				AddTexture(mlightDir);
			}
			Texture2D mshadowmap = LightmapSettings.lightmaps[i].shadowMask;
			if (mshadowmap)
			{
				AddTexture(mshadowmap);
			}
		}

		//RefletionProbe
		if(ReflectionProbe.defaultTexture) //环境默认RefletionProbe
			AddTexture(ReflectionProbe.defaultTexture);
		foreach (var trans in _allChildrenTransfroms)
		{ 
			var _refProbe = trans.GetComponent<ReflectionProbe>();
			if (_refProbe) { 
				if(_refProbe.texture)
					AddTexture(_refProbe.texture);
			}
		}
	}

	//会返回未激活对象
	private void GetAllChildren(Transform parent) {
		_allChildrenTransfroms.Add(parent);

		for (int i = 0; i < parent.childCount; i++) {
			Transform child = parent.GetChild(i);
			GetAllChildren(child);
		}
	}

	public static GameObject[] GetAllRootGamObjects() {
		return EditorSceneManager.GetActiveScene().GetRootGameObjects();
		
	}

	private void AddMeshCombined(Mesh mesh) {
		if (mesh) {
			MeshInfo meshInfo;
			if (!_meshesCombined.TryGetValue(mesh, out meshInfo)) {
				meshInfo = new MeshInfo();
				_meshesCombined.Add(mesh, meshInfo);
			}

			meshInfo.memorySize += Profiler.GetRuntimeMemorySizeLong(mesh)/2; //合并的Mesh不可读写，需要除以2才是原本的数据
			meshInfo.verticesTotal += mesh.vertexCount;
			meshInfo.usedCount++;
		}
	}

	private void AddMeshUncombined(Mesh mesh) {
		if (mesh)
		{
			MeshInfo meshInfo;
			if (!_meshesUncombined.TryGetValue(mesh, out meshInfo))
			{
				meshInfo = new MeshInfo();
				_meshesUncombined.Add(mesh, meshInfo);
			}
			if (mesh.isReadable){ //判断Mesh是否可读写
				meshInfo.memorySize = Profiler.GetRuntimeMemorySizeLong(mesh);
			}
			else {
				meshInfo.memorySize = Profiler.GetRuntimeMemorySizeLong(mesh)/2;
			}           
			meshInfo.verticesTotal = mesh.vertexCount;
			meshInfo.usedCount++;
		}
	}

	private void AddTexture(Texture texture) {
		if (!_activeTextures.ContainsKey(texture))
		{
			int memSize = (int)(Profiler.GetRuntimeMemorySizeLong(texture) / 2);
			_activeTextures.Add(texture, memSize);
		}
	}
}

public class SceneMemoryAnalysis : EditorWindow {
	private MemoryAnalysis _memoryAnalysis;

	Vector2 _textureListScrollPos = new Vector2(0, 0);
	Vector2 _meshListScrollPos = new Vector2(0, 0);
	Vector2 _animationClipsListScrollPos = new Vector2(0, 0);

	static string[] _inspectToolbarStrings = { "Textures", "Meshes"/*, "Animation"*/ };
	int _currentPage = 0;

	void OnEnable() {
		titleContent = new GUIContent("场景内存统计");
	}

	public void InitData() {
		_memoryAnalysis = new MemoryAnalysis();
	}


	void OnGUI() {

		if (GUILayout.Button("Start")) {
			_memoryAnalysis.DoAnalyse(true);
		}

		long texturesMemories = _memoryAnalysis.CalcTextureMemories();
		long meshesCombinedMemories = _memoryAnalysis.CalcMeshesCombinedMemories();
		long meshesUncombinedMemories = _memoryAnalysis.CalcMeshesUncombinedMemories();
		long totalMemories = texturesMemories + (meshesCombinedMemories + meshesUncombinedMemories);

		GUILayout.Label("估计总内存：" + MemoryAnalysis.GetMemoriesString(totalMemories));
		//EditorGUILayout.BeginHorizontal();
		GUILayout.Label("贴图占用：" + MemoryAnalysis.GetMemoriesString(texturesMemories));
		GUILayout.Label("Mesh占用：" + MemoryAnalysis.GetMemoriesString(meshesCombinedMemories + meshesUncombinedMemories) + " (其中未合并Mesh占用：" + MemoryAnalysis.GetMemoriesString(meshesUncombinedMemories) + ")");

		_currentPage = GUILayout.Toolbar(_currentPage, _inspectToolbarStrings);
		switch (_currentPage) {
			case 0:
				//GUILayout.Label("(显示格式 —— 贴图名: 占用内存大小)");
				ListTextures();
				break;

			case 1:
				GUILayout.Label("                                                                     (占用内存大小/总顶点数/使用次数)    (红色为未合并网格)");
				ListMeshes();
				break;
		}
	}

	private void ListTextures() {
		_textureListScrollPos = EditorGUILayout.BeginScrollView(_textureListScrollPos);

		var dicSort = from objDic in _memoryAnalysis._activeTextures orderby objDic.Value descending select objDic;
		foreach (KeyValuePair<Texture, int> kvp in dicSort) {
			EditorGUILayout.BeginHorizontal();
			if(GUILayout.Button(kvp.Key.name,GUILayout.Width(250)))
				Selection.objects = new Object[] { kvp.Key };
			//GUILayout.Label(kvp.Key.name, GUILayout.Width(300));
			GUILayout.Space(50);
			GUILayout.Label(MemoryAnalysis.GetMemoriesString(kvp.Value), GUILayout.Width(100));
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("查找引用", GUILayout.Width(80)))
			{
				string _path = AssetDatabase.GetAssetPath(kvp.Key);
				_path = _path.Replace("Assets/", "");
				_path = "ref:" + _path;
				FindReferenceInScene(_path);
			}
			EditorGUILayout.EndHorizontal();
		}
		EditorGUILayout.EndScrollView();
	}

	private void ListMeshes() {
		_meshListScrollPos = EditorGUILayout.BeginScrollView(_meshListScrollPos);


		var dicCombinedSort = from objCombinedDic in _memoryAnalysis._meshesCombined orderby objCombinedDic.Value.memorySize descending select objCombinedDic;
		Color initColor = GUI.contentColor;
		foreach (KeyValuePair<Mesh, MemoryAnalysis.MeshInfo> kvp in dicCombinedSort)
		{
			EditorGUILayout.BeginHorizontal();
			if (GUILayout.Button(kvp.Key.name, GUILayout.Width(250)))
				Selection.objects = new Object[] { kvp.Key };
			GUILayout.Space(50);
			GUILayout.Label(MemoryAnalysis.GetMemoriesString(kvp.Value.memorySize) + "/" + kvp.Value.verticesTotal + "/" + kvp.Value.usedCount);
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("查找引用", GUILayout.Width(80)))
			{
				string _path = AssetDatabase.GetAssetPath(kvp.Key);
				int instanceID = kvp.Key.GetInstanceID();
				_path = _path.Replace("Assets/", "");
				_path = "ref:" + instanceID + ":" + _path;
				FindReferenceInScene(_path);
			}
			EditorGUILayout.EndHorizontal();
		}
		//未合并Mesh列表
		var dicUnCombinedSort = from objUnCombinedDic in _memoryAnalysis._meshesUncombined orderby objUnCombinedDic.Value.memorySize descending select objUnCombinedDic;
		foreach (KeyValuePair<Mesh, MemoryAnalysis.MeshInfo> kvp in dicUnCombinedSort)
		{
			EditorGUILayout.BeginHorizontal();
			GUI.contentColor = Color.red;
			if (GUILayout.Button(kvp.Key.name, GUILayout.Width(250)))
				Selection.objects = new Object[] { kvp.Key };
			GUILayout.Space(50);
			GUILayout.Label(MemoryAnalysis.GetMemoriesString(kvp.Value.memorySize) + "/" + kvp.Value.verticesTotal + "/" + kvp.Value.usedCount);
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("查找引用", GUILayout.Width(80)))
			{
				string _path = AssetDatabase.GetAssetPath(kvp.Key);
				int instanceID = kvp.Key.GetInstanceID();
				_path = _path.Replace("Assets/", "");
				_path = "ref:" + instanceID +":" + _path;
				FindReferenceInScene(_path);
			}
			EditorGUILayout.EndHorizontal();
		}
		GUI.contentColor = initColor;

		EditorGUILayout.EndScrollView();
	}

	//查找在场景中的所有引用
	private void FindReferenceInScene(string filter)
	{
		SearchableEditorWindow[] windows = (SearchableEditorWindow[])Resources.FindObjectsOfTypeAll(typeof(SearchableEditorWindow));
		SearchableEditorWindow hierarchy = null;
		foreach (SearchableEditorWindow window in windows)
		{
			if (window.GetType().ToString() == "UnityEditor.SceneView")
			{

				hierarchy = window;
				break;
			}
		}
		if (hierarchy == null)
			return;


		MethodInfo setSearchType = typeof(SearchableEditorWindow).GetMethod("SetSearchFilter", BindingFlags.NonPublic | BindingFlags.Instance);
		object[] parameters = new object[] { filter, 0, true,false };

		setSearchType.Invoke(hierarchy, parameters);
	}
}



