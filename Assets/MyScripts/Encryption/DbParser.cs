using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public static class DbParser
{
    public static string Encode(string original)
    {
        return AESHelper.Encode(original);
    }

    public static string Decode(string original)
    {
        return AESHelper.Decode(original);
    }
}
