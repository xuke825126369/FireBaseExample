

BoardQuestMainUIPop = {}



function BoardQuestMainUIPop:Show()
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then
        return
    end
    if GameConfig.PLATFORM_EDITOR then
        ActivityBundleHandler:asynLoadAssetBundle()
        self:Show()
    else
        if self.asynLoadCo == nil then
            self.asynLoadCo = StartCoroutine(function()
                Scene.loadingAssetBundle:SetActive(true)
                Debug.Log("-------BoardQuest begin Loaded---------")
                ActivityBundleHandler:asynLoadAssetBundle()
                local isReady = BoardQuestUnloadedUI.m_bAssetReady
                while (not isReady) do
                    yield_return(0)
                end
                Scene.loadingAssetBundle:SetActive(false)
                self:Show()
                self.asynLoadCo = nil
            end)
        end
    end
end

function BoardQuestMainUIPop:Show()
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end

    if not self.m_bInitFlag then
        self:Init()
    end

    ViewScaleAni:Show(self.transform.gameObject)
    GlobalAudioHandler:PlayActiveBackgroundMusic("board_music")

    if not SlotsCardsManager:orActivityOpen() then
        for i = 1, BoardQuestConfig.N_MAX_LEVEL do
            for j = 1, #BoardQuestConfig.ROAD[i] do
                if BoardQuestConfig.ROAD[i][j] == BoardQuestConfig.ITEM.CARD then
                    BoardQuestConfig.ROAD[i][j] = BoardQuestConfig.ITEM.NONE
                end
            end
        end
    end

    self:setLevel(BoardQuestDataHandler.data.nLevel)
    self:setInAnimation(false)

    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    EventHandler:AddListener(self, "onActiveTimeChanged")
    EventHandler:AddListener(self, "onActiveTimesUp")
    EventHandler:AddListener(self, "onFetchAvatarNotifictation")
    EventHandler:AddListener(self, "onFBConnectChangedNotifictation")

    self:updateFBAvatar()
    EventHandler:Brocast("onActiveShow")
end

