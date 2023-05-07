using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;

public class SceneLightingSettingEditor : Editor 
{
	[MenuItem("Tools/ThemeReal3D/UpdateRenderSettting")]
	static void UpdateSceneRenderSettings() 
	{
		Material mMaterial = Resources.Load<Material>("Prefabs/Default-Skybox");
		RenderSettings.skybox = mMaterial;
		RenderSettings.sun = null;

		RenderSettings.ambientMode = AmbientMode.Flat;
		RenderSettings.ambientLight = new Color(1, 1, 1, 1);
		
		RenderSettings.defaultReflectionMode = DefaultReflectionMode.Skybox;
		RenderSettings.defaultReflectionResolution = 128;
		UnityEditor.LightmapEditorSettings.reflectionCubemapCompression = ReflectionCubemapCompression.Auto;
		RenderSettings.reflectionIntensity = 1;
		RenderSettings.reflectionBounces = 1;

		Lightmapping.realtimeGI = true;
		Lightmapping.giWorkflowMode = Lightmapping.GIWorkflowMode.Iterative;
		
		QualitySettings.pixelLightCount = 1;
	}
}
