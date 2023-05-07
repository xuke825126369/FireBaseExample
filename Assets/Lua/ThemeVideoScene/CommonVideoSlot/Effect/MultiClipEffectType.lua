local MultiClipEffectType = {}

MultiClipEffectType.EnumMultiClipEffectType_NULL = 0
MultiClipEffectType.EnumPixieScatter_Stop = 1 --//playMode=0
MultiClipEffectType.EnumPixieScatter_Ani = 2 -- //playMode=1

MultiClipEffectType.EnumMardigrasLampEffect_Stop = 3 --//4-14 暂时不用了。。白加了以后再说
MultiClipEffectType.EnumMardigrasLampEffect_Ani = 4
	
MultiClipEffectType.EnumClipEffectDefaultClip = 5 -- //类似LuckyVegas里的wild scatter这种，一个静态的clip加一个中奖的aniClip
MultiClipEffectType.EnumClipEffectAniClip = 6 -- // m_nPlayMode = 1时播放 中奖特效。。。
MultiClipEffectType.EnumChangeEffectClip = 7 --  //TroyNormalWild 小变大的特效。。。m_nPlayMode = 2时播放

return MultiClipEffectType