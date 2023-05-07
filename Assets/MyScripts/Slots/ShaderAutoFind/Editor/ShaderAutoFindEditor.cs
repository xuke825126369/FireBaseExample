using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ShaderAutoFind))]
public class ShaderAutoFindEditor : Editor
{
	private ShaderAutoFind instance;
	void Awake()
	{
		instance = (ShaderAutoFind)target;
		EditorUtility.SetDirty(instance);
	}

	public override void OnInspectorGUI()
	{
		base.DrawDefaultInspector();
		instance = (ShaderAutoFind)target;
		GUI.changed = false;

		if (GUILayout.Button("自动寻找Shader", GUILayout.MaxWidth(100)))
		{
			GetAllShaderVariantCount();
		}

		if (GUILayout.Button("Find Legacy Shader", GUILayout.MaxWidth(200)))
		{
			FindLegacyShader();
		}

		if (GUILayout.Button("Relace Legacy Shader", GUILayout.MaxWidth(200)))
		{
			RelaceLegacyShader();
		}
	}

	public void FindLegacyShader()
	{
		AssetDatabase.SaveAssets();

		var matList = AssetDatabase.FindAssets("t:Material");
		foreach (var i in matList)
		{
			var path = AssetDatabase.GUIDToAssetPath(i);
			Material s = AssetDatabase.LoadAssetAtPath(path, typeof(Material)) as Material;
			if (s.shader.name.StartsWith("Legacy"))
			{
				Debug.Log("Legacy: " + path + " | " + s.shader.name);
			}
		}
	}

	public void RelaceLegacyShader()
    {
		var matList = AssetDatabase.FindAssets("t:Material");
		foreach (var i in matList)
		{
			var path = AssetDatabase.GUIDToAssetPath(i);
			Material s = AssetDatabase.LoadAssetAtPath(path, typeof(Material)) as Material;
			if (s.shader.name.StartsWith("Legacy"))
			{
				if(s.shader.name == "Legacy Shaders/Particles/Additive")
                {
					s.shader = Shader.Find("Mobile/Particles/Additive");
                }

				if (s.shader.name == "Legacy Shaders/Particles/Alpha Blended")
				{
					s.shader = Shader.Find("Mobile/Particles/Alpha Blended");
				}

				if (s.shader.name == "Legacy Shaders/Particles/Additive (Soft)")
				{
					s.shader = Shader.Find("Mobile/Particles/Additive");
				}

				if (s.shader.name == "Legacy Shaders/Particles/Alpha Blended Premultiply")
				{
					s.shader = Shader.Find("Mobile/Particles/Alpha Blended");
				}

				if (s.shader.name == "Legacy Shaders/Particles/Anim Alpha Blended")
				{
					s.shader = Shader.Find("Mobile/Particles/Alpha Blended");
				}
			}
		}
		
		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
	}
	
	public void GetAllShaderVariantCount()
	{
		AssetDatabase.SaveAssets();

		instance.mShaderList.Clear();
		var shaderList = AssetDatabase.FindAssets("t:Shader");
		foreach (var i in shaderList)
		{
			var path = AssetDatabase.GUIDToAssetPath(i);
			Shader s = AssetDatabase.LoadAssetAtPath(path, typeof(Shader)) as Shader;
			if (!instance.mShaderList.Contains(s))
			{
				instance.mShaderList.Add(s);
			}
		}

		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
	}

	static void CreateNewPrefab(GameObject obj, string newPath)
	{
		Object prefab = PrefabUtility.SaveAsPrefabAssetAndConnect(obj, newPath, InteractionMode.AutomatedAction);
		if (prefab == null)
		{
			Debug.LogError(newPath + "新 创建预制件 失败 0000000");
		}

		AssetDatabase.SaveAssets();
	}
}

