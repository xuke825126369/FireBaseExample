--[[
    author:{author}
    time:2021-08-11 14:29:37
]]
ThemeParkLevelUI = {}
ThemeParkLevelUI.mapGoReelbg = {} -- 黄色背景游戏对象表
ThemeParkLevelUI.goZhaohuo = {} -- 着火特效游戏对象
ThemeParkLevelUI.bIsFiring = false -- 是否正在着火

ThemeParkLevelUI.bPlayingFireSound = false -- 是否正在播放着火音效
ThemeParkLevelUI.audioFire = nil -- 着火音效

-- FreeSpin
ThemeParkLevelUI.fFreeSpinPlayCutSceneTime = 0.5 --弹窗开始播放隐藏动画后，多长时间开始播放FreeSpin转场动画
ThemeParkLevelUI.fFreeSpinLoadSceneTime = 1.1 --播放FreeSpin转场动画后，多长时间切换场景
-- ThemeParkLevelUI.nUsefulCharSymbolNum = 0 -- FreeSpin 中如果在特定的线上出现了和选择的角色一样的Symbol，则要增加Prize
ThemeParkLevelUI.bTriggerScatterBonus = false
ThemeParkLevelUI.bIsCharacterRewardFollowParticleFinished = true
ThemeParkLevelUI.bIsScatterFollowParticleFinished = true





function ThemeParkLevelUI:initLevelUI()
    self.DiceSpine = require "Lua/ThemeVideo2020/ThemePark/SplashUI/DiceSpine"
    self.DiceSpine:Init()

    self.transform = ThemeVideo2020Scene.mNewGameNodeParent.transform:FindDeepChild("LevelBG")

    -- self.goNormalSpinTitle = self.m_transform:FindDeepChild("NormalSpinTitle").gameObject
    self.CharacterSelectUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/CharacterSelectUI"
    self.CharacterSelectUI:Init()

    self.FreeSpinBeginSplashUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/FreeSpinBeginSplashUI"
    self.FreeSpinBeginSplashUI:Init()

    self.FreeSpinFinishSplashUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/FreeSpinFinishSplashUI"
    self.FreeSpinFinishSplashUI:Init()

    self.ChestSplashUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/ChestSplashUI"
    self.ChestSplashUI:Init()

    self.GiftBoxSplashUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/GiftBoxSplashUI"
    self.GiftBoxSplashUI:Init()

    self.FreeSpinExtraSplashUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/FreeSpinExtraSplashUI"
    self.FreeSpinExtraSplashUI:Init()

    self.GoldCoinSplashUI = require "Lua/ThemeVideo2020/ThemePark/SplashUI/GoldCoinSplashUI"
    self.GoldCoinSplashUI:Init()
    
    ThemeParkFreeSpin:InitFreeSpinParm()
    ThemeParkFreeSpinUI:Init() 

    self.m_SpecialEffects = self.transform:FindDeepChild("SpecialEffects")
    -- 获取3个reelbg黄色背景游戏对象
    local trReelbg = self.transform:FindDeepChild("ReelBG")
    local trReel0bg = trReelbg.transform:FindDeepChild("reelbg0")
    trReel0bg.gameObject:SetActive(false)
    local trReel2bg = trReelbg.transform:FindDeepChild("reelbg2")
    trReel2bg.gameObject:SetActive(false)
    local trReel4bg = trReelbg.transform:FindDeepChild("reelbg4")
    trReel4bg.gameObject:SetActive(false)
    self.mapGoReelbg = {trReel0bg.gameObject, trReel2bg.gameObject, trReel4bg.gameObject}

    -- 获取着火游戏特效
    self.goZhaohuo = self.transform:FindDeepChild("zhaohuo").gameObject
    self.goZhaohuo:SetActive(false)
    self.bIsFiring = false

    -- 获取棋盘上方的Mega Bonus
    self.trMega1 = self.transform:FindDeepChild("Mega")
    self.trMega2 = self.transform:FindDeepChild("Mega1")
    -- self:HideMegaBonusExplosion()

    self.mapCharSymbolRewardEffect = {}
    for i = 0, 4 do
        local EffectName = "huanraolizi" .. i
        local goEffect = trReelbg.transform:FindDeepChild(EffectName).gameObject
        goEffect:SetActive(false)
        table.insert(self.mapCharSymbolRewardEffect, goEffect)
    end

    -- 设置棋盘的遮罩
    self:SetRectMaskGroup()
end


function ThemeParkLevelUI:FindSymbolElement(goSymbol, strkey)
    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end

    if self.goSymbolElementPool[goSymbol][strkey] == nil then
        if strkey == "Animatior" then
            self.goSymbolElementPool[goSymbol][strkey] = goSymbol:GetComponentInChildren(typeof(Unity.Animator))
            if self.goSymbolElementPool[goSymbol][strkey] == nil then
                Debug.LogError(goSymbol.name)
            end
        end
    end

    return self.goSymbolElementPool[goSymbol][strkey]
