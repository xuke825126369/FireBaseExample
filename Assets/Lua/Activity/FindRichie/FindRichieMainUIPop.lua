FindRichieMainUIPop = {}

FindRichieMainUIPop.m_bIsFirstBegin = true
FindRichieMainUIPop.m_bIsGenerateLevel = false

FindRichieMainUIPop.m_LeanTweenIDs = {}
FindRichieMainUIPop.m_mapFruitItems = {}

FindRichieMainUIPop.m_randomConfig = {
    steps = {1, 2, 3, 4, 5}, --1代表没获取任何东西，2代表获取金币，3代表获取额外的pickCount，4代表获取卡包， 5代表结束
    probs = {1, 1, 1, 1, 1}
}

function FindRichieMainUIPop:Show()
    if FindRichieAssetBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then
        return
    end
    if self.asynLoadCo == nil then
        self.asynLoadCo = StartCoroutine(function()
            Scene.loadingAssetBundle:SetActive(true)
            Debug.Log("-------FindRichie begin Loaded---------")
            FindRichieAssetBundleHandler:asynLoadFindRichieAssetBundle()
            local isReady = FindRichieUnloadedUI.m_bAssetReady
            while (not isReady) do
                yield_return(0)
            end
            Scene.loadingAssetBundle:SetActive(false)
            self:Show()
            self.asynLoadCo = nil
        end)
    end
end

