using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public static class StreamingAssetsBundlePathDir
{
	private static List<string> mBundleNameList = new List<string>()
    {
		"initscene_054a6c7dea1e6c9397350afc20a4037f",
		"themevideoentry_redhat_9dc1f9e60f9b8dd1ce62dd44e8ad141c",
		"themevideoslot_redhat_98335164df79503e1e3a9d99a3da12f7",
	};

	public static bool orExistFile(string subfilePath)
	{
		subfilePath = subfilePath.ToLower();
        return mBundleNameList.Contains(subfilePath);
	}
}
