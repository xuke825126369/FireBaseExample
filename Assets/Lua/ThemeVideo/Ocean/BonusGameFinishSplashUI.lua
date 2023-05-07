local BonusGameFinishSplashUI = {}

BonusGameFinishSplashUI.m_transform = nil -- GameObject
BonusGameFinishSplashUI.m_nSplashType = nil

BonusGameFinishSplashUI.m_animator = nil --Animator
BonusGameFinishSplashUI.m_strDefaultStateName = nil

BonusGameFinishSplashUI.m_textMeshProWinCoins = nil
BonusGameFinishSplashUI.m_textMeshProFreeSpinNum = nil --进行了几次FreeSpin

BonusGameFinishSplashUI.m_bAutoHideFlag = true
BonusGameFinishSplashUI.m_fAge = 0.0
BonusGameFinishSplashUI.m_fLife = 6.2

BonusGameFinishSplashUI.m_fAddCoinTime = 4.0
BonusGameFinishSplashUI.bCanCollectMoney = false
BonusGameFinishSplashUI.fMoneyCount = 0.0

function BonusGameFinishSplashUI:Init()
    local assetPath = "qBonusGameEnd.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    local obj = Unity.Object.Instantiate(goPrefab)

    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.m_textMeshProWinCoins  = self.m_transform:FindDeepChild("TextMeshProCoins"):GetComponent(typeof(TextMeshProUGUI))
    self.mClickBtn = self.m_transform:FindDeepChild("ButtonCollect"):GetComponent(typeof(UnityUI.Button))

    DelegateCache:addOnClickButton(self.mClickBtn)
    self.mClickBtn.onClick:AddListener(function()
        self:onClickBtn()
    end)

end

function BonusGameFinishSplashUI:Update()
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

function BonusGameFinishSplashUI:Show(nJackPotIndex)
    self.m_nSplashType = SplashType.CustomWindow
    self.fMoneyCount = OceanFunc.tableNowJackPotMoneyCount[nJackPotIndex]
    self.m_textMeshProWinCoins.text = MoneyFormatHelper.numWithCommas(self.fMoneyCount)
    self.m_transform.gameObject:SetActive(true)

    self.mClickBtn.interactable = true
    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end 

    OceanLevelUI:UpdateTotalWinToUI(self.fMoneyCount, 2.0)
    AudioHandler:PlayThemeSound("bonusPopEnd")
end

function BonusGameFinishSplashUI:onClickBtn()
    if not self.mClickBtn.interactable then
        return
    end

    self.mClickBtn.interactable = false
    self:Hide()

    AudioHandler:PlayBtnSound()
end

function BonusGameFinishSplashUI:Hide()
    AudioHandler:LoadBaseGameMusic()
    SceneSlotGame:OnSplashHide(self.m_nSplashType)
    self.m_transform.gameObject:SetActive(false)
    self.m_bAutoHideFlag = false
    UITop:updateCoinCountInUi()
end

return BonusGameFinishSplashUI
