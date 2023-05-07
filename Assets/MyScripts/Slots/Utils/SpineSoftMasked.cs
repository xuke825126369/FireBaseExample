using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Spine.Unity;

[ExecuteInEditMode]
[DisallowMultipleComponent]
public class SpineSoftMasked : MonoBehaviour {

	public SpriteRenderer m_mask; 
	private SkeletonAnimation m_skeletonAnimation;
	public int m_stencilRef = 0;
	public CompareFunction m_stencilComp = CompareFunction.Always;
	public StencilOp m_stencilOp = StencilOp.Keep;

	private Material m_material;
	int m_alphaMaskPropertyId;
	int m_alphaAreaPropertyId;
	int m_stencilRefPropertyId;
	int m_stencilCompPropertyId;
	int m_stencilOpPropertyId;

	void Start()
	{
		m_alphaMaskPropertyId = Shader.PropertyToID("_AlphaMask");
		m_alphaAreaPropertyId = Shader.PropertyToID("_AlphaArea");
		m_stencilRefPropertyId = Shader.PropertyToID("_Stencil");
		m_stencilCompPropertyId = Shader.PropertyToID("_StencilComp");
		m_stencilOpPropertyId = Shader.PropertyToID("_StencilOp");

		m_material = new Material(ShaderAutoFind.Find("Customer/SpineMaskElem"));
		m_skeletonAnimation = GetComponent<SkeletonAnimation>();
		if (m_skeletonAnimation != null && m_skeletonAnimation.skeletonDataAsset != null)
		{
			AtlasAsset[] atlasAssets = m_skeletonAnimation.skeletonDataAsset.atlasAssets;
			foreach (AtlasAsset atlasAsset in atlasAssets)
			{
				foreach (Material atlasMaterial in atlasAsset.materials)
				{
					m_material.mainTexture = atlasMaterial.mainTexture;
					m_skeletonAnimation.CustomMaterialOverride[atlasMaterial] = m_material;
				}
			}
		}
		m_material.EnableKeyword("HAS_ALPHAMASK");
	}

	void Update()
	{
		if (m_skeletonAnimation == null || m_mask == null || m_mask.sprite == null)
			return;
		Vector3 maskSize = m_mask.bounds.size;
		Vector3 maskPos = m_mask.transform.position;
		Vector3 maskScale = Vector3.one;
		Vector3 maskAreaMin = new Vector3(maskPos.x - maskSize.x / 2 * maskScale.x, maskPos.y - maskSize.y / 2 * maskScale.y, maskPos.z);
		Vector3 maskAreaMax = new Vector3(maskPos.x + maskSize.x / 2 * maskScale.x, maskPos.y + maskSize.y / 2 * maskScale.y, maskPos.z);

		Vector3 min = transform.InverseTransformPoint(maskAreaMin);
		Vector3 max = transform.InverseTransformPoint(maskAreaMax);
		Rect rect = new Rect(min.x, min.y, max.x - min.x, max.y - min.y);
		Vector2 scale = new Vector2(m_mask.sprite.textureRect.width / m_mask.sprite.texture.width / rect.size.x,
			m_mask.sprite.textureRect.height / m_mask.sprite.texture.height / rect.size.y);
		Vector2 offset = -rect.min;
		offset.Scale(scale);
		offset += new Vector2(m_mask.sprite.textureRect.xMin / m_mask.sprite.texture.width,
							   m_mask.sprite.textureRect.yMin / m_mask.sprite.texture.height);
		Vector4 area = new Vector4(m_mask.sprite.textureRect.xMin / m_mask.sprite.texture.width,
			m_mask.sprite.textureRect.yMin / m_mask.sprite.texture.height,
			m_mask.sprite.textureRect.xMax / m_mask.sprite.texture.width,
			m_mask.sprite.textureRect.yMax / m_mask.sprite.texture.height);

		m_material.SetInt(m_stencilRefPropertyId, m_stencilRef);
		m_material.SetInt(m_stencilCompPropertyId, (int)m_stencilComp);
		m_material.SetInt(m_stencilOpPropertyId, (int)m_stencilOp);
		m_material.SetTextureOffset(m_alphaMaskPropertyId, offset);
		m_material.SetTextureScale(m_alphaMaskPropertyId, scale);
		m_material.SetVector(m_alphaAreaPropertyId, area);
		m_material.SetTexture(m_alphaMaskPropertyId, m_mask.sprite.texture);

	}
}
