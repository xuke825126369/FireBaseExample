using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SpriteRendererRGBtoHSVControl : MonoBehaviour 
{
	private SpriteRenderer mSpriteRenderer;
	MaterialPropertyBlock materialPropertyBlock = null;

	[Range(0f, 360f)]
	public float _Hue;
	[Range(0f, 1f)]
	public float _Saturation;
	[Range(0f, 1f)]
	public float _Value;

	void Start ()
	{
		mSpriteRenderer = GetComponent<SpriteRenderer>();
		materialPropertyBlock = new MaterialPropertyBlock();

		Debug.Assert(mSpriteRenderer.sharedMaterial.HasProperty("_Hue"), "请添加正确的Shader材质");
		Debug.Assert(mSpriteRenderer.sharedMaterial.HasProperty("_Saturation"), "请添加正确的Shader材质");
		Debug.Assert(mSpriteRenderer.sharedMaterial.HasProperty("_Value"), "请添加正确的Shader材质");
	}

	void Update()
	{
		mSpriteRenderer.GetPropertyBlock(materialPropertyBlock);

		materialPropertyBlock.SetFloat("_Hue", _Hue);
		materialPropertyBlock.SetFloat("_Saturation", _Saturation);
		materialPropertyBlock.SetFloat("_Value", _Value);

		mSpriteRenderer.SetPropertyBlock(materialPropertyBlock);
	}

}
