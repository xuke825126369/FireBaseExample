require "Lua/ThemeVideo/FortunesOfGold/FortunesOfGoldFreeSpinSelUI"

FortunesOfGoldLevelUI = {}

FortunesOfGoldLevelUI.m_transform = nil -- "LevelBG"

FortunesOfGoldLevelUI.m_goFreeSpinUI = nil
FortunesOfGoldLevelUI.m_btnBalanceOfWealth = nil
FortunesOfGoldLevelUI.m_TextMeshProFreeSpinNum = nil -- text 目前不在界面上展示了
FortunesOfGoldLevelUI.m_goFreeSpinsInfo = nil
FortunesOfGoldLevelUI.m_goBalanceOfWealth = nil

FortunesOfGoldLevelUI.m_mapSpineEffects = {}


function FortunesOfGoldLevelUI:initLevelUI()
    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    self:initFreeSpinUI()
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    FortunesOfGoldFreeSpinSelUI:initFreeSpinSelUI()

    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/FortunesOfGold/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()
    self.mFreeSpinAgainSplashUI = require "Lua/ThemeVideo/FortunesOfGold/FreeSpinAgainSplashUI"
    self.mFreeSpinAgainSplashUI:Init()
    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/FortunesOfGold/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()

end

function FortunesOfGoldLevelUI:Start()
    
end

function FortunesOfGoldLevelUI:Update()
end

function FortunesOfGoldLevelUI:OnDisable()
    
end

function FortunesOfGoldLevelUI:OnDestroy()
    FortunesOfGoldFunc.m_listReel2Deck2 = {}
    FortunesOfGoldFunc.m_listSymbolPos = {}
    FortunesOfGoldFunc.m_listGoSymbol = {}
    FortunesOfGoldFunc.m_curSymbolIds = {}
    
    FortunesOfGoldFunc.m_listOutSideSymbols = {}
    
    FortunesOfGoldFunc.m_listWins2 = {}
    FortunesOfGoldFunc.m_listScatterKey = {}
end

function FortunesOfGoldLevelUI:initFreeSpinUI()
	local strFullName = "FreeSpinUI.prefab"
	local freeSpinObj = AssetBundleHandler:LoadThemeAsset(strFullName, typeof(Unity.GameObject))
	if freeSpinObj ~= nil then
		local goFreeSpin = Unity.Object.Instantiate(freeSpinObj)
        goFreeSpin.transform:SetParent(ThemeVideoScene.mPopWorldCanvas, false)
		goFreeSpin.name = "FreeSpinUI"
        goFreeSpin:SetActive(false)
        self.m_goFreeSpinUI = goFreeSpin

        self.m_btnBalanceOfWealth = goFreeSpin.transform:GetComponentInChildren(typeof(UnityUI.Button))
        self.m_btnBalanceOfWealth.onClick:AddListener(function()
            self:onBalanceOfWealthBtnClick()
        end)

        local trFreeSpinNum = goFreeSpin.transform:FindDeepChild("FreeSpinNum")
        self.m_TextMeshProFreeSpinNum = trFreeSpinNum:GetComponent(typeof(TextMeshProUGUI))
        self.m_TextMeshProFreeSpinNum.text = ""

        self.m_goFreeSpinsInfo = goFreeSpin.transform:FindDeepChild("FreeSpins").gameObject
        self.m_goBalanceOfWealth = goFreeSpin.transform:FindDeepChild("BalanceOfWealth").gameObject

        self.m_goFreeSpinsInfo:SetActive(false) -- 目前这个信息展示不在这里了
    end
end

function FortunesOfGoldLevelUI:onBalanceOfWealthBtnClick()
	AudioHandler:PlayBtnSound()
    FortunesOfGoldFreeSpinSelUI:showFreeSpinSelUI(true)
end

function FortunesOfGoldLevelUI:updateFreeSpinCountInfo(nFreeSpinNum) -- 还剩下几次
    local bVisible = self.m_goBalanceOfWealth.activeSelf
    if nFreeSpinNum < 16 and bVisible then
        self.m_goBalanceOfWealth:SetActive(false)
    end

end

