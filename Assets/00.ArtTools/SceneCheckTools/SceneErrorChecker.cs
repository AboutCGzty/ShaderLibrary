using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;


public class SceneErrorChecker : EditorWindow {
	public static bool _checkGameObjects = true;
	public static bool _checkLights = true;
	public static bool _checkBakeSettings = true;
	public static bool _checkMeshUV2 = true;

	void OnEnable() {
		titleContent = new GUIContent("检查设置");
	}

	void OnGUI() {
		_checkGameObjects = EditorGUILayout.Toggle("检查GameObject", _checkGameObjects);
		_checkLights = EditorGUILayout.Toggle("检查灯光设置", _checkLights);
		_checkBakeSettings = EditorGUILayout.Toggle("检查烘焙设置", _checkBakeSettings);
		_checkMeshUV2 = EditorGUILayout.Toggle("检查Mesh第二层UV", _checkMeshUV2);

		if (GUILayout.Button("开始")) {
			CheckAll();
		}
	}

	void CheckAll() {
		ClearLogWindow();

		if (_checkGameObjects)
			CheckAllGameObjects();
		if (_checkLights)
			CheckAllLights();
		if (_checkBakeSettings)
			CheckBakeSettings();
		if (_checkMeshUV2)
			CheckMeshUV2();
	}

	void ClearLogWindow() {
		var assembly = Assembly.GetAssembly(typeof(UnityEditor.Editor));
		var type = assembly.GetType("UnityEditor.LogEntries");
		var method = type.GetMethod("Clear");
		method.Invoke(new object(), null);
	}

	void CheckAllGameObjects() {
		GameObject sceneRoot = GameObject.Find("map");
		if (sceneRoot == null)
		{
			Debug.LogError("场景中必须存在map根节点");
			return;
		}
		else
		{ 
			var renderGroup = sceneRoot.GetComponentsInChildren<Renderer>();
			foreach(var renderer in renderGroup)
			{
				CheckMaterialError(renderer);
				CheckGameObjectFlag(renderer.gameObject);
			}
		}

		CheckGroupManage();

		CheckHelpRootSetting();

	}

	//检查材质球丢失
	private void CheckMaterialError(Renderer renderer)
	{ 
		if (renderer.sharedMaterials.Length > 0)
		{ 
			var mat = renderer.sharedMaterials[0];
			if(mat == null)
				Debug.LogError(renderer.gameObject.name + "丢失材质球", renderer.gameObject);
			else
				CheckShaderError(mat);
		}
	}

	//检查Shader
	private void CheckShaderError(Material mat)
	{ 
		if(mat.shader != null)
		{
			if (!mat.shader.name.Contains("Qtz"))
				Debug.LogError(mat.name + "材质球必须要使用Qtz组下的Shader", mat);
		}
		else
		{
			Debug.LogError(mat.name + "材质球的Shader丢失", mat);
		}
	}

	//检查Gameobject的Flag设置
	private void CheckGameObjectFlag(GameObject go)
	{
		if(GameObjectUtility.AreStaticEditorFlagsSet(go,StaticEditorFlags.ContributeGI) && !GameObjectUtility.AreStaticEditorFlagsSet(go,StaticEditorFlags.BatchingStatic))
			Debug.LogError(go.name + "勾选了lightmapStatic却没有勾选BatchingStatic！！！", go);
	}

	//检查场景物件分组情况
	private void CheckGroupManage()
	{
		GameObject staticRoot = GameObject.Find("staticObjs");
		if (staticRoot == null)
		{
			Debug.LogWarning("场景中没有找到staticObjs，建议按照map/staticObjs对静态物体进行分类");
		}

		GameObject dynamicRoot = GameObject.Find("dynObjs");
		if (dynamicRoot == null)
		{
			Debug.LogWarning("场景中没有找到dynObjs，建议按照map/dynObjs对非静态物体进行分类");
		}
	}