end


function ThemeParkLevelUI:PlayAnimator(goAnimator, strkey)
    Debug.Assert(goAnimator)
    local animator = self:FindSymbolElement(goAnimator, "Animatior")
    Debug.Assert(animator)
    if animator and goAnimator.activeInHierarchy then
        animator:Play(strkey, 0, 0)
    end
end

--[[
    @desc: 设置动画状态机
    author:coldflag
    time:2021-08-26 11:12:40
    --@Animator: 状态机
	--@strkey: 变量名
	--@nAction: 状态值
    @return:
]]
function ThemeParkLevelUI:SetInteger(Animator, strkey, nAction)
    Debug.Assert(Animator)
    if Animator and Animator.gameObject.activeInHierarchy then
        if Animator:GetInteger(strkey) ~= nAction then
            Animator:SetInteger(strkey, nAction)
        end
    end
end

-- 隐藏棋盘上方的Mega Bonus的爆炸特效，并设置为Idle状态
function ThemeParkLevelUI:HideMegaBonusExplosion()
    if self.trMega1 then
        local ExplosionEffect = self.goMega1:FindDeepChild("baozha1")
        ExplosionEffect.gameObject:SetActive(false)

    end
    if self.trMega1 then
        local ExplosionEffect = self.goMega2:FindDeepChild("baozha2")
        ExplosionEffect.gameObject:SetActive(false)
    end
end

-- 显示棋盘上方的Mega Bonus的爆炸特效
function ThemeParkLevelUI:ShowMegaBonusExplosion()
    if self.goBaozha1 then
        self.goBaozha1:SetActive(true)
    end
    if self.goBaozha2 then
        self.goBaozha2:SetActive(true)
    end
end

--[[
    @desc: 如果是第一个出现的Scatter且在第一列，或者是第二个出现的Scatter且在第三列，则可能会中奖
    author:coldflag
    time:2021-08-31 09:44:18
    --@nReelID: 
    @return:
]]
function ThemeParkLevelUI:IsScatterPossiblyUseful(nReelID)
    local bIsUseful = false
    
    if #ThemeParkFreeSpinUI.mapGoScatter == 1 and nReelID == 0 then
        bIsUseful = true
    end

    if #ThemeParkFreeSpinUI.mapGoScatter == 2 and nReelID == 2 then
        bIsUseful = true
    end
    

    return bIsUseful
    
end

--[[
    @desc: 播放Scatter落地特效
    author:coldflag
    time:2021-08-20 18:37:09
    --@key: 棋盘上的元素的位置，0~14。 与Deck表一致
    @return:
]]
function ThemeParkLevelUI:ShowScatterLandedEffect(key)
    local rv = false

    local nRowCount = SlotsGameLua.m_nRowCount
    local nReelID = math.floor(key / nRowCount)
    local nRowIndex = math.floor(key % nRowCount)

    local listGoSymbol = SlotsGameLua.m_listReelLua[nReelID].m_listGoSymbol
    local goSymbol = listGoSymbol[nRowIndex]

    -- 这个Scatter游戏对象加入要结算的列表
    table.insert(ThemeParkFreeSpinUI.mapGoScatter, goSymbol)
    if #ThemeParkFreeSpinUI.mapGoScatter == 3 then
        self.bTriggerScatterBonus = true
    end
    

    -- 如果可能有用，就从对象池中获取这个游戏对象作为索引的游戏特效
    
    local ScatterLandEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]
    if ScatterLandEffect == nil then
        rv = false
    else
        ThemeParkFunc:SetSymbolRectGroup(goSymbol, nil)

        -- 动画名， 延时几秒播放， 是否循环， 播放速率
        ScatterLandEffect:PlayAnimation("animation1", 0, false, 1)
        -- 播放落地音效

        rv = true
    end

    

    return rv
end

