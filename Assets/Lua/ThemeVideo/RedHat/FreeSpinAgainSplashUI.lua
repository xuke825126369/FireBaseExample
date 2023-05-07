local FreeSpinBeginSplashUI = {}

FreeSpinBeginSplashUI.m_transform = nil -- GameObject
FreeSpinBeginSplashUI.m_nSplashType = nil

function FreeSpinBeginSplashUI:Init()
    local assetPath = "qFreeSpinsBegin.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)
        
    self.m_textMeshProFreeSpinNum = self.m_transform:FindDeepChild("TextMeshProFreeSpins"):GetComponent(typeof(TextMeshProUGUI))
    self.mButton = self.m_transform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    self.mButton.onClick:AddListener(function()
        self:onClickBtn()
    end)

end 

function FreeSpinBeginSplashUI:Update()
    if self.m_bAutoHideFlag then
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        if self.m_fAge > self.m_fLife then
            self:Hide()
        end
    end

end

function FreeSpinBeginSplashUI:Show()
    self.m_nSplashType = SplashType.FreeSpin
    self.m_transform.gameObject:SetActive(true)

    self.m_textMeshProFreeSpinNum.text = SlotsGameLua.m_GameResult.m_nNewFreeSpinCount
    self.mButton.interactable = true

    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end

    AudioHandler:PlayFreeGamePopupSound()
end

function FreeSpinBeginSplashUI:onClickBtn(nIndex)
    self.mButton.interactable = false
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function FreeSpinBeginSplashUI:Hide()
    SceneSlotGame:ShowFreeSpinUI(true)
    AudioHandler:LoadFreeGameMusic()
    if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0 then
        SceneSlotGame:resetResultData(true)
    end
    
    self.m_transform.gameObject:SetActive(false)
    self.m_bAutoHideFlag = false
    SceneSlotGame:OnSplashHide(self.m_nSplashType)
    RedHatLevelUI:PlayFreeSpinBeginHideAni()
end

return FreeSpinBeginSplashUI