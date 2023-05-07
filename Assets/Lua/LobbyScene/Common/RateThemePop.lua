

RateThemePop = {}

function RateThemePop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function RateThemePop:createAndShow(themeKey, parentTransform)
    Debug.Log("RateThemePop RateThemePop")
    if true then
        return
    end
    if(not self.gameObject) then
        self.gameObject = Unity.Object.Instantiate(Util.getBasePrefab("PopPanel/RateSlotGamePop.prefab"))
        self.transform = self.gameObject.transform
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)

        self.buttonSubmit = self.transform:FindDeepChild("ButtonSubmit"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.buttonSubmit)
        self.buttonSubmit.onClick:AddListener(function()
            self:onSubmitBtnClicked()
        end)
        self.submitBonusText = self.transform:FindDeepChild("SubmitBonusText"):GetComponent(typeof(TextMeshProUGUI))
        self.themeIconRawImage = self.transform:FindDeepChild("ThemeIcon"):GetComponent(typeof(UnityUI.RawImage))
        self.classicMachineContainerTransform = self.transform:FindDeepChild("ClassicMachineContainer")
        self.starGameObjectArray = {}
        local starsButtonContainer = self.transform:FindDeepChild("StarsContainer")
        for i = 0, starsButtonContainer.childCount - 1 do
            local item = starsButtonContainer:GetChild(i)
            self.starGameObjectArray[i+1] = item:GetChild(0).gameObject
            local itemButton = item:GetComponent(typeof(UnityUI.Button))
            DelegateCache:addOnClickButton(itemButton)
            itemButton.onClick:AddListener(function()
                self:onStarClicked(itemButton)
            end)
        end
    end
    self.themeKey = themeKey
    self.buttonSubmit.interactable = false
    for i, v in ipairs(self.starGameObjectArray) do
        v:SetActive(false)
    end
    self.starCount = 0
    local type = ThemeAssetBundleHandler:getBundleInfoDict()[themeKey].type
    if type == 1 then
        self.themeIconRawImage.gameObject:SetActive(true)
        self.themeIconRawImage.enabled = false
        local smallIconPrefab = ThemeEntryHandler:getSmallIconPrefab(themeKey)
        local smallIconObject = Unity.Object.Instantiate(smallIconPrefab)
        smallIconObject.transform.anchoredPosition = Unity.Vector2.zero
        smallIconObject.transform:SetParent(self.themeIconRawImage.transform, false)
        -- self.themeIconRawImage.texture = ThemeEntryHandler:getSmallIconTexture(themeKey)
        self.classicMachineContainerTransform.transform:DestroyAllChildren()
    elseif type == 2 then
        self.themeIconRawImage.gameObject:SetActive(false)
        local smallEntryPrefab = ThemeEntryHandler:getSmallEntryPrefab(themeKey)
        local themeItemGameObject = Unity.Object.Instantiate(smallEntryPrefab)
        local themeItem = themeItemGameObject:GetComponent(typeof(Unity.RectTransform))
        themeItem:FindDeepChild("DownloadContainer").gameObject:SetActive(false)
        themeItem.anchoredPosition = Unity.Vector2.zero
        self.classicMachineContainerTransform.transform:DestroyAllChildren()
        themeItem:SetParent(self.classicMachineContainerTransform, false)
    end

    self.submitBonusText.text = MoneyFormatHelper.numWithCommas(GameConfig.RATETHEME_COINS)
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function RateThemePop:onStarClicked(sender)
    self.buttonSubmit.interactable = true
    self.starCount = sender.transform:GetSiblingIndex() + 1
    for i, v in ipairs(self.starGameObjectArray) do
        v:SetActive(i <= self.starCount)
    end
end

function RateThemePop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function RateThemePop:onSubmitBtnClicked()
    self:rateThemeEvent()
    DBHandler:addRatedTheme(self.themeKey, self.starCount)
    PlayerHandler:AddCoin(GameConfig.RATETHEME_COINS)
    CoinFly:fly(self.buttonSubmit.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10)
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
    if Util.IsRatePopTime() then
        RateUsPop:createAndShow()
    end
end

function RateThemePop:rateThemeEvent()
    if not GameConfig.RELEASE_VERSION then
        return
    end
    
	local eventParams = CS.System.Collections.Generic["Dictionary`2[System.String,System.Object]"]()
	
	local nUserLevel = PlayerHandler.nLevel
    local nLevel = PlayerLevelEXP:NormalizeIntParam(nUserLevel, 5)
    
	local nTotalSpinNum = LevelDataHandler:getTotalSpinNum()
    local fRate = PlayerLevelEXP:GetLevelReturnRate()
    CS.LuaHelper.SetItemForDict(eventParams, "returnRate", fRate)
	CS.LuaHelper.SetItemForDict(eventParams, "level", nLevel)
	CS.LuaHelper.SetItemForDict(eventParams, "totalSpinNum", nTotalSpinNum)
    CS.LuaHelper.SetItemForDict(eventParams, "starCount", self.starCount)
    
	local strEventKey = "RateTheme_" .. self.themeKey
    FBHandler:FBEvent(strEventKey, eventParams)
    self:trackEventForAppsflyer()
end

function RateThemePop:trackEventForAppsflyer()
    local eventParams = CS.System.Collections.Generic["Dictionary`2[System.String,System.String]"]()
    local strEventKey = "RateTheme_" .. self.themeKey
    CS.LuaHelper.SetItemForDict(eventParams, "starCount",  tostring(self.starCount))
    CS.AppsFlyerSDK.AppsFlyer.sendEvent(strEventKey, eventParams)
end