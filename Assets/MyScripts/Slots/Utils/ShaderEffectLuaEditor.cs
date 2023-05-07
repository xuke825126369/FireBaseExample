#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using UnityEditor;
using UnityEngine.SceneManagement;

[RequireComponent(typeof(MaterialResource))]
public class ShaderEffectLuaEditor : MonoBehaviour 
{
    public string m_LuaPath = "Lua/";
    public string m_EntryPointFunc = "EditorTest";
    
    void Start () 
    {
        if (SceneManager.GetActiveScene().name == "Scene")
        {
            enabled = false;
            return;
        }

        string gameObjecFullName = GetRootFullName();

        LuaEnv mLuaEnv = new LuaEnv();
        mLuaEnv.AddLoader((ref string filename) => {
            TextAsset luaTextAsset = null;
            string path = "Assets/LuaCode/" + filename.Replace('.', '/') + ".lua.txt";
            luaTextAsset = UnityEditor.AssetDatabase.LoadAssetAtPath<TextAsset>(path);
            if (luaTextAsset != null)
            {
                return System.Text.Encoding.UTF8.GetBytes(LuaParser.Decode(luaTextAsset.text));
            }
            return null;
        });

        mLuaEnv.DoString("print('Start')  \n" +
            "local luaScript = require '" + m_LuaPath + "' \n" +
            "luaScript:" + m_EntryPointFunc + "('" + gameObjecFullName + "') \n" +
            "print('Finish')"
            );
	}

    private string GetRootFullName()
    {
        string path = "";

        List<string> mPathList = new List<string>();

        Transform mTransform = transform;
        while (mTransform.parent)
        {
            mPathList.Add(mTransform.parent.name);
            mTransform = mTransform.parent;
        }

        for (int i = mPathList.Count - 1; i >= 0; i--)
        {
            string Name = mPathList[i];
            path += Name + "/";
        }

        path += transform.name;

        return path;
    }

}

#endif