function BoardQuestMainUIPop:Init()
    self.AttackWheel = require("Lua.Activity.BoardQuest.AttackWheel")
    self.MysteryReward = require("Lua.Activity.BoardQuest.MysteryReward")
    self.MysteryRewardEnd = require("Lua.Activity.BoardQuest.MysteryRewardEnd")
    self.LevelPrize = require("Lua.Activity.BoardQuest.LevelPrize")
    self.FinalPrize = require("Lua.Activity.BoardQuest.FinalPrize")
    self.Introduce = require("Lua.Activity.BoardQuest.Introduce")
    self.Store = require("Lua.Activity.BoardQuest.Store")
    self.FireAgain = require("Lua.Activity.BoardQuest.FireAgain")
    self.Dice = require("Lua.Activity.BoardQuest.Dice")
    self.RewardCoinOnBoard = require("Lua.Activity.BoardQuest.RewardCoinOnBoard")
    self.RewardCardPackOnBoard = require("Lua.Activity.BoardQuest.RewardCardPackOnBoard")
    --unloadAssetBundle用来销毁游戏物体
    self.tableUI = {
        self.AttackWheel,
        self.MysteryReward,
        self.MysteryRewardEnd,
        self.LevelPrize,
        self.FinalPrize,
        self.Introduce,
        self.Store,
        self.Dice,
        self.RewardCoinOnBoard,
        self.RewardCardPackOnBoard,
        self
    }

    self.CannonTime = require("Lua.Activity.BoardQuest.CannonTime")
    
    self.m_bInitFlag = true
    local prefabObj = AssetBundleHandler:LoadActivityAsset("BoardQuestMainUIPop")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    -- if GameConfig.IS_GREATER_169 then
    --     self.popController.adapterContainer.localScale = Unity.Vector3.one * 0.9
    -- end

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bInAnimation then return end
        ActivityAudioHandler:PlaySound("board_button")
        self:hide()
    end)

    self.trLevels = self.transform:FindDeepChild("Levels")
    self.trBg = self.transform:FindDeepChild("Bg")
    self.trPrefabPool = self.transform:FindDeepChild("PrefabPool")

    --Action次数
    self.trAction = self.transform:FindDeepChild("Action")
    self.textAction = self.transform:FindDeepChild("textAction"):GetComponent(typeof(TextMeshProUGUI))
    ActivityHelper:addDataObserver("nAction", self, function(self, nAction)
        self.textAction.text = tostring(nAction)
    end)

    self.trCharacter = self.transform:FindDeepChild("Character")
    self.goCharacter = self.trCharacter.gameObject

    self.goDefaultAvatar = self.trCharacter:FindDeepChild("DefaultAvatar").gameObject
    self.goFBAvatar = self.trCharacter:FindDeepChild("FBAvatar").gameObject
    self.goDefaultAvatar:SetActive(true)
    self.goFBAvatar:SetActive(false)
    self.spriteAvatar = self.goFBAvatar:GetComponent(typeof(Unity.SpriteRenderer))

    self.btnRoll = self.transform:FindDeepChild("btnRoll"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnRoll)
    self.btnRoll.onClick:AddListener(function()
        if self.bInAnimation then return end
        ActivityAudioHandler:PlaySound("board_button")
        self:roll()
    end)

    local btnIntroduce = self.transform:FindDeepChild("btnIntroduce"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnIntroduce)
    btnIntroduce.onClick:AddListener(function()
        if self.bInAnimation then return end
        ActivityAudioHandler:PlaySound("board_button")
        self.Introduce:Show()
    end)
    --商店
    self.tableTextBooster = {}
    for i = 1, 3 do
        local goBtn = self.transform:FindDeepChild("btn"..BoardQuestIAPConfig.TYPE_NAME[i]).gameObject
        EventTriggerListener.Get(goBtn).onClick = function()
            if self.bInAnimation then return end
            ActivityAudioHandler:PlaySound("board_button")
            self.Store:Show()
        end
        self.tableTextBooster[i] = self.transform:FindDeepChild("text"..BoardQuestIAPConfig.TYPE_NAME[i]):GetComponent(typeof(TextMeshProUGUI))
    end

    local goLevelPrize = self.transform:FindDeepChild("LevelPrize").gameObject
    local btnLevelPrize = goLevelPrize.transform:FindDeepChild("btnLevelPrize"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnLevelPrize)
    self.bLevelPrizeShowState = false
    btnLevelPrize.onClick:AddListener(function()
        if self.bInAnimation then return end
        ActivityAudioHandler:PlaySound("board_button")
        self.bLevelPrizeShowState = not self.bLevelPrizeShowState
        if self.bLevelPrizeShowState then
            ActivityHelper:PlayAni(goLevelPrize, "Down")
        else
            ActivityHelper:PlayAni(goLevelPrize, "Up")
        end
    end)

    local trLevelsPrize= self.transform:FindDeepChild("LevelPrize")
    self.tableTrLevelPrize = LuaHelper.GetTableFindChild(trLevelsPrize, BoardQuestConfig.N_MAX_LEVEL, nil, Unity.Transform)
    self.tableGoLevelPrizeShadow = {}
    self.tableGoLevelPrizeUnfinished = {}
    self.tableGoLevelPrizeFinished = {}
    self.tableTextLevelPrizeReward = {}
    for i = 1, 5 do
        self.tableGoLevelPrizeShadow[i] = self.tableTrLevelPrize[i]:FindDeepChild("Shadow").gameObject
        self.tableGoLevelPrizeUnfinished[i] = self.tableTrLevelPrize[i]:FindDeepChild("Unfinished").gameObject
        self.tableGoLevelPrizeFinished[i] = self.tableTrLevelPrize[i]:FindDeepChild("Finished").gameObject
        self.tableTextLevelPrizeReward[i] = self.tableTrLevelPrize[i]:FindDeepChild("textReward"):GetComponent(typeof(UnityUI.Text))
    end
    
    self.textBoardReward = self.transform:FindDeepChild("textBoardReward"):GetComponent(typeof(TextMeshProUGUI))
    self.textFinalePrize = self.transform:FindDeepChild("textFinalPrize"):GetComponent(typeof(TextMeshProUGUI))
    self.textDate = self.transform:FindDeepChild("textDate"):GetComponent(typeof(TextMeshProUGUI))

    self.tableCannonTime = {}

    self.tableGoItem = {} --格子上的物品

    local strPath1 = "Assets/ActiveNeedLoad/BoardQuest/res/plot.png"
    local strPath2 = "Assets/ActiveNeedLoad/BoardQuest/res/plot_2.png"

    self.spriteGrayBlock = ActivityBundleHandler:loadAssetFromLoadedBundle(strPath1 ,typeof(Unity.Sprite)) 
    self.spriteLightBlock = ActivityBundleHandler:loadAssetFromLoadedBundle(strPath2 ,typeof(Unity.Sprite)) 