--[[
    @desc: 从特效缓存池中取出特效，如果没有在缓存池中，则从磁盘读取预制件
    author:coldflag
    time:2021-08-19 16:36:08
    --@strkey: 特效名称
    @return: 特效游戏对象
]]
function ThemeParkLevelUI:GetEffectByEffectPool(strkey)
    if not self.EffectPool then
        self.EffectPool = {}
    end

    if not self.EffectPool[strkey] then
        self.EffectPool[strkey] = {}
    end

    if not self.EffectParent then
        self.EffectParent = {}
    end

    if not self.EffectParent[strkey] then
        local obj = Unity.GameObject()
        obj.transform:SetParent(self.m_SpecialEffects)
        obj.transform.localPosition = Unity.Vector3.zero
        obj.name = strkey .. "s"
        self.EffectParent[strkey] = obj.transform
    end

    local UsedObj = table.remove(self.EffectPool[strkey])
    if UsedObj then
        UsedObj.transform:SetParent(self.EffectParent[strkey], false)
        return UsedObj
    else
        local assetPath = "SpecialEffectAnimation/" .. strkey .. ".prefab"
        local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
        if goPrefab == nil then
            Debug.Log("GetEffectByEffectPool goPrefab == nil" .. strkey)
        end

        local obj = Unity.Object.Instantiate(goPrefab)
        obj.name = strkey
        obj.transform:SetParent(self.EffectParent[strkey], false)
        obj:SetActive(false)

        table.insert(self.EffectPool[strkey], obj)
    end

    return self:GetEffectByEffectPool(strkey)
end

--[[
    @desc: 将不用的特效对象重新加回缓存池中
    author:coldfla
    time:2021-08-19 16:40:31
    --@UsedObj: 特效对象
    @return: true or false
]]
function ThemeParkLevelUI:RecycleEffectToPool(UsedObj)
    if UsedObj == nil then
        return false
    end

    UsedObj.transform:SetParent(self.EffectParent[UsedObj.name], false)
    UsedObj:SetActive(false)
    table.insert(self.EffectPool[UsedObj.name], UsedObj)

    return true
end

--[[
    @desc: 将有Scatter列的黄色背景设为隐藏
    author:coldflag
    time:2021-08-23 09:25:32
    @return:
]]
function ThemeParkLevelUI:RemoveYellowGB()
    if #self.mapGoReelbg > 0 then
        for i = 1, #self.mapGoReelbg do
            self.mapGoReelbg[i]:SetActive(false)
        end
        return true
    end
    return false
end

--[[
    @desc: 将有Scatter列的黄色背景激活
    author:coldflag
    time:2021-08-23 09:26:06
    --@nReelID: 列的名称
    @return:
]]
function ThemeParkLevelUI:SetYellowBG(nReelID)
    local rv = false
    if self:IsScatterPossiblyUseful(nReelID) then
        if nReelID == 0 then
            self.mapGoReelbg[1]:SetActive(true)
            rv = true
        end
        if nReelID == 2 then
            self.mapGoReelbg[2]:SetActive(true)
            rv = true
        end
        if nReelID == 4 then
            self.mapGoReelbg[3]:SetActive(true)
            rv = true
        end
    end
    
    return rv
end

--[[
    @desc: 修改最后一列的滚动时间为3.9倍
    author:coldflag
    time:2021-08-23 11:09:27
    @return: 
]]
function ThemeParkLevelUI:RaiseReelDistance()
    local rv = false
    
    local fDisCoef = 3.9
    local fDis = SlotsGameLua.m_fRotateDistance * fDisCoef
    if SlotsGameLua.m_bQuickStopFlag then
        SlotsGameLua.m_listReelLua[4]:ModifyRotateDistance(fDis)
        rv = true
    else
        SlotsGameLua.m_listReelLua[4].m_fRotateDistance = fDis
        rv = true
    end

    if not self.bPlayingFireSound then
        self.audioFire = AudioHandler:PlayThemeSound("slotfire")
        self.bPlayingFireSound = true
        rv = true
    end

    return rv
end

--[[
    @desc: 根据参数来选择是否需要播放着火特效，若需要，则还会增加最后一列的旋转距离，并播放着火音效；
                                        若不需要，则关闭着火特效和音效
    author:coldflag
    time:2021-08-23 10:35:28
    --@bActiveFlag: TRUE 为激活， FALSE 隐藏
    @return: TRUE 为执行了正常的操作，FALSE为执行了不正常的操作或未操作
]]
function ThemeParkLevelUI:ActiveFireEffect(bActiveFlag)
    local rv = false

    if bActiveFlag then
        if not self.bIsFiring then
            self:RaiseReelDistance() -- 增加旋转时间，并播放着火音效
            self.goZhaohuo:SetActive(true)
            self.bIsFiring = true
            rv = true
        else
            rv = false
        end
    else
        if self.bIsFiring then
            if self.audioFire then -- 关闭音效
                self.audioFire:Stop()
                self.slotFireAudioSource = nil
            end
            self.goZhaohuo:SetActive(false) -- 关闭特效
            self.bIsFiring = false
            rv = true
        else
            rv = false
        end
    end

    return rv
end

--[[
    @desc: 只有没有在FreeSpin期间,触发FreeSpin才会播放Scatter中奖特效
    author:coldflag
    time:2021-08-25 19:00:00
    @return:
]]
function ThemeParkLevelUI:ShowScatterBonusEffect()
    local rv = false
    if SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount == 0 then
        for k, v in pairs(ThemeParkFreeSpinUI.mapGoScatter) do
            self:PlaySignalScatterBonusEffect(v, true)
       end
    end

    return rv
