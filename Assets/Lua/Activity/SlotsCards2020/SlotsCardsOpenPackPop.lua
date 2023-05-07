SlotsCardsOpenPackPop = {}
SlotsCardsOpenPackPop.m_trCardsContainer = nil
SlotsCardsOpenPackPop.cardItems = {}
SlotsCardsOpenPackPop.m_bIsShow = true
SlotsCardsOpenPackPop.m_sTriggerAni = Unity.Animator.StringToHash("ShowEffect")
SlotsCardsOpenPackPop.m_LeanTweenIDs = {}
SlotsCardsOpenPackPop.m_bIsSkip = false

local z = -1060
function SlotsCardsOpenPackPop:Show(params, nPackType)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("SlotsCardsOpenPackPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trCardsContainer = self.transform:FindDeepChild("CardContainer")
        self.m_posOriginTr = self.transform:FindDeepChild("CardProgressOriginPos").transform
        self.m_trThemeProgressContainer = self.transform:FindDeepChild("ThemeProgressContainer")
        self.m_mapThemeEntry = {}
        for i = 0, self.m_trThemeProgressContainer.childCount-1 do
            local child = self.m_trThemeProgressContainer:GetChild(i)
            local themeKey = child.gameObject.name
            self.m_mapThemeEntry[themeKey] = child
            self:UpdateThemeProgress(themeKey)
        end
        self.m_goFinishEffect = self.transform:FindDeepChild("FinishEffect").gameObject
        self.m_btnSkip = self.transform:FindDeepChild("BtnNext"):GetComponent(typeof(UnityUI.Button))
        self.m_textPackCount = self.transform:FindDeepChild("PackCount"):GetComponent(typeof(TextMeshProUGUI))
        self.m_goOpenPack = self.transform:FindDeepChild("OpenPackAni").gameObject
        self.m_goOpenPackAni = self.m_goOpenPack:GetComponent(typeof(Unity.Animator))
        self.m_starContainer = self.transform:FindDeepChild("StarFly")
    end

    self.m_goFinishEffect:SetActive(false)
    self.m_bIsSkip = false
    self.m_btnSkip.gameObject:SetActive(true)
    self.m_btnSkip.interactable = true
    self.m_textPackCount.text = "PACK ".."1/"..#params
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        SlotsCardsAudioHandler:PlaySound("stamp_pack_pop")
        self:initContent(params, nPackType)
    end)
end

function SlotsCardsOpenPackPop:initContent(params, nPackType)
    if #self.cardItems ~= 0 then
        for k,v in pairs(self.cardItems) do
            Unity.Object.Destroy(v.gameObject)
        end
        self.cardItems = {}
    end
    self.lastOne = nil
    self.length = 0 --用于计算位置

    self.tableAllFlyToBottomCardItem = {}
    self.params = params
    self.m_btnSkip.onClick:RemoveAllListeners()
    DelegateCache:addOnClickButton(self.m_btnSkip)
    self.m_btnSkip.onClick:AddListener(function()
        self:skipBtnClicked(self.params)
    end)
    self:OpenOnePackAni(self.params, nPackType, 1)
end

