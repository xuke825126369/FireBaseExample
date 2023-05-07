

QuitPop = {}

function QuitPop:isActiveShow()
    return LuaHelper.OrGameObjectExist(self.transform) and self.transform.gameObject.activeInHierarchy
end

function QuitPop:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local go = Unity.Object.Instantiate(AssetBundleHandler:LoadAsset("lobby", "View/QuitPop.prefab"))
        self.transform = go.transform
        self.transform:SetParent(GlobalScene.LoadingCanvas, false)
        self.transform.localScale = Unity.Vector3.one

        local btn = self.transform:FindDeepChild("ButtonYes"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onYesClicked()
        end)
        local btn = self.transform:FindDeepChild("ButtonNo"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onNoClicked()
        end)
        local btn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onNoClicked()
        end)
    end

    ViewScaleAni:Show(self.transform.gameObject)
end

function QuitPop:onYesClicked()
    GlobalAudioHandler:PlayBtnSound()
    Unity.Application.Quit()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function QuitPop:onNoClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end