end

--[[
    @desc: 停止FreeSpin中奖特效
    author:coldflag
    time:2021-08-26 13:51:38
    @return:
]]
function ThemeParkLevelUI:StopScatterBonusEffect()
    local rv = false
    if ThemeParkFreeSpinUI.mapGoScatter ~= nil then
        for k, v in pairs(ThemeParkFreeSpinUI.mapGoScatter) do
            -- 从对象池中获取这个游戏对象作为索引的游戏特效
           local ScatterBonusEffect = SymbolObjectPool.m_mapSpinEffect[v]
           if ScatterBonusEffect == nil then
               rv = false
           else
               ThemeParkFunc:SetSymbolRectGroup(v, self.m_cpDefaultMaskGroup)
               ScatterBonusEffect:setNeedStop()
               rv = true
           end
       end
    end

    return rv
end

--[[
    @desc: 由公共流程自行调用， 用于处理FreeSpin弹出后，点击Start后，公共流程不能处理的逻辑
    author:coldflag
    time:2021-08-27 17:00:16
    --@bShowFlag: 
    @return:
]]
function ThemeParkLevelUI:ShowFreeSpinUI(bShowFlag)
    if bShowFlag then
        -- FreeSpin开始
        -- SceneSlotGame.m_bUIState = true -- 阻塞公共流程，暂时处理剩余的逻辑，在ThemeParkFreeSpinUI:onCompleteMapMove()中，置为false，放行公共流程
        self:StopScatterBonusEffect()
        ThemeParkFreeSpinUI.mapGoScatter = {}
        
        PayLinePayWaysEffectHandler:MatchLineHide(true) -- 隐藏Spin结束后的中奖特效
        ThemeParkFreeSpinUI:ShowCharacterSelectScene()  -- 展示选择人物界面，剩余的（人物选择完成后，隐藏人物选择界面）在玩家选择人物后，由按钮的监听函数完成
    else
        -- FreeSpin结束
        LevelUI.CharacterSelectUI:FlushCharacterID(nil)
        ThemeParkFreeSpin.bHasDownMap = false
        -- ThemeParkFreeSpin:ResetCharacterPosition() -- 当人物读取到的是nil的时候，会先重置位置

        ThemeParkFreeSpinUI:BackToNormalScene()
    end
end 


--[[
    @desc: 用于给SplashUI调用的接口
    author:coldflag
    time:2021-08-26 13:53:45
    @return:
]]
function ThemeParkLevelUI:OnFreeSpinBeginSplashUIHide()
    self:StopScatterBonusEffect()
    AudioHandler:LoadFreeGameMusic()
    
    SceneSlotGame:ShowFreeSpinUI(true) -- 此处转入公共流程，然后由公共流程转入self:ShowFreeSpinUI(true)，即上面一个函数
end

--[[
    @desc: 用于给SplashUI调用的接口
    author:coldflag
    time:2021-09-07 18:11:27
    @return:
]]
function ThemeParkLevelUI:OnFreeSpinEndSplashUIHide()
    AudioHandler:LoadBaseGameMusic()
end

--[[
    @desc: 在FreeSpin中，返回@nReelID列可能出现和当前选择角色一样的符号的行位置
    author:coldflag
    time:2021-08-31 14:10:00
    @return: 位置表
]]
function ThemeParkLevelUI:ReturnPossibleCharSymbolRowPos(nReelID)
    -- 加载当前列有效的角色符号的位置
    local mapNeedToIncreasePrizeLines = ThemeParkConfig:Return_NeedToIncreasePrize_Lines()
    local mapCharSymbolRowPos = {}
    for k, v in pairs(mapNeedToIncreasePrizeLines) do 
        local lineIndex = SlotsGameLua:GetLine(v)
        if not Tool:IsElemInTable(lineIndex.Slots[nReelID], mapCharSymbolRowPos) then -- 如果有重复的，就不保存了
            table.insert(mapCharSymbolRowPos, lineIndex.Slots[nReelID])
        end
    end

    return mapCharSymbolRowPos
end

--[[
    @desc: 这个符号如果在人物奖励的线上，那么认为是可能有用的
    author:coldflag
    time:2021-08-31 14:15:48
    --@nRowID: 从0开始
	--@mapCharSymbolPos: 
    @return:
]]
function ThemeParkLevelUI:IsPossibleCharSymbolRowPos(nRowID, mapCharSymbolRowPos)
    local bResult = Tool:IsElemInTable(nRowID, mapCharSymbolRowPos)
    
    return bResult
end