function SlotsCardsOpenPackPop:OpenOnePackAni(params, nPackType, nCurrentPack)
    if self.m_bIsSkip then
        return
    end
    local allPackCount = LuaHelper.tableSize(params)
    self.m_textPackCount.text = "PACK "..nCurrentPack.."/"..allPackCount
    SlotsCardsAudioHandler:PlaySound("open_pack")
    self.m_goOpenPackAni:SetInteger("nPlayMode", nPackType)
    
    local id = LeanTween.delayedCall(1.2, function()
        local data = params[nCurrentPack]
        local delay = 0
        local tableFlyToThemeKeyCardItem = {}
        local tableFlyToBottomCardItem = {}

        for k,v in pairs(data) do
            local count = #data --指这一行有几个
            local n = k --第几个
            local ratio = Unity.Screen.width / Unity.Screen.height
            if ratio > 1.7 then
                ratio = 1.7
            end

            local fx = self.m_btnSkip.transform.anchoredPosition.x - (6 - count) / 6 * self.m_btnSkip.transform.anchoredPosition.x - (n - 1) * 150 * ratio
            local targetPos = Unity.Vector3(fx, 0, 0) --计算卡牌位置
            local path = "Card.prefab"
            local prefab = AssetBundleHandler:LoadSlotsCardsAsset(path)
            local card = Unity.Object.Instantiate(prefab).transform
            card:SetParent(self.m_trCardsContainer)
            card.localScale = Unity.Vector3.one
            card.anchoredPosition3D = Unity.Vector3.zero
            card.localRotation = Unity.Quaternion.Euler(0,0,0)
            local cardItem = ShowCard:new(card.gameObject, SlotsCardsManager.album, v.themeKey, v.cardKey)
            cardItem.button.interactable = false
            local bflag = self:showMoveLocalFlyAni(cardItem, delay, targetPos, nil, nCurrentPack, k)
            if bflag then
                table.insert(tableFlyToThemeKeyCardItem, cardItem)
            else
                table.insert(tableFlyToBottomCardItem, cardItem)
            end
            table.insert(self.cardItems, cardItem)
            delay = delay + 0.02
        end
        local id = LeanTween.delayedCall(delay+2, function()
            local index = 0
            local delay = 0
            tableFlyToBottomCardItem = self:reverseTable(tableFlyToBottomCardItem)
            for k,v in pairs(tableFlyToBottomCardItem) do
                if self.length >= 60 then
                    self.length = 60
                end
                local targetPos = Unity.Vector3(self.m_posOriginTr.anchoredPosition.x + 20*self.length, self.m_posOriginTr.anchoredPosition.y, 0)
                index = index + 1
                self.length = self.length + 1
                delay = delay + index*0.05
                v.transform:SetAsLastSibling()
                self:showMoveLocalFlyAni(v, delay, targetPos, function()
                    if self.lastOne ~= nil then
                        self.lastOne.transform.localScale = Unity.Vector3.one*0.5
                        self.lastOne:showBackBG()
                    end
                    self.lastOne = v
                    self.lastOne.transform.localScale = Unity.Vector3.one*0.55
                end)
                table.insert(self.tableAllFlyToBottomCardItem, v)
            end
            self.m_goOpenPackAni:SetInteger("nPlayMode", 0)
            local id = LeanTween.delayedCall(delay, function()
                local toThemeKeyLength = LuaHelper.tableSize(tableFlyToThemeKeyCardItem)
                if toThemeKeyLength > 0 then
                    for k,v in pairs(tableFlyToThemeKeyCardItem) do
                        local themeKey = v.themeKey
                        if not self.m_mapThemeEntry[themeKey].gameObject.activeSelf then
                            self.m_mapThemeEntry[themeKey].gameObject:SetActive(true)
                        end
                    end
                    local id = LeanTween.delayedCall(0.3, function()
                        local mapThemeAni = {}
                        for k,v in pairs(tableFlyToThemeKeyCardItem) do
                            local themeKey = v.themeKey
                            local targetPos = self.m_mapThemeEntry[themeKey].position
                            self:showFromPackFlyAni(v, delay, targetPos)
                            local id = LeanTween.scale(v.gameObject, Unity.Vector3.zero, 0.5):setDelay(delay):setOnComplete(function()
                                -- 做动画Theme进度放大缩小爆粒子，且刷新UI
                                if not LuaHelper.tableContainsElement(mapThemeAni, self.m_mapThemeEntry[themeKey]) then
                                    local ani = self:FindGoElement(self.m_mapThemeEntry[themeKey], "EntryAni")
                                    ani:SetTrigger(self.m_sTriggerAni)
                                    table.insert(mapThemeAni, self.m_mapThemeEntry[themeKey])
                                end
                                self:DoProgressUpdateAni(themeKey)
                            end).id
                            table.insert( self.m_LeanTweenIDs, id )
                        end
                        local id = LeanTween.delayedCall(delay+1, function()
                            -- 缩小隐藏ThemeEntry
                            for k,v in pairs(mapThemeAni) do
                                local ani = self:FindGoElement(v, "EntryAni")
                                self:SetInteger(ani, "nPlayMode", 1)
                            end
                            local id = LeanTween.delayedCall(0.5, function()
                                for k,v in pairs(mapThemeAni) do
                                    local ani = self:FindGoElement(v, "EntryAni")
                                    self:SetInteger(ani, "nPlayMode", 0)
                                    v.gameObject:SetActive(false)
                                end
                                tableFlyToThemeKeyCardItem = nil
                                mapThemeAni = nil

                                nCurrentPack = nCurrentPack + 1
                                if nCurrentPack <= allPackCount then
                                    local id1 = LeanTween.delayedCall(1, function()
                                        self:OpenOnePackAni(params, nPackType, nCurrentPack)
                                    end).id
                                    table.insert( self.m_LeanTweenIDs, id1 )
                                else
                                    self.m_btnSkip.interactable = false
                                    self:ShowOpenPackEndAni()
                                end
                            end).id
                            table.insert( self.m_LeanTweenIDs, id )
                        end).id
                        table.insert( self.m_LeanTweenIDs, id )
                    end).id
                    table.insert( self.m_LeanTweenIDs, id )
                else
                    nCurrentPack = nCurrentPack + 1
                    if nCurrentPack <= allPackCount then
                        local id1 = LeanTween.delayedCall(1, function()
                            self:OpenOnePackAni(params, nPackType, nCurrentPack)
                        end).id
                        table.insert( self.m_LeanTweenIDs, id1 )
                    else
                        self.m_btnSkip.interactable = false
                        self:ShowOpenPackEndAni()
                    end
                end
            end).id
            table.insert( self.m_LeanTweenIDs, id )
        end).id
        table.insert( self.m_LeanTweenIDs, id )
    end).id
    table.insert( self.m_LeanTweenIDs, id )
