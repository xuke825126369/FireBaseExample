using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(TextMesh))]
public class TextMeshAutoSize : MonoBehaviour {
    [SerializeField]
    private float m_maxWidth;
    [SerializeField]
    private float m_maxCharacterSize;

    private TextMesh m_textMesh;

    // Use this for initialization
    void Start () {
        m_textMesh = GetComponent<TextMesh>();
        m_textMesh.fontSize = 0;
        m_textMesh.fontStyle = FontStyle.Normal;
        Build();
    }

    public float maxWitdh
    {
        get { return m_maxWidth; }
        set
        {
            m_maxWidth = value;
            Build();
        }
    }

    public float maxCharacterSize
    {
        get { return m_maxCharacterSize; }
        set
        {
            m_maxCharacterSize = value;
            Build();
        }
    }

    public void Build() {
        float width = 0;
        foreach (char symbol in m_textMesh.text)
        {
            CharacterInfo info;
            if (m_textMesh.font.GetCharacterInfo(symbol, out info, m_textMesh.fontSize, m_textMesh.fontStyle))
            {
                width += info.advance;
            }
        }

        if (width > 0)
        {
            width *= 0.1f;

            // width 如果等于0 会报错： 所以 得把 text 事先赋值
            float preferCharacterSize = m_maxWidth / width;
            m_textMesh.characterSize = m_maxCharacterSize < preferCharacterSize ? m_maxCharacterSize : preferCharacterSize;
        }
    }

    void LateUpdate()
    {
        Build();
    }

#if UNITY_EDITOR
    void OnDrawGizmos()
    {
        if (m_textMesh == null) return;

        float XLeft = 0f;
        float fAutoSizeMaxWidth = m_maxWidth * transform.lossyScale.x;

        if (m_textMesh.anchor == TextAnchor.LowerLeft || m_textMesh.anchor == TextAnchor.UpperLeft || m_textMesh.anchor == TextAnchor.MiddleLeft)
        {
            XLeft = transform.position.x;
        }
        else if (m_textMesh.anchor == TextAnchor.LowerCenter || m_textMesh.anchor == TextAnchor.UpperCenter || m_textMesh.anchor == TextAnchor.MiddleCenter)
        {
            XLeft = transform.position.x - fAutoSizeMaxWidth / 2f;
        }
        else
        {
            XLeft = transform.position.x - fAutoSizeMaxWidth;
        }
        
        float yPos = 0f;
        if (m_textMesh.anchor == TextAnchor.UpperCenter || m_textMesh.anchor == TextAnchor.UpperLeft || m_textMesh.anchor == TextAnchor.UpperRight)
        {
            yPos = transform.position.y;
        }
        else if (m_textMesh.anchor == TextAnchor.LowerCenter || m_textMesh.anchor == TextAnchor.LowerLeft || m_textMesh.anchor == TextAnchor.LowerRight)
        {
            yPos = transform.position.y;
        }
        else
        {
            yPos = transform.position.y;
        }

        Gizmos.DrawLine(new Vector3(XLeft, yPos, transform.position.z + m_textMesh.offsetZ), new Vector3(XLeft + fAutoSizeMaxWidth, yPos, transform.position.z + m_textMesh.offsetZ));
    }
#endif
}
