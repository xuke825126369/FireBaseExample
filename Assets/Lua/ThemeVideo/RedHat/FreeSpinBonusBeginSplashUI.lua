local FreeSpinBonusBeginSplashUI = {}

FreeSpinBonusBeginSplashUI.m_transform = nil -- GameObject
FreeSpinBonusBeginSplashUI.m_nSplashType = nil

function FreeSpinBonusBeginSplashUI:Init()
    local assetPath = "FreeSpinsBonusBegin.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.m_textMeshProFreeSpinNum = self.m_transform:FindDeepChild("TextMeshProFreeSpins"):GetComponent(typeof(TextMeshProUGUI))
    self.textFixedWildKeysNum = self.m_transform:FindDeepChild("BonusFreeSpinNum"):GetComponent(typeof(TextMeshProUGUI))
    self.mClickBtn = self.m_transform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    self.mClickBtn.onClick:AddListener(function()
        self:onClickBtn()
    end)

    self.tableBonusFeatureGoFixedWildType = {}
    for i = 1, 9 do
        self.tableBonusFeatureGoFixedWildType[i] = self.m_transform:FindDeepChild("StickyLogoTypes/ImageType"..i).gameObject
    end 

end 

function FreeSpinBonusBeginSplashUI:Update()
    if self.m_bAutoHideFlag then
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        if self.m_fAge > self.m_fLife then
            self:Hide()
        end
    end

end

function FreeSpinBonusBeginSplashUI:Show()
    self.m_nSplashType = SplashType.FreeSpin
    self.m_transform.gameObject:SetActive(true)
    
    self.m_textMeshProFreeSpinNum.text = SlotsGameLua.m_GameResult.m_nNewFreeSpinCount
    self.textFixedWildKeysNum.text = LuaHelper.tableSize(RedHatFunc.tableFreeSpinStickySymbol)
    self.mClickBtn.interactable = true
    
    for k, v in pairs(self.tableBonusFeatureGoFixedWildType) do
        v:SetActive(k == RedHatFunc.nFreeSpinFixedType)
    end

    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end

    AudioHandler:PlayFreeGamePopupSound()
end

function FreeSpinBonusBeginSplashUI:onClickBtn(nIndex)
    self.mClickBtn.interactable = false
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function FreeSpinBonusBeginSplashUI:Hide()
    self.m_bAutoHideFlag = false
    self.mClickBtn.interactable = false
    
    SceneSlotGame:ShowFreeSpinUI(true)
    AudioHandler:LoadFreeGameMusic()
    if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0 then
        SceneSlotGame:resetResultData(true)
    end

    self.m_transform.gameObject:SetActive(false)
    SceneSlotGame:OnSplashHide(self.m_nSplashType)
    RedHatLevelUI:PlayFreeSpinBeginHideAni()
end

return FreeSpinBonusBeginSplashUI