end

function BoardQuestMainUIPop:hide()
    EventHandler:Brocast("onActiveHide")
    self.transform.gameObject:SetActive(false)
    NotificationHandler:removeObserver(self)
end

function BoardQuestMainUIPop:updateBoosterTime(nowSecond)
    for i = 1, 3 do
        if BoardQuestDataHandler.data.tableNBoosterEndTime[i] > 0 then
            local time = BoardQuestDataHandler.data.tableNBoosterEndTime[i] - nowSecond
            if time <= 0 then
                BoardQuestDataHandler.data.tableNBoosterEndTime[i] = 0
                if i == BoardQuestIAPConfig.TYPE.MORE_CANNON then
                    local nLevel = BoardQuestDataHandler.data.nLevel
                    local trItemParent = self.goItems.transform:FindDeepChild("Items")
                    for i = 1, #BoardQuestConfig.ROAD[nLevel] do
                        local nItem = BoardQuestConfig.ROAD[nLevel][i]
                        if nItem == BoardQuestConfig.ITEM.MORE_CANNON then
                            if self.tableGoItem[i] then
                                local go = self.tableGoItem[i]
                                ActivityBundleHandler:RecycleObjectToPool(self.tableCannonTime[go].transform.gameObject) 
                                self.tableCannonTime[go] = nil
                                ActivityBundleHandler:RecycleObjectToPool(go)
                                self.tableGoItem[i] = nil
                            end
                        end
                    end
                end
            else
                local days = time // (3600*24)
                local hours = time // 3600 - 24 * days
                local minutes = time // 60 - 24 * days * 60 - 60 * hours
                local seconds = time % 60
                local str = string.format("%02d:%02d:%02d", hours, minutes, seconds)

                self.tableTextBooster[i].text = str
                if i == BoardQuestIAPConfig.TYPE.MORE_CANNON then
                    local minutes = time // 60 - 24 * days * 60 + 60 * hours
                    for k, v in pairs(self.tableCannonTime) do
                        v.textTime.text = string.format("%02d:%02d", minutes, seconds)
                    end
                end
            end
        else
            local str = string.format("%02d:%02d:%02d", 0, 0, 0)
            self.tableTextBooster[i].text = str
        end
    end
end

