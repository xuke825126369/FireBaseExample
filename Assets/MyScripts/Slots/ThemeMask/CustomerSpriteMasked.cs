using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using XLua;

[LuaCallCSharp]
[RequireComponent(typeof(SpriteRenderer))]
[DisallowMultipleComponent]
[ExecuteAlways]
public class CustomerSpriteMasked : CustomerRectMaskGroupChildren
{
    public SpriteRenderer m_SelfSoftMask;
    public BlendOption m_blendOption;

    private SpriteRenderer m_spriteRenderer;

    [SerializeField]
    private Material m_CustomMaterial;

    private static Material m_defaultNormalMaterial;
    private static Material m_defaultAddictiveMaterial;
    private static Material m_defaultLightenMaterial;
    private MaterialPropertyBlock m_materialProperty;

    private Bounds mDefaultSelfSoftClipRect = new Bounds(Vector3.zero, Vector3.zero);
    private Bounds mLastSelfSoftMaskRelativeRect;

    static Material defaultNormalMaterial
    {
        get
        {
            if (m_defaultNormalMaterial == null)
            {
                m_defaultNormalMaterial = new Material(ShaderAutoFind.Find("Customer/CustomerSpriteMasked"));
                m_defaultNormalMaterial.name = "default normal materail";
                m_defaultNormalMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                m_defaultNormalMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
            }
            return m_defaultNormalMaterial;
        }
    }

    static Material defaultAddictivelMaterial
    {
        get
        {
            if (m_defaultAddictiveMaterial == null)
            {
                m_defaultAddictiveMaterial = new Material(ShaderAutoFind.Find("Customer/CustomerSpriteMasked"));
                m_defaultAddictiveMaterial.name = "default addictive materail";
                m_defaultAddictiveMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                m_defaultAddictiveMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
            }
            return m_defaultAddictiveMaterial;
        }
    }

    static Material defaultLightenMaterial
    {
        get
        {
            if (m_defaultLightenMaterial == null)
            {
                m_defaultLightenMaterial = new Material(ShaderAutoFind.Find("Customer/CustomerSpriteMasked"));
                m_defaultLightenMaterial.name = "default Lighten materail";
                m_defaultLightenMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                m_defaultLightenMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
            }
            return m_defaultLightenMaterial;
        }
    }

    Material GetDefaultMaterial(BlendOption blendOption)
    {
        if (blendOption == BlendOption.Addictive)
        {
            return defaultAddictivelMaterial;
        }
        else if (blendOption == BlendOption.Lighten)
        {
            return defaultLightenMaterial;
        }
        else
        {
            return defaultNormalMaterial;
        }
    }

    protected override void Awake()
    {
        base.Awake();
        Init();
    }

    protected override bool orInit()
    {
        return m_materialProperty != null;
    }

    private void Init()
    {
        if (!orInit())
        {
            m_spriteRenderer = GetComponent<SpriteRenderer>();
            m_spriteRenderer.sharedMaterial = m_CustomMaterial == null ? GetDefaultMaterial(m_blendOption) : m_CustomMaterial;
            m_materialProperty = new MaterialPropertyBlock();
            m_spriteRenderer.SetPropertyBlock(m_materialProperty);
        }
    }

#if UNITY_EDITOR
    void EditorInit()
    {
        Init();
        m_spriteRenderer.sharedMaterial = m_CustomMaterial == null ? GetDefaultMaterial(m_blendOption) : m_CustomMaterial;
        InitMaskGroup();
        UpdateMaterial();
    }

    private void OnValidate()
    {
        InitUpdateMaterial();
    }
#endif

    private void Start()
    {
        InitUpdateMaterial();
    }

    void LateUpdate()
    {

#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            if (transform.hasChanged || (m_SelfSoftMask && m_SelfSoftMask.transform.hasChanged))
            {
                InitUpdateMaterial();
                transform.hasChanged = false;
            }
        }
#endif

