local FreeSpinAgainSplashUI = {}

FreeSpinAgainSplashUI.m_transform = nil -- GameObject
FreeSpinAgainSplashUI.m_nSplashType = nil

FreeSpinAgainSplashUI.m_animator = nil --Animator
FreeSpinAgainSplashUI.m_strDefaultStateName = nil
FreeSpinAgainSplashUI.m_textMeshProFreeSpinNum = nil

FreeSpinAgainSplashUI.m_bAutoHideFlag = true
FreeSpinAgainSplashUI.m_fAge = 0.0
FreeSpinAgainSplashUI.m_fLife = 6.2

function FreeSpinAgainSplashUI:Init()
    local assetPath = "".."qFreeSpinsBegin.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))
    if goPrefab == nil then
        return nil
    end

	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)


    self.textFreeSpinCount = self.m_transform:FindDeepChild("TextMeshProFreeSpins"):GetComponent(typeof(TextMeshProUGUI))

    self.mClickBtn = self.m_transform:FindDeepChild("Button"):GetComponent(typeof(UnityUI.Button))
    
    DelegateCache:addOnClickButton(self.mClickBtn)
    self.mClickBtn.onClick:AddListener(function()
         self:onClickBtn()
    end)
        
end 

function FreeSpinAgainSplashUI:Update()
    if self.m_bAutoHideFlag then
        self.m_fAge = self.m_fAge + Unity.Time.deltaTime
        if self.m_fAge > self.m_fLife then
            self:Hide()
        end
    end
end

function FreeSpinAgainSplashUI:Show()
    self.m_nSplashType = SplashType.FreeSpin
    
    self.m_transform.gameObject:SetActive(true)
    self.mClickBtn.interactable = true

    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end

    self.textFreeSpinCount.text = SlotsGameLua.m_GameResult.m_nNewFreeSpinCount
    
    AudioHandler:PlayFreeGamePopupSound()
    Debug.Log("=================== Show FreeSpinAgain UI =================")
end

function FreeSpinAgainSplashUI:onClickBtn()
    if not self.mClickBtn.interactable then
        return
    end
    
    self.mClickBtn.interactable = false
    AudioHandler:PlayFreeGamePopupBtnSound()
    self:Hide()
end

function FreeSpinAgainSplashUI:Hide()
    SceneSlotGame:ShowFreeSpinUI(true)
    self.m_transform.gameObject:SetActive(false)
    SceneSlotGame:OnSplashHide(self.m_nSplashType)
    self.m_bAutoHideFlag = false
end

return FreeSpinAgainSplashUI