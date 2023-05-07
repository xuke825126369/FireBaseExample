local FreeSpinAgainSplashUI = {}

FreeSpinAgainSplashUI.m_transform = nil -- GameObject
FreeSpinAgainSplashUI.m_nSplashType = nil

function FreeSpinAgainSplashUI:Init()
    local assetPath = "qFreeSpinsAgain.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.textFreeSpinCount = self.m_transform:FindDeepChild("TextMeshProFreeSpins"):GetComponent(typeof(TextMeshProUGUI))  
end 

function FreeSpinAgainSplashUI:Show()
    self.m_nSplashType = SplashType.FreeSpin
    self.m_transform.gameObject:SetActive(true)
    
    self.textFreeSpinCount.text = SlotsGameLua.m_GameResult.m_nNewFreeSpinCount
    LeanTween.delayedCall(6.0, function()
        self:Hide()    
    end)

    AudioHandler:PlayFreeGamePopupSound()
end

function FreeSpinAgainSplashUI:Hide()
    SceneSlotGame:ShowFreeSpinUI(true)
    self.m_transform.gameObject:SetActive(false)
    SceneSlotGame:OnSplashHide(self.m_nSplashType)
end

return FreeSpinAgainSplashUI