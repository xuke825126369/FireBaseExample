using UnityEngine;
using XLua;

[ExecuteAlways]
[LuaCallCSharp]
[RequireComponent(typeof(TextMesh))]
[DisallowMultipleComponent]
public class CurveTextMeshFontMasked : CurveGroupChildren
{
    public Color m_Color = Color.white;

    private Vector4 mLastClipVector4;
    private Rect mLastTextRect;
    private TextMesh mText = null;

    [SerializeField]
    private Material m_Material = null;
    private MeshRenderer mMeshRenderer = null;
    private static Material mDefaultMat = null;
    private MaterialPropertyBlock mMaterialPropertyBlock = null;

#if UNITY_EDITOR
    void EditorInit()
    {
        Init();
        mMeshRenderer.sharedMaterial = m_Material != null ? m_Material : GetDefaultMaterial();
        InitMaskGroup();
    }
#endif

    void Start()
    {
        Init();
        InitMaskGroup();
    }

    protected override bool orInit()
    {
        return mText != null && mMaterialPropertyBlock != null;
    }

    void Init()
    {
        if (!orInit())
        {
            mLastTextRect = Rect.zero;
            mLastClipVector4 = Vector4.zero;
            mText = gameObject.GetComponent<TextMesh>();
            mMeshRenderer = gameObject.GetComponent<MeshRenderer>();
            
            mMeshRenderer.sharedMaterial = mText.font.material;
            mMaterialPropertyBlock = new MaterialPropertyBlock();
            mMaterialPropertyBlock.SetTexture("_MainTex", mText.font.material.mainTexture);
            mMaterialPropertyBlock.SetColor("_Color", mText.font.material.color);

            mMeshRenderer.sharedMaterial = m_Material != null ? m_Material : GetDefaultMaterial();
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

    private void UpdateClip()
    {
        Rect clipRect = Rect.MinMaxRect(-32767, -32767, 32767, 32767);
        if (m_RectMaskGroup != null)
        {
            clipRect = m_RectMaskGroup.GetWorldRect();
        }

        mMaterialPropertyBlock.SetColor("_Color", m_Color);
        mMaterialPropertyBlock.SetVector("_ClipRect", new Vector4(clipRect.x, clipRect.y, clipRect.max.x, clipRect.max.y));
        mMeshRenderer.SetPropertyBlock(mMaterialPropertyBlock);
    }

    public override void UpdateMaskGroupClipRect()
    {
        if (!orInit()) return;
        UpdateClip();
    }

    private void OnDidApplyAnimationProperties()
    {
        if (!orInit()) return;
        UpdateClip();
    }

}
