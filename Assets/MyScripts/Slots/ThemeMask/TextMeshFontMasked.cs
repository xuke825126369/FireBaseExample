using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
[RequireComponent(typeof(TextMesh))]
[DisallowMultipleComponent]
[ExecuteAlways]
public class TextMeshFontMasked : CustomerRectMaskGroupChildren
{
    public bool orUseMaterialBlock = true;
    public Color m_Color = Color.white;

    private Vector4 mLastClipVector4;
    private Rect mLastTextRect;
    private TextMesh mText = null;

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
            mText = gameObject.GetComponent<TextMesh>();
            mMeshRenderer = gameObject.GetComponent<MeshRenderer>();

            if (orUseMaterialBlock)
            {
                mMeshRenderer.sharedMaterial = mText.font.material;
                mMaterialPropertyBlock = new MaterialPropertyBlock();
                mMaterialPropertyBlock.SetTexture("_MainTex", mText.font.material.mainTexture);
                mMaterialPropertyBlock.SetColor("_Color", mText.font.material.color);

                mMeshRenderer.sharedMaterial = GetDefaultMaterial();
            }
            else
            {
                mMeshRenderer.sharedMaterial = CreateMaterialInstance(mText.font.material);
            }
            
            CheckMaterial();
            InitMaskGroup();
        }
    }

    private void CheckMaterial()
    {
        Material material = mMeshRenderer.sharedMaterial;
        if (!material.HasProperty("_ClipRect"))
        {
            Debug.LogWarning(string.Format("Material Shader:{0} 属性:{1} 不存在", material.shader.name, "_ClipRect"));
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
        mat.SetColor("_Color", source.color);
        mat.SetTexture("_MainTex", source.mainTexture);
        mat.shaderKeywords = source.shaderKeywords;
        mat.name += " (Instance)";
        return mat;
    }

    public override void UpdateMaskGroupClipRect()
    {
        if (!orInit()) return;
        UpdateMaterial();
    }

    private void UpdateMaterial()
    {
        Rect clipRect = Rect.MinMaxRect(-32767, -32767, 32767, 32767);
        if (m_RectMaskGroup != null)
        {
            clipRect = m_RectMaskGroup.GetWorldRect();
        }

        if (orUseMaterialBlock)
        {
            mMaterialPropertyBlock.SetColor("_Color", m_Color);
            mMaterialPropertyBlock.SetVector("_ClipRect", new Vector4(clipRect.x, clipRect.y, clipRect.max.x, clipRect.max.y));
            mMeshRenderer.SetPropertyBlock(mMaterialPropertyBlock);
        }
        else
        {
            mMeshRenderer.sharedMaterial.SetColor("_Color", m_Color);
            mMeshRenderer.sharedMaterial.SetVector("_ClipRect", new Vector4(clipRect.x, clipRect.y, clipRect.max.x, clipRect.max.y));
        }
    }

    private void OnDidApplyAnimationProperties()
    {
        if (!orInit()) return;
        UpdateMaterial();
    }

}
