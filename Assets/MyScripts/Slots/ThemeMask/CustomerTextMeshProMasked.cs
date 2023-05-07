using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using XLua;

[LuaCallCSharp]
[RequireComponent(typeof(TextMeshPro))]
[DisallowMultipleComponent]
[ExecuteAlways]
public class CustomerTextMeshProMasked : CustomerRectMaskGroupChildren
{
    private Vector4 mLastClipVector4;
    private Rect mLastTextRect;
    private TextMeshPro mText = null;

    public Material m_Material;

    protected override void Awake()
    {
        base.Awake();
        Init();
    }

    void Start()
    {
        SetMaterial();
        InitMaskGroup();
    }

#if UNITY_EDITOR
    void EditorInit()
    {
        Init();
        SetMaterial();
        InitMaskGroup();
    }

    private void OnValidate()
    {
        InitMaskGroup();
    }
#endif

    protected override bool orInit()
    {
        return mText != null;
    }

    private void Init()
    {
        if(!orInit())
        {
            mLastTextRect = Rect.zero;
            mLastClipVector4 = Vector4.zero;
            mText = gameObject.GetComponent<TextMeshPro>();
            SetMaterial();
        }
    }

    private void SetMaterial()
    {
        Material material = GetMaterial();
        if (material)
        {
            mText.fontMaterial = material;
        }
    }

    private Material GetMaterial()
    {
        if (m_Material != null)
        {
            return CreateMaterialInstance(m_Material);
        }
        else
        {
            //Debug.LogWarning("属性字段: m_Material 不应该为 Null");
            if (mText.fontSharedMaterial)
            {                
                return CreateMaterialInstance(mText.fontSharedMaterial);
            }
            else
            {
                return null;
            }
        }
    }

    private Material CreateMaterialInstance(Material source)
    {
        Material mat = new Material(source);
        mat.shaderKeywords = source.shaderKeywords;
        mat.name += " (Instance)";
        mat.EnableKeyword("UNITY_UI_CLIP_RECT");
        return mat;
    }
    
    // 这里应该 改为 LateUpdate, 否则有问题
    void LateUpdate()
    {
        if (mText.rectTransform.hasChanged || mText.rectTransform.rect != mLastTextRect)
        {
            mText.rectTransform.hasChanged = false;
            mLastTextRect = mText.rectTransform.rect;
            UpdateClip();
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
    }

    private void UpdateClip()
    {
        Vector4 mMinMaxClip = Vector4.zero;
        if (m_RectMaskGroup != null)
        {
            Rect mWorldRect = m_RectMaskGroup.GetWorldRect();

            Vector2 minPos = transform.InverseTransformPoint(mWorldRect.min);
            Vector2 maxPos = transform.InverseTransformPoint(mWorldRect.max);
            Rect mClipRect = Rect.MinMaxRect(minPos.x, minPos.y, maxPos.x, maxPos.y);

            Rect mTextRect = mText.rectTransform.rect;

            float xMin = Mathf.Max(mClipRect.xMin, mTextRect.xMin);
            float xMax = Mathf.Min(mClipRect.xMax, mTextRect.xMax);
            float yMin = Mathf.Max(mClipRect.yMin, mTextRect.yMin);
            float yMax = Mathf.Min(mClipRect.yMax, mTextRect.yMax);

            mMinMaxClip = new Vector4(xMin, yMin, xMax, yMax);
        }
        else
        {
            mMinMaxClip = new Vector4(-32767, -32767, 32767, 32767);
        }

        if (mLastClipVector4 != mMinMaxClip)
        {
            mLastClipVector4 = mMinMaxClip;
            mText.fontMaterial.SetVector(ShaderUtilities.ID_ClipRect, mMinMaxClip);
        }
    }

    public override void UpdateMaskGroupClipRect()
    {
        if (!orInit()) return;
        UpdateClip();
    }

}
