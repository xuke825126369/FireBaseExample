local JackPotGrandSplashUI = {}

JackPotGrandSplashUI.m_transform = nil -- GameObject
JackPotGrandSplashUI.m_animator = nil --Animator

JackPotGrandSplashUI.m_textMeshProWinCoins = nil

JackPotGrandSplashUI.m_nSplashType = nil

JackPotGrandSplashUI.m_bAutoHideFlag = true
JackPotGrandSplashUI.m_fAge = 0.0
JackPotGrandSplashUI.m_fLife = 8.2

JackPotGrandSplashUI.m_fAddCoinTime = 4.0
JackPotGrandSplashUI.bCanCollectMoney = false
JackPotGrandSplashUI.fMoneyCount = 0.0

function JackPotGrandSplashUI:Init()
    local assetPath = "qjackpotEnd.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    local obj = Unity.Object.Instantiate(goPrefab)

    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)


    self.m_textMeshProWinCoins = self.m_transform:FindDeepChild("TextMeshProValue"):GetComponent(typeof(TextMeshProUGUI))

    self.mClickBtn = self.m_transform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
        
    DelegateCache:addOnClickButton(self.mClickBtn)
    self.mClickBtn.onClick:AddListener(function()
         self:onClickBtn()
    end)
end

function JackPotGrandSplashUI:Update()
    if self.m_bAutoHideFlag then
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        if self.m_fAge > self.m_fLife then
            self:Hide()
        end
    end
end

function JackPotGrandSplashUI:Show(fAddMoneyCount)
    self.m_transform.gameObject:SetActive(true)

    self.fMoneyCount = fAddMoneyCount
    self.mClickBtn.interactable = true
    self.m_textMeshProWinCoins.text = MoneyFormatHelper.numWithCommas(self.fMoneyCount)

    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end
    
    AudioHandler:PlayThemeSound("respin_end_popup")

end 

function JackPotGrandSplashUI:onClickBtn()
    if not self.mClickBtn.interactable then
        return
    end
    
    self.mClickBtn.interactable = false
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function JackPotGrandSplashUI:Hide()
    self.m_bAutoHideFlag = false
    self.m_transform.gameObject:SetActive(false)
    
    if SlotsGameLua.m_GameResult:HasFreeSpin() then
        AudioHandler:LoadFreeGameMusic()
    else
        AudioHandler:LoadBaseGameMusic()
    end
end     

return JackPotGrandSplashUI