function BoardQuestMainUIPop:setLevel(nLevel)
    self.textBoardReward.text = string.format("Board Reward %d/%d", nLevel, BoardQuestConfig.N_MAX_LEVEL)
    
    local nPrize = BoardQuestDataHandler:getFinalPrizePrize()
    
    self.textFinalePrize.text = MoneyFormatHelper.numWithCommas(nPrize)

    for i = 1, BoardQuestConfig.N_MAX_LEVEL do
        self.tableGoLevelPrizeShadow[i]:SetActive(i ~= nLevel)
        self.tableGoLevelPrizeUnfinished[i]:SetActive(i >= nLevel)
        self.tableGoLevelPrizeFinished[i]:SetActive(i < nLevel)
        if i >= nLevel then
            self.tableTextLevelPrizeReward[i].text = MoneyFormatHelper.coinCountOmit(BoardQuestDataHandler:getLevelPrize(i))
        end
    end
    self.tableTrLevelPrize[nLevel]:SetAsLastSibling()
    --背景
    if self.goBg then
        Unity.Object.Destroy(self.goBg)
    end
    local prefab = AssetBundleHandler:LoadActivityAsset(string.format("Prefab/BG%s", nLevel))
    local go = Unity.Object.Instantiate(prefab, self.trBg)
    self.goBg = go
    local tr = go.transform
    --tr:SetParent(self.trBg)
    tr.localScale = Unity.Vector3.one
    tr.localPosition = Unity.Vector3.zero
    --关卡
    if self.goItems then
        Unity.Object.Destroy(self.goItems)
    end
    local prefab = AssetBundleHandler:LoadActivityAsset(string.format("Prefab/Level%s", nLevel))
    local go = Unity.Object.Instantiate(prefab)
    self.goItems = go
    local tr = go.transform
    tr:SetParent(self.trLevels)
    tr.localScale = Unity.Vector3.one
    tr.localPosition = Unity.Vector3.zero
    self.trItemParent = tr:FindDeepChild("Items")
    --格子上的物体
    for k, v in pairs(self.tableGoItem) do
        ActivityBundleHandler:RecycleObjectToPool(v)
    end
    self.tableGoItem = {}
    --格子
    self.tableGoBlock = LuaHelper.GetTableFindChild(tr, BoardQuestConfig.ROAD_ITEM_COUNT[nLevel])
    self.tableSpriteBlock = {}
    for i = 1, #BoardQuestConfig.ROAD[nLevel] do
        self.tableSpriteBlock[i] = self.tableGoBlock[i]:GetComponent(typeof(Unity.SpriteRenderer))
        Debug.Assert(self.tableSpriteBlock[i], i)
        self.tableSpriteBlock[i].sprite = self.spriteGrayBlock
        local nItem = BoardQuestConfig.ROAD[nLevel][i]
        if nItem == BoardQuestConfig.ITEM.MORE_CANNON then
            if BoardQuestDataHandler:checkInBoosterTime(BoardQuestIAPConfig.TYPE.MORE_CANNON) then
                nItem = BoardQuestConfig.ITEM.CANNON
            else
                nItem = BoardQuestConfig.ITEM.NONE
            end
        end
        if nItem ~= BoardQuestConfig.ITEM.NONE then
            local strItemName = BoardQuestConfig.ITEM_KEY[nItem]
            if nItem == BoardQuestConfig.ITEM.CANNON then
                local nRoadWidth = BoardQuestConfig.ROAD_ITEM_COUNT[nLevel] / 4
                local nCannonType = math.floor((i - 1)/nRoadWidth) + 1
                strItemName = strItemName..nCannonType
            end
            local go = ActivityBundleHandler:GetObjectFromPool("Prefab/"..strItemName, self.trItemParent)
            local tr = go.transform
            tr.position = self.tableGoBlock[i].transform.position
            local v3 = tr.localPosition
            v3.z = 0
            tr.localPosition = v3
            tr.localScale = Unity.Vector3.one
            go:SetActive(true)
            self.tableGoItem[i] = go

            if nItem == BoardQuestConfig.ITEM.CARD then
                local cardPack = CardPackUI:new(go)
                local nCardPackType = BoardQuestConfig.ROAD_CARD_PACK_TYPE[nLevel]
                cardPack:set(nCardPackType)
            end

            if BoardQuestConfig.ROAD[nLevel][i] == BoardQuestConfig.ITEM.MORE_CANNON then
                if BoardQuestDataHandler:checkInBoosterTime(BoardQuestIAPConfig.TYPE.MORE_CANNON) then
                    self.tableCannonTime[go] = self.CannonTime:new(go)
                end
            end
        end
    end
    --怪物
    self.goMonster = tr:FindDeepChild("Monster").gameObject
    self.textHp = tr:FindDeepChild("textHp"):GetComponent(typeof(TextMeshProUGUI))
    self.imgMaskHp = tr:FindDeepChild("imgMaskHp"):GetComponent(typeof(UnityUI.Image))
    self.imgHp = tr:FindDeepChild("imgHp"):GetComponent(typeof(UnityUI.Image))
    self:setMonsterSpineAnimation()

    local nMaxHp = BoardQuestConfig.MONSTER_HP[BoardQuestDataHandler.data.nLevel]
    local fRatio = BoardQuestDataHandler.data.nMonsterHp / nMaxHp
    self.textHp.text = math.floor(fRatio * 100).."%"
    self.imgMaskHp.fillAmount = fRatio

    self.tableFMonsterStageRatio = {0.66, 0.33, 0}
    self.tableHpBarColor = {Unity.Color(9/255, 1, 0, 1), Unity.Color(1, 1, 1, 1), Unity.Color(1, 90/255, 90/255, 1)}

    for i = 1, 3 do
        if fRatio >= self.tableFMonsterStageRatio[i] then
            self.imgHp.color = self.tableHpBarColor[i]
            break
        end
    end

    --角色
    self.trCharacter.position = self.tableGoBlock[BoardQuestDataHandler.data.nPosition].transform.position
    self.trCharacter:SetParent(tr)
    self.trCharacter:SetParent(self.transform)
    local trRoad = tr:FindDeepChild("Road")
    self.trCharacter.localScale = trRoad.localScale

    self.trAttackPosition = tr:FindDeepChild("AttackPosition")

    self.tableSpriteBlock[BoardQuestDataHandler.data.nPosition].sprite = self.spriteLightBlock
