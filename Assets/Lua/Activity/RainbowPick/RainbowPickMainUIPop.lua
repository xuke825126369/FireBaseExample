

RainbowPickMainUIPop = {}

function RainbowPickMainUIPop:Show()
    if ActivityBundleHandler.m_bundleInfo.downloadStatus ~= DownloadStatus.Downloaded then
        return
    end
    if self.asynLoadCo == nil then
        self.asynLoadCo = StartCoroutine(function()
            Scene.loadingAssetBundle:SetActive(true)
            Debug.Log("-------RainbowPick begin Loaded---------")
            ActivityBundleHandler:asynLoadAssetBundle()
            local isReady = RainbowPickUnloadedUI.m_bAssetReady
            while (not isReady) do
                yield_return(0)
            end
            Scene.loadingAssetBundle:SetActive(false)
            self:Show()
            self.asynLoadCo = nil
        end)
    end
end

function RainbowPickMainUIPop:Show()
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

    self.popController:show(function()
        GlobalAudioHandler:PlayActiveBackgroundMusic("rainbow_music_loop")
    end)
    self:setItem(RainbowPickDataHandler.data.nLevel)
    self:setChest()
    local nLevelPrizeCoin, nRatio, gift = RainbowPickDataHandler:getLevelPrize()
    self:setLevelPrize(nLevelPrizeCoin, nRatio, gift)
    EventHandler:AddListener(self, "onActiveTimesUp")
    EventHandler:AddListener(self, "onActiveTimeChanged")
    EventHandler:Brocast("onActiveShow")

    if RainbowPickDataHandler.data.bFirstIntroduction then
        self.FirstIntroduction:Show()
    end
end

