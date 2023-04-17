using UnityEngine;
using UnityEditor;
using System;

namespace ShaderControl
{
	public class SCMenu : Editor
	{
		[MenuItem ("美术工具/Shaders Control", false, 5000)]
		static void BrowseShaders (MenuCommand command)
		{
			SCWindow.ShowWindow();
		}

	}
}
