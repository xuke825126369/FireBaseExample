using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Spine.Unity;
using XLua;

[LuaCallCSharp]
[RequireComponent(typeof(SkeletonRenderer))]
[DisallowMultipleComponent]
[ExecuteAlways]
public class CustomerSpineMasked : CustomerRectMaskGroupChildren
{
    [SerializeField]
    private Color m_Color = Color.white;
    [SerializeField]
    private SpriteRenderer m_SelfSoftMask;
    [SerializeField]
    private Material[] m_CustomMaterialList;
    [SerializeField]

    private MaterialPropertyBlock m_materialProperty;

    private Bounds mDefaultSelfSoftClipRect = new Bounds(Vector3.zero, Vector3.zero);
    private Bounds mLastSelfSoftMaskRelativeRect;

    private MeshRenderer m_MeshRenderer;
    private static Material m_defaultMaterial;
    private Material[] mMaterialList = null;

    private bool orOnlyUseOneMaterial = false;

    Material GetMaterial()
    {
        if (orOnlyUseOneMaterial)
        {
            if (!m_defaultMaterial)
            {
                m_defaultMaterial = new Material(ShaderAutoFind.Find("Customer/CustomerSpineMasked"));
            }

            return m_defaultMaterial;
        }
        else
        {
            return new Material(ShaderAutoFind.Find("Customer/CustomerSpineMasked"));
        }

    }

    protected override void Awake()
    {
        base.Awake();
        Init();
    }

    protected override bool orInit()
    {
        if (orOnlyUseOneMaterial)
        {
            return m_materialProperty != null;
        }
        else
        {
            return mMaterialList != null;
        }
    }

    private void Init()
    {
        if (!orInit())
        {
            SkeletonRenderer m_skeletonAnimation = GetComponent<SkeletonRenderer>();
            Material[] mMatList = GetSpineAtlasMaterials(m_skeletonAnimation);
            orOnlyUseOneMaterial = mMatList.Length == 1;

            if (orOnlyUseOneMaterial)
            {
                m_materialProperty = new MaterialPropertyBlock();
                m_MeshRenderer = GetComponent<MeshRenderer>();

                Material m_material = m_CustomMaterialList != null && m_CustomMaterialList.Length > 0 && m_CustomMaterialList[0] != null ? m_CustomMaterialList[0] : GetMaterial();
                Material atlasMaterial = mMatList[0];
                m_skeletonAnimation.CustomMaterialOverride[atlasMaterial] = m_material;

                m_materialProperty.SetTexture("_MainTex", atlasMaterial.mainTexture);
                m_MeshRenderer.SetPropertyBlock(m_materialProperty);

            }
            else
            {
                mMaterialList = new Material[mMatList.Length];
                for (int i = 0; i < mMatList.Length; i++)
                {
                    mMaterialList[i] = m_CustomMaterialList != null && m_CustomMaterialList.Length > i && m_CustomMaterialList[i] != null ? m_CustomMaterialList[i] : GetMaterial();
                    Material atlasMaterial = mMatList[i];
                    m_skeletonAnimation.CustomMaterialOverride[atlasMaterial] = mMaterialList[i];

                    mMaterialList[i].SetTexture("_MainTex", atlasMaterial.mainTexture);
                }
            }

        }
    }

    private Material[] GetSpineAtlasMaterials(SkeletonRenderer m_skeletonAnimation)
    {
        List<Material> mList = new List<Material>();
        if (m_skeletonAnimation != null && m_skeletonAnimation.skeletonDataAsset != null)
        {
            AtlasAsset[] atlasAssets = m_skeletonAnimation.skeletonDataAsset.atlasAssets;
            foreach (AtlasAsset atlasAsset in atlasAssets)
            {
                foreach (Material atlasMaterial in atlasAsset.materials)
                {
                    mList.Add(atlasMaterial);
                }
            }
        }

        return mList.ToArray();
    }

#if UNITY_EDITOR
    void EditorInit()
    {
        Init();
        InitUpdateMaterial();
    }

    private void OnValidate()
    {
        InitUpdateMaterial();
    }
#endif

    void OnEnable()
    {
        UpdateColorAni();
    }

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

    protected override void OnDestroy()
    {
        base.OnDestroy();
        mMaterialList = null;
    }