function RainbowPickMainUIPop:Init()
    self.ChestRewardSplashUI = require("Lua.Activity.RainbowPick.ChestRewardSplashUI")
    self.ChestSpotsFullSplashUI = require("Lua.Activity.RainbowPick.ChestSpotsFullSplashUI")
    self.ChestSpotsAlreadyFullSplashUI = require("Lua.Activity.RainbowPick.ChestSpotsAlreadyFullSplashUI")
    self.LevelPrizeHaveGiftSplashUI = require("Lua.Activity.RainbowPick.LevelPrizeHaveGiftSplashUI")
    self.LevelPrizeSplashUI = require("Lua.Activity.RainbowPick.LevelPrizeSplashUI")
    self.FinalPrizeSplashUI = require("Lua.Activity.RainbowPick.FinalPrizeSplashUI")
    self.LuckyPick = require("Lua.Activity.RainbowPick.LuckyPick")
    self.LuckyPickEndSplashUI = require("Lua.Activity.RainbowPick.LuckyPickEndSplashUI")
    self.OutOfPickSplashUI = require("Lua.Activity.RainbowPick.OutOfPickSplashUI")
    self.PrizeBiggerSplashUI = require("Lua.Activity.RainbowPick.PrizeBiggerSplashUI")
    self.StoreUI = require("Lua.Activity.RainbowPick.StoreUI")
    self.Introduction = require("Lua.Activity.RainbowPick.Introduction")
    self.FirstIntroduction = require("Lua.Activity.RainbowPick.FirstIntroduction")
    self.OpenNow = require("Lua.Activity.RainbowPick.OpenNow")

    --unloadAssetBundle用来销毁游戏物体
    self.tableUI = {
        self.ChestRewardSplashUI,
        self.ChestSpotsFullSplashUI,
        self.ChestSpotsAlreadyFullSplashUI,
        self.LevelPrizeHaveGiftSplashUI,
        self.LevelPrizeSplashUI,
        self.FinalPrizeSplashUI,
        self.LuckyPick,
        self.LuckyPickEndSplashUI,
        self.PrizeBiggerSplashUI,
        self.OutOfPickSplashUI,
        self.StoreUI,
        self.Introduction,
        self.FirstIntroduction,
        self.OpenNow,
        self
    }

    self.m_bInitFlag = true
    local prefabObj = AssetBundleHandler:LoadActivityAsset("RainbowPickMainUIPop")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
   LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)

    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    if GameConfig.IS_GREATER_169 then
        self.popController.adapterContainer.localScale = Unity.Vector3.one * 0.9
    end

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bCanClick then
            ActivityAudioHandler:PlaySound("rainbow_button")
            self:hide()
        end
    end)

    self.trLevels = self.transform:FindDeepChild("Levels")
    self.trPrefabPool = self.transform:FindDeepChild("PrefabPool")

    --Pick次数
    self.trPick = self.transform:FindDeepChild("Pick")
    self.textPickCount = self.transform:FindDeepChild("textPickCount"):GetComponent(typeof(UnityUI.Text))
    ActivityHelper:addDataObserver("nAction", self, function(self, nCount)
        self.textPickCount.text = tostring(nCount)
    end)

    --箱子
    self.tableGoChest = {}
    local goChest = self.transform:FindDeepChild("Chest1")
    self.tableGoChest[1] = goChest
    local trParent = goChest.transform.parent
    for i = 2, 5 do
        local goChest2 = Unity.Object.Instantiate(goChest, trParent)
        --goChest2.transform:SetParent()
        self.tableGoChest[i] = goChest2
    end
    self.tableTextChestLockTime = {}
    self.tableTextChestDiamond = {}
    for i = 1, RainbowPickConfig.N_MAX_CHEST do
        self.tableTextChestLockTime[i] = self.tableGoChest[i].transform:FindDeepChild("textLockTime"):GetComponent(typeof(TextMeshProUGUI))
        self.tableTextChestDiamond[i] = self.tableGoChest[i].transform:FindDeepChild("textDiamondNum"):GetComponent(typeof(UnityUI.Text))
    end
    for i = 1, RainbowPickConfig.N_MAX_CHEST do
        local btn = self.tableGoChest[i]:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            if self.bCanClick then
                self:onClickChest(i)
            end
        end)
    end

    --进度条
    self.imageProgressBar = self.transform:FindDeepChild("imageProgressBar"):GetComponent(typeof(UnityUI.Image))
    self.imageProgressBar.fillAmount = (RainbowPickDataHandler.data.nLevel - 1) / RainbowPickConfig.N_MAX_LEVEL

    self.textFinalPrizeCoin = self.transform:FindDeepChild("Container/AdapterContainer/ProgressBar/FinalPrize/JinDuTiaoHe2/textCoin"):GetComponent(typeof(UnityUI.Text))

    --商店
    self.tableTextBooster = {}
    self.tableTextBooster[1] = self.transform:FindDeepChild("textPickBooster"):GetComponent(typeof(TextMeshProUGUI))
    self.tableTextBooster[2]  = self.transform:FindDeepChild("textCoinBooster"):GetComponent(typeof(TextMeshProUGUI))
    self.textSuperPickCount = self.transform:FindDeepChild("textSuperPickCount"):GetComponent(typeof(TextMeshProUGUI))

    ActivityHelper:addDataObserver("nSuperPickCount", self, 
    function(self, nSuperPickCount)
        self.textSuperPickCount.text = tostring(nSuperPickCount)
    end)

    local btnAddPickBooster = self.transform:FindDeepChild("btnAddPickBooster"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddPickBooster)
    btnAddPickBooster.onClick:AddListener(function()
        if self.bCanClick then
            ActivityAudioHandler:PlaySound("rainbow_button")
            self.StoreUI:Show()
        end
    end)

    local btnAddCoinBooster = self.transform:FindDeepChild("btnAddCoinBooster"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddCoinBooster)
    btnAddCoinBooster.onClick:AddListener(function()
        if self.bCanClick then
            ActivityAudioHandler:PlaySound("rainbow_button")
            self.StoreUI:Show()
        end
    end)

    local btnAddSuperPick = self.transform:FindDeepChild("btnAddSuperPick"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnAddSuperPick)
    btnAddSuperPick.onClick:AddListener(function()
        if self.bCanClick then
            ActivityAudioHandler:PlaySound("rainbow_button")
            self.StoreUI:Show()
        end
    end)

    --LevelPrize
    self.textWinCoin = self.transform:FindDeepChild("textWinCoin"):GetComponent(typeof(UnityUI.Text))
    self.goSlotsCards = self.transform:FindDeepChild("SlotsCards").gameObject
    self.tableGoCardPack = LuaHelper.GetTableFindChild(self.transform, 5, "CardPack")
    self.tableGoStar = LuaHelper.GetTableFindChild(self.transform, 5, "Star")
    self.textCardPackCount = self.transform:FindDeepChild("textCardPackCount"):GetComponent(typeof(TextMeshProUGUI))

    self.levelPrizeCardPackUI = CardPackUI:new(self.goSlotsCards)

    self.goRatio = self.transform:FindDeepChild("Ratio").gameObject
    self.textRatio = self.goRatio.transform:FindDeepChild("textRatio"):GetComponent(typeof(UnityUI.Text))
    self.goRatio:SetActive(RainbowPickDataHandler.data.nRatio > 0)
    self.textRatio.text = RainbowPickDataHandler.data.nRatio.."%"

    self.textLevel = self.transform:FindDeepChild("textLevel"):GetComponent(typeof(UnityUI.Text))
    self.textLevel.text = RainbowPickDataHandler.data.nLevel.."/"..RainbowPickConfig.N_MAX_LEVEL

    local btnIntroduction = self.transform:FindDeepChild("btnIntroduction"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnIntroduction)
    btnIntroduction.onClick:AddListener(function()
        if self.bCanClick then
            ActivityAudioHandler:PlaySound("rainbow_button")
            self.Introduction:Show()
        end
    end)
