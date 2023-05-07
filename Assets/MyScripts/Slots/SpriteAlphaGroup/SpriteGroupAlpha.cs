using System.Collections;
using System.Collections.Generic;
using Spine.Unity;
using UnityEngine;

[XLua.LuaCallCSharp]
[ExecuteAlways]
// 仿照 CanvasGroup
public class SpriteGroupAlpha : MonoBehaviour
{
    [Range(0, 1)]
    public float m_fAlpha = 1.0f;
    private float m_lastAlpha = -1f;

    private void Start()
    {
        AddSpriteGroupAlphaChildrens(transform);
    }
    
    private void OnDestroy()
    {
        SpriteGroupAlphaChildren[] mAlphaChildren = transform.GetComponentsInChildren<SpriteGroupAlphaChildren>(true);
        foreach (SpriteGroupAlphaChildren child in mAlphaChildren)
        {
            DestroyImmediate(child);
        }
    }

    private void AddSpriteGroupAlphaChildrens(Transform parent)
    {
        if (parent.childCount > 0)
        {
            foreach (Transform child in parent)
            {
                if (orAllowAddAlphaChildren(child))
                {
                    SpriteGroupAlphaChildren mAlphaChildren = child.GetComponent<SpriteGroupAlphaChildren>();
                    if (!mAlphaChildren)
                    {
                        mAlphaChildren = child.gameObject.AddComponent<SpriteGroupAlphaChildren>();
                        mAlphaChildren.m_Parent = this;
                    }
                }

                //将来修改为这里
                AddSpriteGroupAlphaChildrens(child);
            }
        }
    }
    
    private bool orAllowAddAlphaChildren(Transform child)
    {
        return child.GetComponent<SpriteRenderer>() ||
            child.GetComponent<TMPro.TextMeshPro>() ||
            child.GetComponent<TextMesh>() ||
            child.GetComponent<ParticleSystemRenderer>();

    }
}
