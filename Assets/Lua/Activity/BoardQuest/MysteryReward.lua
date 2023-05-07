local MysteryReward = {}

MysteryReward.N_ITEM_COUNT = 5

function MysteryReward:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("MysteryReward")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    self.tableGoItem = LuaHelper.GetTableFindChild(self.transform, self.N_ITEM_COUNT, "Item")
    for i = 1, self.N_ITEM_COUNT do
        EventTriggerListener.Get(self.tableGoItem[i]).onClick = function()
            self:onClick(i)
        end
    end

    self.tableGoReward = {}
    local trReward = self.transform:FindDeepChild("Rewards")
    local tableRewardName = LuaHelper.GetKeyValueSwitchTable(BoardQuestConfig.MYSTERY_REWARD_ITEM)
    for i = 1, #tableRewardName do
        self.tableGoReward[i] = trReward:FindDeepChild(tableRewardName[i]).gameObject
    end
end

function MysteryReward:onClick(nItemIndex)
    if self.bInAnimation then return end
    self.bInAnimation = true
    local nRewardIndex = LuaHelper.GetIndexByRate(BoardQuestConfig.MYSTERY_REWARD_RATE)
    local tableRewardItem = {}
    for i = 1, self.N_ITEM_COUNT do
        tableRewardItem[i] = i
    end
    local nRewardType = nRewardIndex
    table.remove(tableRewardItem, nRewardIndex)
    tableRewardItem = LuaHelper.GetRandomTable(tableRewardItem)
    table.insert(tableRewardItem, nItemIndex, nRewardType)

    local nValue = BoardQuestConfig.MYSTERY_REWARD_VALUE[nRewardType]

    BoardQuestMainUIPop.MysteryRewardEnd.nRewardType = nRewardType

    if nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN1 
    or nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN2 
    or nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN3 then
        local nCoin = ActivityHelper:getBasePrize() * nValue
        PlayerHandler:AddCoin(nCoin)

        BoardQuestMainUIPop.MysteryRewardEnd.nCoin = nCoin
        BoardQuestMainUIPop.MysteryRewardEnd.nPlayerCoin = PlayerHandler.nGoldCount
    elseif nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.CANNON then
        local nTarget = BoardQuestDataHandler.data.nPosition
        local nTotal = 0
        local nItem = BoardQuestConfig.ROAD[BoardQuestDataHandler.data.nLevel][nTarget]
        for i = 1, 100 do
            local bFlag = nItem ~= BoardQuestConfig.ITEM.CANNON
            if BoardQuestDataHandler:checkInBoosterTime(BoardQuestIAPConfig.TYPE.MORE_CANNON) then
                bFlag = bFlag and nItem ~= BoardQuestConfig.ITEM.MORE_CANNON
            end
            if bFlag then
                nTotal = nTotal + 1
                nTarget = LuaHelper.Loop(nTarget + 1, 1, BoardQuestConfig.ROAD_ITEM_COUNT[BoardQuestDataHandler.data.nLevel])
                nItem = BoardQuestConfig.ROAD[BoardQuestDataHandler.data.nLevel][nTarget]
            else
                break
            end
        end
        BoardQuestMainUIPop.MysteryRewardEnd.nTotal = nTotal
    elseif nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.DICE then
        ActivityHelper:AddMsgCountData("nAction", nValue)
    end

    ActivityAudioHandler:PlaySound("board_chest_opens")
    ActivityHelper:PlayAni(self.tableGoItem[nItemIndex], "Open")
    LeanTween.delayedCall(0.7, function()
        local id = LeanTween.scale(self.tableGoItem[nItemIndex], Unity.Vector3.zero, 0.5).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id)
    end)
    LeanTween.delayedCall(1, function()
        local nRewardType = tableRewardItem[nItemIndex]
        self:openChest(nItemIndex, nItemIndex, nRewardType)
        LeanTween.delayedCall(0.3, function()
            ActivityAudioHandler:PlaySound("board_chest_opens_reveal")
        end)
        LeanTween.delayedCall(1.5, function() 
            for i = 1, 5 do
                if i ~= nItemIndex then
                    local id = LeanTween.scale(self.tableGoItem[i], Unity.Vector3.zero, 0.5).id
                    table.insert(ActivityHelper.m_LeanTweenIDs, id)
                end
            end
            LeanTween.delayedCall(0.5, function()
                -- LeanTween.delayedCall(0.3, function()
                --     ActivityAudioHandler:PlaySound("board_chest_opens_reveal")
                -- end)
                ActivityAudioHandler:PlaySound("board_chest_opens")
                for i = 1, self.N_ITEM_COUNT do
                    if i ~= nItemIndex then
                        local nRewardType = tableRewardItem[i]
                        self:openChest(i, nItemIndex, nRewardType)
                    end
                end
            end)
        end)
    end)

    LeanTween.delayedCall(5, function()
        self:hide()
        BoardQuestMainUIPop.MysteryRewardEnd:Show()
    end)
end

function MysteryReward:openChest(i, nItemIndex, nRewardType)
    local goReward = self.tableGoReward[nRewardType]
    goReward:SetActive(true)
    goReward.transform.localScale = Unity.Vector3.zero
       goReward.transform.position = self.tableGoItem[i].transform.position
    local go0 = ActivityHelper:FindDeepChild(goReward, "0")
    local go1 = ActivityHelper:FindDeepChild(goReward, "1")
    go0:SetActive(i ~= nItemIndex)
    go1:SetActive(i == nItemIndex)

    local strName
    if i == nItemIndex then
        strName = 1
    else
        strName = 0
    end
    local text = ActivityHelper:FindDeepChild(goReward, "text"..strName):GetComponent(typeof(TextMeshProUGUI))
    if nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN1 
    or nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN2 
    or nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN3 then
        local nCoin = ActivityHelper:getBasePrize() * BoardQuestConfig.MYSTERY_REWARD_VALUE[nRewardType]
        text.text = MoneyFormatHelper.numWithCommas(nCoin)
    elseif nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.CANNON then

    elseif nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.DICE then
        text.text = string.format("+%0.0f turns", BoardQuestConfig.MYSTERY_REWARD_VALUE[nRewardType])
    end

    local id = LeanTween.scale(goReward, Unity.Vector3.one, 0.5).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
end

function MysteryReward:Show()
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init()
    end
    self.bCanHide = true
    self.popController:show(nil, function()
        ActivityAudioHandler:PlaySound("board_mystery_book_pop")
        GlobalAudioHandler:LowerActiveBackgroundMusicVolume()
    end, true)

    for i = 1, self.N_ITEM_COUNT do
        self.tableGoItem[i]:SetActive(true)
        self.tableGoReward[i]:SetActive(false)
    end

    for i = 1, self.N_ITEM_COUNT do
        ActivityHelper:PlayAni(self.tableGoItem[i], "ClosedStatic")
        self.tableGoItem[i].transform.localScale = Unity.Vector3.one
    end

    self.bInAnimation = false
end

function MysteryReward:hide()
    ViewScaleAni:Hide(self.transform.gameObject)
    self.bInAnimation = false
end

return MysteryReward