end

function RainbowPickMainUIPop:hide()
    EventHandler:Brocast("onActiveHide")
    ViewScaleAni:Hide(self.transform.gameObject)
    NotificationHandler:removeObserver(self)
end

function RainbowPickMainUIPop:setItem(nLevel)
    if self.goItems then
        Unity.Object.Destroy(self.goItems)
    end
    local prefab = AssetBundleHandler:LoadActivityAsset(string.format("Levels/Level%s", nLevel))
    local go = Unity.Object.Instantiate(prefab)
    self.goItems = go
    local tr = go.transform
    tr:SetParent(self.trLevels)
    tr.localScale = Unity.Vector3.one
    tr.localPosition = Unity.Vector3.zero

    for i = 0, tr.childCount - 1 do
        local goItem = tr:GetChild(i).gameObject
        --local image = goItem:GetComponent(typeof(UnityUI.Image))
        --Debug.Log(image.sprite.name)
        goItem:SetActive(RainbowPickDataHandler.data.tableItem[i + 1] == RainbowPickItem.Unrevealed)
        local btn = goItem:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onClickItem(nLevel, i + 1, goItem)
        end)
    end

    self.bCanClick = true
end

function RainbowPickMainUIPop:setLevelPrize(nLevelPrizeCoin, nRatio, gift)
    self.textWinCoin.text = MoneyFormatHelper.numWithCommas(nLevelPrizeCoin)
    local nPrizeCoin = RainbowPickDataHandler:getFinalPrize()
    local str = MoneyFormatHelper.coinCountOmit(nPrizeCoin, 5)
    self.textFinalPrizeCoin.text = str
    self.goRatio:SetActive(nRatio > 0)
    if nRatio > 0 then self.textRatio.text = nRatio.."%" end
    if gift and gift.cardPack and SlotsCardsManager:orActivityOpen() then
        self.levelPrizeCardPackUI:set(gift.cardPack.nCardPackType, gift.cardPack.nCount)
    else
        self.levelPrizeCardPackUI:set()
    end
end

function RainbowPickMainUIPop:onClickItem(nLevel, nItemIndex, goItem)
    if not self.bCanClick then return end
    self.bCanClick = false
    if RainbowPickDataHandler.data.nAction <= 0 then
        self.OutOfPickSplashUI:Show()
        return
    end

    RainbowPickDataHandler:onClickItem(nLevel, nItemIndex, goItem)
    
    goItem:SetActive(false)
    local strItemName = goItem:GetComponent(typeof(UnityUI.Image)).sprite.name
    local goEffect = ActivityBundleHandler:GetAnimationObject(strItemName, self.trPrefabPool)
    goEffect.transform.position = goItem.transform.position
    goEffect:SetActive(true)
    LeanTween.delayedCall(2, function()
        ActivityBundleHandler:RecycleObjectToPool(goEffect)
    end)
end

function RainbowPickMainUIPop:flyPick(v3StartPos)
    local go = ActivityBundleHandler:GetAnimationObject("Pick", self.trPrefabPool)
    go.transform.position = v3StartPos
    go:SetActive(true)
    local id = LeanTween.move(go, self.trPick.position, 0.4):setOnComplete(function()
        ActivityHelper:AddMsgCountData("nAction", 0)
        ActivityBundleHandler:RecycleObjectToPool(go)
        self.bCanClick = true
    end):setDelay(0.8).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
end

function RainbowPickMainUIPop:flyChest(v3StartPos, v3EndPos, nChestType)
    local go = ActivityBundleHandler:GetAnimationObject("Chest"..nChestType, self.trPrefabPool)
    go.transform.position = v3StartPos
    go.transform.localScale = Unity.Vector3.one
    local fTime = 0.4
    local seq = LeanTween.sequence()

    local l = LeanTween.delayedCall(0.6, function()
        go:SetActive(true)
        LeanTween.move(go, Unity.Vector3.zero, fTime)
        LeanTween.scale(go, Unity.Vector3.one * 5, fTime)
    end)
    table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
    seq:append(l)

    local l = LeanTween.delayedCall(1.2, function()
        local id = LeanTween.scale(go, Unity.Vector3.one * 1.5, fTime).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id)
        local id = LeanTween.move(go, v3EndPos, fTime).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id)
    end)
    seq:append(l)
    table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
    
    local l = LeanTween.delayedCall(fTime, function()
        ActivityBundleHandler:RecycleObjectToPool(go)
        self:setChest()
        self.bCanClick = true
    end)
    table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
    seq:append(l)
    
    return 2.5
