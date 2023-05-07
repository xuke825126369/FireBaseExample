local UISplash = {}
UISplash.m_goUISplash = nil -- GameObject
UISplash.m_nSplashType = -1
UISplash.m_bAutoHideFlag = true
UISplash.m_fAge = 0.0
UISplash.m_fLife = 6.2

function UISplash:create(go, nSplashType)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.m_goUISplash = go
    o.m_nSplashType = nSplashType

    if nSplashType == SplashType.FiveInRow then

    end
        
    if nSplashType == SplashType.BigWin or nSplashType == SplashType.MegaWin or nSplashType == SplashType.EpicWin then
        o.hideCallBack = nil
        o.m_textMeshProWinCoins  = go.transform:FindDeepChild("TextMeshProTotalWin"):GetComponent(typeof(TextMeshProUGUI))
        o.m_SlotsNumberWinCoins = SlotsNumber:create("", 0, 100000000000, 0, 2)
        o.m_SlotsNumberWinCoins:AddUIText(o.m_textMeshProWinCoins)
        o.m_SlotsNumberWinCoins:SetTimeEndFlag(true)
        o.m_SlotsNumberWinCoins:ChangeTo(0)

        o.m_imageCollect = go.transform:FindDeepChild("imageCollect").gameObject
        o.m_imageSkip = go.transform:FindDeepChild("imageSkip").gameObject
		o.m_enumCollectBtnType = enumCollectBtnType.BtnType_Skip

        local freeSpinStartBtn = go.transform:FindDeepChild("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
        freeSpinStartBtn.onClick:AddListener(function()
            o:onBigWinCollect()
		end)
    end

    if nSplashType == SplashType.FreeSpin then
        -- body
        local trBtnStart = go.transform:FindDeepChild("ButtonStart")
        if trBtnStart ~= nil then
            local freeSpinStartBtn = trBtnStart:GetComponent(typeof(UnityUI.Button))
            freeSpinStartBtn.onClick:AddListener(function()
                o:onFreeSpinBegin()
            end)
        end

        local trFreeSpinNum = go.transform:FindDeepChild("TextMeshProFreeSpinNum")
        o.m_textMeshProFreeSpinNum = trFreeSpinNum:GetComponent(typeof(TextMeshProUGUI))
        if o.m_textMeshProFreeSpinNum == nil then
            o.m_textMeshProFreeSpinNum = trFreeSpinNum:GetComponent(typeof(UnityUI.Text))
        end
    end
    
    if nSplashType == SplashType.FreeSpinEnd then
        local tr = go.transform:FindDeepChild("TextMeshProFreeSpinTotalWin")
        o.m_textMeshProWinCoins = tr:GetComponent(typeof(TextMeshProUGUI))
        if o.m_textMeshProWinCoins == nil then
            o.m_textMeshProWinCoins = tr:GetComponent(typeof(UnityUI.Text))
        end

        o.m_SlotsNumberWinCoins = SlotsNumber:create("", 0, 100000000000, 0, 2)
        o.m_SlotsNumberWinCoins:AddUIText(o.m_textMeshProWinCoins)
        o.m_SlotsNumberWinCoins:SetTimeEndFlag(true)
        o.m_SlotsNumberWinCoins:ChangeTo(0)
        
        local tr = go.transform:FindDeepChild("TextMeshProFreeSpinNum")
        o.m_textMeshProFreeSpinNum = tr:GetComponent(typeof(TextMeshProUGUI))
        if o.m_textMeshProFreeSpinNum == nil then
            o.m_textMeshProFreeSpinNum = tr:GetComponent(typeof(UnityUI.Text))
        end

		o.m_enumCollectBtnType = enumCollectBtnType.BtnType_Skip
        local freeSpinStartBtn = go.transform:FindDeepChild("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
        freeSpinStartBtn.onClick:AddListener(function()
            o:onFreeSpinEnd()
		end)
    end

    if nSplashType == SplashType.Bonus then
        -- body
        local freeSpinStartBtn = go.transform:FindDeepChild("ButtonStart"):GetComponent(typeof(UnityUI.Button))
        freeSpinStartBtn.onClick:AddListener(function()
			o:onBonusGameBegin()
		end)
    end

    if nSplashType == SplashType.BonusGameEnd then
        local tr = go.transform:FindDeepChild("TextMeshProTotalWin")
        o.m_textMeshProWinCoins = tr:GetComponent(typeof(TextMeshProUGUI))
        if o.m_textMeshProWinCoins == nil then
            o.m_textMeshProWinCoins = tr:GetComponent(typeof(UnityUI.Text))
        end

        o.m_SlotsNumberWinCoins = SlotsNumber:create("", 0, 100000000000, 0, 2)
        o.m_SlotsNumberWinCoins:AddUIText(o.m_textMeshProWinCoins)
        o.m_SlotsNumberWinCoins:SetTimeEndFlag(true)
        o.m_SlotsNumberWinCoins:ChangeTo(0)

        --o.m_imageCollect = self.m_goUISplash.transform:FindDeepChild("ImageCollect").gameObject
        --o.m_imageSkip = self.m_goUISplash.transform:FindDeepChild("ImageSkip").gameObject
		o.m_enumCollectBtnType = enumCollectBtnType.BtnType_Skip

        local freeSpinStartBtn = go.transform:FindDeepChild("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
        freeSpinStartBtn.onClick:AddListener(function()
            o:onBonusGameEnd()
		end)
    end

	LuaAutoBindMonoBehaviour.Bind(o.m_goUISplash, o)
    return o
end

function UISplash:Update(dt)
    if self.m_SlotsNumberWinCoins ~= nil then
        self.m_SlotsNumberWinCoins:Update()
    end

    if self.m_bAutoHideFlag then
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        if self.m_fAge > self.m_fLife then
            self:Hide()
        end
    end
end

function UISplash:Hide()
    self.m_fBigWinMegaWins = 0
    self.m_bAutoHideFlag = false
    self.m_fAge = 0

    local st = self.m_nSplashType
    if st == SplashType.BigWin or st == SplashType.MegaWin or st == SplashType.EpicWin then
        if self.m_SlotsNumberWinCoins ~= nil then
            self.m_SlotsNumberWinCoins:End(0)
        end

        if self.hideCallBack then
            self.hideCallBack()
            self.hideCallBack = nil
        end
    elseif st == SplashType.BonusGameEnd then
        self:handleBonusGameEnd()
        AudioHandler:LoadBaseGameMusic()
    elseif st == SplashType.FreeSpin then
        AudioHandler:LoadFreeGameMusic()
        SceneSlotGame:ShowFreeSpinUI(true)

        local bCashRespinFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins
        local bPhoenixFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_Phoenix
        local bFortunesOfGoldFlag = SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_FortunesOfGold
        local bCond1 = bCashRespinFlag or bPhoenixFlag or bFortunesOfGoldFlag

        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0 and not bCond1 then
            SceneSlotGame:resetResultData(true)
        end
    elseif st == SplashType.FreeSpinEnd then
        AudioHandler:LoadBaseGameMusic()
        SceneSlotGame:collectFreeSpinTotalWins()
        SceneSlotGame:ShowFreeSpinUI(false)
    end
        
    self.m_goUISplash:SetActive(false)
    if st == SplashType.FiveInRow then
        
    else
        if not self.bCustomBigWin then
            SceneSlotGame:OnSplashHide(self.m_nSplashType)
        end
        SceneSlotGame.m_bUIState = false
    end

end

function UISplash:onFreeSpinBegin()
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function UISplash:onFreeSpinEnd()
	AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function UISplash:onBonusGameBegin()
    self:Hide()
    SceneSlotGame:resetResultData(false)
    AudioHandler:LoadAndPlayBonusGameMusic()
end

function UISplash:onBonusGameEnd()
    self:Hide()
end

function UISplash:onBigWinCollect()
    if self.m_enumCollectBtnType == enumCollectBtnType.BtnType_Collect then
        self:Hide()
    else
        AudioHandler:HandleSkipBigMegaWin()
        self.m_imageCollect:SetActive(true)
        self.m_imageSkip:SetActive(false)
        self.m_enumCollectBtnType = enumCollectBtnType.BtnType_Collect
        self.m_SlotsNumberWinCoins:End(self.m_fBigWinMegaWins)
    end
end

function UISplash:onMegaWinCollect()
    if self.m_enumCollectBtnType == enumCollectBtnType.BtnType_Collect then
        self:Hide()
    else
        AudioHandler:HandleSkipBigMegaWin()
        self.m_imageCollect:SetActive(true)
        self.m_imageSkip:SetActive(false)
        self.m_enumCollectBtnType = enumCollectBtnType.BtnType_Collect
        self.m_SlotsNumberWinCoins:End(self.m_fBigWinMegaWins)
    end
end

function UISplash:_Show(type)
    if self.m_nSplashType == SplashType.FiveInRow then
        self.m_bAutoHideFlag = true
        LeanTween.delayedCall(2.0, function()
            if self.bCustomBigWin then
                if self.hideCallBack then
                    self.hideCallBack()
                    self.hideCallBack = nil
                end
            else
                SceneSlotGame:OnSplashHide(type)
            end
            SceneSlotGame.m_bUIState = false
        end)

        LeanTween.delayedCall(4.0, function()
            self.m_goUISplash:SetActive(false)
        end)
    elseif self.m_nSplashType == SplashType.BigWin or self.m_nSplashType == SplashType.MegaWin or self.m_nSplashType == SplashType.EpicWin then
        local fWin = 0
        if self.bCustomBigWin then
            fWin = self.nCustomBigWinMoneyCount
        else
            fWin = SlotsGameLua.m_GameResult.m_fGameWin
            local bFreeSpin = SlotsGameLua.m_GameResult:InFreeSpin()
            local bReSpin = SlotsGameLua.m_GameResult:InReSpin()

            if bReSpin then
                if bFreeSpin then
                    fWin = SlotsGameLua.m_GameResult.m_fReSpinTotalWins
                else
                    fWin = SlotsGameLua.m_GameResult.m_fGameWin
                end
            elseif bFreeSpin then
                fWin = SlotsGameLua.m_GameResult.m_fSpinWin
            end

            if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
                if GiantTreasureFunc.m_nGameType == 1 then -- 1 或者 2 两种多棋盘状态
                    fWin = GiantSpinsUI.m_fCurTotalSpinWin
                elseif GiantTreasureFunc.m_nGameType == 2 then
                    fWin = GiantSpinsExtraUI.m_fCurTotalSpinWin
                end
            end

            if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SantaMania then
                local bFreeSpinFlag = SlotsGameLua.m_GameResult:InFreeSpin()
                if bFreeSpinFlag then
                    fWin = SantaFreeSpinGameMain.m_fCurTotalSpinWin
                end
            end

            if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_CashRespins then
                if CashRespinsFunc.m_fRespinTotalWin > 0 then
                    fWin = CashRespinsFunc.m_fRespinTotalWin
                end
            end
        end

        local  ftime = (self.m_fLife - 2.0) * 0.9
        local id = LeanTween.delayedCall(ftime, function()
            self.m_imageCollect:SetActive(true)
            self.m_imageSkip:SetActive(false)
            self.m_enumCollectBtnType = enumCollectBtnType.BtnType_Collect
        end).id
        table.insert(SceneSlotGame.m_listLeanTweenIDs, id)
        
        self.m_SlotsNumberWinCoins:ChangeTo(fWin,ftime)
        self.m_fBigWinMegaWins = fWin
    elseif self.m_nSplashType == SplashType.Bonus then
        
    elseif self.m_nSplashType == SplashType.BonusGameEnd then
        self:InitBonusGameEndParam()

    elseif self.m_nSplashType == SplashType.FreeSpin then
        if self.m_textMeshProFreeSpinNum ~= nil then
            self.m_textMeshProFreeSpinNum.text = SlotsGameLua.m_GameResult.m_nNewFreeSpinCount
        end
        if self.m_textMeshProWinCoins ~= nil then
            self.m_textMeshProWinCoins.text = MoneyFormatHelper.numWithCommas(SlotsGameLua.m_GameResult.m_fNonLineBonusWin)
        end
    elseif self.m_nSplashType == SplashType.FreeSpinEnd then
        self.m_textMeshProFreeSpinNum.text = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount
        self.m_textMeshProWinCoins.text = MoneyFormatHelper.numWithCommas(SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins)
    end

end

function UISplash:InitBonusGameEndParam()
    local fWin = SlotsGameLua.m_GameResult.m_fJackPotBonusWin
    local strWinCoins =  MoneyFormatHelper.numWithCommas(fWin)
    strWinCoins = "$"..strWinCoins
    self.m_textMeshProWinCoins.text = strWinCoins
    local enumBonusType = SlotsGameLua.m_GameResult.m_enumJackpotType
    local enumLevelType = SlotsGameLua.m_enumLevelType

    local strLevelName = ThemeLoader.themeKey
    if strLevelName == "Phoenix" then
        PhoenixLevelUI:initBonusGameEndUIParam()
    end
end

function UISplash:Show(type, hideCallBack, bCustomBigWin)
    self.m_bCanHide = true
    self.bCustomBigWin = bCustomBigWin
    if self.m_goUISplash.activeSelf then
        self.m_goUISplash:SetActive(false)
    end

    self.m_goUISplash.transform.localPosition = Unity.Vector3.zero
    self.m_goUISplash:SetActive(true)
    SceneSlotGame.m_bUIState = true

    self.m_nSplashType = type
    self.m_fAge = 0.0

    local bEnableAutoHide = true
    local bCond1 = false
    if SlotsGameLua.m_bAutoSpinFlag then
        bCond1 = true
    end

    local bAutoSpin = SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin
    local bFreeSpin = SlotsGameLua.m_GameResult:InFreeSpin() and SlotsGameLua.m_GameResult.m_nFreeSpinCount > 0

    if bAutoSpin or bFreeSpin or bCond1 and bEnableAutoHide then
        self.m_bAutoHideFlag = true
    else
        self.m_bAutoHideFlag = false
    end

    if self.m_nSplashType == SplashType.BigWin or self.m_nSplashType == SplashType.MegaWin or self.m_nSplashType == SplashType.EpicWin then
        self.m_imageCollect:SetActive(false)
        self.m_imageSkip:SetActive(true)
        self.m_enumCollectBtnType = enumCollectBtnType.BtnType_Skip

        self.hideCallBack = hideCallBack
    elseif self.m_nSplashType == SplashType.FiveInRow then
        self.m_fLife = 3.92
    elseif self.m_nSplashType == SplashType.FreeSpin then
        self.m_fLife = 3.5
    end
    
    if self.m_nSplashType == SplashType.BigWin then
        AppLocalEventHandler:AddThemeBigWinCount()
    elseif self.m_nSplashType == SplashType.MegaWin then
        AppLocalEventHandler:AddThemeMegaWinCount()
    elseif self.m_nSplashType == SplashType.EpicWin then
        AppLocalEventHandler:AddThemeEpicWinCount()
    end

    self:_Show(type)
end

function UISplash:ShowCustomBigWin(type, nMoneyCount, hideCallBack)
    self.nCustomBigWinMoneyCount = nMoneyCount
    self:Show(type, hideCallBack, true)
end

return UISplash