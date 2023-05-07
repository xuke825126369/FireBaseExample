using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public static class LuaParser
{
	public static string Encode(string input)
	{
		return AESHelper.Encode(input);
	}

	public static string Decode(string hexString)
	{
		return AESHelper.Decode(hexString);
	}
}
