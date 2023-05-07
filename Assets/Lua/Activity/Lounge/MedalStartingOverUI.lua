MedalStartingOverUI = {}

-- 换赛季的时候调用显示一次
function MedalStartingOverUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local strPath = "MedalStartingOverUI.prefab"
        local prefabObj = AssetBundleHandler:LoadGoldenLoungeAsset(strPath)
        local go = Unity.Object.Instantiate(prefabObj)
        self.transform = go.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)

        self.btnStart = self.transform:FindDeepChild("BtnStart"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.btnStart)
        self.btnStart.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:OnBtnStartClicked()
        end)
    end
    
    ViewAlphaAni:Show(self.transform.gameObject)
    self.transform:SetAsLastSibling()
    self.btnStart.interactable = true
end

function MedalStartingOverUI:Hide()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

function MedalStartingOverUI:OnBtnStartClicked()
    self.btnStart.interactable = false
    self:Hide()
end