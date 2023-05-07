

ChutesRocketsIntroducePop = {}

function ChutesRocketsIntroducePop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsIntroducePop.prefab"
        self.transform.gameObject = Unity.Object.Instantiate(Util.getChutesRocketsPrefab(strPath))
        self.transform = self.transform.gameObject.transform
        local trOK = self.transform:FindDeepChild("OKBtn")
        local btnOK = trOK:GetComponent(typeof(UnityUI.Button))
        btnOK.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        DelegateCache:addOnClickButton(btnOK)
        local btn = self.transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button))
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        DelegateCache:addOnClickButton(btn)
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChutesRocketsIntroducePop:onCloseBtnClicked()
    --TODO 关闭音效
    self.popController:hide(true)
end

function ChutesRocketsIntroducePop:OnDestroy()
    Debug.Log("ChutesRocketsIntroducePop Destroy")
end