using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEngine;

public class ClearCacheEditor : MonoBehaviour
{
	[MenuItem("UnityEditor/Clear PlayerPrefs")]
	private static void NewMenuOption1()
	{
		PlayerPrefs.DeleteAll();
	}

	[MenuItem("UnityEditor/Clear Cache")]
	private static void NewMenuOption2()
	{
		Caching.ClearCache();
	}

    [MenuItem("UnityEditor/Open Persist Dir")]
    public static void OpenPersistDir()
    {
        Process.Start(Application.persistentDataPath);
    }

    [MenuItem("UnityEditor/Clear Persist Dir")]
    public static void ClearPersistDir()
    {
        var ppath = Application.persistentDataPath;
        var dirs = Directory.GetDirectories(ppath);
        foreach (var d in dirs)
        {
            Directory.Delete(d, true);
            UnityEngine.Debug.Log($"remove persist dir {d}");
        }

        foreach (var d in Directory.GetFiles(ppath))
        {
            File.Delete(d);
            UnityEngine.Debug.Log($"remove persist file {d}");
        }
    }
}