end

function BoardQuestMainUIPop:setLevelPrize(nLevelPrizeCoin, nRatio, gift)
    self.textWinCoin.text = MoneyFormatHelper.numWithCommas(nLevelPrizeCoin)
    self.goRatio:SetActive(nRatio > 0)
    if nRatio > 0 then self.textRatio.text = nRatio.."%" end
    if gift and gift.cardPack and SlotsCardsManager:orActivityOpen() then
        self.levelPrizeCardPackUI:set(gift.cardPack.nCardPackType, gift.cardPack.nCount)
    else
        self.levelPrizeCardPackUI:set()
    end
end

function BoardQuestMainUIPop:setMonsterSpineAnimation(goMonster, nHp, nMaxHp)
    goMonster = goMonster or self.goMonster
    nHp = nHp or BoardQuestDataHandler.data.nMonsterHp
    nMaxHp = nMaxHp or BoardQuestConfig.MONSTER_HP[BoardQuestDataHandler.data.nLevel]

    --两个阶段，每个阶段一种动画
    local fRatio = nHp / nMaxHp
    local strSpineName 
    if fRatio > 0.7 then
        strSpineName = "animation"
    else
        strSpineName = "animation2"
    end
    local state = ActivityHelper:GetComponentInChildren(goMonster, CS.Spine.Unity.SkeletonAnimation).AnimationState
    state:SetAnimation(0, strSpineName, true)
end

function BoardQuestMainUIPop:setHpBar(fTargetRatio)
    fTargetRatio = fTargetRatio or BoardQuestDataHandler.data.nMonsterHp / BoardQuestConfig.MONSTER_HP[BoardQuestDataHandler.data.nLevel]
    local fCurRatio = self.imgMaskHp.fillAmount
    local fAnimationTime = (fCurRatio - fTargetRatio) * 3.5

    local nStage = 1
    for i = 1, 3 do
        if fCurRatio >= self.tableFMonsterStageRatio[i] then
            nStage = i
            break
        end
    end
    local id = LeanTween.value(fCurRatio, fTargetRatio, fAnimationTime):setOnUpdate(function(value)
        self.imgMaskHp.fillAmount = value
        self.textHp.text = math.floor(value * 100).."%"
        local nCurStage
        for i = 1, 3 do
            if value >= self.tableFMonsterStageRatio[i] then
                nCurStage = i
                break
            end
        end
        if nCurStage ~= nStage then
            nStage = nCurStage
            self.imgHp.color = self.tableHpBarColor[nCurStage]
        end
    end).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    return fAnimationTime
end

function BoardQuestMainUIPop:roll()
    if BoardQuestDataHandler.data.nAction >= 1 then
        ActivityHelper:AddMsgCountData("nAction", -1)
    else
        self.Store:Show()
        return 
    end
    local nDice1 = math.random(1, 6)
    local nDice2 = math.random(1, 6)
    local nTotal = nDice1 + nDice2

    if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType > 0 then
        nTotal = 1
    end

    self:setInAnimation(true)

    self.Dice:show(nDice1, nDice2)

    LeanTween.delayedCall(4, function()
        self:move(nTotal)
    end)
