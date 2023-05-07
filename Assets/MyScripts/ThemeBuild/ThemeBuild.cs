using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ThemeBuild : MonoBehaviour
{
    [System.Serializable]
    public class BuildItem
    {
        public bool m_bSelect = false;
        public string themeName = string.Empty;
    }
    
    public List<BuildItem> m_BuildThemeVideoList = new List<BuildItem>();
}