end

function RainbowPickMainUIPop:flyKey(v3StartPos, v3EndPos, nItem, nChestPosition)
    local strChestName = RainbowPickItemKey[nItem]
    local go = ActivityBundleHandler:GetAnimationObject(strChestName, self.trPrefabPool)
    go.transform.position = v3StartPos
    go:SetActive(true)

    local goEffect = ActivityBundleHandler:GetAnimationObject("ClickEmptyParticle")
    local id = LeanTween.move(go, v3EndPos, 0.6):setOnComplete(function()
        ActivityBundleHandler:RecycleObjectToPool(go)
        RainbowPickDataHandler.data.tableNChestLockTime[nChestPosition] = 0
        RainbowPickDataHandler:writeFile()
        goEffect.transform.position = v3EndPos
        goEffect:SetActive(true)
    end).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)

    LeanTween.delayedCall(1.2, function()
        ActivityBundleHandler:RecycleObjectToPool(goEffect)
        self:openChest(nChestPosition)
    end)
end

function RainbowPickMainUIPop:flyMore(v3StartPos, nItem, nRatio)
    local strName = RainbowPickItemKey[nItem]
    local go = ActivityBundleHandler:GetAnimationObject(strName, self.trPrefabPool)
    go.transform.position = v3StartPos
    go:SetActive(true)

    LeanTween.delayedCall(0.8, function()
        self.PrizeBiggerSplashUI:show(nRatio)
    end)

    LeanTween.delayedCall(1.3, function()
        ActivityBundleHandler:RecycleObjectToPool(go)
        local nLevelPrize, nRatio, gift = RainbowPickDataHandler:getLevelPrize()
        self:setLevelPrize(nLevelPrize, nRatio, gift)
    end)
end

function RainbowPickMainUIPop:setChest()
    for i = 1, #RainbowPickDataHandler.data.tableChest do
        local nChestIndex = RainbowPickDataHandler.data.tableChest[i]
        local go = self.tableGoChest[i]
        local goChest = ActivityHelper:FindDeepChild(go, "HaveChest")
        local goNoChest = ActivityHelper:FindDeepChild(go, "NoChest")
        goChest:SetActive(nChestIndex > 0)
        goNoChest:SetActive(nChestIndex == 0)
        if nChestIndex > 0 then
            for i = 1, 3 do
                local goChest = ActivityHelper:FindDeepChild(go, "ChestType"..i)
                goChest:SetActive(i == nChestIndex)
            end
            self.tableTextChestDiamond[i].text = tostring(RainbowPickConfig.tableChestUnlockDiamond[nChestIndex])
        end
    end
    self:updateChestTime(TimeHandler:GetServerTimeStamp(), true)
end

function RainbowPickMainUIPop:updateBoosterTime(nowSecond)
    for i = 1, 2 do
        if RainbowPickDataHandler.data.tableNBoosterEndTime[i] > 0 then
            local time = RainbowPickDataHandler.data.tableNBoosterEndTime[i] - nowSecond
            if time <= 0 then
                RainbowPickDataHandler.data.tableNBoosterEndTime[i] = 0
                if i == RainbowPickBooster.Coin then
                    local nLevelPrizeCoin, nRatio, gift = RainbowPickDataHandler:getLevelPrize()
                    self:setLevelPrize(nLevelPrizeCoin, nRatio, gift)
                end
            else
                local days = time // (3600*24)
                local hours = time // 3600 - 24 * days
                local minutes = time // 60 - 24 * days * 60 - 60 * hours
                local seconds = time % 60
                local str = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                self.tableTextBooster[i].text = str
            end
        else
            local str = string.format("%02d:%02d:%02d", 0, 0, 0)
            self.tableTextBooster[i].text = str
        end
    end
end