	//检查HelpRoot设置
	private void CheckHelpRootSetting()
	{
		var helpRoot = GameObject.Find("HelpRoot");
		if(helpRoot == null)
			return;
		else
		{
			var help_Renderers = helpRoot.transform.GetComponentsInChildren<MeshRenderer>();
			foreach (var renderer in help_Renderers)
			{
				if (renderer.enabled)
					Debug.LogError(string.Format("请禁用HelpRoot下{0}物体的MeshRenderer组件", renderer.gameObject.name), renderer.gameObject);
			}
		}

		GameObject clickArea = GameObject.Find("HelpRoot/ClickArea");
		if (clickArea == null)
		{
			Debug.LogError("没有找到ClickArea物体，检查是否存在或隐藏");
		}
		else if (!clickArea.activeSelf || clickArea.layer != LayerMask.NameToLayer("ClickArea"))
		{
			Debug.LogError("ClickArea物体设置错误");
		}

		GameObject flyClickArea = GameObject.Find("HelpRoot/FlyClickArea");
		if (flyClickArea == null)
		{
			Debug.LogError("没有找到FlyClickArea物体,检查是否存在或隐藏");
		}
		else if (!flyClickArea.activeSelf || flyClickArea.layer != LayerMask.NameToLayer("FlyClickArea"))
		{
			Debug.LogError("FlyClickArea物体设置错误");
		}
	}

	//检查灯光设置
	void CheckAllLights() {
		foreach (Light light in Object.FindObjectsOfType<Light>()) {
			if (light.enabled && light.cullingMask == -1) {
				if(light.lightmapBakeType != LightmapBakeType.Realtime && !light.bakingOutput.isBaked)
					Debug.LogError(light.name + ": 该灯光还没有参与烘焙，请删除或重新烘焙", light);
				else if (light.lightmapBakeType == LightmapBakeType.Realtime)
					Debug.LogError(light.name + ": 该灯光为实时光", light);
			}
		}

	}

	//检查烘焙设置
	void CheckBakeSettings() {

		if (Lightmapping.realtimeGI)
			Debug.LogError("[Lighting面板] 必须关闭Realtime Global Illumination模式！");

		if (!Lightmapping.bakedGI)
			Debug.LogError("[Lighting面板] 必须勾选Baked GI模式！");

		if (Lightmapping.giWorkflowMode != Lightmapping.GIWorkflowMode.OnDemand)
			Debug.LogError("[Lighting面板] 请关闭Auto模式！");

		if (LightmapSettings.lightmaps.Length > 2)
		{
			Debug.LogError("[Lighting面板] lightmap贴图最多为两张");
		}
		if (Lightmapping.lightingSettings.lightmapMaxSize != 2048)
			Debug.LogError("[Lighting面板] 建议将Lightmapping Settings -> Lightmap Size设置为2048");

		if (LightmapSettings.lightmapsMode != LightmapsMode.NonDirectional)
			Debug.LogError("[Lighting面板] 必须将Directional Mode设置为Non-Directional");

		if (RenderSettings.fog) {
			if (RenderSettings.fogMode != FogMode.Linear) {
				Debug.LogError("[Lighting面板] Fog->Fog Mode使用线性雾！");
			}
		}
	}

	void CheckMeshUV2() {
		List<Mesh> sharedMeshes = new List<Mesh>();
		foreach (MeshFilter meshFilter in Object.FindObjectsOfType<MeshFilter>()) {
			if (GameObjectUtility.AreStaticEditorFlagsSet(meshFilter.gameObject, StaticEditorFlags.ContributeGI)) {
				if (meshFilter.sharedMesh != null && !sharedMeshes.Contains(meshFilter.sharedMesh)) {
					sharedMeshes.Add(meshFilter.sharedMesh);
				}
			}
		}

		int index = 0;
		foreach (Mesh mesh in sharedMeshes) {
			if (!EditorUtility.DisplayCancelableProgressBar("Checking UV 2", mesh.name, index++ / (float)sharedMeshes.Count)) {
				for (int i = 0; i < mesh.uv.Length; i++) {
					Vector2 lightmapUV;
					if (mesh.uv2.Length == 0)
						lightmapUV = mesh.uv[i];
					else
						lightmapUV = mesh.uv2[i];
					if (lightmapUV.x < 0 || lightmapUV.x < 0 || lightmapUV.y > 1 || lightmapUV.y > 1) {
						Debug.LogError(mesh.name + ": uv2不在[0, 1]范围内！", mesh);
						break;
					}
				}
			} else {
				break;
			}

		}
		EditorUtility.ClearProgressBar();
	}

}

