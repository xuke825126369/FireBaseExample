using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[RequireComponent(typeof(ParticleSystem))]
[DisallowMultipleComponent]
[ExecuteAlways]
public class CustomerParticleMasked : CustomerRectMaskGroupChildren
{
    public SpriteRenderer m_SelfSoftMask;
    public Texture2D m_Texture;

    [SerializeField]
    private Material m_CustomMaterial;
    private static Material m_defaultNormalMaterial;

    private MaterialPropertyBlock m_materialProperty;

    private Bounds mDefaultSelfSoftClipRect = new Bounds(Vector3.zero, Vector3.zero);
    private Bounds mLastSelfSoftMaskRelativeRect;

    private ParticleSystemRenderer m_ParticleRenderer;

    Material GetDefaultMaterial()
    {
        if (!m_defaultNormalMaterial)
        {
            m_defaultNormalMaterial = new Material(ShaderAutoFind.Find("Customer/CustomerParticleMasked"));
        }

        return m_defaultNormalMaterial;
    }

    // Use this for initialization
    protected override void Awake()
    {
        base.Awake();
        Init();
    }

    protected override bool orInit()
    {
        return m_materialProperty != null && m_ParticleRenderer != null;
    }

    private void Init()
    {
        if (!orInit())
        {
            m_ParticleRenderer = GetComponent<ParticleSystemRenderer>();
            m_materialProperty = new MaterialPropertyBlock();
            m_ParticleRenderer.sharedMaterial = m_CustomMaterial != null ? m_CustomMaterial : GetDefaultMaterial();
        }
    }

#if UNITY_EDITOR
    void EditorInit()
    {
        Init();
        m_ParticleRenderer.sharedMaterial = null;
        m_ParticleRenderer.sharedMaterial = m_CustomMaterial != null ? m_CustomMaterial : GetDefaultMaterial();
        InitUpdateMaterial();
    }

    private void OnValidate()
    {
        InitUpdateMaterial();
    }
#endif

    private void Start()
    {
        InitUpdateMaterial();
        CheckCustomerMaterialShader();
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

    protected override void OnDestroy()
    {
        base.OnDestroy();
        m_ParticleRenderer.sharedMaterial = null;
    }

    private void InitUpdateMaterial()
    {
        if (!orInit()) return;
            
        InitUpdateTexture();
        InitSelfSoftMaskClipRect();
        InitMaskGroup();
    }

    private void CheckUpdateSelfSoftMaskClipRect(bool bForce = false)
    {
        if (m_ParticleRenderer.sharedMaterial == null)
        {
            return;
        }

        // 用 相对坐标，发现多个克隆物体 会出现 遮挡 混乱的问题(Shader 混乱)， 所以改用 世界坐标
        //maskAreaMin = transform.InverseTransformPoint(maskAreaMin);
        //maskAreaMax = transform.InverseTransformPoint(maskAreaMax);

        if (m_SelfSoftMask)
        {
            if (m_SelfSoftMask.bounds != mLastSelfSoftMaskRelativeRect || bForce)
            {
                mLastSelfSoftMaskRelativeRect = m_SelfSoftMask.bounds;

                Vector3 maskSize = m_SelfSoftMask.bounds.size;
                Vector3 maskPos = m_SelfSoftMask.transform.position;
                Vector2 maskAreaMin = new Vector2(maskPos.x - maskSize.x / 2, maskPos.y - maskSize.y / 2);
                Vector2 maskAreaMax = new Vector2(maskPos.x + maskSize.x / 2, maskPos.y + maskSize.y / 2);

                Rect mRect = Rect.MinMaxRect(maskAreaMin.x, maskAreaMin.y, maskAreaMax.x, maskAreaMax.y);

                m_materialProperty.SetVector("_ClipSoftRect", new Vector4(mRect.xMin, mRect.yMin, mRect.width, mRect.height));
                m_materialProperty.SetFloat("bUseSoftMask", 1);
                m_ParticleRenderer.SetPropertyBlock(m_materialProperty);
            }
        }
        else
        {
            if (mLastSelfSoftMaskRelativeRect != mDefaultSelfSoftClipRect || bForce)
            {
                mLastSelfSoftMaskRelativeRect = mDefaultSelfSoftClipRect;
                m_materialProperty.SetFloat("bUseSoftMask", 0);

                m_ParticleRenderer.SetPropertyBlock(m_materialProperty);
            }
        }
    }

    private void InitSelfSoftMaskClipRect()
    {
        CheckUpdateSelfSoftMaskClipRect(true);
    }

    public override void UpdateMaskGroupClipRect()
    {
        if (!orInit()) return;

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

        m_ParticleRenderer.SetPropertyBlock(m_materialProperty);
    }

    private void InitUpdateTexture()
    {
        if (m_ParticleRenderer.sharedMaterial == null)
        {
            return;
        }

        if (m_CustomMaterial && m_CustomMaterial.mainTexture)
        {
            m_materialProperty.SetVector("_MainTex_ST", new Vector4(1, 1, 0, 0));
            m_materialProperty.SetTexture("_MainTex", m_CustomMaterial.mainTexture);
        }
        else if (m_Texture != null)
        {
            m_materialProperty.SetVector("_MainTex_ST", new Vector4(1, 1, 0, 0));
            m_materialProperty.SetTexture("_MainTex", m_Texture);
        }else
        {
            m_materialProperty.SetTexture("_MainTex", Texture2D.whiteTexture);
        }

        if (m_SelfSoftMask && m_SelfSoftMask.sprite)
        {
            m_materialProperty.SetTexture("_AlphaMask", m_SelfSoftMask.sprite.texture);

            Vector2 scale = new Vector2(m_SelfSoftMask.sprite.bounds.size.x / m_SelfSoftMask.sprite.texture.width, m_SelfSoftMask.sprite.bounds.size.y / m_SelfSoftMask.sprite.texture.height);
            Vector2 offset = new Vector2(m_SelfSoftMask.sprite.textureRect.xMin / m_SelfSoftMask.sprite.texture.width, m_SelfSoftMask.sprite.textureRect.yMin / m_SelfSoftMask.sprite.texture.height);

            m_materialProperty.SetVector("_AlphaMask_ST", new Vector4(scale.x, scale.y, offset.x, offset.y));

            m_materialProperty.SetFloat("bUseSoftMask", 1);
        }
        else
        {
            m_materialProperty.SetVector("_AlphaMask_ST", new Vector4(1, 1, 0, 0));
            m_materialProperty.SetTexture("_AlphaMask", Texture2D.whiteTexture);
            m_materialProperty.SetFloat("bUseSoftMask", 0);
        }

        m_ParticleRenderer.SetPropertyBlock(m_materialProperty);
    }

    private void CheckCustomerMaterialShader()
    {
        if (m_CustomMaterial)
        {
            Debug.Assert(m_CustomMaterial.HasProperty("_AlphaMask"), "脚本 CustomerParticleMasked Shader 遮罩属性:_AlphaMask 丢失");
            Debug.Assert(m_CustomMaterial.HasProperty("_ClipSoftRect"), "脚本 CustomerParticleMasked Shader 遮罩属性: _ClipSoftRect 丢失");
            Debug.Assert(m_CustomMaterial.HasProperty("_ClipGroupRect"), "脚本 CustomerParticleMasked Shader 遮罩属性: _ClipGroupRect 丢失");
        }
    }
    
}