end

function BoardQuestMainUIPop:move(nTotal)
    local nLevel = BoardQuestDataHandler.data.nLevel
    local nTarget = LuaHelper.Loop(BoardQuestDataHandler.data.nPosition + nTotal, 1, BoardQuestConfig.ROAD_ITEM_COUNT[nLevel])

    local nOriginalPosition = BoardQuestDataHandler.data.nPosition
    BoardQuestDataHandler.data.nPosition = nTarget
    local nItem = BoardQuestConfig.ROAD[nLevel][nTarget]

    if nItem == BoardQuestConfig.ITEM.MORE_CANNON then
        if BoardQuestDataHandler:checkInBoosterTime(BoardQuestIAPConfig.TYPE.MORE_CANNON) then
            nItem = BoardQuestConfig.ITEM.CANNON
        else
            nItem = BoardQuestConfig.ITEM.NONE
        end
    end

    if nItem == BoardQuestConfig.ITEM.CANNON then

    elseif nItem == BoardQuestConfig.ITEM.MYSTERY_REWARD then
        
    elseif nItem == BoardQuestConfig.ITEM.COIN then
        local nCoin = ActivityHelper:getBasePrize() * BoardQuestConfig:getCoinReward()
        PlayerHandler:AddCoin(nCoin)
        self.RewardCoinOnBoard.nCoin = nCoin
        self.RewardCoinOnBoard.nPlayerCoin = PlayerHandler.nGoldCount
    elseif nItem == BoardQuestConfig.ITEM.CARD then
        local nPackType = BoardQuestConfig.ROAD_CARD_PACK_TYPE[BoardQuestDataHandler.data.nLevel]
        SlotsCardsGiftManager:getStampPackInActive(nPackType, 1)
    end
    BoardQuestDataHandler:writeFile()

    local seq = LeanTween.sequence()
    for i = 1, nTotal do
        local nStartPos = LuaHelper.Loop(nOriginalPosition + i - 1, 1, BoardQuestConfig.ROAD_ITEM_COUNT[nLevel])
        local nTarget = LuaHelper.Loop(nOriginalPosition + i, 1, BoardQuestConfig.ROAD_ITEM_COUNT[nLevel])
        local v3Target = self.tableGoBlock[nTarget].transform.position
        local l = LeanTween.move(self.goCharacter, v3Target, 0.52)
        :setEase(LeanTweenType.easeInOutCubic)
        :setOnStart(function()
            ActivityAudioHandler:PlaySound("board_move")
            ActivityHelper:PlayAni(self.goCharacter, "Move")
        end)
        :setOnComplete(function ()
            self.tableSpriteBlock[nStartPos].sprite = self.spriteGrayBlock
            self.tableSpriteBlock[nTarget].sprite = self.spriteLightBlock
        end)
        seq:append(l)
        seq:append(0.04)
        table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
    end
    local l = LeanTween.delayedCall(0.4, function()
        if nItem == BoardQuestConfig.ITEM.NONE then
            self:setInAnimation(false)
        elseif nItem == BoardQuestConfig.ITEM.CANNON then
            self.AttackWheel:show(true, self.tableGoItem[nTarget])
        elseif nItem == BoardQuestConfig.ITEM.MYSTERY_REWARD then
            self.MysteryReward:Show()
        elseif nItem == BoardQuestConfig.ITEM.COIN then
            self.RewardCoinOnBoard:Show()
        elseif nItem == BoardQuestConfig.ITEM.CARD then
            self.RewardCardPackOnBoard:Show()
            local nPackType = BoardQuestConfig.ROAD_CARD_PACK_TYPE[BoardQuestDataHandler.data.nLevel]
            self.RewardCardPackOnBoard.cardPackUI:set(nPackType, 1)
        end
    end)
    seq:append(l)
    table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
end