--[[
    @desc: 播放角色符号有效的时候展示的环绕粒子特效
    author:coldflag
    time:2021-08-31 14:41:46
    @return:
]]
function ThemeParkLevelUI:PlayCharacterRewardEffect(nReelID)
    local bool = false
    if self.mapCharSymbolRewardEffect[nReelID + 1] ~= nil then
        self.mapCharSymbolRewardEffect[nReelID + 1]:SetActive(true)
        table.insert(ThemeParkFreeSpinUI.mapGoCharRewardEffect, self.mapCharSymbolRewardEffect[nReelID + 1])
        bool = true
    end

    return bool
end


--[[
    @desc: 播放GoScatter这个对象所拥有的Bonus动画
    author:coldflag
    time:2021-09-07 18:10:06
    --@goScatter: Scatter对象
	--@bLoop: 是否循环播放
    @return:
]]
function ThemeParkLevelUI:PlaySignalScatterBonusEffect(goScatter, bLoop)
    local rv = false
    -- 从对象池中获取这个游戏对象作为索引的游戏特效
    local ScatterBonusEffect = SymbolObjectPool.m_mapSpinEffect[goScatter]
    if ScatterBonusEffect == nil then
        rv = false
    else
        ThemeParkFunc:SetSymbolRectGroup(goScatter, nil)
        ScatterBonusEffect:PlayActiveAnimation(SpineAnimationType.EnumSpinType_Normal, bLoop, 1.0)
        
        rv = true
    end

    return rv
end

--[[
    @desc: 播放 +3FreeSpin 动画2秒
    author:coldflag
    time:2021-09-01 14:49:56
    --@goScatter: 
    @return:
]]
function ThemeParkLevelUI:PlayScatterExtra3FreeSpin2Secs(goScatter)
    local trScatter = goScatter.transform
    local goFreeSpinAni = trScatter:FindDeepChild("FreeSpinAni").gameObject
    goFreeSpinAni:SetActive(true)
    local nFreeSpinTimes = ThemeParkConfig.FreeSpinTimes_3rdScatter

    if SlotsGameLua.m_bSplashFlags[SplashType.FreeSpinEnd] then -- 如果在还剩0次的时候，触发的FreeSpin +3，那么就阻断FreeSpinEnd处理
        SlotsGameLua.m_bSplashFlags[SplashType.FreeSpinEnd] = false
    end
    
    SceneSlotGame.m_bUIState = true -- 为了等ExtraFreeSpin弹窗结束

    ThemeParkFreeSpin:IncreaseFreeSpinTimes(nFreeSpinTimes)
    LeanTween.delayedCall(2.5, function()
        self.FreeSpinExtraSplashUI:Show()
    end)

    LeanTween.delayedCall(2, function()
        self:DelayCallInThirdScatter(goFreeSpinAni)
    end)
    
end

function ThemeParkLevelUI:DelayCallInThirdScatter(goFreeSpinAni)
    goFreeSpinAni:SetActive(false)
end

--[[
    @desc: 逐个播放 出现和选择的人物相同的Symbol的时候的 粒子特效
    author:coldflag
    time:2021-09-03 18:55:53
    @return:
]]
function ThemeParkLevelUI:CoPlayCharRewardFollowParticle()
    self.bMoving = false
    local fFollowParticleMoveTime = ThemeParkConfig.FreeSpinFollowParticleMoveTime
    local fCardParticleShowTime = ThemeParkConfig.FreeSpinCardParticleShowTime
    if #ThemeParkFreeSpinUI.mapGoCharRewardEffect == 0 then
        self.bIsCharacterRewardFollowParticleFinished = true
        return
    end


    for i = 1, #ThemeParkFreeSpinUI.mapGoCharRewardEffect do

        while self.bMoving do
            yield_return(Unity.WaitForSeconds(0))
        end
        
        self.goFollowParticle = self:GetEffectByEffectPool("gensuilizi")
        self.bMoving = true
        self.bIsCharacterRewardFollowParticleFinished = false
        self.goFollowParticle.transform.position = ThemeParkFreeSpinUI.mapGoCharRewardEffect[i].transform.position
        ThemeParkFreeSpinUI.mapGoCharRewardEffect[i]:SetActive(false)
        self.goFollowParticle:SetActive(true)
        local Vec3Dest = ThemeParkFreeSpinUI.mapGoCardLizi.prize.transform.position
        LeanTween.move(self.goFollowParticle, Vec3Dest, fFollowParticleMoveTime):setOnComplete(function()
            self:OnCompleteCharRewardFollowParticle(fCardParticleShowTime)
        end)
    end
    yield_return(Unity.WaitForSeconds(fFollowParticleMoveTime + fCardParticleShowTime + 0.4))
    self.bIsCharacterRewardFollowParticleFinished = true
    ThemeParkFreeSpinUI.mapGoCharRewardEffect = {}
        

