local BonusGameBeginSplashUI = {}

BonusGameBeginSplashUI.m_transform = nil -- GameObject
BonusGameBeginSplashUI.m_nSplashType = nil

function BonusGameBeginSplashUI:Init()
    local assetPath = "qBonusGameBegin.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    
	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.mClickBtn = self.m_transform:FindDeepChild("ButtonStart"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.mClickBtn)
    self.mClickBtn.onClick:AddListener(function()
         self:onClickBtn()
    end)

end 

function BonusGameBeginSplashUI:Update()
    if self.m_bAutoHideFlag then
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        if self.m_fAge > self.m_fLife then
            self:Hide()
        end
    end
end

function BonusGameBeginSplashUI:Show()
    self.m_transform.gameObject:SetActive(true)
    self.mClickBtn.interactable = true

    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end
    
    AudioHandler:PlayThemeSound("bonusPopStart")
end

function BonusGameBeginSplashUI:onClickBtn()
    if not self.mClickBtn.interactable then
        return
    end

    self.mClickBtn.interactable = false
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function BonusGameBeginSplashUI:Hide()
    self.m_transform.gameObject:SetActive(false)
    self.m_bAutoHideFlag = false
    
    ArabLevelUI:ResetTotalWinToUI(0)
    ArabLevelUI.mBonusGameUI:Show()
end

return BonusGameBeginSplashUI