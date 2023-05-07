using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using xk_System;
using XLua;

[DisallowMultipleComponent]
[ExecuteAlways]
[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
[LuaCallCSharp]
public class CurveItem : CurveGroupChildren
{
	private static Material m_defaultNormalMaterial;
	private static Material m_defaultAddictiveMaterial;
	private static Material m_defaultLightenMaterial;
	private MaterialPropertyBlock m_materialProperty;

	private int m_segmentCount;
	private MeshFilter m_meshFilter;
	private MeshRenderer m_meshRenderer;
	Mesh mesh = null;

	Vector3[] verts = new Vector3[0];
	int[] indices = new int[0];
	Vector2[] uvs = new Vector2[0];

	int m_mainTexPropertyId;
	int m_centerPropertyId;
	int m_colorPropertyId;
	int m_areaWidthPropertyId;
	int m_areaHeightPropertyId;
	int m_alphaMaskPropertyId;
	int m_alphaMaskSTPropertyId;
	int m_alphaAreaPropertyId;

	[SerializeField] 
	Material m_material;
	public Color m_color = Color.white;

	public Sprite m_mainSprite;
	public Vector2 m_size = new Vector2(1, 1);
	public string m_sortingLayerName = "Default";
	[SerializeField] 
	private int m_sortingOrder = 0;
	public BlendOption blendOption;

	private Sprite m_lastFrameSprite = null;

	public ArrayGCPool<Vector3> mVector3Pool = new ArrayGCPool<Vector3> ();

	public int sortingOrder 
	{
		get
		{
			return m_sortingOrder;
		}
		set
		{
			m_sortingOrder = value;
			if (m_meshRenderer != null)
			{
				m_meshRenderer.sortingOrder = m_sortingOrder;
			}
		}
	}

	public float alpha 
	{
		set { 

			m_color.a = value;
			if (m_materialProperty != null) {
				m_materialProperty.SetColor (m_colorPropertyId, m_color); 
				m_meshRenderer.SetPropertyBlock (m_materialProperty);
			}
		}
	}

	public Color color 
	{
		set { 
			m_color = value;
			if (m_materialProperty != null) {
				m_materialProperty.SetColor (m_colorPropertyId, m_color); 
				m_meshRenderer.SetPropertyBlock (m_materialProperty);
			}
		}
	}

	public Rect worldRect
	{
		get { 
			Vector3 pos = transform.position;
			Vector3 scale = transform.lossyScale;
			return new Rect (pos.x - m_size.x / 2 * scale.x, pos.y - m_size.y / 2 * scale.y, 
				m_size.x * scale.x, m_size.y * scale.y);
		}
	}

	public Vector3[] worldCorners
	{
		get {
			Vector3 pos = transform.position;
			Vector3 scale = transform.lossyScale;

			Vector3[] array = mVector3Pool.Pop (2);
			array[0] = new Vector3 (pos.x - m_size.x / 2 * scale.x, pos.y - m_size.y / 2 * scale.y, pos.z);
			array[1] = new Vector3 (pos.x + m_size.x / 2 * scale.x, pos.y + m_size.y / 2 * scale.y, pos.z);

			return  array;
		}
	}
	
	static Material defaultNormalMaterial
	{
		get
		{
			if (m_defaultNormalMaterial == null) {
				m_defaultNormalMaterial = new Material (ShaderAutoFind.Find ("Customer/CurveItem"));
				m_defaultNormalMaterial.name = "default normal materail";
				m_defaultNormalMaterial.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
				m_defaultNormalMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
				m_defaultNormalMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
				m_defaultNormalMaterial.DisableKeyword("HAS_ALPHAMASK");
			}
			return m_defaultNormalMaterial;
		}
	}

	static Material defaultAddictivelMaterial
	{
		get
		{
			if (m_defaultAddictiveMaterial == null) {
				m_defaultAddictiveMaterial = new Material (ShaderAutoFind.Find ("Customer/CurveItem"));
				m_defaultAddictiveMaterial.name = "default addictive materail";
				m_defaultAddictiveMaterial.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
				m_defaultAddictiveMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
				m_defaultAddictiveMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
				m_defaultAddictiveMaterial.DisableKeyword("HAS_ALPHAMASK");
			}
			return m_defaultAddictiveMaterial;
		}
	}

	static Material defaultLightenMaterial
	{
		get
		{
			if (m_defaultLightenMaterial == null) {
				m_defaultLightenMaterial = new Material (ShaderAutoFind.Find ("Customer/CurveItem"));
				m_defaultLightenMaterial.name = "default addictive materail";
				m_defaultLightenMaterial.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
				m_defaultLightenMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
				m_defaultLightenMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
				m_defaultLightenMaterial.DisableKeyword("HAS_ALPHAMASK");
			}
			return m_defaultLightenMaterial;
		}
	}

	Material GetDefaultMaterial(BlendOption blendOption)
	{
		if (blendOption == BlendOption.Addictive) {
			return defaultAddictivelMaterial;
		} else if (blendOption == BlendOption.Lighten) {
			return defaultLightenMaterial;
		} else {
			return defaultNormalMaterial;
		}
	}

    // Use this for initialization
    void Start ()
	{
		Build ();
	}

	public void Build()
	{
		Init();

		m_meshRenderer.sortingLayerName = m_sortingLayerName;
		m_meshRenderer.sortingOrder = m_sortingOrder;

		CurveAlphaMask curveAlphaMaskParent = transform.parent.GetComponent<CurveAlphaMask>();
		if (curveAlphaMaskParent == null)
		{
			m_meshRenderer.sharedMaterial = m_material == null ? GetDefaultMaterial (blendOption) : m_material;
		}
		else
		{
			if (m_material == null)
			{
				Material material = new Material (ShaderAutoFind.Find ("Customer/CurveItem"));
				material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
				m_meshRenderer.sharedMaterial = material;
				if (blendOption == BlendOption.Normal) {
					material.SetInt ("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
					material.SetInt ("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
				} else if (blendOption == BlendOption.Addictive) {
					material.SetInt ("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
					material.SetInt ("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
				} else if (blendOption == BlendOption.Lighten) {
					material.SetInt ("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
					material.SetInt ("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
				}

				curveAlphaMaskParent.AddCurveChild (this);
				material.EnableKeyword ("HAS_ALPHAMASK");
			}
			else
			{
				Material material = new Material (m_material);
				material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
				m_meshRenderer.sharedMaterial = material;
			}
		}

		if (GetComponent<CurveAlphaMask> () != null)
		{
			bool showMask = GetComponent<CurveAlphaMask> ().showMask;
			m_meshRenderer.enabled = showMask;
		}

		InitMaskGroup();
	}

	public void SetMaskArea(Vector3 areaMin, Vector3 areaMax, Sprite sprite)
	{
		if (!orInit()) return;

		m_materialProperty.SetColor(m_colorPropertyId, m_color); 
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

		m_materialProperty.SetVector (m_alphaMaskSTPropertyId, new Vector4(maskScale.x, maskScale.y, maskOffset.x, maskOffset.y));
		m_materialProperty.SetTexture (m_alphaMaskPropertyId, sprite.texture);
		m_materialProperty.SetVector (m_alphaAreaPropertyId, area);
		m_meshRenderer.SetPropertyBlock (m_materialProperty);
	}

	private void UpdateMesh()
	{
		if (m_RectMaskGroup == null || m_mainSprite == null) return;

		Vector2 tightOffset = new Vector2(m_mainSprite.textureRectOffset.x / m_mainSprite.rect.size.x, m_mainSprite.textureRectOffset.y / m_mainSprite.rect.size.y);
		Vector2 tightScale = new Vector2(m_mainSprite.textureRect.size.x / m_mainSprite.rect.size.x, m_mainSprite.textureRect.size.y / m_mainSprite.rect.size.y);
		Vector2 boundsMin = new Vector2(transform.position.x - m_size.x / 2, transform.position.y - m_size.y / 2);
		boundsMin += new Vector2(m_size.x * tightOffset.x, m_size.y * tightOffset.y);
		Vector2 boundsMax = boundsMin + new Vector2(m_size.x * tightScale.x, m_size.y * tightScale.y);
		Vector2 actualCenter = (boundsMax + boundsMin) / 2f;
		Vector3 centerOffset = new Vector3(actualCenter.x - transform.position.x, actualCenter.y - transform.position.y, 0);

		float fActualSizeX = m_size.x * tightScale.x;
		float fActualSizeY = m_size.y * tightScale.y;
		m_segmentCount = (int)(Mathf.Ceil((fActualSizeY / (m_RectMaskGroup.m_curveRadius / 20.0f))));
		float segmentLength = fActualSizeY / m_segmentCount;

		// 确定 顶点数量 Begin
		int nVertCount = (m_segmentCount + 1) * 2;
		int nUvCount = nVertCount;
		int nTriangleCount = m_segmentCount * 6;

		if(nVertCount > verts.Length)
        {
			verts = new Vector3[nVertCount];
        }
		else if(nVertCount < verts.Length)
        {
			Array.Clear(verts, nVertCount, verts.Length - nVertCount);
		}

		if(nUvCount > uvs.Length)
        {
			uvs = new Vector2[nUvCount];
        }
        else if (nUvCount < uvs.Length)
        {
            Array.Clear(uvs, nUvCount, uvs.Length - nUvCount);
        }

        if (nTriangleCount > indices.Length)
        {
			indices = new int[nTriangleCount];
			for (int i = 0; i < m_segmentCount; i++)
			{
				int nVerBeginInex = i * 2;
				int nBeginIndex = i * 6;

				indices[nBeginIndex + 0] = nVerBeginInex + 0;
				indices[nBeginIndex + 1] = nVerBeginInex + 2;
				indices[nBeginIndex + 2] = nVerBeginInex + 1;
				
				indices[nBeginIndex + 3] = nVerBeginInex + 1;
				indices[nBeginIndex + 4] = nVerBeginInex + 2;
				indices[nBeginIndex + 5] = nVerBeginInex + 3;
			}

			mesh.vertices = verts;
			mesh.uv = uvs;
			mesh.triangles = indices;
		}

		// 确定 顶点数量 End

		for (int i = 0; i <= m_segmentCount; i++)
		{
			verts[i * 2] = new Vector3(-fActualSizeX / 2, -fActualSizeY / 2 + i * segmentLength, 0) + centerOffset;
			verts[i * 2 + 1] = new Vector3(fActualSizeX / 2, -fActualSizeY / 2 + i * segmentLength, 0) + centerOffset;

			uvs[i * 2] = new Vector2 (m_mainSprite.textureRect.xMin / m_mainSprite.texture.width, i * m_mainSprite.textureRect.height / m_mainSprite.texture.height / m_segmentCount + m_mainSprite.textureRect.yMin / m_mainSprite.texture.height);
			uvs[i * 2 + 1] = new Vector2 (m_mainSprite.textureRect.xMax / m_mainSprite.texture.width, i * m_mainSprite.textureRect.height / m_mainSprite.texture.height / m_segmentCount + m_mainSprite.textureRect.yMin / m_mainSprite.texture.height);
		}

		mesh.vertices = verts;
		mesh.uv = uvs;
		mesh.RecalculateBounds();
	}

	public Vector3 center
	{
		set 
		{ 
			Vector4 v = new Vector4(value.x, value.y, value.z, 1);
			if (m_materialProperty != null) {
				m_materialProperty.SetVector (m_centerPropertyId, v);
				m_meshRenderer.SetPropertyBlock(m_materialProperty);
			}
		}
	}

	void OnDidApplyAnimationProperties()
	{
		if (!orInit()) return;

		UpdateMesh();
		UpdateMaterialAtt();
	}

	// ------------------------------------------------- 2021-3-9 冗余重构经典关卡 ----------------------------------------------

	private void Init()
	{
		if (!orInit())
		{
			m_mainTexPropertyId = Shader.PropertyToID("_MainTex");
			m_centerPropertyId = Shader.PropertyToID("_Center");
			m_colorPropertyId = Shader.PropertyToID("_Color");
			m_areaWidthPropertyId = Shader.PropertyToID("_AreaWidth");
			m_areaHeightPropertyId = Shader.PropertyToID("_AreaHeight");
			m_alphaMaskPropertyId = Shader.PropertyToID("_AlphaMask");
			m_alphaMaskSTPropertyId = Shader.PropertyToID("_AlphaMask_ST");
			m_alphaAreaPropertyId = Shader.PropertyToID("_AlphaArea");

			m_meshFilter = GetComponent<MeshFilter>();
			m_meshRenderer = GetComponent<MeshRenderer>();

			m_materialProperty = new MaterialPropertyBlock();
			m_meshRenderer.SetPropertyBlock(m_materialProperty);

			mesh = new Mesh();
			m_meshFilter.sharedMesh = mesh;
		}
	}

	protected override bool orInit()
    {
		return m_materialProperty != null;
	}

    public override void UpdateMaskGroupClipRect()
	{
		if (!orInit()) return;
		UpdateMesh();
		UpdateMaterialAtt();
	}

	private void UpdateMaterialAtt()
    {
		if (m_mainSprite != null)
		{
			m_materialProperty.SetTexture(m_mainTexPropertyId, m_mainSprite.texture);
		}

		m_materialProperty.SetColor(m_colorPropertyId, m_color);

		if (m_RectMaskGroup != null)
		{
			m_materialProperty.SetFloat(m_areaWidthPropertyId, m_RectMaskGroup.m_areaSize.x);
			m_materialProperty.SetFloat(m_areaHeightPropertyId, m_RectMaskGroup.m_areaSize.y);
			var center = new Vector4(m_RectMaskGroup.transform.position.x, m_RectMaskGroup.transform.position.y, m_RectMaskGroup.transform.position.z + m_RectMaskGroup.m_curveRadius, 1);
			m_materialProperty.SetVector(m_centerPropertyId, center);
		}

		m_meshRenderer.SetPropertyBlock(m_materialProperty);
	}

	public Material sharedMaterial
    {
		get
		{
			if (orInit())
			{
				return m_meshRenderer.sharedMaterial;
			}else
            {
				return null;
            }
        }
    }

	public void GetPropertyBlock(MaterialPropertyBlock propertyBlock)
	{
		if (!orInit()) return;
		m_meshRenderer.GetPropertyBlock(propertyBlock);
	}

	public void SetPropertyBlock(MaterialPropertyBlock propertyBlock)
	{
		if (!orInit()) return;
		m_meshRenderer.SetPropertyBlock(propertyBlock);
	}

}
