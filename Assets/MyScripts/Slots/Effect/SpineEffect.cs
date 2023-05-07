using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using Spine.Unity;


public enum enumSpinAnimationType
{
	//GodOfWealth --2 animations
	EnumSpinType_Normal = 0, // "animation" -- 笑
	EnumSpinType_GodOfWealthClap = 1, //"xiaohehe" -- 拍手

	//Witch magicBall --2 animations
	EnumSpinType_MagicBallWin = 2, // >=6个触发中奖 或者是respin结束结算时候播放 长动画。。
};

public class SpineEffect : MonoBehaviour 
{
	//以下是放在canvas外面的spine动画 --2017--4--29
	public SkeletonAnimation m_SpineAnimation1 = null;
	public SkeletonAnimation m_SpineAnimation2 = null;
	public SkeletonAnimation m_SpineAnimation3 = null;
	//

	public bool m_bNeedStopFlag = false; //true 逻辑已经要求该特效停止了，等这一遍播放结束就停止！

	//m_SpineAnimation1.AnimationState.compele、、 .state.comp

	private bool m_bActiveAnimation = false;

	private readonly string ACTIVEANIMATION_NAME = "animation"; //笑
	private readonly string GODOFWEALTHCLAP_NAME = "xiaohehe";  //拍手
	private readonly string MAGICBALLWIN_NAME = "animation2";

	private enumSpinAnimationType m_curEnumAniType = enumSpinAnimationType.EnumSpinType_Normal;

	private bool m_bInitParamFlag = false;

	private bool m_bInPlaying = false;
	// Use this for initialization
	void Start()
	{
		if(!m_bInPlaying)
		{
			initParam();
			Reset();

			if(m_SpineAnimation1 != null)
				m_SpineAnimation1.state.Complete += SpineAnimation1Complete;
			if(m_SpineAnimation2 != null)
				m_SpineAnimation2.state.Complete += SpineAnimation2Complete;
			if(m_SpineAnimation3 != null)
				m_SpineAnimation3.state.Complete += SpineAnimation3Complete;

//			m_SpineAnimation1.state.Complete += (trackIndex) => {
//				Debug.Log("----m_SpineAnimation1.state.Complete-----" + trackIndex);
//			};

		}
	}

	void SpineAnimation1Complete(Spine.TrackEntry entry)
	{
		//Debug.Log("--------SpineAnimation1Complete---------" + entry);
		//就依据spine1来确定是否播放完一遍了。。
		if(m_bNeedStopFlag)
			StopActiveAnimation();
	}

	void SpineAnimation2Complete(Spine.TrackEntry entry)
	{
		//Debug.Log("--------SpineAnimation2Complete---------" + entry);
	}

	void SpineAnimation3Complete(Spine.TrackEntry entry)
	{
		//Debug.Log("--------SpineAnimation3Complete---------" + entry);
	}

	public void setNeedStop()
	{
		m_bNeedStopFlag = true;
	}

	// Update is called once per frame
	void Update()
	{
	}

	public void initParam()
	{
		if(m_bInitParamFlag)
			return;
		m_bInitParamFlag = true;

	}

	public void PlayActiveAnimation(bool bLoop)
	{
		PlayActiveAnimation(enumSpinAnimationType.EnumSpinType_Normal, bLoop);
	}

	public void PlayActiveAnimation()
	{
		PlayActiveAnimation(enumSpinAnimationType.EnumSpinType_Normal, true);
	}

	public void PlayActiveAnimation(enumSpinAnimationType enumType, bool bLoop, float fSpeed = 1.0f)
	{
		m_bInPlaying = true;

		if(m_bActiveAnimation)
		{
			//某元素上次拍完手没有中奖 下次再来的时候需要拍手还得拍手。。所以这里不能把拍手的情况return了
			if(m_curEnumAniType==enumType && enumType==enumSpinAnimationType.EnumSpinType_Normal)
				return;
			else
			{
				StopActiveAnimation();
			}
		}

		m_curEnumAniType = enumType;

		initParam();

		string strAniName = ACTIVEANIMATION_NAME;
		switch(enumType)
		{
		case enumSpinAnimationType.EnumSpinType_GodOfWealthClap:
			{
				strAniName = GODOFWEALTHCLAP_NAME;
			}
			break;

		case enumSpinAnimationType.EnumSpinType_MagicBallWin:
			{
				strAniName = MAGICBALLWIN_NAME;
			}
			break;

			default:
			break;
		}

		m_bActiveAnimation = true;

		if(m_SpineAnimation1 != null)
		{
			m_SpineAnimation1.AnimationState.TimeScale = fSpeed;
			m_SpineAnimation1.AnimationState.SetAnimation(0, strAniName, bLoop).TrackTime = 0.0f;
		}

		if(m_SpineAnimation2 != null)
		{
			m_SpineAnimation2.AnimationState.TimeScale = fSpeed;
			m_SpineAnimation2.AnimationState.SetAnimation(0, strAniName, bLoop).TrackTime = 0.0f;
		}

		if(m_SpineAnimation3 != null)
		{
			m_SpineAnimation3.AnimationState.TimeScale = fSpeed;
			m_SpineAnimation3.AnimationState.SetAnimation(0, strAniName, bLoop).TrackTime = 0.0f;
		}
	}

	public void StopActiveAnimation()
	{
		m_bNeedStopFlag = false;

		Reset();
		return;
	}

	public void Reset()
	{
		m_bInPlaying = false;

		m_bActiveAnimation = false;

		if(m_SpineAnimation1 != null)
		{
			var track = m_SpineAnimation1.AnimationState.GetCurrent(0);
			if(track != null)
				track.TrackTime = 0.0f;
			else
			{
			}

			m_SpineAnimation1.AnimationState.TimeScale = 0.0f;
		}

		if(m_SpineAnimation2 != null)
		{
			var track = m_SpineAnimation2.AnimationState.GetCurrent(0);
			if(track != null)
				track.TrackTime = 0.0f;
			else
			{
			}

			m_SpineAnimation2.AnimationState.TimeScale = 0.0f;
		}

		if(m_SpineAnimation3 != null)
		{
			var track = m_SpineAnimation3.AnimationState.GetCurrent(0);
			if(track != null)
				track.TrackTime = 0.0f;
			else
			{
			}

			m_SpineAnimation3.AnimationState.TimeScale = 0.0f;
		}
	}
}
