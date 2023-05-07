using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class SpriteGroupAlphaChildren : MonoBehaviour
{
    public SpriteGroupAlpha m_Parent;
    [Range(0, 1)]
    public float m_AlphaValue = 1.0f;
    public Material m_OriMaterial = null;
    private float m_lastAlpha = -1f;

    private void Start()
    {
        Init();
        UpdateAlpha();
    }

    private void LateUpdate()
    {
        UpdateAlpha();
    }

    private void OnDestroy()
    {
        UpdateAlpha(true);

        ParticleSystemRenderer ren10 = transform.GetComponent<ParticleSystemRenderer>();
        if (ren10 != null)
        { 
            if (ren10.sharedMaterial != m_OriMaterial)
            {
                if (ren10.sharedMaterial)
                {
                    DestroyImmediate(ren10.sharedMaterial);
                }
                ren10.sharedMaterial = m_OriMaterial;
            }
        }
    }

    private void CreateParticleMat(ParticleSystemRenderer mParticleRenderer)
    {
        if (m_OriMaterial != null && (m_OriMaterial == mParticleRenderer.sharedMaterial || mParticleRenderer.sharedMaterial == null))
        {
            Material mOriMat = m_OriMaterial;
            Material mMaterial = new Material(mOriMat);
            mMaterial.name = mOriMat.name + "(SpriteGroupAlpha)";
            mParticleRenderer.sharedMaterial = mMaterial;
        }
    }

    private void Init()
    {
        m_Parent = gameObject.GetComponentInParent<SpriteGroupAlpha>();

        SpriteRenderer ren1 = transform.GetComponent<SpriteRenderer>();
        if (ren1 != null)
        {
            m_AlphaValue = ren1.color.a;
        }

        TMPro.TextMeshPro ren2 = transform.GetComponent<TMPro.TextMeshPro>();
        if (ren2 != null)
        {
            m_AlphaValue = ren2.color.a;
        }

        TextMesh ren3 = transform.GetComponent<TextMesh>();
        if (ren3 != null)
        {
            m_AlphaValue = ren3.color.a;
        }

        ParticleSystemRenderer ren10 = transform.GetComponent<ParticleSystemRenderer>();
        if (ren10 != null && (ren10.sharedMaterial || m_OriMaterial))
        {
            if (m_OriMaterial == null)
            {
                m_OriMaterial = ren10.sharedMaterial;
            }

            Material mMaterial = m_OriMaterial;
            if (mMaterial.HasProperty("_Color"))
            {
                Color mColor = mMaterial.GetColor("_Color");
                m_AlphaValue = mColor.a;
            }

            if (mMaterial.HasProperty("_TintColor"))
            {
                Color mColor = mMaterial.GetColor("_TintColor");
                m_AlphaValue = mColor.a;
            }

            CreateParticleMat(ren10);
        }
        
        m_lastAlpha = m_AlphaValue;
    }

    public void UpdateAlpha(bool bDestroy = false)
    {
        float fAlphaValue = m_AlphaValue;
        if(!bDestroy && m_Parent)
        {
            fAlphaValue = m_Parent.m_fAlpha * m_AlphaValue;
        }

        if (fAlphaValue == m_lastAlpha) return;
        m_lastAlpha = fAlphaValue;

        SpriteRenderer ren1 = transform.GetComponent<SpriteRenderer>();
        if (ren1 != null)
        {
            Color mColor = ren1.color;
            ren1.color = new Color(mColor.r, mColor.g, mColor.b, fAlphaValue);
        }

        TMPro.TextMeshPro ren2 = transform.GetComponent<TMPro.TextMeshPro>();
        if (ren2 != null)
        {
            Color mColor = ren2.color;
            ren2.color = new Color(mColor.r, mColor.g, mColor.b, fAlphaValue);
        }

        TextMesh ren3 = transform.GetComponent<TextMesh>();
        if (ren3 != null)
        {
            Color mColor = ren3.color;
            ren3.color = new Color(mColor.r, mColor.g, mColor.b, fAlphaValue);
        }

        ParticleSystemRenderer ren10 = transform.GetComponent<ParticleSystemRenderer>();
        if (ren10 != null && ren10.sharedMaterial && m_OriMaterial)
        {
            CreateParticleMat(ren10);
            if (ren10.sharedMaterial != m_OriMaterial)
            {
                Material mMaterial = ren10.sharedMaterial;
                if (mMaterial.HasProperty("_Color"))
                {
                    Color mColor = mMaterial.GetColor("_Color");
                    mMaterial.SetColor("_Color", new Color(mColor.r, mColor.g, mColor.b, fAlphaValue));
                }

                if (mMaterial.HasProperty("_TintColor"))
                {
                    Color mColor = mMaterial.GetColor("_TintColor");
                    mMaterial.SetColor("_TintColor", new Color(mColor.r, mColor.g, mColor.b, fAlphaValue));
                }
            }
        }
    }
}
