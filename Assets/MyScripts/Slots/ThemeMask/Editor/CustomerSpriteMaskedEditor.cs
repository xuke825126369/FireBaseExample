using UnityEngine;
using UnityEditor;
using System.Reflection;

/// <summary>
/// Editor class used to edit UI Graphics.
/// Extend this class to write your own graphic editor.
/// </summary>

[CustomEditor(typeof(CustomerSpriteMasked), true)]
[CanEditMultipleObjects]
public class CustomerSpriteMaskedEditor : CustomerRectMaskGroupChildrenEditor
{
    SerializedProperty m_SelfSoftMask;
    SerializedProperty m_blendOption;
    SerializedProperty m_CustomMaterial;

    GUIContent m_SelfSoftMaskContent;

    private SpriteRenderer mSpriteRenderer = null;
    private CustomerSpriteMasked mCustomerSpriteMasked = null;

    protected override void OnEnable()
    {
        base.OnEnable();

        m_SelfSoftMaskContent = new GUIContent("Soft Mask");

        m_SelfSoftMask = serializedObject.FindProperty("m_SelfSoftMask");
        m_blendOption = serializedObject.FindProperty("m_blendOption");
        m_CustomMaterial = serializedObject.FindProperty("m_CustomMaterial");

        mSpriteRenderer = ((MonoBehaviour)target).GetComponent<SpriteRenderer>();
        mCustomerSpriteMasked = target as CustomerSpriteMasked;
    }

    public override void OnInspectorGUI () 
    {
        serializedObject.Update();
        DrawInspectorGUI();
        serializedObject.ApplyModifiedProperties();
        
        if (GUI.changed)
        {
            mCustomerSpriteMasked.GetType().InvokeMember("EditorInit", BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.NonPublic, null, mCustomerSpriteMasked, new object[] { });
            GUI.changed = false;
        }
    }

    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        EditorGUILayout.PropertyField(m_SelfSoftMask, m_SelfSoftMaskContent);
        EditorGUILayout.PropertyField(m_blendOption);
        EditorGUILayout.PropertyField(m_CustomMaterial);
    }

    public override bool HasPreviewGUI() { return true; }

    public override void OnPreviewGUI(Rect rect, GUIStyle background)
    {
        //return;
        if (mSpriteRenderer.sprite == null) return;
        Sprite sprite = mSpriteRenderer.sprite;
        Rect drawArea = rect;

        Texture2D tex = sprite.texture;
        if (tex == null)
            return;
        
        Rect outer = sprite.rect;
        Rect inner = outer;
        inner.xMin += sprite.border.x;
        inner.yMin += sprite.border.y;
        inner.xMax -= sprite.border.z;
        inner.yMax -= sprite.border.w;

        Vector4 uv4 = UnityEngine.Sprites.DataUtility.GetOuterUV(sprite);
        Rect uv = new Rect(uv4.x, uv4.y, uv4.z - uv4.x, uv4.w - uv4.y);
        Vector4 padding = UnityEngine.Sprites.DataUtility.GetPadding(sprite);
        padding.x /= outer.width;
        padding.y /= outer.height;
        padding.z /= outer.width;
        padding.w /= outer.height;

        Rect outerRect = drawArea;
        outerRect.width = Mathf.Abs(outer.width);
        outerRect.height = Mathf.Abs(outer.height);

        if (outerRect.width > 0f)
        {
            float f = drawArea.width / outerRect.width;
            outerRect.width *= f;
            outerRect.height *= f;
        }

        if (drawArea.height > outerRect.height)
        {
            outerRect.y += (drawArea.height - outerRect.height) * 0.5f;
        }
        else if (outerRect.height > drawArea.height)
        {
            float f = drawArea.height / outerRect.height;
            outerRect.width *= f;
            outerRect.height *= f;
        }

        if (drawArea.width > outerRect.width)
        {
            outerRect.x += (drawArea.width - outerRect.width) * 0.5f;
            EditorGUI.DrawTextureTransparent(outerRect, null, ScaleMode.ScaleToFit, outer.width / outer.height);
        }

        GUI.color = mSpriteRenderer.color;

        Rect paddedTexArea = new Rect(
            outerRect.x + outerRect.width * padding.x,
            outerRect.y + outerRect.height * padding.w,
            outerRect.width - (outerRect.width * (padding.z + padding.x)),
            outerRect.height - (outerRect.height * (padding.w + padding.y))
        );

        GUI.DrawTextureWithTexCoords(paddedTexArea, tex, uv, true);

#region PreView Slice Show
        GUI.BeginGroup(outerRect);
        {
            tex = contrastTexture;
            GUI.color = Color.white;

            if (inner.xMin != outer.xMin)
            {
                float x = (inner.xMin - outer.xMin) / outer.width * outerRect.width - 1;
                DrawTiledTexture(new Rect(x, 0f, 1f, outerRect.height), tex);
            }

            if (inner.xMax != outer.xMax)
            {
                float x = (inner.xMax - outer.xMin) / outer.width * outerRect.width - 1;
                DrawTiledTexture(new Rect(x, 0f, 1f, outerRect.height), tex);
            }

            if (inner.yMin != outer.yMin)
            {
                // GUI.DrawTexture is top-left based rather than bottom-left
                float y = (inner.yMin - outer.yMin) / outer.height * outerRect.height - 1;
                DrawTiledTexture(new Rect(0f, outerRect.height - y, outerRect.width, 1f), tex);
            }

            if (inner.yMax != outer.yMax)
            {
                float y = (inner.yMax - outer.yMin) / outer.height * outerRect.height - 1;
                DrawTiledTexture(new Rect(0f, outerRect.height - y, outerRect.width, 1f), tex);
            }
        }

        GUI.EndGroup();
#endregion

    }

