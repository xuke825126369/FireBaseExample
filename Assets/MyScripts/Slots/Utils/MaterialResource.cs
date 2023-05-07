using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

[LuaCallCSharp]
public class MaterialResource : MonoBehaviour 
{
    public List<Shader> m_ShaderList = null;
    public List<Texture2D> mTextureList = null; 

    public Shader GetShader(string name)
    {
       return m_ShaderList.Find((x)=> x.name == name);
    }

    public Texture2D GetTexture(string name)
    {
        return mTextureList.Find((x)=> x.name == name);
    }
}
