using UnityEngine;
using UnityEditor;
using System;

namespace ShaderControl
{
	public class SCMenu : Editor
	{
		[MenuItem ("��������/Shaders Control", false, 5000)]
		static void BrowseShaders (MenuCommand command)
		{
			SCWindow.ShowWindow();
		}

	}
}