#region PreView Slice Show
    private static Texture2D s_ContrastTex;

    private Texture2D contrastTexture
    {
        get
        {
            if (s_ContrastTex == null)
            {
                s_ContrastTex = CreateCheckerTex(
                        new Color(0f, 0.0f, 0f, 0.5f),
                        new Color(1f, 1f, 1f, 0.5f));
            }
            return s_ContrastTex;
        }
    }

    // Create a checker-background texture.
    private Texture2D CreateCheckerTex(Color c0, Color c1)
    {
        Texture2D tex = new Texture2D(16, 16);
        tex.name = "[Generated] Checker Texture";
        tex.hideFlags = HideFlags.DontSave;

        for (int y = 0; y < 8; ++y) for (int x = 0; x < 8; ++x) tex.SetPixel(x, y, c1);
        for (int y = 8; y < 16; ++y) for (int x = 0; x < 8; ++x) tex.SetPixel(x, y, c0);
        for (int y = 0; y < 8; ++y) for (int x = 8; x < 16; ++x) tex.SetPixel(x, y, c0);
        for (int y = 8; y < 16; ++y) for (int x = 8; x < 16; ++x) tex.SetPixel(x, y, c1);

        tex.Apply();
        tex.filterMode = FilterMode.Point;
        return tex;
    }

    private void DrawTiledTexture(Rect rect, Texture tex)
    {
        float u = rect.width / tex.width;
        float v = rect.height / tex.height;

        Rect texCoords = new Rect(0, 0, u, v);
        TextureWrapMode originalMode = tex.wrapMode;
        tex.wrapMode = TextureWrapMode.Repeat;
        GUI.DrawTextureWithTexCoords(rect, tex, texCoords);
        tex.wrapMode = originalMode;
    }
#endregion


    public override string GetInfoString()
    {
        Sprite sprite = mSpriteRenderer.sprite;

        int x = (sprite != null) ? Mathf.RoundToInt(sprite.rect.width) : 0;
        int y = (sprite != null) ? Mathf.RoundToInt(sprite.rect.height) : 0;
        
        return string.Format("Sprite Size: {0}x{1} \n", x, y);
    }



}