        CheckUpdateSelfSoftMaskClipRect();
    }

    private void InitUpdateMaterial()
    {
        if (!orInit()) return;
        
        InitMaskGroup();
        UpdateMaterial();
    }

    private void CheckUpdateSelfSoftMaskClipRect()
    {
        if (m_SelfSoftMask)
        {
            if (m_SelfSoftMask.bounds != mLastSelfSoftMaskRelativeRect)
            {
                mLastSelfSoftMaskRelativeRect = m_SelfSoftMask.bounds;
                UpdateMaterial();
            }
        }
        else
        {
            if (mLastSelfSoftMaskRelativeRect != mDefaultSelfSoftClipRect)
            {
                mLastSelfSoftMaskRelativeRect = mDefaultSelfSoftClipRect;
                UpdateMaterial();
            }
        }
    }

    public override void UpdateMaskGroupClipRect()
    {
        if (!orInit()) return;
        UpdateMaterial();
    }

    private void UpdateMaterial()
    {
        if (m_spriteRenderer && m_spriteRenderer.sprite)
        {
            m_materialProperty.SetTexture("_MainTex", m_spriteRenderer.sprite.texture);
        }

        if (m_SelfSoftMask && m_SelfSoftMask.sprite)
        {
            Vector2 scale = new Vector2(m_SelfSoftMask.sprite.bounds.size.x / m_SelfSoftMask.sprite.texture.width, m_SelfSoftMask.sprite.bounds.size.y / m_SelfSoftMask.sprite.texture.height);
            Vector2 offset = new Vector2(m_SelfSoftMask.sprite.textureRect.xMin / m_SelfSoftMask.sprite.texture.width, m_SelfSoftMask.sprite.textureRect.yMin / m_SelfSoftMask.sprite.texture.height);

            // 用 相对坐标，发现多个克隆物体 会出现 遮挡 混乱的问题(Shader 混乱)， 所以改用 世界坐标
            //maskAreaMin = transform.InverseTransformPoint(maskAreaMin);
            //maskAreaMax = transform.InverseTransformPoint(maskAreaMax);
            Vector3 maskSize = m_SelfSoftMask.bounds.size;
            Vector3 maskPos = m_SelfSoftMask.transform.position;
            Vector2 maskAreaMin = new Vector2(maskPos.x - maskSize.x / 2, maskPos.y - maskSize.y / 2);
            Vector2 maskAreaMax = new Vector2(maskPos.x + maskSize.x / 2, maskPos.y + maskSize.y / 2);
            Rect mRect = Rect.MinMaxRect(maskAreaMin.x, maskAreaMin.y, maskAreaMax.x, maskAreaMax.y);

            m_materialProperty.SetTexture("_AlphaMask", m_SelfSoftMask.sprite.texture);
            m_materialProperty.SetVector("_AlphaMask_ST", new Vector4(scale.x, scale.y, offset.x, offset.y));
            m_materialProperty.SetVector("_ClipSoftRect", new Vector4(mRect.xMin, mRect.yMin, mRect.width, mRect.height));
            m_materialProperty.SetFloat("bUseSoftMask", 1);
        }
        else
        {
            m_materialProperty.SetVector("_AlphaMask_ST", new Vector4(1, 1, 0, 0));
            m_materialProperty.SetTexture("_AlphaMask", Texture2D.whiteTexture);
            m_materialProperty.SetFloat("bUseSoftMask", 0);
        }

        if (m_RectMaskGroup)
        {
            Rect mRect = m_RectMaskGroup.GetWorldRect();
            m_materialProperty.SetVector("_ClipGroupRect", new Vector4(mRect.xMin, mRect.yMin, mRect.width, mRect.height));
            m_materialProperty.SetFloat("bUseGroupMask", 1);
        }
        else
        {
            m_materialProperty.SetFloat("bUseGroupMask", 0);
        }

        m_spriteRenderer.SetPropertyBlock(m_materialProperty);
    }

}