end

--[[
    @desc: 人物奖励情况下， 跟随粒子到目的地后要做的事情
    author:coldflag
    time:2021-09-03 18:57:27
    --@fCardParticleShowTime: 跟随粒子飞行的时间
    @return:
]]
function ThemeParkLevelUI:OnCompleteCharRewardFollowParticle(fCardParticleShowTime)
    local nCharID = self.CharacterSelectUI:GetSelectedCharacterID()
    local fPrizePerSymbol = ThemeParkConfig:GetPrizePerSymbol(nCharID)
    ThemeParkFreeSpin:IncreaseCharPrize(nCharID, fPrizePerSymbol)-- 暂时就先当一列只有一个可能的人物符号算，后续玩法有变再改
    local fFlusedPrize = ThemeParkFreeSpin:ReturnCharPrize(nCharID)
    self.goFollowParticle:SetActive(false)

    self:RecycleEffectToPool(self.goFollowParticle)

    ThemeParkFreeSpinUI.mapGoCardLizi.prize:SetActive(true)
    ThemeParkFreeSpinUI:ChangeCardPrize(fFlusedPrize)
    
    self.bMoving = false
    LeanTween.delayedCall(fCardParticleShowTime, function() 
        ThemeParkFreeSpinUI.mapGoCardLizi.prize:SetActive(false)
    end)
end


--[[
    @desc: 逐个播放FreeSpin下 Scatter中奖的粒子特效，以及要做的事情
    author:coldflag
    time:2021-09-03 18:58:46
    @return:
]]
function ThemeParkLevelUI:CoPlayScatterFollowParticleEffect()

    if #ThemeParkFreeSpinUI.mapGoScatter == 0 then
        return
    end

    self.bMoving = false
    local fFollowParticleMoveTime = 0.6

    for i = 1, #ThemeParkFreeSpinUI.mapGoScatter do
        while self.bMoving do
            yield_return(Unity.WaitForSeconds(0))
        end
        
        if i == 1 then
            self.goFollowParticle = self:GetEffectByEffectPool("gensuiliziD")
            local DiceNo = ThemeParkFreeSpin:GetDice1OrDice2()
            local goEnd = ThemeParkFreeSpinUI.trDice[DiceNo]
            local goStart = ThemeParkFreeSpinUI.mapGoScatter[i]
            self.bMoving = true
            
            self.goFollowParticle.transform.position = goStart.transform.position
            self.goFollowParticle:SetActive(true)
            local Vec3Dest = goEnd.transform.position
            LeanTween.move(self.goFollowParticle, Vec3Dest, fFollowParticleMoveTime):setOnComplete(function()
                ThemeParkFreeSpinUI:PlayCharMoveScene()
            end)
            ThemeParkFreeSpin.bMapRewardFinish = false
            ThemeParkFreeSpinUI.bIsCharactrerMoveFinished = false
            while not ThemeParkFreeSpinUI.bIsCharactrerMoveFinished do
                yield_return(Unity.WaitForSeconds(0))
            end
            while not ThemeParkFreeSpin.bMapRewardFinish do  -- 如果小游戏的奖励还没有发放完毕，则阻塞流程
                yield_return(Unity.WaitForSeconds(0))  
            end
            self.bMoving = false
        end

        if i == 2 then
            self.goFollowParticle = self:GetEffectByEffectPool("gensuiliziD")
            local goEnd = ThemeParkFreeSpinUI.mapGoCardLizi.multi
            local goStart = ThemeParkFreeSpinUI.mapGoScatter[i]
            self.bMoving = true
            
            self.goFollowParticle.transform.position = goStart.transform.position
            self.goFollowParticle:SetActive(true)
            local Vec3Dest = goEnd.transform.position
            LeanTween.move(self.goFollowParticle, Vec3Dest, fFollowParticleMoveTime):setOnComplete(function()
                self:SecendScatterEffect()
            end)
        end

        if i == 3 then
            self.bMoving = true
            self:PlaySignalScatterBonusEffect(ThemeParkFreeSpinUI.mapGoScatter[i], false) 
            -- 播放+3FreeSpin动画
            self:PlayScatterExtra3FreeSpin2Secs(ThemeParkFreeSpinUI.mapGoScatter[i])
        end
    end

    yield_return(Unity.WaitForSeconds(1))
    ThemeParkFreeSpinUI.mapGoScatter = {}
end


