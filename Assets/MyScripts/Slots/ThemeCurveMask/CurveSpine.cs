using System.Collections;
using System.Collections.Generic;
using Spine.Unity;
using UnityEngine;
using UnityEngine.Rendering;
using XLua;

[LuaCallCSharp]
[ExecuteAlways]
[DisallowMultipleComponent]
public class CurveSpine : CurveGroupChildren
{
	int m_centerPropertyId;
	int m_colorPropertyId;
	int m_areaWidthPropertyId;
	int m_areaHeightPropertyId;
	
	private Material m_material;

	[SerializeField] 
	private string m_sortingLayerName = "Default";
	[SerializeField] 
	private int m_sortingOrder = 0;
	[SerializeField] 
	private Color m_color = Color.white;
	
	private MeshRenderer m_meshRenderer;
	int m_alphaMaskPropertyId;
	int m_alphaAreaPropertyId;

	void Start ()
	{
		Build ();
	}

	public void Build()
	{
		Init();
		m_meshRenderer.sortingLayerName = m_sortingLayerName;
		m_meshRenderer.sortingOrder = m_sortingOrder;

		//---------------------- 得到材质 Begin-----------------------
		Spine.Unity.SkeletonRenderer skeletonRenderer = GetComponent<Spine.Unity.SkeletonRenderer>();

		if (skeletonRenderer != null && skeletonRenderer.skeletonDataAsset != null)
		{
			Spine.Unity.AtlasAsset[] atlasAssets = skeletonRenderer.skeletonDataAsset.atlasAssets;

			foreach (Spine.Unity.AtlasAsset atlasAsset in atlasAssets)
			{
				foreach (Material atlasMaterial in atlasAsset.materials)
				{
					m_material.mainTexture = atlasMaterial.mainTexture;
					skeletonRenderer.CustomMaterialOverride[atlasMaterial] = m_material;
				}
			}
		}

		if (GetComponent<Spine.Unity.Modules.SkeletonRenderSeparator>() != null)
		{
			foreach (Spine.Slot slot in skeletonRenderer.skeleton.Slots)
			{
				skeletonRenderer.CustomSlotMaterials[slot] = m_material;
			}
		}
		//---------------------- 得到材质 End-----------------------

		CurveAlphaMask curveAlphaMaskParent = transform.parent.GetComponent<CurveAlphaMask>();
		if (curveAlphaMaskParent == null)
		{
			m_material.DisableKeyword("HAS_ALPHAMASK");
		}
		else
		{
			m_material.EnableKeyword("HAS_ALPHAMASK");
		}

		if (curveAlphaMaskParent != null)
		{
			curveAlphaMaskParent.AddCurveSpineChild(this);
		}

		InitMaskGroup();
	}

	public void SetMaskArea(Vector3 areaMin, Vector3 areaMax, Sprite sprite)
	{
		if (!orInit()) return;

		m_material.SetColor(m_colorPropertyId, m_color); 
		Vector3 min = transform.InverseTransformPoint (areaMin);
		Vector3 max = transform.InverseTransformPoint (areaMax);
		Rect rect = new Rect(min.x, min.y,  max.x - min.x, max.y - min.y);
		var size = rect.size;
		Vector2 maskScale = new Vector2(sprite.textureRect.width / sprite.texture.width / size.x, 
			sprite.textureRect.height / sprite.texture.height / size.y);
		Vector2 maskOffset = -rect.min;
		maskOffset.Scale (maskScale);
		maskOffset += new Vector2 (sprite.textureRect.xMin / sprite.texture.width,
			sprite.textureRect.yMin / sprite.texture.height);
		Vector4 area = new Vector4 (sprite.textureRect.xMin / sprite.texture.width,
			sprite.textureRect.yMin / sprite.texture.height, 
			sprite.textureRect.xMax / sprite.texture.width,
			sprite.textureRect.yMax / sprite.texture.height);
		
		m_material.SetTextureOffset(m_alphaMaskPropertyId, maskOffset);
		m_material.SetTextureScale (m_alphaMaskPropertyId, maskScale);
		m_material.SetTexture (m_alphaMaskPropertyId, sprite.texture);
		m_material.SetVector (m_alphaAreaPropertyId, area);
	}

	public Vector3 center
	{
		set 
		{ 
			if (m_material != null) {
				Vector4 v = new Vector4(value.x, value.y, value.z, 1);
				m_material.SetVector(m_centerPropertyId, v); 
			}
		}
	}

	public int sortingOrder 
	{
		get {  return m_sortingOrder; }
		set {
			m_sortingOrder = value;
			if (m_meshRenderer != null)
			{
				m_meshRenderer.sortingOrder = m_sortingOrder;
			}
		}
	}

	public Color color 
	{
		get { return m_color;}
		set {
			m_color = value;
			if (m_material != null)
			{
				m_material.SetColor (m_colorPropertyId, m_color);
			}
		}
	}

	public float alpha 
	{
		get { return m_color.a;}
		set {
			m_color.a = value;
			if (m_material != null)
			{
				m_material.SetColor (m_colorPropertyId, m_color); 
			}
       }
	}

	//---------------------------------2021-03-10 冗余重构经典关卡-----------------------------------
	private void Init()
	{
		if (!orInit())
		{
			m_centerPropertyId = Shader.PropertyToID("_Center");
			m_colorPropertyId = Shader.PropertyToID("_Color");
			m_areaWidthPropertyId = Shader.PropertyToID("_AreaWidth");
			m_areaHeightPropertyId = Shader.PropertyToID("_AreaHeight");
			m_alphaMaskPropertyId = Shader.PropertyToID("_AlphaMask");
			m_alphaAreaPropertyId = Shader.PropertyToID("_AlphaArea");
			
			m_meshRenderer = GetComponent<MeshRenderer>();

			m_material = new Material(ShaderAutoFind.Find("Customer/CurveSpine"));
		}
	}

	protected override bool orInit()
	{
		return m_meshRenderer != null;
	}

	public override void UpdateMaskGroupClipRect()
	{
		if (!orInit()) return;

		m_material.SetColor(m_colorPropertyId, m_color);

		if (m_RectMaskGroup != null)
		{
			m_material.SetFloat(m_areaWidthPropertyId, m_RectMaskGroup.m_areaSize.x);
			m_material.SetFloat(m_areaHeightPropertyId, m_RectMaskGroup.m_areaSize.y);
			var center = new Vector3(m_RectMaskGroup.transform.position.x, m_RectMaskGroup.transform.position.y, m_RectMaskGroup.transform.position.z + m_RectMaskGroup.m_curveRadius);
			m_material.SetVector(m_centerPropertyId, center);
		}
	}

}
