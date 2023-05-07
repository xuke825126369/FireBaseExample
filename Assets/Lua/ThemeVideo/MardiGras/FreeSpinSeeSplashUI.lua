local FreeSpinSeeSplashUI = {}

FreeSpinSeeSplashUI.m_transform = nil -- GameObject
FreeSpinSeeSplashUI.m_nSplashType = nil

function FreeSpinSeeSplashUI:Init()
    local assetPath = "FreeSpinsPre.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    
	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.mClickBtn = self.m_transform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))

    DelegateCache:addOnClickButton(self.mClickBtn)
    self.mClickBtn.onClick:AddListener(function()
         self:onClickBtn()
    end)

end 

function FreeSpinSeeSplashUI:Update()
    if self.m_bAutoHideFlag then
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        if self.m_fAge > self.m_fLife then
            self:onClickBtn()
        end
    end
end

function FreeSpinSeeSplashUI:Show()
    self.m_transform.gameObject:SetActive(true)
    self.mClickBtn.interactable = true

    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end
end

function FreeSpinSeeSplashUI:onClickBtn()
    if not self.mClickBtn.interactable then
        return
    end

    self.mClickBtn.interactable = false
    AudioHandler:PlayThemeSound("popupBtnClicked")
    self:Hide()
    
    MardiGrasLevelUI.mWheelUI:PlayRotateAni()
end

function FreeSpinSeeSplashUI:Hide()
    self.m_transform.gameObject:SetActive(false)
    self.m_bAutoHideFlag = false
end

return FreeSpinSeeSplashUI