--[[
    @desc: 第二个Scatter的效果是粒子飞到卡牌的Multi上面，然后Multi自增1
    author:coldflag
    time:2021-09-07 18:07:05
    @return:
]]
function ThemeParkLevelUI:SecendScatterEffect()

    ThemeParkFreeSpinUI.mapGoCardLizi.multi:SetActive(true)
    -- 增加人物的Mutiplier的值，并更新界面显示的值
    ThemeParkFreeSpinUI:IncreaseCardMulti()
    
    local fFreeSpinCardParticleShowTime = ThemeParkConfig.FreeSpinCardParticleShowTime
    local NextOpsAfterComplete = ThemeParkConfig.FreeSpinSecendScatterDeleyTimeAfterComplete
    LeanTween.delayedCall(fFreeSpinCardParticleShowTime, function()  
        ThemeParkFreeSpinUI.mapGoCardLizi.multi:SetActive(false)
    end)
    LeanTween.delayedCall(NextOpsAfterComplete, function()
        self.bMoving = false
    end)
end

function ThemeParkLevelUI:IsEveryThingReady()
    local rv = false
    if ThemeParkFreeSpinUI.bIsCharactrerMoveFinished 
        and self.bIsCharacterRewardFollowParticleFinished 
        and self.bIsScatterFollowParticleFinished 
    then
        rv = true
    end

    return rv
end


--[[
    @desc: 判断下一列是否需要显示着火、Scatter落地特效
    author:coldflag
    time:2021-08-18 16:12:06
    --@intReelID: 列的索引，从0开始
    @return:
]]
function ThemeParkLevelUI:OnPreReelStop(nReelID)
    local Reel = SlotsGameLua.m_listReelLua[nReelID]

    local mapCharSymbolRowPos = {}
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        mapCharSymbolRowPos = self:ReturnPossibleCharSymbolRowPos(nReelID)
    end
    
    -- 用户点击“stop”按钮，或者当前列的ID为最后一列
    -- SpinButton.m_bUserStopSpin为 FALSE 时候，表示用户没有点击“stop”按钮
    if not SpinButton.m_bUserStopSpin or nReelID == SlotsGameLua.m_nReelCount - 1 then
        AudioHandler:PlayReelStopSound(0) -- 播放列停止音效
    end

    -- 如果玩家点了“stop”按钮，则停止播放着火动画
    if SpinButton.m_bUserStopSpin then
        if SlotsGameLua.m_bPlayingSlotFireSound then
            SlotsGameLua.m_bPlayingSlotFireSound = false
            self:ActiveFireEffect(false)
        end
        self:RemoveYellowGB()
    end

    -- 播放着火特效并增加最后一列的旋转时间
    if nReelID == 3 and #ThemeParkFreeSpinUI.mapGoScatter == 2 then
        self:ActiveFireEffect(true)
    end

    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local nSymbolID = Reel.m_curSymbolIds[i]
        if ThemeParkSymbol:IsScatterSymbol(nSymbolID) then
            -- 播放Scatter落地特效
            self:ShowScatterLandedEffect(nReelID * SlotsGameLua.m_nRowCount + i)

            if not SpinButton.m_bUserStopSpin then
                AudioHandler:PlayScatterStopSound(nReelID)
            end
            
            self:SetYellowBG(nReelID)
        end

        if SlotsGameLua.m_GameResult:InFreeSpin() and self:IsPossibleCharSymbolRowPos(i, mapCharSymbolRowPos) and ThemeParkSymbol:IsSelectedCharacter(nSymbolID) then
            self:PlayCharacterRewardEffect(nReelID)
        end
    end

    if nReelID == 4 then
        local ltd = LeanTween.delayedCall(0.5, function()
            self:RemoveYellowGB()
        end)

        -- if self.bTriggerScatterBonus == true and SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount - SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0 then
        --     -- 播放Scatter中奖特效
        --     -- local time = ThemeParkConfig.DelayPlayScatterBonus 
        --     -- local co = coroutine.create(function()
        --     --     yield_return(Unity.WaitForSeconds(time))
        --     -- end)
        --     -- assert(coroutine.resume(co))
        --     -- self:ShowScatterBonusEffect()    
        -- end

        if not SlotsGameLua.m_GameResult:InFreeSpin() and #ThemeParkFreeSpinUI.mapGoScatter ~= 3 then
            ThemeParkFreeSpinUI.mapGoScatter = {}
        end
            
        self:ActiveFireEffect(false) -- 函数内部再检查是否正在播放着火特效和音效

    end
end

