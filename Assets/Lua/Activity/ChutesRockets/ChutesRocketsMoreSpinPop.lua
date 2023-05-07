

ChutesRocketsMoreSpinPop = {}

function ChutesRocketsMoreSpinPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsMoreSpinPop.prefab"
        self.transform.gameObject = Unity.Object.Instantiate(Util.getChutesRocketsPrefab(strPath))
        self.transform = self.transform.gameObject.transform
        local trKeep = self.transform:FindDeepChild("KeepBtn")
        local btnKeep = trKeep:GetComponent(typeof(UnityUI.Button))
        btnKeep.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(btnKeep)
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

function ChutesRocketsMoreSpinPop:onCloseBtnClicked()
    --TODO 关闭音效
    self.popController:hide(true)
    ChutesRocketsMainUIPop.popController:hide()
    self.m_bPortraitFlag = false
    if ThemeLoader.themeKey ~= nil then
        self.m_bPortraitFlag = GameLevelUtil:isPortraitLevel()
    end
    if self.m_bPortraitFlag then
        Debug.Log("切屏")
        Scene:SwitchScreenOp(false)
    end
end

function ChutesRocketsMoreSpinPop:onKeepBtnClick()
    ViewScaleAni:Hide(self.transform.gameObject)
    ChutesRocketsMainUIPop.popController:hide()
    self.m_bPortraitFlag = false
    if ThemeLoader.themeKey ~= nil then
        self.m_bPortraitFlag = GameLevelUtil:isPortraitLevel()
    end
    if self.m_bPortraitFlag then
        Debug.Log("切屏")
        Scene:SwitchScreenOp(false)
    end
end

function ChutesRocketsMoreSpinPop:OnDestroy()
    
end