using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[RequireComponent(typeof(CustomerTextMesh))]
[DisallowMultipleComponent]
[ExecuteAlways]
public class CustomerTextMeshFontMasked : CustomerRectMaskGroupChildren
{
    public bool orUseMaterialBlock = true;
    private Vector4 mLastClipVector4;
    private Rect mLastTextRect;
    private CustomerTextMesh mText = null;

    private MeshRenderer mMeshRenderer = null;
    private static Material mDefaultMat = null;
    private MaterialPropertyBlock mMaterialPropertyBlock = null;

    void Start()
    {
        Init();
    }

    protected override bool orInit()
    {
        if (orUseMaterialBlock)
        {
            return mText != null && mMaterialPropertyBlock != null;
        }else
        {
            return mText != null;
        }
    }

    void Init()
    {
        if (!orInit())
        {
            mLastTextRect = Rect.zero;
            mLastClipVector4 = Vector4.zero;
            mText = gameObject.GetComponent<CustomerTextMesh>();
            mMeshRenderer = gameObject.GetComponent<MeshRenderer>();
            if (orUseMaterialBlock)
            {
                mMeshRenderer.sharedMaterial = mText.font.material;
                mMaterialPropertyBlock = new MaterialPropertyBlock();
                mMaterialPropertyBlock.SetTexture("_MainTex", mText.font.material.mainTexture);
                mMaterialPropertyBlock.SetColor("_Color", mText.font.material.color);

                mMeshRenderer.sharedMaterial = GetDefaultMaterial();
            }else
            {
                mMeshRenderer.sharedMaterial = CreateMaterialInstance(mText.font.material);
            }

            InitMaskGroup();
        }
    }

    private Material GetDefaultMaterial()
    {
        if (mDefaultMat == null)
        {
            Material mat = new Material(ShaderAutoFind.Find("Customer/TextMeshFontMasked"));
            mDefaultMat = mat;
        }

        return mDefaultMat;
    }

    private Material CreateMaterialInstance(Material source)
    {
        Material mat = new Material(ShaderAutoFind.Find("Customer/TextMeshFontMasked"));
        mat.CopyPropertiesFromMaterial(source);
        mat.shaderKeywords = source.shaderKeywords;
        mat.name += " (Instance)";

        return mat;
    }
    
    private void UpdateClip()
    {
        Rect clipRect = Rect.MinMaxRect(-32767, -32767, 32767, 32767);
        if (m_RectMaskGroup != null)
        {
            clipRect = m_RectMaskGroup.GetWorldRect();
        }

        if (orUseMaterialBlock)
        {
            mMaterialPropertyBlock.SetVector("_ClipRect", new Vector4(clipRect.x, clipRect.y, clipRect.max.x, clipRect.max.y));
            mMeshRenderer.SetPropertyBlock(mMaterialPropertyBlock);
        }else
        {
            mMeshRenderer.sharedMaterial.SetVector("_ClipRect", new Vector4(clipRect.x, clipRect.y, clipRect.max.x, clipRect.max.y));
        }
    }

    public override void UpdateMaskGroupClipRect()
    {
        if (!orInit()) return;
        UpdateClip();
    }

}
