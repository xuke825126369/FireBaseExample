local JackPotSplashUI = {}

JackPotSplashUI.m_transform = nil -- GameObject
JackPotSplashUI.m_nSplashType = nil

JackPotSplashUI.m_animator = nil --Animator
JackPotSplashUI.m_strDefaultStateName = nil

JackPotSplashUI.m_textMeshProWinCoins = nil
JackPotSplashUI.m_textMeshProFreeSpinNum = nil --进行了几次FreeSpin

JackPotSplashUI.m_bAutoHideFlag = true
JackPotSplashUI.m_fAge = 0.0
JackPotSplashUI.m_fLife = 6.2

JackPotSplashUI.m_fAddCoinTime = 4.0
JackPotSplashUI.bCanCollectMoney = false
JackPotSplashUI.fMoneyCount = 0.0

function JackPotSplashUI:Init()
    local assetPath = "jackpotEnd.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    local obj = Unity.Object.Instantiate(goPrefab)

    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.m_textMeshProWinCoins  = self.m_transform:FindDeepChild("TextMeshProCoins"):GetComponent(typeof(TextMeshProUGUI))
    self.mClickBtn = self.m_transform:FindDeepChild("ButtonCollect"):GetComponent(typeof(UnityUI.Button))

    DelegateCache:addOnClickButton(self.mClickBtn)
    self.mClickBtn.onClick:AddListener(function()
        self:onClickBtn()
    end)

    self.tableGoNumberJackPotIndex = {}
    for i = 4, 9 do
        self.tableGoNumberJackPotIndex[i] = self.m_transform:FindDeepChild("paitou/shuzi/"..i).gameObject
    end

    self.m_SlotsNumberWinCoins = SlotsNumber:create("", 0, 100000000000, 0, 2)
    self.m_SlotsNumberWinCoins:AddUIText(self.m_textMeshProWinCoins)
    self.m_SlotsNumberWinCoins:SetTimeEndFlag(true)
    self.m_SlotsNumberWinCoins:ChangeTo(0)

end

function JackPotSplashUI:Update()
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

function JackPotSplashUI:Show(nJackPotSymbolCount)
    self.m_nSplashType = SplashType.Jackpot

    local nJackPotIndex = nJackPotSymbolCount - 3
    self.fMoneyCount = IrishFunc.tableNowJackPotMoneyCount[nJackPotIndex]
    self.m_transform.gameObject:SetActive(true)

    for i = 4, 9 do
        self.tableGoNumberJackPotIndex[i]:SetActive(i == nJackPotSymbolCount)
    end
    
    self.m_SlotsNumberWinCoins:End(0)
    self.m_SlotsNumberWinCoins:ChangeTo(self.fMoneyCount, 2.0)
    AudioHandler:PlayThemeSound("jackpot_pop_up_loop")

    self.mClickBtn.interactable = true
    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end

    AudioHandler:PlayThemeSound("jackpotPopup")
end

function JackPotSplashUI:onClickBtn()
    if not self.mClickBtn.interactable then
        return
    end

    self.mClickBtn.interactable = false
    self:Hide()

    AudioHandler:PlayThemeSound("popupBtnClicked")
end

function JackPotSplashUI:Hide()
    SceneSlotGame:OnSplashHide(self.m_nSplashType)
    self.m_transform.gameObject:SetActive(false)
    self.m_bAutoHideFlag = false
end

return JackPotSplashUI
