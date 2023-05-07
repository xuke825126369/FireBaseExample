local ReSpinFinishSplashUI = {}

local UISplash = {}

function ReSpinFinishSplashUI:Init()
    
end

function ReSpinFinishSplashUI:removeCshapComponent()
	-- local goBigWin = self.m_uiSplashBigWin.m_goUISplash
	-- Unity.Object.Destroy(goBigWin:GetComponent(typeof(CS.SlotsMania.UISplash)))

	-- local goMegaWin = self.m_uiSplashMegaWin.m_goUISplash
	-- Unity.Object.Destroy(goMegaWin:GetComponent(typeof(CS.SlotsMania.UISplash)))

	-- local goEpicWin = self.m_uiSplashEpicWin.m_goUISplash
	-- Unity.Object.Destroy(goEpicWin:GetComponent(typeof(CS.SlotsMania.UISplash)))
end

--------------
UISplash.m_goUISplash = nil -- GameObject

UISplash.nUIType = -1
UISplash.m_bAutoHideFlag = true
UISplash.m_fAge = 0.0
UISplash.m_fLife = 6.2

function UISplash:create(go, nType)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.m_goUISplash = go
    o.nUIType = nType

    if nType == 2 or nType == 3 or nType == 4 then
        o.m_textMeshProWinCoins  = go.transform:FindDeepChild("TextMeshProTotalWin"):GetComponent(typeof(TextMeshProUGUI))
        if not o.m_textMeshProWinCoins then
            o.m_textMeshProWinCoins = go.transform:FindDeepChild("TextMeshProTotalWin"):GetComponent(typeof(UnityUI.Text))
        end
        o.m_SlotsNumberWinCoins = SlotsNumber:create("", 0, 100000000000, 0, 2)
        o.m_SlotsNumberWinCoins:AddUIText(o.m_textMeshProWinCoins)
        o.m_SlotsNumberWinCoins:SetTimeEndFlag(true)
        o.m_SlotsNumberWinCoins:ChangeTo(0)

        o.m_imageCollect = go.transform:FindDeepChild("imageCollect").gameObject
        o.m_imageSkip = go.transform:FindDeepChild("imageSkip").gameObject
		o.m_enumCollectBtnType = enumCollectBtnType.BtnType_Skip

        local freeSpinStartBtn = go.transform:FindDeepChild("ButtonCollect"):GetComponent(typeof(UnityUI.Button))
        
        DelegateCache:addOnClickButton(freeSpinStartBtn)
        freeSpinStartBtn.onClick:AddListener(function()
            o:onBigWinCollect()
		end)
    end

	LuaAutoBindMonoBehaviour.Bind(o.m_goUISplash, o)
	BaseUpdateBehaviour.Bind(o.m_goUISplash, o)

    return o
end

function UISplash:Update()
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
    self.m_bAutoHideFlag = false
    self.m_goUISplash:SetActive(false) -- 隐藏界面

    local fCoinTime = WitchLevelUI:UpdateCollectMoneyToUI(WitchFunc.fReSpinCollectMoneyCount)
    UITop:updateCoinCountInUi(fCoinTime)
    WitchLevelUI:PlayReSpinFinishHideAni()
    
    LeanTween.delayedCall(fCoinTime, function()
        SceneSlotGame:OnSplashHide(self.m_nSplashType)
    end)
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

function UISplash:Show(fMoneyCount)
    self.fMoneyCount = fMoneyCount
    self.m_nSplashType = SplashType.ReSpinEnd
    self.m_goUISplash.transform.localPosition = Unity.Vector3.zero
    self.m_goUISplash:SetActive(true)

    self.m_fAge = 0.0
    
    local bCond1 = false
    if SlotsGameLua.m_bAutoSpinFlag then
        bCond1 = true
    end

    local bAutoSpin = SpinButton.m_enumSpinStatus == enumSpinButtonStatus.SpinButtonStatus_AutoSpin
    local bFreeSpin = SlotsGameLua.m_GameResult:InFreeSpin() and SlotsGameLua.m_GameResult.m_nFreeSpinCount > 0

    if bAutoSpin or bFreeSpin or bCond1 then
        self.m_bAutoHideFlag = true
    else
        self.m_bAutoHideFlag = false
    end

    if self.nUIType == 2 then
        self.m_fLife = AudioHandler:PlayBigWinMusic() + 2.0
    elseif self.nUIType == 3 then
        self.m_fLife = AudioHandler:PlayMegaWinMusic() + 2.0
    elseif self.nUIType == 4  then
        self.m_fLife = AudioHandler:PlayMegaWinMusic() + 2.0
    end

    if self.nUIType == 2 or self.nUIType == 3 or self.nUIType == 4 then
        self.m_imageCollect:SetActive(false)
        self.m_imageSkip:SetActive(true)
        self.m_enumCollectBtnType = enumCollectBtnType.BtnType_Skip

        local fWins = fMoneyCount

        local ftime = (self.m_fLife - 2.0) * 0.9
        local id = LeanTween.delayedCall(ftime, function()
            self.m_imageCollect:SetActive(true)
            self.m_imageSkip:SetActive(false)
            self.m_enumCollectBtnType = enumCollectBtnType.BtnType_Collect
        end).id
        table.insert(SceneSlotGame.m_listLeanTweenIDs, id)

        self.m_SlotsNumberWinCoins:End(0)
        self.m_SlotsNumberWinCoins:ChangeTo(fWins, ftime)
        self.m_fBigWinMegaWins = fWins
    end

end

return ReSpinFinishSplashUI