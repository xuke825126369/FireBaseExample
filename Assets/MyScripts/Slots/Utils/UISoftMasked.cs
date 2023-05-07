using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum BlendOption
{
	Normal = 0,
	Addictive = 1,
	Lighten = 3
}

[ExecuteAlways]
[XLua.LuaCallCSharp]
public class UISoftMasked : MonoBehaviour {

	Material mat;
	readonly Vector3[] m_WorldCorners = new Vector3[4];
	readonly Vector3[] m_CanvasCorners = new Vector3[4];
	
	public Image m_maskGraphic;
	private Image m_graphic;
	public BlendOption blendOption;
	public bool inverse;

	Vector2 maskOffset = Vector2.zero;
	Vector2 maskScale = Vector2.one;

	private int m_alphaMaskPropertyId;
	private int m_alphaAreaPropertyId;
	int m_srcBendPropertyId;
	int m_dstBendPropertyId;
	
	void Start()
	{
		Build ();
	}

	public void Build()
	{
		m_alphaMaskPropertyId = Shader.PropertyToID("_AlphaMask");
		m_alphaAreaPropertyId = Shader.PropertyToID("_AlphaArea");
		m_srcBendPropertyId = Shader.PropertyToID("_SrcBlend");
		m_dstBendPropertyId = Shader.PropertyToID("_DstBlend");

		m_graphic = GetComponent<Image>();
		if (m_graphic != null)
		{
			mat = new Material(ShaderAutoFind.Find("Customer/UISoftMasked"));
			m_graphic.material = mat;
			if (!inverse)
			{
				mat.DisableKeyword("INVERSE_MASK");
			}
			else
			{
				mat.EnableKeyword("INVERSE_MASK");
			}
			SetMask();
		}
	}

	void Update()
	{
		#if UNITY_EDITOR
		if(m_graphic.material != mat) {
			m_graphic.material = mat;
		}
		#endif
		SetMask();
	}

	void SetMask()
	{
		var worldRect = GetCanvasRect();
		var size = worldRect.size;
		maskScale.Set(m_maskGraphic.sprite.textureRect.width / m_maskGraphic.sprite.texture.width / size.x, m_maskGraphic.sprite.textureRect.height / m_maskGraphic.sprite.texture.height / size.y);
		maskOffset = -worldRect.min;
		maskOffset.Scale(maskScale);
		maskOffset += new Vector2 (m_maskGraphic.sprite.textureRect.xMin / m_maskGraphic.sprite.texture.width,
			m_maskGraphic.sprite.textureRect.yMin / m_maskGraphic.sprite.texture.height);

		Vector4 area = new Vector4 (m_maskGraphic.sprite.textureRect.xMin / m_maskGraphic.sprite.texture.width,
			m_maskGraphic.sprite.textureRect.yMin / m_maskGraphic.sprite.texture.height, 
			m_maskGraphic.sprite.textureRect.xMax / m_maskGraphic.sprite.texture.width,
			m_maskGraphic.sprite.textureRect.yMax / m_maskGraphic.sprite.texture.height);

		mat.SetTextureOffset(m_alphaMaskPropertyId, maskOffset);
		mat.SetTextureScale(m_alphaMaskPropertyId, maskScale);
		mat.SetTexture(m_alphaMaskPropertyId, m_maskGraphic.mainTexture);
		mat.SetVector (m_alphaAreaPropertyId, area);
		if(blendOption == BlendOption.Normal) {
			mat.SetInt(m_srcBendPropertyId, (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
			mat.SetInt(m_dstBendPropertyId, (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
		} 
		else if(blendOption == BlendOption.Addictive) {
			mat.SetInt(m_srcBendPropertyId, (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
			mat.SetInt(m_dstBendPropertyId, (int)UnityEngine.Rendering.BlendMode.One);
		}
		else if(blendOption == BlendOption.Lighten) {
			mat.SetInt(m_srcBendPropertyId, (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
			mat.SetInt(m_dstBendPropertyId, (int)UnityEngine.Rendering.BlendMode.One);
		}
	}

	public Rect GetCanvasRect()
	{
		m_maskGraphic.rectTransform.GetWorldCorners(m_WorldCorners);
		for (int i = 0; i < 4; ++i)
			m_CanvasCorners[i] = m_graphic.canvas.transform.InverseTransformPoint(m_WorldCorners[i]);

		return new Rect(m_CanvasCorners[0].x, m_CanvasCorners[0].y, m_CanvasCorners[2].x - m_CanvasCorners[0].x, m_CanvasCorners[2].y - m_CanvasCorners[0].y);
	}
}