    private void OnDidApplyAnimationProperties()
    {
        if (!orInit()) return;
        UpdateColorAni();
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
                Vector4 mClipSoftRect = new Vector4(mRect.xMin, mRect.yMin, mRect.width, mRect.height);

                if (orOnlyUseOneMaterial)
                {
                    m_materialProperty.SetVector("_ClipSoftRect", mClipSoftRect);
                    m_materialProperty.SetFloat("bUseSoftMask", 1);
                    m_MeshRenderer.SetPropertyBlock(m_materialProperty);
                }
                else
                {
                    foreach (var v in mMaterialList)
                    {
                        Material mMat = v;
                        mMat.SetVector("_ClipSoftRect", mClipSoftRect);
                        mMat.SetFloat("bUseSoftMask", 1);
                    }
                }
            }

        }
        else
        {
            if (mLastSelfSoftMaskRelativeRect != mDefaultSelfSoftClipRect || bForce)
            {
                mLastSelfSoftMaskRelativeRect = mDefaultSelfSoftClipRect;

                if (orOnlyUseOneMaterial)
                {
                    m_materialProperty.SetFloat("bUseSoftMask", 0);
                    m_MeshRenderer.SetPropertyBlock(m_materialProperty);
                }
                else
                {
                    foreach (var v in mMaterialList)
                    {
                        Material mMat = v;
                        mMat.SetFloat("bUseSoftMask", 0);
                    }
                }
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
            Vector4 mClipGroupRect = new Vector4(mRect.xMin, mRect.yMin, mRect.width, mRect.height);

            if (orOnlyUseOneMaterial)
            {
                m_materialProperty.SetVector("_ClipGroupRect", mClipGroupRect);
                m_materialProperty.SetFloat("bUseGroupMask", 1);
                m_MeshRenderer.SetPropertyBlock(m_materialProperty);
            }
            else
            {
                foreach (var v in mMaterialList)
                {
                    Material mMat = v;
                    mMat.SetVector("_ClipGroupRect", mClipGroupRect);
                    mMat.SetFloat("bUseGroupMask", 1);
                }
            }
        }
        else
        {

            if (orOnlyUseOneMaterial)
            {
                m_materialProperty.SetFloat("bUseGroupMask", 0);
                m_MeshRenderer.SetPropertyBlock(m_materialProperty);
            }
            else
            {
                foreach (var v in mMaterialList)
                {
                    Material mMat = v;
                    mMat.SetFloat("bUseGroupMask", 0);
                }
            }
        }

    }

    private void InitUpdateTexture()
    {
        if (m_SelfSoftMask && m_SelfSoftMask.sprite)
        {
            Vector2 scale = new Vector2(m_SelfSoftMask.sprite.bounds.size.x / m_SelfSoftMask.sprite.texture.width, m_SelfSoftMask.sprite.bounds.size.y / m_SelfSoftMask.sprite.texture.height);
            Vector2 offset = new Vector2(m_SelfSoftMask.sprite.textureRect.xMin / m_SelfSoftMask.sprite.texture.width, m_SelfSoftMask.sprite.textureRect.yMin / m_SelfSoftMask.sprite.texture.height);
            Vector4 mScaleOffset = new Vector4(scale.x, scale.y, offset.x, offset.y);

            if (orOnlyUseOneMaterial)
            {
                m_materialProperty.SetTexture("_AlphaMask", m_SelfSoftMask.sprite.texture);
                m_materialProperty.SetVector("_AlphaMask_ST", mScaleOffset);
                m_materialProperty.SetFloat("bUseSoftMask", 1);
            }
            else
            {
                foreach (var v in mMaterialList)
                {
                    Material mMat = v;
                    mMat.SetTexture("_AlphaMask", m_SelfSoftMask.sprite.texture);
                    mMat.SetVector("_AlphaMask_ST", mScaleOffset);
                    mMat.SetFloat("bUseSoftMask", 1);
                }
            }
        }
        else
        {
            Vector4 mScaleOffset = new Vector4(1, 1, 0, 0);
            if (orOnlyUseOneMaterial)
            {
                m_materialProperty.SetVector("_AlphaMask_ST", mScaleOffset);
                m_materialProperty.SetTexture("_AlphaMask", Texture2D.whiteTexture);
                m_materialProperty.SetFloat("bUseSoftMask", 0);
            }
            else
            {
                foreach (var v in mMaterialList)
                {
                    Material mMat = v;
                    mMat.SetVector("_AlphaMask_ST", mScaleOffset);
                    mMat.SetTexture("_AlphaMask", Texture2D.whiteTexture);
                    mMat.SetFloat("bUseSoftMask", 0);
                }
            }
        }

        if (orOnlyUseOneMaterial)
        {
            m_materialProperty.SetColor("_Color", m_Color);
            m_MeshRenderer.SetPropertyBlock(m_materialProperty);
        }
        else
        {
            foreach (var v in mMaterialList)
            {
                Material mMat = v;
                mMat.SetColor("_Color", m_Color);
            }
        }

    }

    private void UpdateColorAni()
    {
        if (!orInit()) return;

        if (orOnlyUseOneMaterial)
        {
            m_materialProperty.SetColor("_Color", m_Color);
            m_MeshRenderer.SetPropertyBlock(m_materialProperty);
        }
        else
        {
            foreach (var v in mMaterialList)
            {
                Material mMat = v;
                mMat.SetColor("_Color", m_Color);
            }
        }
    }

}