--发射炮弹
function BoardQuestMainUIPop:atk(nValue, bShowFireAgain, goCannonOnBoard)
    if BoardQuestDataHandler:checkInBoosterTime(BoardQuestIAPConfig.TYPE.CANNON_BOOSTER) then
        nValue = nValue * 2
    end
    nValue  = math.min(nValue, BoardQuestDataHandler.data.nMonsterHp)
    BoardQuestDataHandler.data.nMonsterHp = BoardQuestDataHandler.data.nMonsterHp - nValue
 
    local fRatio = BoardQuestDataHandler.data.nMonsterHp / BoardQuestConfig.MONSTER_HP[BoardQuestDataHandler.data.nLevel]
    self:hitMonsterSpineAnimation(self.goMonster, fRatio, BoardQuestDataHandler.data.nLevel)
    local fAnimationTime = self:setHpBar()

    local goEffect = ActivityBundleHandler:GetAnimationObject("baozha", self.trPrefabPool)
    goEffect.transform.position = self.trAttackPosition.position
    goEffect:SetActive(true)
    ActivityAudioHandler:PlaySound("board_explosion")
    LeanTween.delayedCall(1.4, function()
        ActivityBundleHandler:RecycleObjectToPool(goEffect)
    end)

    if BoardQuestDataHandler.data.nMonsterHp <= 0 then
        self.LevelPrize.nCoin = BoardQuestDataHandler:getLevelPrize(BoardQuestDataHandler.data.nLevel)
        PlayerHandler:AddCoin(self.LevelPrize.nCoin)
        self.LevelPrize.nPlayerCoin = PlayerHandler.nGoldCount
    
        BoardQuestDataHandler.data.nLevel = LuaHelper.Loop(BoardQuestDataHandler.data.nLevel + 1, 1, BoardQuestConfig.N_MAX_LEVEL)
        BoardQuestDataHandler.data.nPosition = 1
        BoardQuestDataHandler.data.nMonsterHp = BoardQuestConfig.MONSTER_HP[BoardQuestDataHandler.data.nLevel]

        if BoardQuestDataHandler.data.nLevel == 1 then
            self.FinalPrize.nCoin = BoardQuestDataHandler:getFinalPrizePrize()
            PlayerHandler:AddCoin(self.FinalPrize.nCoin)
            self.FinalPrize.nPlayerCoin = PlayerHandler.nGoldCount
            BoardQuestDataHandler.data.fFinalPrizeRatioMutiplier = BoardQuestDataHandler.data.fFinalPrizeRatioMutiplier + 0.1
        end

        LeanTween.delayedCall(fAnimationTime + 1.5, function()
            GlobalAudioHandler:SwitchActiveBackgroundMusic("board_music")
            self.LevelPrize:Show()
            if BoardQuestDataHandler.data.nLevel == 1 then
                self.FinalPrize:Show()
            end
        end)
        LeanTween.delayedCall(fAnimationTime + 2, function()
            self:setLevel(BoardQuestDataHandler.data.nLevel)
            self.goCharacter.transform.position = self.tableGoBlock[1].transform.position
            self:setInAnimation(false)
        end)
    else
        bShowFireAgain = bShowFireAgain
        if bShowFireAgain then
            LeanTween.delayedCall(fAnimationTime + 1.5, function()
                self.FireAgain:show(goCannonOnBoard)
            end)
        else
            LeanTween.delayedCall(1.5, function()
                self:setInAnimation(false)
                GlobalAudioHandler:SwitchActiveBackgroundMusic("board_music")
            end)
        end
    end

    BoardQuestDataHandler:writeFile()
end

--怪物被攻击动画
function BoardQuestMainUIPop:hitMonsterSpineAnimation(goMonster, fRatio, nLevel)
    goMonster = goMonster or self.goMonster
    ActivityHelper:PlayAni(goMonster, "Shake")


    local tableFMixDuration1 = {0.2, 0.2, 0.2, 0.2, 0.2}
    local tableFMixDuration2 = {0.5, 0.5, 0.5, 0.5, 0.5}
    local tableFDelayTime = {0.8, 0.94, 0.64, 0.64, 1}

    local state = ActivityHelper:GetComponentInChildren(goMonster, CS.Spine.Unity.SkeletonAnimation).AnimationState
    state:SetAnimation(0, "animation1", false).MixDuration = tableFMixDuration1[nLevel]

    local strSpineName 
    if fRatio > 0.3 then
        strSpineName = "animation"
    else
        strSpineName = "animation2"
    end

    state:AddAnimation(1, strSpineName, true, tableFDelayTime[nLevel]).MixDuration = tableFMixDuration2[nLevel]
