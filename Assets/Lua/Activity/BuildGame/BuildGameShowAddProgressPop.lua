

BuildGameShowAddProgressPop = {}



BuildGameShowAddProgressPop.m_gameObject = nil
BuildGameShowAddProgressPop.m_transform = nil
BuildGameShowAddProgressPop.m_mapLeanTweenIds = {}
BuildGameShowAddProgressPop.m_mapBuildShowObjects = {}

function BuildGameShowAddProgressPop:createAndShow(depotType, addProgressInfo, count)
    if self.m_gameObject == nil then
        local strPath = "Assets/BuildYourCity/BuildGameShowAddProgressPop.prefab"
        local prefabObj = Util.getBuildGamePrefab(strPath)
        self.m_gameObject = Unity.Object.Instantiate(prefabObj)
        self.m_transform = self.m_gameObject.transform
        self.m_transform:SetParent(LobbyScene.popCanvas, false)
        self.popController = PopController:new(self.m_gameObject)
        self.m_openDepotsAni = self.m_transform:FindDeepChild("OpenDepotsAni"):GetComponent(typeof(Unity.CanvasGroup))
        self.m_lightAni = self.m_transform:FindDeepChild("LightAni"):GetComponent(typeof(Unity.CanvasGroup))
        self.m_depotsContainerGrop = self.m_transform:FindDeepChild("DepotsContianer")
        self.m_textDepotCount = self.m_transform:FindDeepChild("DepotCount"):GetComponent(typeof(TextMeshProUGUI))

        self.m_buildContainer = self.m_transform:FindDeepChild("BuildContainer")
        self.m_buildingAni = self.m_transform:FindDeepChild("BuildAni"):GetComponent(typeof(Unity.Animator)) --正在建造动画
        self.m_coinsAni = self.m_transform:FindDeepChild("CoinsAni"):GetComponent(typeof(Unity.Animator)) --掉金币动画

        self.m_rewardContainer = self.m_transform:FindDeepChild("RewardContainer"):GetComponent(typeof(Unity.CanvasGroup))
        self.m_starContainer = self.m_rewardContainer.transform:FindDeepChild("StarContainer")
        self.m_rewardText = self.m_transform:FindDeepChild("RewardText"):GetComponent(typeof(TextMeshProUGUI))
        -- self.m_addProgressText = self.m_transform:FindDeepChild("AddProgressText"):GetComponent(typeof(TextMeshProUGUI))

        self.btnSkip = self.m_transform:FindDeepChild("BtnSkip"):GetComponent(typeof(UnityUI.Button))
        self.btnSkip.onClick:AddListener(function()
            self:btnSkipClicked()
        end)

        self.m_fullContainer = self.m_transform:FindDeepChild("FullContainer"):GetComponent(typeof(Unity.CanvasGroup))
        self.m_fullProgressImg = self.m_fullContainer.transform:FindDeepChild("FullProgressImg"):GetComponent(typeof(UnityUI.Image))
        self.m_fullProgressText = self.m_fullContainer.transform:FindDeepChild("FullProgressText"):GetComponent(typeof(TextMeshProUGUI))
        -- local btnClose = self.m_transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        -- btnClose.onClick:AddListener(function()
        --     self:hide()
        -- end)
    end
    self.btnSkip.interactable = true
    self.m_addProgressInfo = addProgressInfo
    self:initShowBuildObjects(depotType, count)
    ViewScaleAni:Show(self.transform.gameObject)
end

function BuildGameShowAddProgressPop:initShowBuildObjects(depotType, count)
    for i=1,#self.m_mapBuildShowObjects do
        if self.m_mapBuildShowObjects[i].gameObject ~= nil then
            Unity.Object.Destroy(self.m_mapBuildShowObjects[i].gameObject)
            self.m_mapBuildShowObjects[i].gameObject = nil
        end
    end
    self.m_mapBuildShowObjects = {}

    for k,v in pairs(self.m_addProgressInfo) do
        if v ~= 0 then
            self:createShowBuild(BuildGameMainUIPop:getStrTypeFromIndex(k))
        end
    end
    -- for k,v in pairs(BuildGameConfig.Build[BuildGameDataHandler.m_curSeason]) do
    --     self:createShowBuild(k)
    -- end

    --TODO 第一个Build，先添加progress->升级->再添加progress,
    -- 然后添加一个房屋->再添加一个房屋,
    -- 然后显示第一个房屋的奖励->再显示第二个房屋的奖励
    -- self.seq = LeanTween.sequence()
    self.bIsAllComplete = false
    self.fullProgressCount = 0
    self.fullProgress = BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].build["Silver1"].fullProgress
    self.m_openDepotsAni.alpha = 1
    self.m_rewardContainer.alpha = 0
    self.m_fullContainer.alpha = 0
    self.m_lightAni.alpha = 0
    
    for i=0,self.m_depotsContainerGrop.childCount-1 do
        self.m_depotsContainerGrop:GetChild(i).gameObject:SetActive(i==depotType)
    end
    self.m_textDepotCount.gameObject:SetActive(true)
    self.m_textDepotCount.text = count

    local id = LeanTween.value(1, 0, 0.2):setDelay(1.5):setOnUpdate(function( value )
        self.m_openDepotsAni.alpha = value
    end):setOnComplete(function()
        self.m_textDepotCount.gameObject:SetActive(false)
        self:starAnimation() 
    end).id
    table.insert( self.m_mapLeanTweenIds, id )
