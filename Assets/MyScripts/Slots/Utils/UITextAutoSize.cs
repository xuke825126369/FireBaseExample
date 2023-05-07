using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways]
[RequireComponent(typeof(Text))]
[XLua.LuaCallCSharp]
public class UITextAutoSize : MonoBehaviour {

    private Text m_text;
    [SerializeField]
    private int m_maxFontSize;


    public int maxFontSize
    {
        get { return m_maxFontSize; }
        set
        {
            m_maxFontSize = value;
            Build();
        }
    }

    // Use this for initialization
    void Start () {
        m_text = GetComponent<Text>();
        Build();

    }

    public void Build() 
    {
        int defaultWidth = 0;
        foreach (char symbol in m_text.text)
        {
            CharacterInfo info;
            if (m_text.font.GetCharacterInfo(symbol, out info, m_text.font.fontSize,  m_text.fontStyle))
            {
                defaultWidth += info.advance;
            }
            else
            {
                Debug.Log("字体信息获取失败");
            }
        }

        if (defaultWidth > 0)
        {
            m_maxFontSize = m_maxFontSize == 0 ? m_text.font.fontSize : m_maxFontSize;
            int preferedFontSize = (int)m_text.rectTransform.sizeDelta.x * m_text.font.fontSize / defaultWidth;
            if (preferedFontSize < m_maxFontSize) {
                m_text.fontSize = preferedFontSize;
            } else {
                m_text.fontSize = m_maxFontSize;
            }
        }

    }

    void LateUpdate()
    {
        Build();
    }


}
