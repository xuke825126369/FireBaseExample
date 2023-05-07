using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.U2D;

[XLua.LuaCallCSharp]
public class CommonResSerialization : MonoBehaviour
{
    [SerializeField] List<GameObject> m_PrefabList = new List<GameObject>();
    [SerializeField] List<SpriteAtlas> m_AtlasList = new List<SpriteAtlas>();
    [SerializeField] List<Sprite> m_SpriteList = new List<Sprite>();
    [SerializeField] List<Texture> m_TextureList = new List<Texture>();
    [SerializeField] List<AudioClip> m_AudoClipList = new List<AudioClip>();
    [SerializeField] List<Shader> m_ShaderList = new List<Shader>();
    [SerializeField] List<Material> m_MaterialList = new List<Material>();

    public GameObject FindPrefab(string name)
    {
        return m_PrefabList.Find((x) => x != null && x.name == name);
    }

    public Sprite FindSprite(string name)
    {
        return m_SpriteList.Find((x) => x != null && x.name == name);
    }

    public Texture FindTexture(string name)
    {
        return m_TextureList.Find((x) => x != null && x.name == name);
    }

    public AudioClip FindAudioClip(string name)
    {
        return m_AudoClipList.Find((x) => x != null && x.name == name);
    }

    public Shader FindShader(string name)
    {
        return m_ShaderList.Find((x) => x != null && x.name == name);
    }

    public Material FindMaterial(string name)
    {
        return m_MaterialList.Find((x) => x != null && x.name == name);
    }

    public SpriteAtlas GetAtlas(string atlasName)
    {
        return m_AtlasList.Find((x) => x != null && x.name == atlasName);
    }

    public Sprite GetSpriteByAtlas(string atlasName, string spriteName)
    {
        return GetAtlas(atlasName).GetSprite(spriteName);
    }
}