end

function BuildGameShowAddProgressPop:createShowBuild(strType)
    local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][strType]
    if data == nil then
        return
    end

    local path = "Assets/BuildYourCity/"..BuildGameDataHandler.m_curSeason.."/".. strType ..".prefab"
    local prefabObj = Util.getBuildGamePrefab(path)
    local obj = Unity.Object.Instantiate(prefabObj)
    obj:SetActive(false)
    obj.transform:SetParent(self.m_buildContainer)
    obj.transform.localScale = Unity.Vector3.zero
    obj.transform.anchoredPosition3D = Unity.Vector3(0,60,0)
    local buildObj = BuildShowObj:new(obj, strType)
    buildObj:refreshUI()
    buildObj:updateStar()
    buildObj:updateBuild()
    table.insert( self.m_mapBuildShowObjects, buildObj )
    -- self.m_mapBuildShowObjects[strType] = buildObj
end

function BuildGameShowAddProgressPop:starAnimation()
    if not self:checkIsActive() then
        return
    end
    local isLevelChange = false
    local isProgressChange = false
    local buildShowObj = nil
    local bIsComplete = true --用于查看是否所有的Build已经更新完数据
    for i=1,#self.m_mapBuildShowObjects do
        local v = self.m_mapBuildShowObjects[i]
        local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][v.strType]
        if v.level ~= data.level then
            isLevelChange = true
            buildShowObj = v
            bIsComplete = false
            break
        end
        if v.progress ~= data.progress then
            isProgressChange = true
            buildShowObj = v
            bIsComplete = false
            break
        end
        if v.level >= 5 then
            isProgressChange = true
            buildShowObj = v
            bIsComplete = false
            break
        end
    end
    if bIsComplete and (not self.bIsAllComplete) then --self.bIsAllComplete由于是递归函数多次执行，所以设置一个flag
        self.bIsAllComplete = true
        self:btnSkipClicked()
        return
    end
    if isLevelChange then
        local isFirst = false
        local delay = 0
        if not buildShowObj.gameObject.activeInHierarchy then
            isFirst = true
            delay = 2.5
            buildShowObj.gameObject:SetActive(true)
            self:showAddProgressAndHideAni(buildShowObj)
        end
        buildShowObj.progressContainer.alpha = 1
        local id = LeanTween.scale(buildShowObj.gameObject,Unity.Vector3.one*1.2,0.5):setOnComplete(function()
            local id1 = LeanTween.value(0, 1, 0.5):setDelay(delay):setOnUpdate(function(value)
                if not self:checkIsActive() then
                    return
                end
                if isFirst then
                    buildShowObj.progressText.color = Unity.Color(1,1,1,value)
                    buildShowObj:refreshUI()
                end
            end):setOnComplete(function()
                AudioHandler:PlayBuildGameSound("item_expup")
                local startProgress = buildShowObj.progress
                local targetProgress = buildShowObj.levelProgress
                local id2 = LeanTween.value(startProgress, targetProgress, 1.6):setOnUpdate(function(value)
                    buildShowObj.progress = math.floor( value )
                    buildShowObj:refreshUI(value)
                end):setOnComplete(function()
                    buildShowObj:levelUpToZeroRefreshDataAndUI()
                    -- 这里处理直接升到满级的情况
                    if buildShowObj.level >= 5 then
                        AudioHandler:PlayBuildGameSound("win")
                        if buildShowObj.levelUpCount > 0 then
                            local id5 = LeanTween.value(0, 1, 0.5):setDelay(0.5):setOnUpdate(function(value)
                                self.m_lightAni.alpha = value
                            end).id
                            table.insert( self.m_mapLeanTweenIds, id5 )
                            self:showBuildAnimation(buildShowObj)
                        else --如果没有升级过，刷新下一个BuildObj
                            local id3 = LeanTween.delayedCall(1,function()
                                local id4 = LeanTween.scale(buildShowObj.gameObject,Unity.Vector3.zero,0.5):setOnComplete(function()
                                    self:starAnimation()
                                end).id
                                table.insert( self.m_mapLeanTweenIds, id4 )
                            end).id
                            table.insert( self.m_mapLeanTweenIds, id3 )
                        end
                    else
                        self:starAnimation()
                    end
                end).id
                table.insert( self.m_mapLeanTweenIds, id2 )
            end).id
            table.insert( self.m_mapLeanTweenIds, id1 )
        end).id
        table.insert( self.m_mapLeanTweenIds, id )
        return
    end
    if isProgressChange then
        local isFirst = false
        local delay = 0
        if not buildShowObj.gameObject.activeInHierarchy then
            isFirst = true
            delay = 2.5
            buildShowObj.gameObject:SetActive(true)
            self:showAddProgressAndHideAni(buildShowObj)
        end
        buildShowObj.progressContainer.alpha = 1
        local id = LeanTween.scale(buildShowObj.gameObject,Unity.Vector3.one*1.2,0.5):setOnComplete(function()
            local id1 = LeanTween.value(0, 1, 0.5):setDelay(delay):setOnUpdate(function( value )
                if not self:checkIsActive() then
                    return
                end
                if isFirst then
                    buildShowObj.progressText.color = Unity.Color(1,1,1,value)
                    buildShowObj:refreshUI()
                end
            end):setOnComplete(function()
                if buildShowObj.level >= 5 then
                    self:updateFullProgress(buildShowObj)
                else
                    AudioHandler:PlayBuildGameSound("item_expup")
                    self:showUpdateProgressAni(buildShowObj)
                end
            end).id
            table.insert( self.m_mapLeanTweenIds, id1 )
        end).id
        table.insert( self.m_mapLeanTweenIds, id )
    end
