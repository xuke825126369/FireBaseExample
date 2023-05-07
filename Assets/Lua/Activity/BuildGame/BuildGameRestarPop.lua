BuildGameRestarPop = {}

BuildGameRestarPop.m_gameObject = nil
BuildGameRestarPop.m_transform = nil

function BuildGameRestarPop:createAndShow()
    if not self.m_gameObject then
        local goPrefab = Util.getBuildGamePrefab("Assets/BuildYourCity/BuildGameRestarPop.prefab")
        self.m_gameObject = Unity.Object.Instantiate(goPrefab)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.m_gameObject)

        self.btnClose = self.m_transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        self.btnClose.onClick:AddListener(function()
            self:hide()
        end)

        self.btnSkip = self.m_transform:FindDeepChild("BtnAmazing"):GetComponent(typeof(UnityUI.Button))
        self.btnSkip.onClick:AddListener(function()
            self:hide()
        end)
    end
    self.btnSkip.interactable = true
    self.btnClose.interactable = true
    ViewScaleAni:Show(self.transform.gameObject)
    AudioHandler:PlayBuildGameSound("upgrade")
end

function BuildGameRestarPop:hide()
    BuildGameDataHandler:resetDataAndAddCompleteCount()
    BuildGameMainUIPop:refreshUI()
    self.btnSkip.interactable = false
    self.btnClose.interactable = false
    AudioHandler:PlayBuildGameSound("click")
    self.popController:hide(true)
end