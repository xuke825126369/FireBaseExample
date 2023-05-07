BuildGameShowResultePop = {}

BuildGameShowResultePop.m_gameObject = nil
BuildGameShowResultePop.m_transform = nil
BuildGameShowResultePop.addProgressInfo = nil

function BuildGameShowResultePop:createAndShow(addProgressInfo)
    if not self.m_gameObject then
        local goPrefab = Util.getBuildGamePrefab("Assets/BuildYourCity/BuildGameShowResultePop.prefab")
        self.m_gameObject = Unity.Object.Instantiate(goPrefab)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.m_gameObject)

        self.btnClose = self.m_transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        self.btnClose.onClick:AddListener(function()
            self:hide()
        end)
        self.buildContainer = self.m_transform:FindDeepChild("BuildContainer")
    end
    self.addProgressInfo = addProgressInfo
    self:initContainer(addProgressInfo)
    for k,v in pairs(BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].build) do
        v.fullProgress = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].fullProgress
    end
    self.btnClose.interactable = true
    ViewScaleAni:Show(self.transform.gameObject)
end

function BuildGameShowResultePop:initContainer(addProgressInfo)
    -- self.buildContainer
    if self.buildContainer.childCount > 0 then
        for i=0,self.buildContainer.childCount-1 do
            Unity.Object.Destroy(self.buildContainer:GetChild(i).gameObject)
        end    
    end
    
    for i=1,8 do
        if addProgressInfo[i] > 0 then
            local buildType = BuildGameMainUIPop:getStrTypeFromIndex(i)
            local obj = Unity.Object.Instantiate(BuildGameMainUIPop.m_mapBuildObjects[buildType].gameObject)
            obj:SetActive(true)
            obj.transform:SetParent(self.buildContainer)
            obj.transform.anchoredPosition3D = Unity.Vector3.zero
            obj.transform.localScale = Unity.Vector3.one*0.5
            obj.transform:FindDeepChild("GiftBoxContainer").gameObject:SetActive(false)
            local text = obj.transform:FindDeepChild("AddProgressText"):GetComponent(typeof(TextMeshProUGUI))
            text.text = "+ "..addProgressInfo[i]
            text.gameObject:SetActive(true)
            local buildType = nil
            local obj = nil
            local text = nil
        end
    end
end

function BuildGameShowResultePop:hide()
    self.btnClose.interactable = false
    AudioHandler:PlayBuildGameSound("click")
    ViewScaleAni:Hide(self.transform.gameObject)
end