end

function BuildGameShowAddProgressPop:showBuildAnimation(buildShowObj)
    if not self:checkIsActive() then
        return
    end
    self.m_buildingAni:SetTrigger(Unity.Animator.StringToHash("ShowEffect"))
    AudioHandler:PlayBuildGameSound("item_build")
    local id = LeanTween.delayedCall(2.2,function()
        if not self:checkIsActive() then
            return
        end
        AudioHandler:PlayBuildGameSound("cheer")
    end).id
    table.insert( self.m_mapLeanTweenIds, id )

    local id1 = LeanTween.scale(buildShowObj.buildContainer, Unity.Vector3.zero, 0.3):setDelay(0.5):setOnComplete(function()
        if not self:checkIsActive() then
            return
        end
        buildShowObj:updateBuild()
        buildShowObj.levelUpCount = buildShowObj.levelUpCount - 1
        buildShowObj:updateBuild()
        local id2 = LeanTween.scale(buildShowObj.buildContainer, Unity.Vector3.one, 0.2):setOnComplete(function()
            local delay = 5.5
            if buildShowObj.levelUpCount > 0 then
                local id4 = LeanTween.delayedCall(delay, function()
                    self:showBuildAnimation(buildShowObj)
                end).id
                table.insert( self.m_mapLeanTweenIds, id4 )
            else
                local id3 = LeanTween.value(1, 0, 0.5):setDelay(delay):setOnUpdate(function( value )
                    buildShowObj.progressContainer.alpha = value
                end):setOnComplete(function()
                    --1.5秒做掉金币动画
                    self.m_coinsAni:SetInteger("nPlayMode", 1)
                    AudioHandler:PlayBuildGameSound("coins_drop")
                    local id4 = LeanTween.delayedCall(2, function()
                        self:showRewardAnimation(buildShowObj)
                    end).id
                    table.insert( self.m_mapLeanTweenIds, id4 )    
                end).id
                table.insert( self.m_mapLeanTweenIds, id3 )
            end
        end) .id
        table.insert( self.m_mapLeanTweenIds, id2 )
    end).id
    table.insert( self.m_mapLeanTweenIds, id1 )
end