function RainbowPickMainUIPop:updateChestTime(nowSecond, bSetChest)
    for i = 1, RainbowPickConfig.N_MAX_CHEST do
        local nChestType = RainbowPickDataHandler.data.tableChest[i]
        if RainbowPickDataHandler.data.tableNChestLockTime[i] > 0 
        or RainbowPickDataHandler.data.tableNChestLockTime[i] == -1 and bSetChest and nChestType > 0 then
            local time = RainbowPickDataHandler.data.tableNChestLockTime[i] - nowSecond
            if time <= 0 then
                RainbowPickDataHandler.data.tableNChestLockTime[i] = -1
                ActivityHelper:FindDeepChild(self.tableGoChest[i], "LockTime"):SetActive(false)
                ActivityHelper:FindDeepChild(self.tableGoChest[i], "Purchase"):SetActive(false)
                ActivityHelper:FindDeepChild(self.tableGoChest[i], "Open"):SetActive(true)                            
                local goChestType = ActivityHelper:FindDeepChild(self.tableGoChest[i], "ChestType"..nChestType)
                ActivityHelper:PlayAni(goChestType, "WaitForOpen")
            else
                local str = LuaHelper.formatSecond(time)
                self.tableTextChestLockTime[i].text = str
                ActivityHelper:FindDeepChild(self.tableGoChest[i], "LockTime"):SetActive(true)
                ActivityHelper:FindDeepChild(self.tableGoChest[i], "Purchase"):SetActive(true)
                ActivityHelper:FindDeepChild(self.tableGoChest[i], "Open"):SetActive(false)
            end
        else
            ActivityHelper:FindDeepChild(self.tableGoChest[i], "LockTime"):SetActive(false)
            ActivityHelper:FindDeepChild(self.tableGoChest[i], "Purchase"):SetActive(false)
            ActivityHelper:FindDeepChild(self.tableGoChest[i], "Open"):SetActive(true)
        end
    end
end

function RainbowPickMainUIPop:openChest(nChestPosition)
    self.bCanClick = false
    local nChestType = RainbowPickDataHandler.data.tableChest[nChestPosition]
    RainbowPickDataHandler.data.tableChest[nChestPosition] = RainbowPickChest.None
    local info = RainbowPickConfig:getChestReward(nChestType)
    if info.nRewardType == RainbowPickConfig.ChestReward.CardPack then
        SlotsCardsGiftManager:getStampPackInActive(info.nCardPackType, info.nCount)
    elseif info.nRewardType == RainbowPickConfig.ChestReward.Coin then
        PlayerHandler:AddCoin(info.nCount)
        info.nPlayerCoin = PlayerHandler.nGoldCount
    elseif info.nRewardType == RainbowPickConfig.ChestReward.Diamond then
        PlayerHandler:AddSapphire(info.nCount)
        UITop.uiTopDiamondCountText.text = MoneyFormatHelper.numWithCommas(PlayerHandler.nSapphireCount)
    end
    --隐藏箱子
    local goChest = self.tableGoChest[nChestPosition]
    ActivityHelper:FindDeepChild(goChest, "HaveChest"):SetActive(false)
    ActivityHelper:FindDeepChild(goChest, "NoChest"):SetActive(true)

    local go = ActivityBundleHandler:GetAnimationObject("ChestOpen"..nChestType, self.trPrefabPool)
    go:SetActive(true)
    go.transform.position = goChest.transform.position
    --goChest:SetActive(false)
    ActivityHelper:PlayAni(go, "Open")
    ActivityAudioHandler:PlaySound("rainbow_box_open")
    local id = LeanTween.move(go, Unity.Vector3.zero, 0.6).id
    table.insert(ActivityHelper.m_LeanTweenIDs, id)
    LeanTween.delayedCall(1.55, function()
        ActivityBundleHandler:RecycleObjectToPool(go)
        self.ChestRewardSplashUI:show(info)
        if info.nRewardType == RainbowPickConfig.ChestReward.LuckyPick then
        --TODO断线重连
            self.LuckyPick:show(nChestType)
        end
    end)
    RainbowPickDataHandler:writeFile()
end

function RainbowPickMainUIPop:onClickChest(nChestPosition)
    ActivityAudioHandler:PlaySound("rainbow_button")
    --还没解锁，花钻石快速解锁
    if RainbowPickDataHandler:checkChestLockTime(nChestPosition) then
        self.OpenNow:show(nChestPosition)
    else
        self:openChest(nChestPosition)
    end
end

function RainbowPickMainUIPop:onActiveTimesUp()
    if self.tableUI then
        for k, v in pairs(self.tableUI) do
            if v.transform.gameObject then
                v.transform.gameObject:SetActive(false)
            end
        end
    end
end

function RainbowPickMainUIPop:onActiveTimeChanged()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    self:updateBoosterTime(nowSecond)
    self:updateChestTime(nowSecond)
end