end

function BoardQuestMainUIPop:onPurchaseDoneNotifycation(data)
    local skuInfo = data.skuInfo
    if skuInfo.nType == SkuInfoType.BoardQuest then
        if skuInfo.nActiveIAPType == BoardQuestIAPConfig.TYPE.MORE_CANNON then
            local nLevel = BoardQuestDataHandler.data.nLevel
            for i = 1, #BoardQuestConfig.ROAD[nLevel] do
                local nItem = BoardQuestConfig.ROAD[nLevel][i]
                if nItem == BoardQuestConfig.ITEM.MORE_CANNON then
                    if self.tableGoItem[i] == nil then
                        local nRoadWidth = BoardQuestConfig.ROAD_ITEM_COUNT[nLevel] / 4
                        local nCannonType = math.floor((i - 1)/nRoadWidth) + 1
                        local strItemName = BoardQuestConfig.ITEM_KEY[BoardQuestConfig.ITEM.CANNON]..nCannonType
                        local go = ActivityBundleHandler:GetObjectFromPool("Prefab/"..strItemName, self.trItemParent)
                        local tr = go.transform
                        tr.position = self.tableGoBlock[i].transform.position
                        local v3 = tr.localPosition
                        v3.z = 0
                        tr.localPosition = v3
                        tr.localScale = Unity.Vector3.one
                        go:SetActive(true)                      
                        self.tableGoItem[i] = go
                        self.tableCannonTime[go] = self.CannonTime:new(go)
                    else
                        break
                    end
                end
            end
        end
    end
end

--在播动画时就设为true,让按钮无法点击，动画播放停止设为false
function BoardQuestMainUIPop:setInAnimation(bInAnimation)
    self.bInAnimation = bInAnimation
    self.btnRoll.interactable = not bInAnimation
end

function BoardQuestMainUIPop:onActiveTimeChanged(time)
    self.textDate.text = ActivityHelper:FormatTime(time)
    self:updateBoosterTime(TimeHandler:GetServerTimeStamp())
end

function BoardQuestMainUIPop:onActiveTimesUp()
    if self.tableUI then
        for k, v in pairs(self.tableUI) do
            if v.transform.gameObject then
                v.transform.gameObject:SetActive(false)
            end
        end
    end
end

function BoardQuestMainUIPop:onFetchAvatarNotifictation(data)
	if FBHandler:isLoggedIn() then
		local texture = FBHandler:getAvatar(data.fbId)
		if texture ~= nil then
            local rect = Unity.Rect(0.0, 0.0, 50.0, 50.0)
            local spriteA = CS.UnityEngine.Sprite.Create(texture, rect, Unity.Vector2(0.5, 0.5))
			self.spriteAvatar.sprite = spriteA
            self.spriteAvatar.transform.localScale = Unity.Vector3.one * 260
		end
	end
end

function BoardQuestMainUIPop:updateFBAvatar()
	if FBHandler:isLoggedIn() then
        self.goDefaultAvatar:SetActive(false)
        self.goFBAvatar:SetActive(true)
		local texture = FBHandler:getAvatar(FBHandler:getFbId())
		if texture ~= nil then
            local rect = Unity.Rect(0.0, 0.0, 50.0, 50.0)
            local spriteA = CS.UnityEngine.Sprite.Create(texture, rect, Unity.Vector2(0.5, 0.5))
			self.spriteAvatar.sprite = spriteA
            self.spriteAvatar.transform.localScale = Unity.Vector3.one * 260
		end
    else
        self.goDefaultAvatar:SetActive(true)
        self.goFBAvatar:SetActive(false)
	end
end

function BoardQuestMainUIPop:onFBConnectChangedNotifictation()
    if not FBHandler:isLoggedIn() then
        self.goDefaultAvatar:SetActive(true)
        self.goFBAvatar:SetActive(false)
    end
end


