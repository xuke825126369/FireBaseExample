local MaxReachedSplashUI = {}

function MaxReachedSplashUI:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local prefab = AssetBundleHandler:LoadActivityAsset("MaxReached.prefab")
    local go = Unity.Object.Instantiate(prefab)
    self.transform = go.transform
    self.transform:SetParent(GlobalScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.anchoredPosition3D = Unity.Vector3.zero
    self.transform.gameObject:SetActive(false)

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:Hide()
    end)
    
    local btnPlay = self.transform:FindDeepChild("btnPlay"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnPlay)
    btnPlay.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        ThemeLoader:ReturnToLobby()
        BingoMainUIPop:Show()
        self:Hide()
    end)
    self.bShowed = false
end

function MaxReachedSplashUI:Show()
    self:Init()
    if self.bShowed then return end
    self.bShowed = true
        
    ViewScaleAni:Show(self.transform.gameObject)
    SlotsGameLua.m_bReelPauseFlag = true
end

function MaxReachedSplashUI:Hide()
    SlotsGameLua.m_bReelPauseFlag = false
    ViewScaleAni:Hide(self.transform.gameObject)
end

return MaxReachedSplashUI