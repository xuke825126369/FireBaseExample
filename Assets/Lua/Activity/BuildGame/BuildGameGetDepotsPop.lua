BuildGameGetDepotsPop = {}

BuildGameGetDepotsPop.m_gameObject = nil
BuildGameGetDepotsPop.m_transform = nil

--常驻内存的，预制体应该在Hot内
function BuildGameGetDepotsPop:createAndShow(depotType, bInQueue, count)--DepotsType
    if not self.m_gameObject then
        local goPrefab = Util.getHotPrefab("Assets/BaseHotAdd/BuildYourCity/GetDepotsPop.prefab")
        self.m_gameObject = Unity.Object.Instantiate(goPrefab)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.m_trContent = self.m_transform:FindDeepChild("DepotsContianer")
        self.popController = PopController:new(self.m_gameObject,PopPriority.middlePriority)
        self.countText = self.m_transform:FindDeepChild("DepotCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_light = self.m_transform:FindDeepChild("Guang")
        self.m_transform:FindDeepChild("CloseBtn"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
            self:hide()
        end)
    end
    for i=0,self.m_trContent.childCount-1 do
        self.m_trContent:GetChild(i).gameObject:SetActive(i==depotType)
    end
    local str = "Common"
    if depotType == 0 then
        str = "Common"
    elseif depotType == 1 then
        str = "Rare"
    elseif depotType == 2 then
        str = "Epic"
    elseif depotType == 3 then
        str = "Legendary"
    end
    self.countText.text = "+ "..count.." "..str.." Depots"
    self.popController:show(nil, function()
        GlobalAudioHandler:PlaySound("get_vault")

        LeanTween.delayedCall(3,function()
            self:hide()
        end)
    end,bInQueue)
    
    local bLandscape = Unity.Screen.width > Unity.Screen.height
    if not bLandscape and BuyView:isActiveShow() then
        self.popController.containerRectTransform.localRotation = Unity.Quaternion.Euler(0,0,-90)
    else
        self.popController.containerRectTransform.localRotation = Unity.Quaternion.Euler(0,0,0)
    end
end

function BuildGameGetDepotsPop:hide()
    self.popController:hide(true)
end