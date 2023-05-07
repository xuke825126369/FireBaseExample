local FreeSpinBeginSplashUI = {}

FreeSpinBeginSplashUI.m_transform = nil -- GameObject
FreeSpinBeginSplashUI.m_nSplashType = nil

function FreeSpinBeginSplashUI:Init()
    local assetPath = "qFreeSpinWildSel.prefab"
	local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

	local obj = Unity.Object.Instantiate(goPrefab)
    obj.transform:SetParent(ThemeVideoScene.mPopScreenCanvas, false)
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    self.m_transform = obj.transform
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)
    self.m_transform.gameObject:SetActive(false)

    self.mHongPixieBtn = self.m_transform:FindDeepChild("HongPixieBtn"):GetComponent(typeof(UnityUI.Button))
    self.mHuangPixieBtn = self.m_transform:FindDeepChild("HuangPixieBtn"):GetComponent(typeof(UnityUI.Button))
    self.mLvPixieBtn = self.m_transform:FindDeepChild("LvPixieBtn"):GetComponent(typeof(UnityUI.Button))
    self.mLanPixieBtn = self.m_transform:FindDeepChild("LanPixieBtn"):GetComponent(typeof(UnityUI.Button))

    self.mHongPixieBtn.onClick:AddListener(function()
        self:onClickBtn(1)
    end)

    self.mHuangPixieBtn.onClick:AddListener(function()
        self:onClickBtn(2)
    end)

    self.mLvPixieBtn.onClick:AddListener(function()
        self:onClickBtn(3)
    end)    

    self.mLanPixieBtn.onClick:AddListener(function()
        self:onClickBtn(4)
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
        
    self.mHongPixieBtn.interactable = true
    self.mHuangPixieBtn.interactable = true
    self.mLvPixieBtn.interactable = true
    self.mLanPixieBtn.interactable = true
    
    self.m_fAge = 0.0
    self.m_fLife = 6.0
    self.m_bAutoHideFlag = false
    if SceneSlotGame:orAutoHideSplashUI() then
        self.m_bAutoHideFlag = true
    end

    AudioHandler:PlayFreeGamePopupSound()
end

function FreeSpinBeginSplashUI:onClickBtn(nIndex)
    self.mHongPixieBtn.interactable = false
    self.mHuangPixieBtn.interactable = false
    self.mLvPixieBtn.interactable = false
    self.mLanPixieBtn.interactable = false
    
    AudioHandler:PlayFreeGamePopupBtnSound()

    PixieFunc.nFreeSpinSelectBigSymbolId = 0
    if nIndex == 1 then
        PixieFunc.nFreeSpinSelectBigSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieRedC_1")
    elseif nIndex == 2 then
        PixieFunc.nFreeSpinSelectBigSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieYellowD_1")
    elseif nIndex == 3 then
        PixieFunc.nFreeSpinSelectBigSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieGreenB_1")
    elseif nIndex == 4 then
        PixieFunc.nFreeSpinSelectBigSymbolId = SlotsGameLua:GetSymbolIdByObjName("PixieBlueA_1")
    else
        Debug.Assert(false)
    end

    PixieLevelUI:setDBFreeSpin()

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
end

return FreeSpinBeginSplashUI