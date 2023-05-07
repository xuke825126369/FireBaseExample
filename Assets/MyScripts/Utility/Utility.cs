using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using Newtonsoft.Json;
using UnityEngine;

/// <summary>
/// 对委托的一些操作
/// </summary>
/// <typeparam name="T"></typeparam>
[XLua.LuaCallCSharp]
public static class DelegateUtility
{
    public static bool CheckFunIsExist<T>(Action<T> mEvent, Action<T> fun)
    {
        if (mEvent == null)
        {
            return false;
        }
        Delegate[] mList = mEvent.GetInvocationList();
        return Array.Exists<Delegate>(mList, (x) => x.Equals(fun));
    }
}

[XLua.LuaCallCSharp]
public static class TimeUtility
{
	public static string GetFormatStringByTimeSpan(TimeSpan mTimeSpan)
	{
		return mTimeSpan.ToString(@"hh\:mm\:ss");
	}

	public static TimeSpan GetTimeSpanFromDateString(string timeStr)
	{
		string dateFormatStr = "g";
		TimeSpan mTimeSpan = TimeSpan.ParseExact(timeStr, dateFormatStr, System.Globalization.CultureInfo.InvariantCulture);
		return mTimeSpan;
	}

	public static DateTime GetLocalTimeFromDateString(string timeStr)
	{
		string dateFormatStr = "yyyy/MM/dd HH:mm:ss";
		DateTime beginTime = DateTime.ParseExact(timeStr, dateFormatStr, System.Globalization.CultureInfo.InvariantCulture);
		return beginTime;
	}

	public static UInt64 GetTimeStampFromDateString(string timeStr)
	{
		DateTime beginTime = GetLocalTimeFromDateString(timeStr);
		return GetTimeStampFromLocalTime(beginTime);
	}

	public static UInt64 GetTimeStampFromLocalTime(DateTime nLocalTime)
	{
		System.DateTime utcTime = TimeZoneInfo.ConvertTimeToUtc(nLocalTime, TimeZoneInfo.Local);
		return GetTimeStampFromUTCTime(utcTime);
	}

	public static UInt64 GetTimeStampFromUTCTime(DateTime utcTime)
	{
		TimeSpan ts = utcTime - new DateTime(1970, 1, 1, 0, 0, 0);
		return (UInt64)ts.TotalSeconds;
	}

	public static DateTime GetUTCTimeFromTimeStamp(UInt64 nTimeStamp)
	{
		DateTime dateTimeStart = new DateTime(1970, 1, 1, 0, 0, 0);
		return dateTimeStart.AddSeconds(nTimeStamp);
	}

	public static DateTime GetLocalTimeFromTimeStamp(UInt64 mTimeStamp)
	{
		DateTime utcTime = GetUTCTimeFromTimeStamp(mTimeStamp);
		return TimeZoneInfo.ConvertTimeFromUtc(utcTime, TimeZoneInfo.Local);
	}

	public static DateTime GetLocalTimeFromUTCTime(DateTime utcTime)
	{
		return TimeZoneInfo.ConvertTimeFromUtc(utcTime, TimeZoneInfo.Local);
	}

	public static DateTime GetUtcTimeFromLocalTime(DateTime LocalTime)
	{
		return TimeZoneInfo.ConvertTimeToUtc(LocalTime, TimeZoneInfo.Utc);
	}
}

[XLua.LuaCallCSharp]
public class Timer
{
	private DateTime nLastTime;

	public Timer()
	{
		restart ();
	}

	public void restart ()
	{
		nLastTime = DateTime.Now;
	}

	public double elapsed ()
	{
		return (DateTime.Now - nLastTime).TotalSeconds;
	}
}

[XLua.LuaCallCSharp]
public class JsonHelper
{
	public static string FormatJsonString(string str)
	{
		//格式化json字符串
		JsonSerializer serializer = new JsonSerializer();
		TextReader tr = new StringReader(str);
		JsonTextReader jtr = new JsonTextReader(tr);
		object obj = serializer.Deserialize(jtr);
		if (obj != null)
		{
			StringWriter textWriter = new StringWriter();
			JsonTextWriter jsonWriter = new JsonTextWriter(textWriter)
			{
				Formatting = Formatting.Indented,
				Indentation = 4,
				IndentChar = ' '
			};
			serializer.Serialize(jsonWriter, obj);
			return textWriter.ToString();
		}
		else
		{
			return str;
		}
	}
}

[XLua.LuaCallCSharp]
public static class RandomUtility
{
	private static System.Random random = null;

	static RandomUtility()
	{
		int nSeed = (int)DateTime.Now.Ticks;
		random = new System.Random(nSeed);
	}

	public static double Random()
	{
		return random.NextDouble();
	}

	public static int Random(int x, int y)
	{
		return random.Next(x, y + 1);
	}

	public static uint Random(uint x, uint y)
	{
		return (uint)random.Next((int)x, (int)y + 1);
	}

	public static ulong Random(ulong x, ulong y)
	{
		return x + (ulong)((y - x) * random.NextDouble());
	}
}

[XLua.LuaCallCSharp]
public static class DebugUtility
{
    public static void LogWithColor(string message)
    {
        Debug.Log("<color=yellow>" + message + "</color>");
    }
}