end

function SlotsCardsOpenPackPop:ShowOpenPackEndAni()
    if self.m_bIsSkip then
        return
    end
    self.m_btnSkip.interactable = false
    local co = StartCoroutine(function()
        local cardsLength = LuaHelper.tableSize(self.tableAllFlyToBottomCardItem)
        for i = cardsLength-1, 1, -1 do
            if i > 60 then
                self.tableAllFlyToBottomCardItem[i].gameObject:SetActive(false)
                table.remove( self.tableAllFlyToBottomCardItem, i )
            end
        end
        local cardsLength = LuaHelper.tableSize(self.tableAllFlyToBottomCardItem)
        if cardsLength > 0 then
            yield_return(Unity.WaitForSeconds(1.5))
            local moveTime = cardsLength*0.05
            if moveTime > 0.5 then
                moveTime = 0.5
            end
            LeanTween.move(self.tableAllFlyToBottomCardItem[cardsLength].gameObject, self.tableAllFlyToBottomCardItem[1].transform.position, moveTime):setEase(LeanTweenType.easeInOutCubic):setOnUpdate(function()
                for i = 1, cardsLength - 1  do
                    if self.tableAllFlyToBottomCardItem[i].transform.position.x >= self.tableAllFlyToBottomCardItem[cardsLength].transform.position.x then
                        self.tableAllFlyToBottomCardItem[i].gameObject:SetActive(false)
                    end
                end
            end):setOnComplete(function()
                LeanTween.scale(self.tableAllFlyToBottomCardItem[cardsLength].gameObject, Unity.Vector3.one*0.45, 0.1):setOnComplete(function()
                    LeanTween.scale(self.tableAllFlyToBottomCardItem[cardsLength].gameObject, Unity.Vector3.one*0.6, 0.2):setOnComplete(function()
                        self.tableAllFlyToBottomCardItem[cardsLength].gameObject:SetActive(false)
                    end)
                end)
                SlotsCardsAudioHandler:PlaySound("turn_stars")
                self.m_goFinishEffect:SetActive(true)
                self:ShowStarFly()
            end)
        else
            self:Hide()
        end
    end)
end

function SlotsCardsOpenPackPop:SetInteger(ani, strKey, nAction)
    if ani.gameObject.activeInHierarchy then
        if ani:GetInteger(strKey) ~= nAction then
            ani:SetInteger(strKey, nAction)
        end
    end
end

