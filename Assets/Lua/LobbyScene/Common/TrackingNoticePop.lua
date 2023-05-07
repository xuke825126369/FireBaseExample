

TrackingNoticePop = {}

function TrackingNoticePop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function TrackingNoticePop:createAndShow(bLandscape)
    bLandscape = bLandscape or Unity.Screen.width > Unity.Screen.height
    if(bLandscape ~= self.bLandscape) then
        if self.gameObject then
            Unity.GameObject.Destroy(self.gameObject)
        end
        if bLandscape then
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/TrackingNotice.prefab"))
        else
            self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/TrackingNotice_Portrait.prefab"))
        end
        self.bLandscape = bLandscape
        
        self.transform = self.gameObject.transform
        self.popController = PopController:new(self.gameObject)

        local btn = self.transform:FindDeepChild("ButLater"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)   
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        btn.interactable = true
        local btn = self.transform:FindDeepChild("BtnOfCoures"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)   
        btn.onClick:AddListener(function()
            self:onRateBtnClicked()
        end)
        btn.interactable = true
    end
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController:show(nil, nil, true)
    DBHandler:setTrackingPopTime()
end

function TrackingNoticePop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function TrackingNoticePop:onRateBtnClicked()
    Util.requestTracking()
    ViewScaleAni:Hide(self.transform.gameObject)
end

