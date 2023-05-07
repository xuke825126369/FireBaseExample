using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using XLua;

[LuaCallCSharp]
public static class UnityEngineObjectExtention
{
    public static Transform FindDeepChild(this Transform aParent, string aName)
    {
        var result = aParent.Find(aName);
        if (result != null)
        {
            return result;
        }

        foreach (Transform child in aParent)
        {
            result = child.FindDeepChild(aName);
            if (result != null)
            {
                return result;
            }
        }
        return null;
    }

    public static void DestroyAllChildren(this Transform aParent)
	{
		foreach(Transform child in aParent)
		{
			GameObject.Destroy (child.gameObject);
		}
	}
	
	public static void SetAlpha(this Image image, float alpha)
	{
		Color color = image.color;
		color.a = alpha;
		image.color = color;
	}

	public static void SetAlpha(this TextMeshProUGUI textMeshProUGUI, float alpha)
	{
		Color color = textMeshProUGUI.color;
		color.a = alpha;
		textMeshProUGUI.color = color;
	}

	public static void SetAlpha(this TextMeshPro textMeshPro, float alpha)
	{
		Color color = textMeshPro.color;
		color.a = alpha;
		textMeshPro.color = color;
	}

	public static void VolumeTo(this AudioSource audioSource, float to, float time) {
		LeanTween.value (audioSource.volume, to, time).setOnUpdate ((float value) => {
			audioSource.volume = value;
		});
	}
}