function BuildGameShowAddProgressPop:showRewardAnimation(buildShowObj)
    if not self:checkIsActive() then
        return
    end
    local id = LeanTween.value(0, 1, 0.5):setOnStart(function()
        if not self:checkIsActive() then
            return
        end
        local rewardList = BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].rewardList
        self.m_rewardText.text = MoneyFormatHelper.numWithCommas(MoneyFormatHelper.normalizeCoinCount(rewardList[buildShowObj.strType][buildShowObj.lastLevel+1]))
        buildShowObj.lastLevel = buildShowObj.lastLevel + 1
        for i=0, 4 do
            self.m_starContainer:GetChild(i).gameObject:SetActive(i < buildShowObj.lastLevel)
        end
    end):setOnUpdate(function(value)
        if not self:checkIsActive() then
            return
        end
        self.m_rewardContainer.alpha = value
    end):setOnComplete(function()
        if not self:checkIsActive() then
            return
        end
        CoinFly:fly(self.m_rewardText.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 6)
    end).id

    table.insert( self.m_mapLeanTweenIds, id )
    local id = LeanTween.delayedCall(2.5, function()
        if not self:checkIsActive() then
            return
        end
        local id1 = LeanTween.value(1, 0, 0.5):setOnUpdate(function( value )
            if not self:checkIsActive() then
                return
            end
            self.m_rewardContainer.alpha = value
        end):setOnComplete(function()
            if buildShowObj.lastLevel ~= buildShowObj.level then
                self:showRewardAnimation(buildShowObj)
            else
                self.m_coinsAni:SetInteger("nPlayMode", 0)
                local id3 = LeanTween.value(1, 0, 0.5):setDelay(1.5):setOnUpdate(function(value)
                    if not self:checkIsActive() then
                        return
                    end
                    self.m_lightAni.alpha = value
                end).id
                table.insert( self.m_mapLeanTweenIds, id3 )
                if buildShowObj.level >= 5 then
                    self:updateFullProgress(buildShowObj)
                else
                    local id2 = LeanTween.scale(buildShowObj.gameObject, Unity.Vector3.zero, 0.5):setDelay(1.5):setOnComplete(function()
                        self:starAnimation()--重新回到star，判断已经完成动画，退出并更新数据
                    end).id
                    table.insert( self.m_mapLeanTweenIds, id2 )
                end
            end
        end).id
        table.insert( self.m_mapLeanTweenIds, id1 )
    end).id
    table.insert( self.m_mapLeanTweenIds, id )
end

function BuildGameShowAddProgressPop:btnSkipClicked()
    self.btnSkip.interactable = false
    for i=1,#self.m_mapLeanTweenIds do
        local id = self.m_mapLeanTweenIds[i]
        if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
    end
    self.m_mapLeanTweenIds = {}
    for i=1,#self.m_mapBuildShowObjects do
        self.m_mapBuildShowObjects[i]:skipBtnClicked()
    end
    BuildGameMainUIPop:refreshUI()
    ViewScaleAni:Hide(self.transform.gameObject)
    LeanTween.delayedCall(0.5,function()
        local isCompleted, reward = BuildGameDataHandler:checkIsAllBuildCompleted()
        if isCompleted then
            -- Debug.Log("完成一次建筑游戏，进入下一轮")
            BuildGameAllCompletedPop:createAndShow(reward)
        else
            BuildGameShowResultePop:createAndShow(self.m_addProgressInfo)
        end
    end)
    UITop:updateCoinCountInUi(2)
end

function BuildGameShowAddProgressPop:hide()
    AudioHandler:PlayBuildGameSound("click")
    ViewScaleAni:Hide(self.transform.gameObject)
end

function BuildGameShowAddProgressPop:checkIsActive()
    if self.m_gameObject == nil then
        return false
    end
    if not self.m_gameObject.activeInHierarchy then
        return false
    end
    return true
end

function BuildGameShowAddProgressPop:showAddProgressAndHideAni(buildObj)
    buildObj.progressText.color = Unity.Color(1,1,1,0)
    buildObj.progressText.text = "+"..self.m_addProgressInfo[BuildGameMainUIPop:getIndexFromStrType(buildObj.strType)]
    local id = LeanTween.value(0, 1, 0.5):setDelay(0.5):setOnUpdate(function(value)
        buildObj.progressText.color = Unity.Color(1,1,1,value)
    end):setOnComplete(function()
        local id1 = LeanTween.value(1, 0, 0.5):setDelay(1):setOnUpdate(function(value)
            buildObj.progressText.color = Unity.Color(1,1,1,value)
        end).id
        table.insert( self.m_mapLeanTweenIds, id1 )
    end).id
    table.insert( self.m_mapLeanTweenIds, id )
end

