AfricaManiaLevelUI = {}

function AfricaManiaLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = {"CoinElement", "suipian", "reSpinzhaohuo", "FeatureSwitch1Effect", "FeatureSwitch2Effect", "lztukuai", "huochetou"}
    self.bUseReSpinCurveGroup = false
    self.tableReSpinFixedCollectGoSymbol = {}

    self.tableCachePos = {}
    self.tableGoCoinElement = {}
    self.tableGoFixedWild = {}
    self.tableSuiPian = {}

end 

function AfricaManiaLevelUI:initLevelUI()
    self:InitVariable()
    AfricaManiaFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/AfricaMania/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/AfricaMania/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()

end

function AfricaManiaLevelUI:Update()
    
end

function AfricaManiaLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(AfricaManiaFunc)
end

function AfricaManiaLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function AfricaManiaLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function AfricaManiaLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"nMoneyCount", "Ani", "textFeature1", "textFeature2", "textWildMoney", "textWildMultuile", "suipianAni",
        "Grand", "Major", "Minor", "Mini", "CoinElementAni", "nMoney1Count"
    }

    Debug.Assert(LuaHelper.tableContainsElement(tablePoolKey, strKey))

    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end 

    if self.goSymbolElementPool[goSymbol][strKey] == nil then
        local goTran = goSymbol.transform:FindDeepChild(strKey)

        if goTran then
            local go = goTran.gameObject

            if strKey == "nMoneyCount" or strKey == "nMoney1Count" or strKey == "textFeature1" or strKey == "textFeature2" or strKey == "textWildMoney" or strKey == "textWildMultuile" then 
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(Unity.TextMesh))
            elseif strKey == "SymbolKuangAni" or strKey == "Ani" or strKey == "suipianAni" or strKey == "CoinElementAni" then 
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(Unity.Animator))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end

        end
    end
    
    return self.goSymbolElementPool[goSymbol][strKey]
end

function AfricaManiaLevelUI:CheckRecoverInfo()
    self.tableCachePos = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            self.tableCachePos[nKey] = goSymbol.transform.position
        end
    end
end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function AfricaManiaLevelUI:ShowScatterBonusEffect()
    self.tableCollectScatter = {}

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local reel = SlotsGameLua.m_listReelLua[x]

            local nSymbolId = reel.m_curSymbolIds[y]
            if AfricaManiaSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[y]
                self.tableCollectScatter[nKey] = goSymbol
            end
        end
    end                  

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapSpinEffect[v]:PlayAnimation("animation", 0.0, true)
    end
end

function AfricaManiaLevelUI:handleFreeSpinBegin()
    PayLinePayWaysEffectHandler:MatchLineHide(true)
    
    local bDelayTime = 0.5
    local bPlayScatterAniTime = 1.35 * 3
    LeanTween.delayedCall(bDelayTime, function()
        self:ShowScatterBonusEffect()

        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
            AudioHandler:PlayFreeGameTriggeredSound()
        else
            AudioHandler:PlayRetriggerSound()
        end 
    end)          
    
    LeanTween.delayedCall(bDelayTime + bPlayScatterAniTime, function()
        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0 then
            self.mFreeSpinBeginSplashUI:Show()
        else

        end
    end)

end

function AfricaManiaLevelUI:handleFreeSpinEnd()
    self.mFreeSpinFinishSplashUI:Show()
end

------==================================== 数据库 ===========================================  
function AfricaManiaLevelUI:setDBReSpin()
    local strLevelName = ThemeLoader.themeKey
	if LevelDataHandler.m_Data.mThemeData == nil then
		LevelDataHandler.m_Data.mThemeData = {}
    end 

    LevelDataHandler.m_Data.mThemeData.bInReSpin = AfricaManiaFunc.bInReSpin
    local tableReSpin_LvKuangSymbol = {}
    for k, v in pairs(AfricaManiaFunc.tableReSpin_LvKuangSymbol) do
        local nKey = k
        local nSymbolId = v[1]
        local nJackPotType = v[2]
        local nMultuile = v[3]
        table.insert(tableReSpin_LvKuangSymbol, {nKey, nSymbolId, nJackPotType, nMultuile})
    end 

    LevelDataHandler.m_Data.mThemeData.tableReSpin_LvKuangSymbol = tableReSpin_LvKuangSymbol
    LevelDataHandler.m_Data.mThemeData.m_fReSpinTotalWins = SlotsGameLua.m_GameResult.m_fReSpinTotalWins
    LevelDataHandler:persistentData()

end

function AfricaManiaLevelUI:getDBReSpin()

	if LevelDataHandler.m_Data.mThemeData == nil then
		return
	end

	if LevelDataHandler.m_Data.mThemeData.bInReSpin == nil then
		return
	end         

    AfricaManiaFunc.bInReSpin = LevelDataHandler.m_Data.mThemeData.bInReSpin
    if AfricaManiaFunc.bInReSpin then
        AfricaManiaFunc.m_fReSpinTotalWins = LevelDataHandler.m_Data.mThemeData.m_fReSpinTotalWins
        AfricaManiaFunc.tableReSpin_LvKuangSymbol = {}
        for k, v in pairs(LevelDataHandler.m_Data.mThemeData.tableReSpin_LvKuangSymbol) do
             local nKey = v[1]
             local nSymbolId = v[2]
             local nJackPotType = v[3]
             local nMultuile = v[4]
             AfricaManiaFunc.tableReSpin_LvKuangSymbol[nKey] = {nSymbolId, nJackPotType, nMultuile}
        end
    end 

end