--[[
    @desc: 通过标尺对象设置RectMask的区域
    author:coldflag
    time:2021-08-12 15:29:25
    @return: void
]]
function ThemeParkLevelUI:SetRectMaskGroup()
    -- 计算矩形遮罩的位置
    local TopObj = self.transform:FindDeepChild("TOP")
    local BottomObj = self.transform:FindDeepChild("BOTTOM")
    local RightObj = self.transform:FindDeepChild("RIGHT")
    local LeftObj = self.transform:FindDeepChild("LEFT")

    local m_fCentBoardX = (LeftObj.transform.position.x + RightObj.transform.position.x) / 2.0
    local m_fCentBoardY = (TopObj.transform.position.y + BottomObj.transform.position.y) / 2.0
    local m_fWidth = math.abs(LeftObj.transform.position.x - RightObj.transform.position.x)
    local m_fHeight = math.abs(TopObj.transform.position.y - BottomObj.transform.position.y)

    -- 获取矩形遮罩区域
    local tr = self.transform:FindDeepChild("RectGroup/NormalGroup")
    self.m_cpDefaultMaskGroup = tr:GetComponent(typeof(CS.CustomerRectMaskGroup))

    Debug.Assert(self.m_cpDefaultMaskGroup)

    -- 设置矩形遮罩的参数
    self.m_cpDefaultMaskGroup.m_SpriteMask.size = Unity.Vector2(m_fWidth, m_fHeight)
    self.m_cpDefaultMaskGroup.m_SpriteMask.transform.position = Unity.Vector3(m_fCentBoardX, m_fCentBoardY, 0)
    self.m_cpDefaultMaskGroup.m_SpriteMask.gameObject:SetActive(true)
end


--[[
    @desc: 自定义FreeSpinBegin处理函数，公共流程在SceneSlotGame.lua：1590行
    author:coldflag
    time:2021-08-25 19:34:23
    @return:
]]
function ThemeParkLevelUI:handleFreeSpinBegin()
    -- PayLinePayWaysEffectHandler:MatchLineHide(true)
    -- 先将本次赢得钱加到钱包里

    -- 再显示FreeSpinStart
    local fDelayTime = 0.5
    local fPlayScatterAniTime = 2

    LeanTween.delayedCall(fDelayTime, function()
        self:ShowScatterBonusEffect()

        if SceneSlotGame.m_bFreeSpinRetrigger then
            AudioHandler:PlayRetriggerSound()
        else
            AudioHandler:PlayFreeGameTriggeredSound()
        end
    end)

    LeanTween.delayedCall(fPlayScatterAniTime + fDelayTime, function()
        if SceneSlotGame.m_bFreeSpinRetrigger then
            -- SceneSlotGame.m_bFreeSpinRetrigger = false
            -- self.FreeSpinAgainSplashUI:Show
        else
            self.FreeSpinBeginSplashUI:Show()
        end
    end)
end

--[[
    @desc: 自定义FreeSpinEnd处理函数，由公共流程调用
    author:coldflag
    time:2021-09-07 18:15:29
    @return:
]]
function ThemeParkLevelUI:handleFreeSpinEnd()
    AudioHandler:PlayFreeGamePopupEndSound()
    self.bIsTheLastFreeSpinFinished = false

    self.FreeSpinFinishSplashUI:Show()
end

--[[
    @desc: 由公共流程OnSplashShow(SplashType.CustomWindow)调用，用于处理在FreeSpin期间，公共流程无法处理的事情
    author:coldflag
    time:2021-09-07 18:03:41
    @return:
]]
function ThemeParkLevelUI:ShowCustomWindow()
    local co = coroutine.create(function()
        self.bIsCharacterRewardFollowParticleFinished = false
        self:CoPlayCharRewardFollowParticle()
        self.bIsCharacterRewardFollowParticleFinished = true
        
        self.bIsScatterFollowParticleFinished = false
        self:CoPlayScatterFollowParticleEffect()
        self.bIsScatterFollowParticleFinished = true
        
        local fDelayFinishTime = ThemeParkConfig.FreeSpinDelayFinishTime

        yield_return(Unity.WaitForSeconds(fDelayFinishTime))
        SceneSlotGame:OnSplashHide(SplashType.CustomWindow)
    end)
    assert(coroutine.resume(co))
end




---------------------------数据库---------------------
-- function ThemeParkLevelUI:setIsInFreeSpinToDB(bIsInFreeSpin)
--     local sLevelName = ThemeLoader.themeKey
--     if LevelDataHandler.m_Data.LevelParams[sLevelName] == nil then
--        LevelDataHandler.m_Data.LevelParams[sLevelName] = {} 
--     end
--     LevelDataHandler.m_Data.LevelParams[sLevelName].bIsInFreeSpin = bIsInFreeSpin
--     LevelDataHandler:persistentData()

--     Debug.Log("Save bIsInFreeSpin: " .. bIsInFreeSpin)

-- end


-- function ThemeParkLevelUI:getIsInFreeSpinFromDB()
--     local param = LevelDataHandler.m_Data
--     if param == nil then
--         return nil
--     end

--     if param.bIsInFreeSopin == nil then
--         return nil
--     end
--     Debug.Log("Archieve bIsInFreeSpin: " .. param.bIsInFreeSpin)
--     return param.bIsInFreeSpin
-- end