function SlotsCardsOpenPackPop:DoProgressUpdateAni(themeKey)
    local strCurAlbumKey = SlotsCardsManager.album
    local collectText = self:FindGoElement(self.m_mapThemeEntry[themeKey].gameObject, "CollectText")
    SlotsCardsHandler:updateCurrentThemeProgress(themeKey)
    local runningData = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].dicThemeProgress
    local progress = runningData[themeKey]
    collectText.text = progress .."/".. #SlotsCardsConfig[strCurAlbumKey][1].ThemeCards
    local progressImg = self:FindGoElement(self.m_mapThemeEntry[themeKey].gameObject, "ProgressBar")
    local id = LeanTween.value(progressImg.sizeDelta.x,(progress/#SlotsCardsConfig[strCurAlbumKey][1].ThemeCards)*160, 0.3):setOnUpdate(function(value)
        progressImg.sizeDelta = Unity.Vector2(value, 30)
    end).id
    table.insert( self.m_LeanTweenIDs, id )
end

function SlotsCardsOpenPackPop:reverseTable(tab)
	local tmp = {}
	for i = 1, #tab do
		local key = #tab
		tmp[i] = table.remove(tab)
	end

	return tmp
end

function SlotsCardsOpenPackPop:UpdateThemeProgress(themeKey)
    local strCurAlbumKey = SlotsCardsManager.album
    local collectText = self:FindGoElement(self.m_mapThemeEntry[themeKey].gameObject, "CollectText")
    local progress = SlotsCardsHandler.data.activityData[strCurAlbumKey].dicThemeProgress[themeKey]
    collectText.text = progress .."/".. #SlotsCardsConfig[strCurAlbumKey][1].ThemeCards
    local progressImg = self:FindGoElement(self.m_mapThemeEntry[themeKey].gameObject, "ProgressBar")
    progressImg.sizeDelta = Unity.Vector2((progress/#SlotsCardsConfig[strCurAlbumKey][1].ThemeCards)*160, 30)
end

function SlotsCardsOpenPackPop:Hide()
    self.params = nil
    ViewScaleAni:Hide(self.transform.gameObject)
    SlotsCardsMainUIPop:refresh()
    SlotsCardsHandler:checkThemeEnd()
end

function SlotsCardsOpenPackPop:skipBtnClicked(params)
    local allPackCount = LuaHelper.tableSize(params)
    self.m_textPackCount.text = "PACK "..allPackCount.."/"..allPackCount
    for k,v in pairs(self.m_mapThemeEntry) do
        local ani = self:FindGoElement(v, "EntryAni")
        self:SetInteger(ani, "nPlayMode", 0)
    end

    self.m_bIsSkip = true
    self.m_btnSkip.gameObject:SetActive(false)
    self.m_btnSkip.interactable = false
    SlotsCardsAudioHandler:PlaySound("click")
    self:CancelLeanTween()
    if #self.cardItems ~= 0 then
        for k,v in pairs(self.cardItems) do
            Unity.Object.Destroy(v.gameObject)
        end
        self.cardItems = {}
    end

    StartCoroutine(function()
        local length = 0 --用于计算位置
        local nMaxLength = 60 --点击skip显示最多的卡牌数
        local tableFlyToThemeKey = {}
        for i = 1, LuaHelper.tableSize(params) do
            local data = params[i]
            local cardCount = #data
            local tableFlyToBottomCardItem = {}

            for k,v in pairs(data) do
                local cardRunningInfo = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo[v.cardKey]
                if v.bIsNew then
                    table.insert(tableFlyToThemeKey, v.themeKey)
                else
                    if cardRunningInfo.cardCount < 1 then
                        table.insert(tableFlyToThemeKey, v.themeKey)
                    else
                        table.insert(tableFlyToBottomCardItem, {themeKey = v.themeKey, cardKey = v.cardKey})
                    end
                end
                cardRunningInfo.cardCount = SlotsCardsHandler.data.activityData[v.cardKey].count
            end
            
            for k,v in pairs(tableFlyToBottomCardItem) do
                if length >= nMaxLength then
                    break
                end
                local path = "Card.prefab"
                local prefab = AssetBundleHandler:LoadSlotsCardsAsset(path)
                local card = Unity.Object.Instantiate(prefab).transform

                card:SetParent(self.m_trCardsContainer)
                card.localScale = Unity.Vector3.one*0.5
                card.anchoredPosition3D = Unity.Vector3(self.m_posOriginTr.anchoredPosition.x + 20*length, self.m_posOriginTr.anchoredPosition.y, 0)
                local cardItem = ShowCard:new(card.gameObject, SlotsCardsManager.album, v.themeKey, v.cardKey)
                table.insert(self.cardItems, cardItem)
                length = length + 1
            end
        end

        local toThemeKeyLength = LuaHelper.tableSize(tableFlyToThemeKey)
        if toThemeKeyLength > 0 then
            SlotsCardsHandler:updateThemeProgress()
            SlotsCardsMainUIPop:refresh()
            for k,v in pairs(tableFlyToThemeKey) do
                self:UpdateThemeProgress(v)
                if not self.m_mapThemeEntry[v].gameObject.activeSelf then
                    self.m_mapThemeEntry[v].gameObject:SetActive(true)
                end
            end
        end
        local cardsLength = LuaHelper.tableSize(self.cardItems)
        if cardsLength > 0 then
            if cardsLength > 1 then
                for i = 1, cardsLength-1 do
                    local cardItem = self.cardItems[i]
                    cardItem:showBackBG()
                end
            end
            self.cardItems[cardsLength].transform.localScale = Unity.Vector3.one*0.55
        end
        yield_return(Unity.WaitForSeconds(1.5))
        for k,v in pairs(tableFlyToThemeKey) do
            self.m_mapThemeEntry[v].gameObject:SetActive(false)
        end
        if cardsLength > 0 then
            local moveTime = cardsLength*0.05
            if moveTime > 0.5 then
                moveTime = 0.5
            end
            LeanTween.move(self.cardItems[cardsLength].gameObject, self.cardItems[1].transform.position, moveTime):setEase(LeanTweenType.easeInOutCubic):setOnUpdate(function()
                for i = 1, cardsLength - 1  do
                    if self.cardItems[i].transform.position.x >= self.cardItems[cardsLength].transform.position.x then
                        self.cardItems[i].gameObject:SetActive(false)
                    end
                end
            end):setOnComplete(function()
                LeanTween.scale(self.cardItems[cardsLength].gameObject, Unity.Vector3.one*0.45, 0.1):setOnComplete(function()
                    LeanTween.scale(self.cardItems[cardsLength].gameObject, Unity.Vector3.one*0.6, 0.2):setOnComplete(function()
                        self.cardItems[cardsLength].gameObject:SetActive(false)
                    end)
                end)
                SlotsCardsAudioHandler:PlaySound("turn_stars")
                self.m_goFinishEffect:SetActive(true)
                self:ShowStarFly()
            end)
        else
            self:Hide()
        end
    end)

end

-- 卡牌进入主题进度增加
function SlotsCardsOpenPackPop:showFromPackFlyAni(cardItem, delay, to, fun, nCurrentPack, nCurrentCard)
    local id = LeanTween.delayedCall(delay,function()
        if cardItem.gameObject ~= nil and cardItem.gameObject.activeInHierarchy then
            SlotsCardsAudioHandler:PlaySound("card_fly")
            if fun ~= nil then
                local id = LeanTween.scale(cardItem.gameObject, Unity.Vector3.one * 0.5, 0.5).id
                table.insert(self.m_LeanTweenIDs, id)
                local effectGo = self:FindGoElement(cardItem.gameObject, "lanliz")
                effectGo:SetActive(true)
                local id1 = LeanTween.delayedCall(1, function()
                    if cardItem.gameObject ~= nil then
                        effectGo:SetActive(false)
                    end
                end).id
                table.insert(self.m_LeanTweenIDs, id1)
            end
            local id1 = LeanTween.move(cardItem.gameObject, to, 0.5):setEase(LeanTweenType.easeInOutQuad):setOnComplete(function()
                if cardItem.gameObject ~= nil and cardItem.gameObject.activeInHierarchy then
                    if fun ~= nil then
                        fun()
                    else
                        local cardRunningInfo = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo[cardItem.cardKey]
                        if cardRunningInfo.cardCount < 1 then
                            cardItem.goNew:SetActive(true)
                            cardItem.goNew.transform.localScale = Unity.Vector3.one*1.4
                            local id = LeanTween.alpha(cardItem.goNew.transform, 1, 0.5).id
                            local id1 = LeanTween.scale(cardItem.goNew,Unity.Vector3.one, 0.5).id
                            table.insert(self.m_LeanTweenIDs, id)
                            table.insert(self.m_LeanTweenIDs, id1)
                            self.params[nCurrentPack][nCurrentCard].bIsNew = true
                        end
                        cardRunningInfo.cardCount = SlotsCardsHandler.data.activityData[cardItem.cardKey].count
                    end
                end
            end).id
            table.insert(self.m_LeanTweenIDs, id1)
        end
    end).id
    table.insert(self.m_LeanTweenIDs, id)
    if SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo[cardItem.cardKey].cardCount < 1 then
       return true
    end
    return false
end

function SlotsCardsOpenPackPop:showMoveLocalFlyAni(cardItem, delay, to, fun, nCurrentPack, nCurrentCard)
    local id = LeanTween.delayedCall(delay,function()
        if cardItem.gameObject ~= nil and cardItem.gameObject.activeInHierarchy then
            SlotsCardsAudioHandler:PlaySound("card_fly")
            if fun ~= nil then
                local id = LeanTween.scale(cardItem.gameObject, Unity.Vector3.one * 0.5, 0.5).id
                table.insert(self.m_LeanTweenIDs, id)
                local effectGo = self:FindGoElement(cardItem.gameObject, "lanliz")
                effectGo:SetActive(true)
                local id1 = LeanTween.delayedCall(1, function()
                    if cardItem.gameObject ~= nil then
                        effectGo:SetActive(false)
                    end
                end).id
                table.insert(self.m_LeanTweenIDs, id1)
            end
            local id1 = LeanTween.moveLocal(cardItem.gameObject, to, 0.5):setEase(LeanTweenType.easeInOutQuad):setOnComplete(function()
                if cardItem.gameObject ~= nil and cardItem.gameObject.activeInHierarchy then
                    if fun ~= nil then
                        fun()
                    else
                        local cardRunningInfo = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo[cardItem.cardKey]
                        if cardRunningInfo.cardCount < 1 then
                            cardItem.goNew:SetActive(true)
                            cardItem.goNew.transform.localScale = Unity.Vector3.one*1.4
                            local id = LeanTween.alpha(cardItem.goNew.transform, 1, 0.5).id
                            local id1 = LeanTween.scale(cardItem.goNew,Unity.Vector3.one, 0.5).id
                            table.insert(self.m_LeanTweenIDs, id)
                            table.insert(self.m_LeanTweenIDs, id1)
                            self.params[nCurrentPack][nCurrentCard].bIsNew = true
                        end
                        cardRunningInfo.cardCount = SlotsCardsHandler.data.activityData[cardItem.cardKey].count
                    end
                end
            end).id
            table.insert(self.m_LeanTweenIDs, id1)
        end
    end).id
    table.insert(self.m_LeanTweenIDs, id)
    if SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo[cardItem.cardKey].cardCount < 1 then
       return true
    end
    return false
end

function SlotsCardsOpenPackPop:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function SlotsCardsOpenPackPop:FindGoElement(goSymbol, strKey, bSelf)
    if not GameConfig.RELEASE_VERSION then
        local tablePoolKey = { "CollectText", "ProgressBar", "EntryAni", "lanliz"}
        Debug.Assert(LuaHelper.tableContainsElement(tablePoolKey, strKey))
    end

    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end     

    if self.goSymbolElementPool[goSymbol][strKey] == nil then
        local goTran = nil
        if bSelf then
            goTran = goSymbol.transform
        else
            goTran = goSymbol.transform:FindDeepChild(strKey)
        end

        if goTran then
            local go = goTran.gameObject

            if strKey == "CollectText" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshProUGUI))
            elseif strKey == "ProgressBar" then
                self.goSymbolElementPool[goSymbol][strKey] = go.transform--:GetComponent(typeof(UnityUI.Image))
            elseif strKey == "EntryAni" then
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(Unity.Animator))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end

    end     
    
    return self.goSymbolElementPool[goSymbol][strKey]
