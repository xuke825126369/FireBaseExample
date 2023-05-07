using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Text;

public class LuaCopyEditor
{
	[MenuItem("XLua/CopyLua")]
	public static void CopyLua ()
	{
		string root = "Assets/Lua";
		string dest = "Assets/ResourceABs/Lua";
		if (Directory.Exists (dest)) {
			Directory.Delete (dest, true);
		}
		Directory.CreateDirectory(dest);
		CloneLuaDirectory (root, dest);

		CreateInitSceneFile();

		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh ();
		Debug.Log ("Copy Lua Success !");
	}

	private static void CloneLuaDirectory(string root, string dest)
	{
		foreach (var directory in Directory.GetDirectories(root))
		{
			string dirName = Path.GetFileName(directory);
			if (!Directory.Exists(Path.Combine(dest, dirName)))
			{
				Directory.CreateDirectory(Path.Combine(dest, dirName));
			}
			CloneLuaDirectory(directory, Path.Combine(dest, dirName));
		}

		foreach (var file in Directory.GetFiles(root))
		{
			if (file.EndsWith(".lua") || file.EndsWith(".pb") || file.EndsWith(".proto"))
			{
				EncodeAndWriteFile(dest, file);
			}
		}
	}

	private static void ClearInitSceneFile(string root)
    {
		foreach (var file in Directory.GetFiles(root))
		{
			if (file.EndsWith(".lua") || file.EndsWith(".lua.txt") || file.EndsWith(".pb") || file.EndsWith(".proto"))
			{
				File.Delete(file);
			}
		}
	}

	private static void EncodeAndWriteFile(string destPath, string orifilePath)
    {
		string content = File.ReadAllText(orifilePath, Encoding.UTF8);
		content = LuaParser.Encode(content);
		string filePath = Path.Combine(destPath, Path.GetFileName(orifilePath) + ".txt");
		File.WriteAllText(filePath, content, Encoding.UTF8);
	}

	private static void CreateInitSceneFile()
	{
		string dest = "Assets/ResourceABs/InitScene/";
		ClearInitSceneFile(dest);

		string root1 = "Assets/Lua/InitScene/";
		string dest1 = "Assets/ResourceABs/InitScene/Lua/";
		CloneLuaDirectory(root1, dest1);

		string srcfilePath1 = "Assets/Lua/Utility/CSharpApiToLua.lua";
		EncodeAndWriteFile(dest1, srcfilePath1);

        srcfilePath1 = "Assets/Lua/Utility/LuaHelper.lua";
        EncodeAndWriteFile(dest1, srcfilePath1);

        srcfilePath1 = "Assets/Lua/Utility/LogManager.lua";
		EncodeAndWriteFile(dest1, srcfilePath1);
		
		srcfilePath1 = "Assets/Lua/Effect/ViewScaleAni.lua";
		EncodeAndWriteFile(dest1, srcfilePath1);

		srcfilePath1 = "Assets/Lua/Utility/LuaAutoBindMonoBehaviour.lua";
		EncodeAndWriteFile(dest1, srcfilePath1);
				
		srcfilePath1 = "Assets/Lua/Utility/DelegateCache.lua";
		EncodeAndWriteFile(dest1, srcfilePath1);
	}
}