function FindRichieMainUIPop:Show()
    self.m_bPortraitFlag = false
    if ThemeLoader.themeKey ~= nil then
        self.m_bPortraitFlag = GameLevelUtil:isPortraitLevel()
        SlotsGameLua.m_bReelPauseFlag = true
    end
    if self.m_bPortraitFlag then
        Debug.Log("切横屏")
        Scene:SwitchScreenOp(true) -- 变成横屏
        SceneLoading:ShowBlackBgInThemesTransitionScreen(true)
    end
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end

    if not self.m_bInitFlag then
        if self.transform ~= nil then
            Unity.GameObject.Destroy(self.transform.gameObject)
        end

        self.m_bInitFlag = true
        local strPath = "Assets/FindRichie/FindRichieMainUIPop.prefab"
        local prefabObj = Util.getFindRichiePrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        self.m_container = self.transform:FindDeepChild("Container")
        self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

        -- self.leftTimeContainer = self.transform:FindDeepChild("TimeLeftGo").gameObject
        -- self.m_leftTime = self.leftTimeContainer.transform:FindDeepChild("TimeLeft"):GetComponent(typeof(TextMeshProUGUI))
        self.m_levelContainer = self.transform:FindDeepChild("LevelContainer")

        --MainUI
        self.m_textPickCount = self.transform:FindDeepChild("PickCountText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textCurrentLevel = self.transform:FindDeepChild("CurrentLevelText"):GetComponent(typeof(TextMeshProUGUI))
        self.m_textTotalRewards = self.transform:FindDeepChild("TotalRewardsText"):GetComponent(typeof(UnityUI.Text))
        self.m_textLevelRewards = self.transform:FindDeepChild("LevelRewards"):GetComponent(typeof(UnityUI.Text))
        
        --LevelStarBegin
        self.m_goLevelStartBegin = self.transform:FindDeepChild("LevelStartBegin").gameObject
        self.m_trNextLevelContainer = self.m_goLevelStartBegin.transform:FindDeepChild("LevelCountImg")
        self.m_btnLevelStartGoOn = self.m_goLevelStartBegin.transform:FindDeepChild("LevelStartGoOnBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnLevelStartGoOn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onLevelStartGoOnBtnClick()
        end)

        --GetCoins
        self.m_trGetCoinsAni = self.transform:FindDeepChild("GetCoinsAniGo")
        self.m_goGetCoins = self.transform:FindDeepChild("GetCoins").gameObject
        self.m_textGetCoinsReward = self.transform:FindDeepChild("GetCoinsRewardText"):GetComponent(typeof(UnityUI.Text))
        self.m_btnGoOn = self.transform:FindDeepChild("GetCoinsGoOnBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnGoOn.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onGetCoinsAndGoOnBtnClick()
        end)
 
        --GetExtraPick
        self.m_trGetExtraPickAni = self.transform:FindDeepChild("ExtraPickAniGo")
        self.m_goGetExtraPick = self.transform:FindDeepChild("GetExtraPick").gameObject
        self.m_btnExtraPick = self.transform:FindDeepChild("GetExtraPickBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnExtraPick.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onGetExtraPickAndGoOnBtnClick()
        end)

        --GetSlotsCards
        self.m_trGetPackAni = self.transform:FindDeepChild("SlotsCardsAniGo")
        self.m_goGetSlotsCards = self.transform:FindDeepChild("GetSlotsCards").gameObject
        self.m_btnGetPack = self.transform:FindDeepChild("GetPackBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnGetPack.onClick:AddListener(function()
            self:onGetPackAndGoOnBtnClick()
        end)

        --GetNothing 每次进入消耗完所有pick后没有获得任何物品就弹出这个
        self.m_goGetNothing = self.transform:FindDeepChild("GetNothing").gameObject

        --FirstBegin
        self.m_goFirstBegin = self.transform:FindDeepChild("FristBegin").gameObject
        self.m_btnFristGo = self.transform:FindDeepChild("FristBegainGoBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnFristGo.onClick:AddListener(function()
            self:onFristBeginBtnClick()
        end)
        
        --LevelEnd
        self.m_levelEndContainer = self.transform:FindDeepChild("LevelEnd").gameObject
        self.m_goLevelEndContent = self.transform:FindDeepChild("LevelEndContent").gameObject
        self.m_goLevelAllEndContainer = self.transform:FindDeepChild("AllLevelCompletedEnd").gameObject
        self.m_textLevelEndRewards = self.transform:FindDeepChild("LevelEndRewardText"):GetComponent(typeof(UnityUI.Text))
        self.m_btnClaim = self.transform:FindDeepChild("ClaimBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnClaim.onClick:AddListener(function()
            self:onLevelEndClaimBtnClick()
        end)
        
        self.m_btnStartAgain = self.transform:FindDeepChild("StartAgainBtn"):GetComponent(typeof(UnityUI.Button))
        self.m_btnStartAgain.onClick:AddListener(function()
            self:onStartAgainBtnClick()
        end)

        --这个获得卡包时不显示，FirstBegin不显示，LevelEnd不显示
        --GetNothing和GetCoins：显示"Fill the Star Bar find Mr.Gold!" ， GetExtraPick：显示"Pick again with Extra Picks"
        self.m_textGetAnyThingInfo = self.transform:FindDeepChild("GetAnyThingInfoText"):GetComponent(typeof(TextMeshProUGUI))

        self.transform:FindDeepChild("IntroduceBtn"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
            GlobalAudioHandler:PlayFindRichieSound("click")
            -- FindRichiePrizesPop:Show()
        end)

        -- self:updateTime()
        -- self.transform:FindDeepChild("ShopBtn"):GetComponent(typeof(UnityUI.Button)).onClick:AddListener(function()
        --     GlobalAudioHandler:PlayFindRichieSound("button")
        --     BuyView:Show()
        -- end)
        
        self.m_btnGoSpin = self.transform:FindDeepChild("GoSpinBtn"):GetComponent(typeof(UnityUI.Button)) --实际就是退出按钮
        self.m_btnGoSpin.onClick:AddListener(function()
            GlobalAudioHandler:PlayFindRichieSound("click")
            self:onGoSpinBtnClick()
        end)
    end
    if not self.m_bIsGenerateLevel then
        self:InitFruitItem()
    end
    self.m_textTotalRewards.text = MoneyFormatHelper.numWithCommas(FindRichieDataHandler.m_mapPrize["All"])
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.m_container.localScale = Unity.Vector3.one
    self.popController:show(function()
        GlobalAudioHandler:PlayFindRichieMusic("stamp_music")
        if self.m_bIsFirstBegin then
            self.m_bIsFirstBegin = false
            self.m_goFirstBegin:SetActive(true)
        end
    end)
    self:UpdatePickCount()
end

function FindRichieMainUIPop:InitFruitItem()
    self.m_bIsGenerateLevel = true
    if LuaHelper.tableSize(self.m_mapFruitItems) > 0 then
        for k,v in pairs(self.m_mapFruitItems) do
            v = nil
        end
    end
    self.m_mapFruitItems = {}
    if self.m_trFruitContainer ~= nil then
        self.m_trFruitContainer.gameObject:SetActive(false)
    end
    self.m_trFruitContainer = self.m_levelContainer:FindDeepChild("Level"..FindRichieDataHandler.data.nLevel)
    self.m_trFruitContainer.gameObject:SetActive(true)
    for i = 1, (self.m_trFruitContainer.childCount) do
        local go = self.m_trFruitContainer:GetChild(i-1).gameObject
        local item = FruitItem:new(go, i)
        table.insert(self.m_mapFruitItems, item)
    end
    self:UpdateLevelInfo()
end

function FindRichieMainUIPop:UpdatePickCount()
    local count = FindRichieDataHandler.data.nPickCount
    if count == nil then
        count = 0
    end
    self.m_textPickCount.text = count
end

function FindRichieMainUIPop:UpdateLevelInfo()
    local level = FindRichieDataHandler.data.nLevel
    self.m_textCurrentLevel.text = level.."/5"
    self.m_textLevelRewards.text = MoneyFormatHelper.numWithCommas(FindRichieDataHandler.m_mapPrize["Level"..level])
end

function FindRichieMainUIPop:GetPickCount()
    local count = 0
    for i=1,LuaHelper.tableSize(self.m_mapFruitItems) do
        if self.m_mapFruitItems[i].bStates then
            count = count + 1
        end
    end
    return count
end

function FindRichieMainUIPop:updateTime()
    local endTime = FindRichieDataHandler:getEndTime()
    if endTime ~= nil then
        if ((endTime - TimeHandler:GetServerTimeStamp()) // (3600*24)) < 30 then
            self.leftTimeContainer:SetActive(true)
            local prizeMoreText = self.transform:FindDeepChild("PizeMoreText"):GetComponent(typeof(TextMeshProUGUI))
            prizeMoreText.text = string.format("%d", (FindRichieDataHandler.m_lastTimeMoreCoinsRatio-1)*100).."%"
            local co = StartCoroutine( function()
                local waitForSecend = Unity.WaitForSeconds(1)
                while (endTime ~= nil) and (self.transform ~= nil) do
                    local nowSecond = TimeHandler:GetServerTimeStamp()
                    
                    local time = endTime - nowSecond
                    local days = time // (3600*24)
                    local hours = time // 3600 - 24 * days
                    local minutes = time // 60 - 24 * days * 60 - 60 * hours
                    local seconds = time % 60
                    if days < 1 then
                        self.m_leftTime.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                    else
                        self.m_leftTime.text = string.format("%d DAYS LEFT", days)
                    end
                    if time <= 0 then
                        endTime = nil
                        self.leftTimeContainer:SetActive(false)
                    end
                    yield_return(waitForSecend)
                end
            end)
        else
            self.prizeMoreContainer:SetActive(false)
            self.leftTimeContainer:SetActive(false)
        end
    end
end

function FindRichieMainUIPop:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function FindRichieMainUIPop:hide()
    GlobalAudioHandler:StopFindRichieMusic()
    if self.m_bPortraitFlag then
        SceneLoading:ShowBlackBgInThemesTransitionScreen(false)
    end
    self.popController:hide(false, function()
        if self.m_bPortraitFlag then
            Debug.Log("切屏")
            Scene:SwitchScreenOp(false)
            self.m_bPortraitFlag = false
        end
        self:CancelLeanTween()
        if GameConfig.PLATFORM_EDITOR then
            return
        end
        self.m_trFruitContainer = nil
        self.m_bIsGenerateLevel = false
        if self.transform ~= nil then
            Unity.Object.Destroy(self.transform.gameObject)
        end
        FindRichieAssetBundleHandler:unloadFindRichieAssetBundle()
    end)
end

function FindRichieMainUIPop:onFristBeginBtnClick()
    self.m_goFirstBegin:SetActive(false)
end

function FindRichieMainUIPop:ShowGetNothing()
    self.m_goGetNothing:SetActive(true)
    self.m_textGetAnyThingInfo.text = "Fill the Star Bar find Mr.Gold!"
    self.m_textGetAnyThingInfo.gameObject:SetActive(true)
    self.m_btnGoSpin.gameObject:SetActive(true)
end

function FindRichieMainUIPop:ShowGetSlotsCards(pos)
    self:CancelLeanTween()
    self.m_trGetPackAni.position = pos
    self.m_trGetPackAni.localScale = Unity.Vector3.zero
    local id = LeanTween.scale(self.m_trGetPackAni.gameObject, Unity.Vector3.one*0.7, 0.5):setOnComplete(function()
        local id1 = LeanTween.scale(self.m_trGetPackAni.gameObject, Unity.Vector3.one*0.5, 0.2):setOnComplete(function()
            local id2 = LeanTween.move(self.m_trGetPackAni.gameObject, Unity.Vector3.zero, 0.7).id
            table.insert(self.m_LeanTweenIDs, id2)
            local id3 = LeanTween.scale(self.m_trGetPackAni.gameObject, Unity.Vector3.one*2.1, 0.7):setOnComplete(function()
                local id4 = LeanTween.scale(self.m_trGetPackAni.gameObject, Unity.Vector3.one*2, 0.5):setEase(LeanTweenType.easeInOutBack).id
                table.insert(self.m_LeanTweenIDs, id4)
            end).id
            table.insert(self.m_LeanTweenIDs, id3)
        end).id
        table.insert(self.m_LeanTweenIDs, id1)
    end).id
    table.insert(self.m_LeanTweenIDs, id)
    self.m_goGetSlotsCards:SetActive(true)
    self.m_textGetAnyThingInfo.gameObject:SetActive(false)
    if FindRichieDataHandler.data.nPickCount <= 0 then
        self.m_btnGetPack.gameObject:SetActive(false)
        self.m_btnGoSpin.gameObject:SetActive(true)
    else
        self.m_btnGetPack.gameObject:SetActive(true)
        self.m_btnGoSpin.gameObject:SetActive(false)
    end
end

function FindRichieMainUIPop:onGetPackAndGoOnBtnClick()
    self.m_goGetSlotsCards:SetActive(false)
    self.m_textGetAnyThingInfo.gameObject:SetActive(false)
end

function FindRichieMainUIPop:ShowGetExtraPick(pos)
    self:CancelLeanTween()
    self.m_trGetExtraPickAni.position = pos
    self.m_trGetExtraPickAni.localScale = Unity.Vector3.zero
    -- LeanTween.move(self.m_trGetExtraPickAni.gameObject, Unity.Vector3.zero, 0.7):setDelay(0.7)
    local id = LeanTween.scale(self.m_trGetExtraPickAni, Unity.Vector3.one*0.3, 0.5):setOnComplete(function()
        local id1 = LeanTween.scale(self.m_trGetExtraPickAni, Unity.Vector3.one*0.25, 0.2):setOnComplete(function()
            local id2 = LeanTween.move(self.m_trGetExtraPickAni.gameObject, Unity.Vector3.zero, 0.7).id
            table.insert(self.m_LeanTweenIDs, id2)
            local id3 = LeanTween.scale(self.m_trGetExtraPickAni, Unity.Vector3.one*1.1, 0.7):setOnComplete(function()
                local id4 = LeanTween.scale(self.m_trGetExtraPickAni, Unity.Vector3.one, 0.5):setEase(LeanTweenType.easeInOutBack).id
                table.insert(self.m_LeanTweenIDs, id4)
            end).id
            table.insert(self.m_LeanTweenIDs, id3)
        end).id
        table.insert(self.m_LeanTweenIDs, id1)
    end).id
    table.insert(self.m_LeanTweenIDs, id)
    self.m_goGetExtraPick:SetActive(true)
    self.m_textGetAnyThingInfo.text = "Pick again with Extra Picks"
    self.m_textGetAnyThingInfo.gameObject:SetActive(true)
    if FindRichieDataHandler.data.nPickCount <= 0 then
        self.m_btnExtraPick.gameObject:SetActive(false)
        self.m_btnGoSpin.gameObject:SetActive(true)
    else
        self.m_btnExtraPick.gameObject:SetActive(true)
        self.m_btnGoSpin.gameObject:SetActive(false)
    end
end

function FindRichieMainUIPop:onGetExtraPickAndGoOnBtnClick()
    self.m_goGetExtraPick:SetActive(false)
    self.m_textGetAnyThingInfo.gameObject:SetActive(false)
end

function FindRichieMainUIPop:ShowGetCoins(pos)
    self:CancelLeanTween()
    self.m_trGetCoinsAni.position = pos
    self.m_trGetCoinsAni.localScale = Unity.Vector3.zero
    local id = LeanTween.scale(self.m_trGetCoinsAni, Unity.Vector3.one*0.3, 0.5):setOnComplete(function()
        local id1 = LeanTween.scale(self.m_trGetCoinsAni, Unity.Vector3.one*0.25, 0.2):setOnComplete(function()
            local id2 = LeanTween.move(self.m_trGetCoinsAni.gameObject, Unity.Vector3.zero, 0.7).id
            table.insert(self.m_LeanTweenIDs, id2)
            local id3 = LeanTween.scale(self.m_trGetCoinsAni, Unity.Vector3.one*1.1, 0.7):setOnComplete(function()
                local id4 = LeanTween.scale(self.m_trGetCoinsAni, Unity.Vector3.one, 0.5):setEase(LeanTweenType.easeInOutBack):setOnComplete(function()
                    local id5 = LeanTween.move(self.m_trGetCoinsAni.gameObject, Unity.Vector3(-390, 0, 0), 0.5).id
                    table.insert(self.m_LeanTweenIDs, id5)
                end).id
                table.insert(self.m_LeanTweenIDs, id4)
            end).id
            table.insert(self.m_LeanTweenIDs, id3)
        end).id
        table.insert(self.m_LeanTweenIDs, id1)
    end).id
    table.insert(self.m_LeanTweenIDs, id)
    self.m_goGetCoins:SetActive(true)
    self.m_textGetAnyThingInfo.text = "Fill the Star Bar find Mr.Gold!"
    self.m_textGetAnyThingInfo.gameObject:SetActive(true)
    if FindRichieDataHandler.data.nPickCount <= 0 then
        self.m_btnGoOn.gameObject:SetActive(false)
        self.m_btnGoSpin.gameObject:SetActive(true)
    else
        self.m_btnGoOn.gameObject:SetActive(true)
        self.m_btnGoSpin.gameObject:SetActive(false)
    end
end

function FindRichieMainUIPop:onGetCoinsAndGoOnBtnClick()
    self.m_goGetCoins:SetActive(false)
    self.m_textGetAnyThingInfo.gameObject:SetActive(false)
end

function FindRichieMainUIPop:ShowLevelEnd()
    self.m_levelEndContainer:SetActive(true)

    self.m_textLevelEndRewards.text = MoneyFormatHelper.numWithCommas(FindRichieDataHandler.m_mapPrize["Level"..(FindRichieDataHandler.data.nLevel-1)])
    self.m_goLevelEndContent:SetActive(true)
end

function FindRichieMainUIPop:onLevelEndClaimBtnClick()
    self.m_goLevelEndContent:SetActive(false)
    if FindRichieDataHandler.data.nLevel > 5 then
        self.m_goLevelAllEndContainer:SetActive(true)
        FindRichieDataHandler:ResetLevelInfo()
    else
        self.m_levelEndContainer:SetActive(false)
        self:InitFruitItem()
        self:ShowLevelStartBegin()
    end
end

function FindRichieMainUIPop:ShowLevelStartBegin()
    if FindRichieDataHandler.data.nLevel < 2 then
        return
    end
    for i=0,self.m_trNextLevelContainer.childCount-1 do
        local item = self.m_trNextLevelContainer:GetChild(i).gameObject
        item:SetActive(i == (FindRichieDataHandler.data.nLevel-2))
    end
    self.m_goLevelStartBegin:SetActive(true)
end

function FindRichieMainUIPop:onLevelStartGoOnBtnClick()
    self.m_goLevelStartBegin:SetActive(false)
    if FindRichieDataHandler.data.nPickCount <= 0 then
        self:onGoSpinBtnClick()
    end
end

function FindRichieMainUIPop:onStartAgainBtnClick()
    self.m_goLevelEndContent:SetActive(false)
    self.m_goLevelAllEndContainer:SetActive(false)
    self.m_levelEndContainer:SetActive(false)
    self.m_bIsGenerateLevel = false
    self:InitFruitItem()
end

function FindRichieMainUIPop:onGoSpinBtnClick()
    self.m_textGetAnyThingInfo.gameObject:SetActive(false)
    self.m_btnGoSpin.gameObject:SetActive(false)
    if self.m_levelEndContainer.activeSelf then
        self.m_levelEndContainer:SetActive(false)
    end
    if self.m_goFirstBegin.activeSelf then
        self.m_goFirstBegin:SetActive(false)
    end
    if self.m_goGetNothing.activeSelf then
        self.m_goGetNothing:SetActive(false)
    end
    if self.m_goGetSlotsCards.activeSelf then
        self.m_goGetSlotsCards:SetActive(false)
    end
    if self.m_goGetExtraPick.activeSelf then
        self.m_goGetExtraPick:SetActive(false)
    end
    if self.m_goGetCoins.activeSelf then
        self.m_goGetCoins:SetActive(false)
    end
    self:hide()
end

function FindRichieMainUIPop:CheckIsAllEnd()
    if FindRichieDataHandler.data.nLevel > 5 then
        self.m_levelEndContainer:SetActive(true)
        self.m_goLevelAllEndContainer:SetActive(true)
        FindRichieDataHandler:ResetLevelInfo()
    end
end