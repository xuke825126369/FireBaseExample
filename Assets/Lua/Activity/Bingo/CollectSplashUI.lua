local CollectSplashUI = {}

function CollectSplashUI:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local goPrefab = AssetBundleHandler:LoadActivityAsset("Collect.prefab")
    local goPanel = Unity.Object.Instantiate(goPrefab)
    self.transform = goPanel.transform
    self.transform:SetParent(GlobalScene.popCanvas, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        if self.bCanHide then
            self:Hide()
        end
    end)
    
    local playBtn = self.transform:FindDeepChild("btnPlay"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(playBtn)
    playBtn.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        ThemeLoader:ReturnToLobby()
        BingoMainUIPop:Show()
        self:Hide()
    end)
    
    local goCheckMark = self.transform:FindDeepChild("goCheckMark").gameObject
    local btnNotify = self.transform:FindDeepChild("btnNotify"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnNotify)
    btnNotify.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        if self.bCanHide then
            BingoUnloadedUI.bCollectNotify = not BingoUnloadedUI.bCollectNotify
            goCheckMark:SetActive(BingoUnloadedUI.bCollectNotify)
        end
    end)
    self.textAction = self.transform:FindDeepChild("textAction"):GetComponent(typeof(TextMeshProUGUI))

end

function CollectSplashUI:Show()
    self:Init()

    if BingoUnloadedUI.bCollectNotify then
        ViewScaleAni:Show(self.transform.gameObject)
        self.bCanHide = true
        self.textAction.text = string.format("BALLS LEFT:  %d", BingoHandler.data.nAction)
        SlotsGameLua.m_bReelPauseFlag = true
    end
end

function CollectSplashUI:Hide()
    SlotsGameLua.m_bReelPauseFlag = false
    self.bCanHide = false
    ViewScaleAni:Hide(self.transform.gameObject)
    ActivityHelper:SetTrigger(self.transform.gameObject, "Hide")
end

return CollectSplashUI