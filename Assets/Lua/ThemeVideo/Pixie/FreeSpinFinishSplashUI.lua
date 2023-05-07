local FreeSpinFinishSplashUI = {}

FreeSpinFinishSplashUI.m_transform = nil -- GameObject
FreeSpinFinishSplashUI.m_nSplashType = nil

FreeSpinFinishSplashUI.m_animator = nil --Animator
FreeSpinFinishSplashUI.m_strDefaultStateName = nil

FreeSpinFinishSplashUI.m_textMeshProWinCoins = nil
FreeSpinFinishSplashUI.m_textMeshProFreeSpinNum = nil --进行了几次FreeSpin

FreeSpinFinishSplashUI.m_bAutoHideFlag = true
FreeSpinFinishSplashUI.m_fAge = 0.0
FreeSpinFinishSplashUI.m_fLife = 6.2

FreeSpinFinishSplashUI.m_fAddCoinTime = 4.0
FreeSpinFinishSplashUI.bCanCollectMoney = false
FreeSpinFinishSplashUI.fMoneyCount = 0.0

function FreeSpinFinishSplashUI:Init()
    local assetPath = "qFreeSpinsEnd.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    local obj = Unity.Object.Instantiate(goPrefab)
    
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.m_textMeshProFreeSpinNum = self.m_transform:FindDeepChild("TextMeshProFreeSpins"):GetComponent(typeof(TextMeshProUGUI))
    self.m_textMeshProWinCoins  = self.m_transform:FindDeepChild("TextMeshProCoins"):GetComponent(typeof(TextMeshProUGUI))
    self.mClickBtn = self.m_transform:FindDeepChild("ButtonCollect"):GetComponent(typeof(UnityUI.Button))

    DelegateCache:addOnClickButton(self.mClickBtn)
    self.mClickBtn.onClick:AddListener(function()
        self:onClickBtn()
    end)
    
end

function FreeSpinFinishSplashUI:Update()
    if self.m_SlotsNumberWinCoins ~= nil then
        self.m_SlotsNumberWinCoins:Update()
    end

    self.m_fAge = self.m_fAge + Unity.Time.deltaTime
    if self.m_bAutoHideFlag then
        if self.m_fAge > self.m_fLife then
            self:Hide()
        end
    end
end

function FreeSpinFinishSplashUI:Show()
    self.m_nSplashType = SplashType.FreeSpinEnd

    self.m_textMeshProFreeSpinNum.text = SlotsGameLua.m_GameResult.m_nFreeSpinTotalCount

    self.fMoneyCount = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins
    self.m_textMeshProWinCoins.text = MoneyFormatHelper.numWithCommas(self.fMoneyCount)
    self.m_transform.gameObject:SetActive(true)
    
    self.mClickBtn.interactable = true
    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end

    AudioHandler:PlayFreeGamePopupEndSound()
end

function FreeSpinFinishSplashUI:onClickBtn()
    if not self.mClickBtn.interactable then
        return
    end

    self.mClickBtn.interactable = false
    self:Hide()

    AudioHandler:PlayThemeSound("popupBtnClicked")
end

function FreeSpinFinishSplashUI:Hide()
    if SlotsGameLua:orTriggerBigWin(self.fMoneyCount, SceneSlotGame.m_nTotalBet) then
        SceneSlotGame:collectFreeSpinTotalWins(10)
    else
        SceneSlotGame:collectFreeSpinTotalWins(5)
    end
    
    SceneSlotGame:ShowFreeSpinUI(false)
    AudioHandler:LoadBaseGameMusic()
    SceneSlotGame:OnSplashHide(self.m_nSplashType)
    PixieLevelUI:PlayFreeSpinFinishHideAni()

    self.m_transform.gameObject:SetActive(false)
    self.m_bAutoHideFlag = false

    SceneSlotGame.m_bUIState = true
    LeanTween.delayedCall(0.1, function()
        SlotsGameLua:ShowCustomBigWin(self.fMoneyCount, function()   
            SceneSlotGame.m_bUIState = false
        end)
    end)

end

return FreeSpinFinishSplashUI
