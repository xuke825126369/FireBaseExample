using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderAutoFind : MonoBehaviour
{
    public List<Shader> mShaderList = new List<Shader>();

    private static ShaderAutoFind Instance;
    private void Awake()
    {
        Instance = this;
    }

    private Shader Find1(string shaderName)
    {
        return mShaderList.Find((x) => x.name == shaderName);
    }

    public static Shader Find(string shaderName)
    {
#if UNITY_EDITOR
        return Shader.Find(shaderName);
#else
        return ShaderAutoFind.Instance.Find1(shaderName);
#endif
    }
}
