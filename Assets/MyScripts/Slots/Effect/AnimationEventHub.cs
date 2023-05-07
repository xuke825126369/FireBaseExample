using UnityEngine;
using System;

using XLua;

public class AnimationEventHub : MonoBehaviour
{
	private LuaTable m_LuaTable = null;
	private Action<LuaTable, string> m_LuaAnimationEventFunc = null;

	void Awake()
	{
		m_LuaTable = LuaMainEnv.Instance.GetLuaClientEnv().Global.GetInPath<LuaTable> ("AnimationEventHub");
		m_LuaAnimationEventFunc = m_LuaTable.GetInPath<Action<LuaTable, string> > ("AnimationEventFunc");
	}

	public void AnimationEventFunc(string strParam)
	{
		m_LuaAnimationEventFunc(m_LuaTable, strParam);
	}
}

