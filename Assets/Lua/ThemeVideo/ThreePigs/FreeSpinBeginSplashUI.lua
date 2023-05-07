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

    self.mClick1Btn = self.m_transform:FindDeepChild("choose1/Button"):GetComponent(typeof(UnityUI.Button))
    self.mClick2Btn = self.m_transform:FindDeepChild("choose2/Button"):GetComponent(typeof(UnityUI.Button))
    self.mClick3Btn = self.m_transform:FindDeepChild("choose3/Button"):GetComponent(typeof(UnityUI.Button))

    self.mClick1Btn.onClick:AddListener(function()
         self:onClickBtn(1)
    end)

    self.mClick2Btn.onClick:AddListener(function()
        self:onClickBtn(2)
    end)

    self.mClick3Btn.onClick:AddListener(function()
        self:onClickBtn(3)
    end)

end 

function FreeSpinBeginSplashUI:Update()

end

function FreeSpinBeginSplashUI:Show()
    self.m_nSplashType = SplashType.FreeSpin
    self.m_transform.gameObject:SetActive(true)

    self.mClick1Btn.interactable = true
    self.mClick2Btn.interactable = true
    self.mClick3Btn.interactable = true

    AudioHandler:PlayFreeGamePopupSound()

    if GameConfig.PLATFORM_EDITOR then
        LeanTween.delayedCall(6.0, function()
            if self.mClick1Btn.interactable then
                local nFreeSpinType = math.random(1, 3)
                self:onClickBtn(nFreeSpinType)
            end
        end)
    end
    
end

function FreeSpinBeginSplashUI:onClickBtn(nFreeSpinType)
    self.mClick1Btn.interactable = false
    self.mClick2Btn.interactable = false
    self.mClick3Btn.interactable = false
    ThreePigsFunc:SetFreeSpin(nFreeSpinType)

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
    ThreePigsLevelUI:PlayFreeSpinBeginHideAni()
end

return FreeSpinBeginSplashUI