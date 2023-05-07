

RateUsPop = {}

function RateUsPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function RateUsPop:createAndShow(parentTransform)
    if(not self.gameObject) then
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/Prefabs/prefab/RateUsPop.prefab"))
        self.transform = self.gameObject.transform
        self.popController = PopController:new(self.gameObject)

        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        local btn = self.transform:FindDeepChild("ButtonRateus"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onRateBtnClicked()
        end)
    end
    DBHandler:addRateInfoForPopup()
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RateUsPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function RateUsPop:onRateBtnClicked()
    DBHandler:addRateInfoForRated()
    ViewScaleAni:Hide(self.transform.gameObject)
    if GameConfig.PLATFORM_ANDROID then
        Unity.Application.OpenURL("market://details?id="..Unity.Application.identifier)
    elseif GameConfig.PLATFORM_IOS then
        Unity.Application.OpenURL("https://itunes.apple.com/app/id1523002041?action=write-review")
    end

    local eventParams = CS.System.Collections.Generic["Dictionary`2[System.String,System.String]"]()
    CS.AppsFlyerSDK.AppsFlyer.sendEvent("RateTheGame", eventParams)
end