function BuildGameShowAddProgressPop:showUpdateProgressAni(buildShowObj)
    local startProgress = buildShowObj.progress
    local targetProgress = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][buildShowObj.strType].progress
    local id2 = LeanTween.value(startProgress, targetProgress, 1.6):setOnUpdate(function(value)
        buildShowObj.progress = math.floor( value )
        buildShowObj:refreshUI(value)
    end):setOnComplete(function()
        buildShowObj:refreshUI()
        --TODO 判断是否升级过，如果升级过显示房屋
        if buildShowObj.levelUpCount > 0 then
            local id4 = LeanTween.value(0, 1, 0.5):setOnUpdate(function(value)
                self.m_lightAni.alpha = value
            end).id
            table.insert( self.m_mapLeanTweenIds, id4 )
            if buildShowObj.level >= 5 then
                AudioHandler:PlayBuildGameSound("win")
            end
            self:showBuildAnimation(buildShowObj)
        else --如果没有升级过，刷新下一个BuildObj
            local id3 = LeanTween.scale(buildShowObj.gameObject,Unity.Vector3.zero,0.5):setDelay(1):setOnComplete(function()
                self:starAnimation()
            end).id
            table.insert( self.m_mapLeanTweenIds, id3 )
        end
    end).id
    table.insert( self.m_mapLeanTweenIds, id2 )
end

function BuildGameShowAddProgressPop:updateFullProgress(buildShowObj)
    local data = BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].build[buildShowObj.strType]
    local addFullProgree = (self.fullProgress/(BuildGameConfig.nLegendDepotExp))*100
    self.m_fullProgressText.text = math.floor( addFullProgree ).."%"
    self.m_fullProgressImg.fillAmount = addFullProgree/100

    local id1 = LeanTween.value(0,1,0.5):setOnUpdate(function ( value )
        if not self:checkIsActive() then
            return
        end
        self.m_fullContainer.alpha = value
    end):setOnComplete(function()
        self:showUpdateFullProgressAni(buildShowObj)
    end).id
    table.insert( self.m_mapLeanTweenIds, id1 )
end

function BuildGameShowAddProgressPop:showUpdateFullProgressAni(buildShowObj)
    local data = BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].build[buildShowObj.strType]
    local addFullProgree = (self.fullProgress/(BuildGameConfig.nLegendDepotExp))*100
    local targetProgress = (data.targetFullProgress/(BuildGameConfig.nLegendDepotExp))*100
    -- Debug.Log("------------init:"..addFullProgree.."---------------")
    -- Debug.Log("------------target:"..targetProgress.."---------------")
    if data.fullProgressCount > 0 then
        targetProgress = 100
    end
    local id3 = LeanTween.value(addFullProgree, targetProgress, 0.5):setOnUpdate(function(value)
        if not self:checkIsActive() then
            return
        end
        local progress = value
        self.m_fullProgressText.text = math.floor( progress ).."%"
        self.m_fullProgressImg.fillAmount = progress/100
    end):setOnComplete(function()
        if data.fullProgressCount > 0 then
            self.fullProgress = 0
            data.fullProgressCount = data.fullProgressCount - 1
            self.fullProgressCount = self.fullProgressCount + 1
            self:showUpdateFullProgressAni(buildShowObj)
        else
            self.fullProgress = data.targetFullProgress
            if self.fullProgressCount > 0 then
                BuildGameGetDepotsPop:createAndShow(BuildGameAllProbTable.DepotsType.Legendary,false,self.fullProgressCount)
                self.fullProgressCount = 0 
            end

            local id2 = LeanTween.value(1,0,0.5):setDelay(1.5):setOnUpdate(function( value )
                if not self:checkIsActive() then
                    return
                end
                self.m_fullContainer.alpha = value
            end):setOnComplete(function()
                local id3 = LeanTween.scale(buildShowObj.gameObject, Unity.Vector3.zero, 0.5):setDelay(1.5):setOnComplete(function()
                    if not self:checkIsActive() then
                        return
                    end
                    LuaHelper.removeElementFromArray(self.m_mapBuildShowObjects, buildShowObj)
                    Unity.Object.Destroy(buildShowObj.gameObject)
                    self:starAnimation()--重新回到star，判断已经完成动画，退出并更新数据
                end).id
                table.insert( self.m_mapLeanTweenIds, id3 )
            end).id
            table.insert( self.m_mapLeanTweenIds, id2 )

            for k,v in pairs(BuildGameDataHandler.m_runningData[BuildGameDataHandler.m_curSeason].build) do
                v.fullProgress = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].fullProgress
            end
        end
    end).id
    table.insert( self.m_mapLeanTweenIds, id3 )
end