end

function SlotsCardsOpenPackPop:ShowStarFly()
    local pos = self.m_goFinishEffect.transform.position
    local targetPos = SlotsCardsMainUIPop.starShopBtn.transform.position
    local delay = 0.5
    for i=0,self.m_starContainer.childCount-1 do
        local star = self.m_starContainer:GetChild(i)
        star.position = pos
        star.anchoredPosition3D = Unity.Vector3.zero
        star.localScale = Unity.Vector3.zero
        LeanTween.delayedCall(delay, function()
            LeanTween.scale(star.gameObject, Unity.Vector3.one*0.5, 0.5):setOnComplete(function()
                LeanTween.scale(star.gameObject, Unity.Vector3.zero, 0.5)
            end)
            local tempPos1 = Unity.Vector3(pos.x+40, pos.y+40, z)
            local tempPos2 = Unity.Vector3(pos.x+90, pos.y+90, z)
            local tempPos3= Unity.Vector3(targetPos.x - pos.x, targetPos.y - pos.y, z)
            local path = CS.System.Array.CreateInstance(typeof(Unity.Vector3), 4)
            path:SetValue (tempPos1, 0)
            path:SetValue (tempPos2, 1)
            path:SetValue (tempPos3, 2)
            path:SetValue (targetPos, 3)
            SlotsCardsAudioHandler:PlaySound("card_fly")
            LeanTween.move(star.gameObject, path, 1):setEase(LeanTweenType.easeInOutQuad)
        end)
        delay = delay + 0.05
    end
    LeanTween.delayedCall(delay+1, function()
        SlotsCardsMainUIPop:DoStarCountUpdateAni()
        self:Hide()
    end)
end