function FortunesOfGoldLevelUI:ShowFreeSpinUI(bShow)
    local nRestFreeSpins = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount
    nRestFreeSpins = nRestFreeSpins - SlotsGameLua.m_GameResult.m_nFreeSpinCount
    if nRestFreeSpins < 16 then
        self.m_goBalanceOfWealth:SetActive(false)
    end
    
    if bShow then
        self.m_goFreeSpinUI:SetActive(true)
        if nRestFreeSpins >= 16 then
            self.m_goBalanceOfWealth:SetActive(true)
        end
    else
        self.m_goFreeSpinUI:SetActive(false)
    end
end

function FortunesOfGoldLevelUI:HideElemEffectNoTriggerFreeSpin()
	-- 3x3关卡展示了线条的 在这里隐藏掉。。
	for k,v in pairs(PayLinePayWaysEffectHandler.m_mapHitLineEffect) do
		if v ~= nil then
			v:reuseCacheEffect()
		end
	end
	PayLinePayWaysEffectHandler.m_mapHitLineEffect = {}

    -- 1. spine effect
    for k,v in pairs(PayLinePayWaysEffectHandler.m_mapSpineEffects) do
        local bFlag = LuaHelper.tableContainsElement(FortunesOfGoldFunc.m_listScatterKey, k)
        if not bFlag then
            local spine = PayLinePayWaysEffectHandler.m_mapSpineEffects[k]
            spine:setNeedStop()  --setNeedStop --StopActiveAnimation 

            PayLinePayWaysEffectHandler.m_mapSpineEffects[k] = nil
        end
    end

    -- 3. 缩放动画
    for k,v in pairs(PayLinePayWaysEffectHandler.m_mapLeanTweenID) do
        LeanTween.cancel(v)
    end
    self.m_mapLeanTweenID = {}
end

function FortunesOfGoldLevelUI:ShowScatterBonusEffect()
    self:HideElemEffectNoTriggerFreeSpin()
    if true then
        return
    end

    local cnt = #FortunesOfGoldFunc.m_listScatterKey
    for i = 1, cnt do
        local nkey = FortunesOfGoldFunc.m_listScatterKey[i]
        
        local bHasSpineEffectFlag = self.m_mapSpineEffects[nkey] ~= nil
        if not bHasSpineEffectFlag then
            local go = nil
            if nkey > 100 then
                local nIndex = nkey - 106
                go = FortunesOfGoldFunc.m_listGoSymbol[nIndex]
            else
                local nRow = SlotsGameLua.m_nRowCount
                local nReelId = math.floor( nkey/nRow )
                local nRowIndex = math.floor( nkey%nRow )

                local reel = SlotsGameLua.m_listReelLua[nReelId]
                go = reel.m_listGoSymbol[nRowIndex]
            end

            local spine = SymbolObjectPool.m_mapSpinEffect[go]
            if spine ~= nil then
                local enumType = SpineAnimationType.EnumSpinType_Normal
                spine:PlayActiveAnimation(enumType, true, 1.0)
                self.m_mapSpineEffects[nkey] = spine
            end
        end
    end
    
end

function FortunesOfGoldLevelUI:HideScatterBonusEffect()
    PayLinePayWaysEffectHandler:MatchLineHide(true)
    if true then
        return
    end

    for k,v in pairs(self.m_mapSpineEffects) do
        local spine = self.m_mapSpineEffects[k]
        spine:StopActiveAnimation()
    end
    self.m_mapSpineEffects = {}

end

function FortunesOfGoldLevelUI:handleFreeSpinBegin()
    PayLinePayWaysEffectHandler:MatchLineHide()

    local bDelayTime = 0.5
    local bPlayScatterAniTime = 1.35 * 2
    LeanTween.delayedCall(bDelayTime, function()
        self:ShowScatterBonusEffect()

        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
            AudioHandler:PlayFreeGameTriggeredSound()
        else
            AudioHandler:PlayRetriggerSound()
        end

        LeanTween.delayedCall(bPlayScatterAniTime, function()
            if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
                self.mFreeSpinBeginSplashUI:Show()
            else
                self.mFreeSpinAgainSplashUI:Show() 
            end
        end)
    end)

end

function FortunesOfGoldLevelUI:handleFreeSpinEnd()
    self.mFreeSpinFinishSplashUI:Show()
end

