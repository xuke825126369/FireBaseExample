#if UNITY_IPHONE || UNITY_IOS

using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using System.IO;

public class PlayFabPostProcessBuild
{
    [PostProcessBuild]
    public static void ChangeXcodePlist(BuildTarget buildTarget,
                                        string pathToBuiltProject)
    {
        string plistPath = pathToBuiltProject + "/Info.plist";
        PlistDocument plist = new PlistDocument();
        plist.ReadFromString(File.ReadAllText(plistPath));

        PlistElementDict rootDict = plist.root;

        rootDict.SetString("NSLocationWhenInUseUsageDescription", "Analyze the geographic distribution of player audiences to increase game revenue");
        File.WriteAllText(plistPath, plist.WriteToString());
    }
}

#endif
