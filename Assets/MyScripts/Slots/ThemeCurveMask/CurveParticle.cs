using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[ExecuteAlways]
[DisallowMultipleComponent]
[RequireComponent(typeof(ParticleSystem))]
public class CurveParticle : CurveGroupChildren
{
	private static Material m_defaultNormalMaterial;
	private static Material m_defaultAddictiveMaterial;
	private static Material m_defaultLightenMaterial;
	private MaterialPropertyBlock m_materialProperty;
	private ParticleSystemRenderer m_particleSystemRenderer;
	
	public Sprite m_sprite;
	public Color m_color = Color.white;
	public BlendOption blendOption;
	[SerializeField] 
	private Material m_material;
	
	int m_mainTexPropertyId;
	int m_centerPropertyId;
	int m_colorPropertyId;
	int m_areaWidthPropertyId;
	int m_areaHeightPropertyId;
	
	void Start ()
	{
		Build ();
	}
		
	static Material defaultNormalMaterial
	{
		get
		{
			if (m_defaultNormalMaterial == null) {
				m_defaultNormalMaterial = new Material (ShaderAutoFind.Find ("Customer/CurveParticle"));
				m_defaultNormalMaterial.name = "default normal materail";
				m_defaultNormalMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
				m_defaultNormalMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
			}
			return m_defaultNormalMaterial;
		}
	}

	static Material defaultAddictivelMaterial
	{
		get
		{
			if (m_defaultAddictiveMaterial == null) {
				m_defaultAddictiveMaterial = new Material (ShaderAutoFind.Find ("Customer/CurveParticle"));
				m_defaultAddictiveMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
				m_defaultAddictiveMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
			}
			return m_defaultAddictiveMaterial;
		}
	}

	static Material defaultLightenMaterial
	{
		get
		{
			if (m_defaultLightenMaterial == null) {
				m_defaultLightenMaterial = new Material (ShaderAutoFind.Find ("Customer/CurveParticle"));
				m_defaultLightenMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
				m_defaultLightenMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
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

	public void Build()
	{
		Init();

		Material material = m_material == null ? GetDefaultMaterial(blendOption) : m_material;
		m_particleSystemRenderer.material = material;
		InitMaskGroup();
	}

	void OnDidApplyAnimationProperties()
	{
		if (m_materialProperty != null) {
			m_materialProperty.SetColor (m_colorPropertyId, m_color);
			m_particleSystemRenderer.SetPropertyBlock(m_materialProperty);
		}
	}

	//---------------------------------2021-03-11 冗余重构经典关卡-----------------------------------
	private void Init()
	{
		if (!orInit())
		{
			m_mainTexPropertyId = Shader.PropertyToID("_MainTex");
			m_centerPropertyId = Shader.PropertyToID("_Center");
			m_colorPropertyId = Shader.PropertyToID("_TintColor");
			m_areaWidthPropertyId = Shader.PropertyToID("_AreaWidth");
			m_areaHeightPropertyId = Shader.PropertyToID("_AreaHeight");
			m_materialProperty = new MaterialPropertyBlock();
			m_particleSystemRenderer = GetComponent<ParticleSystemRenderer>();
		}
	}

	protected override bool orInit()
	{
		return m_materialProperty != null;
	}

	public override void UpdateMaskGroupClipRect()
    {
		if (!orInit()) return;

		if (m_sprite != null)
		{
			m_materialProperty.SetTexture(m_mainTexPropertyId, m_sprite.texture);
			Vector2 scale = new Vector2(m_sprite.textureRect.width / m_sprite.texture.width,
										m_sprite.textureRect.height / m_sprite.texture.height);
			Vector2 offset = new Vector2(m_sprite.textureRect.xMin / m_sprite.texture.width,
										m_sprite.textureRect.yMin / m_sprite.texture.height);
			m_materialProperty.SetVector("_MainTex_ST", new Vector4(scale.x, scale.y, offset.x, offset.y));
		}

		m_materialProperty.SetColor(m_colorPropertyId, m_color);

		if (m_RectMaskGroup != null)
		{
			var center = new Vector3(0, m_RectMaskGroup.transform.position.y, m_RectMaskGroup.transform.position.z + m_RectMaskGroup.m_curveRadius);
			m_materialProperty.SetVector(m_centerPropertyId, center);
			m_materialProperty.SetFloat(m_areaWidthPropertyId, m_RectMaskGroup.m_areaSize.x);
			m_materialProperty.SetFloat(m_areaHeightPropertyId, m_RectMaskGroup.m_areaSize.y);
		}

		m_particleSystemRenderer.SetPropertyBlock(m_materialProperty);
	}
}
