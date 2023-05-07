require("Lua.Activity.Lounge.MedalPayTable")
require("Lua.Activity.Lounge.AllMedalLevelTo5StarsUI")
require("Lua.Activity.Lounge.CollectFreeBonusUI")
require("Lua.Activity.Lounge.MedalStartingOverUI")
require("Lua.Activity.Lounge.LevelUpResultUI")
require("Lua.Activity.Lounge.UseMedalChestUI")

MedalMasterMainUI = {}
MedalMasterMainUI.m_nPageIndex = 1 -- 默认展示第一页

function MedalMasterMainUI:Show(func)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("MedalMasterMainUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.m_trContent = self.transform:FindDeepChild("Content")
        self.m_trPopNode = self.transform:FindDeepChild("PopParentNode")

        local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)
        
        local btnTip = self.transform:FindDeepChild("BtnTip"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnTip)
        btnTip.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onBtnTipClick(btnTip)
        end)

        local btnLeft = self.transform:FindDeepChild("BtnLeft"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnLeft)
        btnLeft.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onBtnLeftClick()
        end)

        local btnRight = self.transform:FindDeepChild("BtnRight"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnRight)
        btnRight.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onBtnRightClick()
        end)

        self.m_btnLeftPage = btnLeft
        self.m_btnRightPage = btnRight

        local tr = self.transform:FindDeepChild("UITop")
        self.TextMeshProSeasonNum = tr:FindDeepChild("TextMeshProSeasonNum"):GetComponent(typeof(TextMeshProUGUI))
        -- 第几季
        self.TextTotalPrize = tr:FindDeepChild("TextTotalPrize"):GetComponent(typeof(UnityUI.Text))
        -- 都五星之后的总奖励

        self.goSeasonRewardCollectedNode = tr:FindDeepChild("SeasonRewardCollectedNode").gameObject
        self.goSeasonRewardCollectedNode:SetActive(false)

        -- 倒计时牌
        self.goEndInNode = tr:FindDeepChild("EndInNode").gameObject
        self.goEndInNode:SetActive(false)
        self.TextMeshProEndInTime = tr:FindDeepChild("TextMeshProEndInTime"):GetComponent(typeof(TextMeshProUGUI))
        --

        local trBottom = self.transform:FindDeepChild("UIBottom")
        trBottom.anchoredPosition = Unity.Vector2(0.0, 50.0)
        self.m_listGoPagePoints = {} -- 屏幕中下方的点 当前是第几页就显示第几个点
        for i=1, 8 do
            local name = "JinDuDianBG" .. i
            local tr = trBottom:FindDeepChild(name)
            local goPagePoint = tr:FindDeepChild("JinDuDian").gameObject
            goPagePoint:SetActive(false)
            table.insert(self.m_listGoPagePoints, goPagePoint)
        end
        
        local tr = self.transform:FindDeepChild("CollectChestBonusTip")
        self.aniCollectChestBonusTip = tr:GetComponent(typeof(Unity.Animator))
        self.goCollectChestBonusTip = tr.gameObject
        self.goCollectChestBonusTip:SetActive(false)
        local tr = self.transform:FindDeepChild("UnlockChestBonusTip")
        self.goUnlockChestBonusTip = tr.gameObject
        self.goUnlockChestBonusTip:SetActive(false)

        self:initUILeft()
        self:initUIRight()
        self:initUIMiddle()
        self:initUIAllMedalLogos() -- 8关每个星级对应的徽章图
        self:initLengendaryNode() -- 5星以后 每个徽章对应一个传奇箱子升级

        self.mTimeOutGenerator = TimeOutGenerator:New()
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    LoungeAudioHandler:PlayBackMusic("Loung_background")

    if func ~= nil then
        func()
    end

    self.m_nPageIndex = 1
    self.m_btnLeftPage.transform.gameObject:SetActive(false)
    self.m_btnRightPage.transform.gameObject:SetActive(true)
    self:RefreshUI()

    LeanTween.delayedCall(1.5, function()
        local data = LoungeHandler.data.activityData.listMedalMasterData
        if not data.bStartOverUIShow and data.nSeasonID > 1 then
            MedalStartingOverUI:Show()
            data.bStartOverUIShow = true
            LoungeHandler:SaveDb()
        end
    end)
    
    local bFlag = LoungeConfig:isAllMedalCompleted()
    if bFlag then
        local playerData = LoungeHandler.data.activityData.listMedalMasterData
        if playerData.bGrandPrizeClaimed then
            self.TextTotalPrize.transform.gameObject:SetActive(false)
            self.goSeasonRewardCollectedNode:SetActive(true)
        end
    end

end

function MedalMasterMainUI:isActiveShow()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        return false
    end

    if not self.transform.gameObject.activeInHierarchy then
        return false
    end

    return true
end

function MedalMasterMainUI:Update()
    if self.mTimeOutGenerator:orTimeOut() then 
        self:UpdateFreeBonusNode()
        self:UpdateFreeChestNode()
    end
end

-- 只缓存资源节点 不更新界面参数
function MedalMasterMainUI:initLengendaryNode()
    local tr = self.transform:FindDeepChild("LengendaryNode")
    self.goLengendaryNode = tr.gameObject
    self.goLengendaryNode:SetActive(false)

    local trProgress = tr:FindDeepChild("LengendaryProgressNode")
    self.goLengendaryProgressNode = trProgress.gameObject
    self.imageLengendaryProgress = trProgress:FindDeepChild("imageLengendaryProgress"):GetComponent(typeof(UnityUI.Image))
    self.TextMeshProLengendaryProgress = trProgress:FindDeepChild("TextMeshProLengendaryProgress"):GetComponent(typeof(TextMeshProUGUI))

    local trCollect = tr:FindDeepChild("BtnCollectLengendary")
    self.goBtnCollectLengendary = trCollect.gameObject
    local btnCollect = trCollect:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnCollect)
    btnCollect.onClick:RemoveAllListeners()
    btnCollect.onClick:AddListener(function()
        self:onCollectLengendaryBtnClick(btnCollect)
    end)
end

function MedalMasterMainUI:onCollectLengendaryBtnClick(btnCollect)
    GlobalAudioHandler:PlayBtnSound()
    btnCollect.interactable = false
    LeanTween.delayedCall(1.0, function()
        btnCollect.interactable = true
    end)

    local playerData = LoungeHandler.data.activityData.listMedalMasterData
    local fexp = playerData.listMedalExp[self.m_nPageIndex]
    playerData.listMedalExp[self.m_nPageIndex] = fexp - LoungeConfig.nLegendDepotExp

    local enumChestType = LoungeConfig.enumCHESTTYPE.Legendary
    LoungeHandler:addChest(enumChestType, 1)
    LoungeHandler:SaveDb()
    PopStackViewHandler:Show(MedalChestPopEffect, enumChestType, true, 1)
    self:UpdateLengendaryNode()

end

function MedalMasterMainUI:UpdateLengendaryNode()
    local nLevel, fProgress, nPlayerExp, nCurLevelExp = LoungeConfig:getMedalLevelInfo(self.m_nPageIndex)
    if nLevel < 5 then
        self.goLengendaryNode:SetActive(false)
        return
    end

    self.goLengendaryNode:SetActive(true)
    local bFull, fLengendaryProgress = LoungeConfig:getLengendaryProgress(self.m_nPageIndex)
    self.goLengendaryProgressNode:SetActive(not bFull)
    self.goBtnCollectLengendary:SetActive(bFull)
    if not bFull then
        self.imageLengendaryProgress.fillAmount = fLengendaryProgress
        local strInfo = math.floor(fLengendaryProgress * 100) .. "%"
        self.TextMeshProLengendaryProgress.text = strInfo
    end

end

function MedalMasterMainUI:initUILeft()
    local trLeft = self.transform:FindDeepChild("UILeft")

    local trPlatinumItems = trLeft:FindDeepChild("PlatinumItems")
    local trRoyalItems = trLeft:FindDeepChild("RoyalItems")
    local trMasterItems = trLeft:FindDeepChild("MasterItems")

    self.goPlatinumItems = trPlatinumItems.gameObject
    self.goRoyalItems = trRoyalItems.gameObject
    self.goMasterItems = trMasterItems.gameObject

    self.m_listMedalLevelPrizeNodes = {} -- Platinum 123 Royal 456 Master 78

    local listTr = {trPlatinumItems, trRoyalItems, trMasterItems}
    for j = 1, 3 do
        local trParent = listTr[j]
        for i = 1, 5 do
            local name = "Level" .. i .. "Node"
            local tr = trParent:FindDeepChild(name)
            local goDone = tr:FindDeepChild("Done").gameObject
            local TextCoins = tr:FindDeepChild("TextCoins"):GetComponent(typeof(UnityUI.Text))
            local name = "Level" .. i .. "More"
            local trMore = trParent:FindDeepChild(name)
            local goMore = trMore.gameObject
            local TextMorePercent = trMore:FindDeepChild("TextMorePercent"):GetComponent(typeof(UnityUI.Text))
            local nodes = {goDone = goDone, TextCoins = TextCoins, goMore = goMore,TextMorePercent = TextMorePercent}
            table.insert(self.m_listMedalLevelPrizeNodes, nodes)
        end
    end

end

function MedalMasterMainUI:initUIRight()
    local trRight = self.transform:FindDeepChild("UIRight")
    local trFreeChestItem = trRight:FindDeepChild("FreeChestItem")
    local goRedBG = trFreeChestItem:FindDeepChild("redBG").gameObject
    local goGreenBG = trFreeChestItem:FindDeepChild("greenBG").gameObject
    local trCountDownNode = trFreeChestItem:FindDeepChild("CountDownNode")
    local goCountDownNode = trCountDownNode.gameObject
    local TextMeshProCountDown = trCountDownNode:FindDeepChild("TextMeshProCountDown"):GetComponent(typeof(TextMeshProUGUI))

    self.m_btnFreeChestItem = trFreeChestItem:GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.m_btnFreeChestItem)
    self.m_btnFreeChestItem.onClick:RemoveAllListeners()
    self.m_btnFreeChestItem.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self:onFreeChestItemBtnClick()
    end)

    self.m_FreeChestNodes = {goRedBG = goRedBG, goGreenBG = goGreenBG, goCountDownNode = goCountDownNode, TextMeshProCountDown = TextMeshProCountDown}

    local trBtnGetChests = trRight:FindDeepChild("BtnGetChests")
    self.m_btnGetChests = trBtnGetChests:GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.m_btnGetChests)
    self.m_btnGetChests.onClick:RemoveAllListeners()
    self.m_btnGetChests.onClick:AddListener(function()
        GlobalAudioHandler:PlayBtnSound()
        self.m_btnGetChests.interactable = false
        LeanTween.delayedCall(1.0, function()
            self.m_btnGetChests.interactable = true
        end)
        self:onGetChestsBtnClick()
    end)

    self.m_listChestItemNodes = {}
    local listNames = {"CommonItem", "RareItem", "EpicItem", "LegendaryItem"}
    for i = 1, 4 do
        local name = listNames[i]
        local trChestItem = trRight:FindDeepChild(name)
        local goRedBG = trChestItem:FindDeepChild("redBG").gameObject
        local goGreenBG = trChestItem:FindDeepChild("greenBG").gameObject
        local goItemName = trChestItem:FindDeepChild("ItemName").gameObject
        local goTextMeshProCollectAll = trChestItem:FindDeepChild("TextMeshProCollectAll").gameObject

        local goNumNode = trChestItem:FindDeepChild("NumNode").gameObject
        local TextMeshProChestCount = trChestItem:FindDeepChild("TextMeshProChestCount"):GetComponent(typeof(TextMeshProUGUI))
        local aniChest = trChestItem:GetComponent(typeof(Unity.Animator))

        local tr =  trChestItem:FindDeepChild("ChestTipNode")
        local goChestTipNode = tr.gameObject
        goChestTipNode:SetActive(false)

        local btnShopChest = tr:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnShopChest)
        btnShopChest.onClick:RemoveAllListeners()
        btnShopChest.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            btnShopChest.interactable = false
            LeanTween.delayedCall(1.0, function()
                btnShopChest.interactable = true
            end)
            BuyView:Show()
        end)

        local btnChest = trChestItem:GetComponentInChildren(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnChest)
        btnChest.onClick:RemoveAllListeners()
        btnChest.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onUseChestsBtnClick(i)
        end)

        local nodes = {goRedBG = goRedBG, goGreenBG = goGreenBG, goItemName = goItemName,
                    goTextMeshProCollectAll = goTextMeshProCollectAll, goNumNode = goNumNode,
                    TextMeshProChestCount = TextMeshProChestCount, goChestTipNode = goChestTipNode,
                    btnChest = btnChest, aniChest = aniChest, }

        table.insert(self.m_listChestItemNodes, nodes)

    end

end

function MedalMasterMainUI:initUIMiddle()
    local trMiddle = self.transform:FindDeepChild("UIMiddle")
    local listNames = {"PlatinumUI", "RoyalUI", "MasterUI"}
    self.m_listMedalInfoNodes = {}
    for i=1, 3 do
        local tr = trMiddle:FindDeepChild(listNames[i])
        local goNode = tr.gameObject
        local imageProgress = tr:FindDeepChild("imageProgress"):GetComponent(typeof(UnityUI.Image))
        local TextMeshProName = tr:FindDeepChild("TextMeshProName"):GetComponent(typeof(TextMeshProUGUI))
        local TextMeshProCurChestPointProgress = tr:FindDeepChild("TextMeshProCurChestPointProgress"):GetComponent(typeof(TextMeshProUGUI))
    
        local listGoStars = {}
        for nStarIndex=1, 5 do
            local name = "StarNode" .. nStarIndex
            local trStarNode = tr:FindDeepChild(name)
            local goStar = trStarNode:FindDeepChild("imageStar").gameObject
            table.insert(listGoStars, goStar)
        end

        local listGoMedalLogos = {}
        for i=1, 5 do
            local name = "MedalStar" .. i
            local goMedalLogo = tr:FindDeepChild(name).gameObject
            table.insert(listGoMedalLogos, goMedalLogo)
        end

        local goProgressNode = tr:FindDeepChild("ProgressNode").gameObject
        local goMedalCompleted = tr:FindDeepChild("MedalCompleted").gameObject
        local trBonusNode = tr:FindDeepChild("BonusNode")
        local goBonusNode = trBonusNode.gameObject
        local goBonusLockedNode = trBonusNode:FindDeepChild("BonusLockedNode").gameObject
        
        local goBonusAvailableIn = trBonusNode:FindDeepChild("BonusAvailableIn").gameObject

        local TextMeshProCountDown = trBonusNode:FindDeepChild("TextMeshProCountDown"):GetComponent(typeof(TextMeshProUGUI))
        -- 24:00:00
        local aniBtnCollect = trBonusNode:FindDeepChild("aniBtnCollect"):GetComponent(typeof(Unity.Animator))
        aniBtnCollect.transform.gameObject:SetActive(false)
        local btnCollect = trBonusNode:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCollect)
        btnCollect.onClick:RemoveAllListeners()
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onFreeBonusCollectBtnClick(btnCollect) -- 24小时领一次的奖
        end)

        local goBtnCollect = btnCollect.transform.gameObject

        -- BtnUnlockFreeBonusTip
        local tr1 = trBonusNode:FindDeepChild("BtnUnlockFreeBonusTip")
        local goBtnUnlockFreeBonusTip = tr1.gameObject
        -- goBtnUnlockFreeBonusTip:SetActive(false)
        local btnUnlockFreeBonusTip = tr1:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnUnlockFreeBonusTip)
        btnUnlockFreeBonusTip.onClick:RemoveAllListeners()
        btnUnlockFreeBonusTip.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onUnlockFreeBonusTipBtnClick(btnUnlockFreeBonusTip) -- 不到4级的 未解锁freebonus
        end)
        
        local nodes = { goNode = goNode,
            imageProgress = imageProgress, TextMeshProName = TextMeshProName, 
            TextMeshProCurChestPointProgress = TextMeshProCurChestPointProgress,
            listGoStars = listGoStars, listGoMedalLogos = listGoMedalLogos,
            goProgressNode = goProgressNode, goMedalCompleted = goMedalCompleted,
            goBonusNode = goBonusNode, goBonusLockedNode = goBonusLockedNode,
            TextMeshProCountDown = TextMeshProCountDown, goBtnCollect = goBtnCollect,
            goBonusAvailableIn = goBonusAvailableIn, goBtnUnlockFreeBonusTip = goBtnUnlockFreeBonusTip,
            aniBtnCollect = aniBtnCollect,
        }

        table.insert(self.m_listMedalInfoNodes, nodes)
    end
end

function MedalMasterMainUI:initUIAllMedalLogos()
    local trMiddle = self.transform:FindDeepChild("UIMiddle")

    -- local listNames = {"PlatinumUI", "RoyalUI", "MasterUI"}
    -- local trPlatinum = trMiddle:FindDeepChild(listNames[1])
    -- local trRoyal = trMiddle:FindDeepChild(listNames[2])
    -- local trMaster = trMiddle:FindDeepChild(listNames[3])

    self.m_listMedalLogos = {} -- 8个子表 每个子表5个元素
    for nLevel=1, 8 do
        local nodes = {}
        for nStar=1, 5 do
            local name = "Star" .. nStar .. "ElemLevel" .. nLevel
            local goLogo = trMiddle:FindDeepChild(name).gameObject
            table.insert(nodes, goLogo)
            goLogo:SetActive(false)
        end
        table.insert(self.m_listMedalLogos, nodes)
    end
end

function MedalMasterMainUI:RefreshLeftUI()
    local listGoLeft = {self.goPlatinumItems, self.goRoyalItems, self.goMasterItems}

    for i=1, 3 do
        listGoLeft[i]:SetActive(false)
    end
    
    local index = 1
    if self.m_nPageIndex <= 3 then
        index = 1
    elseif self.m_nPageIndex <= 6 then
        index = 2
    else
        index = 3
    end
    listGoLeft[index]:SetActive(true)

    local listPrizeParam = {LoungeConfig.listPlatinumParam, LoungeConfig.listRoyalParam,
                                LoungeConfig.listMasterParam}

    local nBaseCoins = LoungeConfig:getOneDollarCoins()

    local nStar, fProgress, nPlayerExp, nCurLevelExp = LoungeConfig:getMedalLevelInfo(self.m_nPageIndex)
    
    for i=1, 5 do
        local fcoef = listPrizeParam[index][i].prize
        local nPrize = math.floor(fcoef * nBaseCoins)

        local nPrizeNodeIndex = 5 * (index-1) + i
        local nodes = self.m_listMedalLevelPrizeNodes[nPrizeNodeIndex]
        nodes.goMore:SetActive(false)

        nodes.TextCoins.text = MoneyFormatHelper.numWithCommas(nPrize)

        if i <= nStar then
            nodes.goDone:SetActive(true)
            nodes.TextCoins.transform.gameObject:SetActive(false)
        else
            nodes.goDone:SetActive(false)
            nodes.TextCoins.transform.gameObject:SetActive(true)
        end
    end

    -- TOPUI..
    
    local nSeasonID = LoungeHandler.data.activityData.listMedalMasterData.nSeasonID
    -- 第几季
    self.TextMeshProSeasonNum.text = tostring(nSeasonID)

    -- 都五星之后的总奖励
    local nTotalPrize = math.floor(LoungeConfig.fTotalPrize * nBaseCoins)
    self.TextTotalPrize.text = MoneyFormatHelper.numWithCommas(nTotalPrize)
end

function MedalMasterMainUI:RefreshMiddleUI()
    local cnt = #self.m_listGoPagePoints
    for i=1, cnt do
        self.m_listGoPagePoints[i]:SetActive(false)
    end
    self.m_listGoPagePoints[self.m_nPageIndex]:SetActive(true)

    for i=1, 3 do
        self.m_listMedalInfoNodes[i].goNode:SetActive(false)
        self.m_listMedalInfoNodes[i].goBonusNode:SetActive(false)

        local listGoStars = self.m_listMedalInfoNodes[i].listGoStars
        for j=1, 5 do
            listGoStars[j]:SetActive(false)
        end
    end

    local index = 1
    if self.m_nPageIndex <= 3 then
        index = 1
    elseif self.m_nPageIndex <= 6 then
        index = 2
    else
        index = 3
    end
    self.m_listMedalInfoNodes[index].goNode:SetActive(true)
    self.m_listMedalInfoNodes[index].TextMeshProName.text = LoungeConfig.listName[self.m_nPageIndex]

    local nStar, fProgress, nPlayerExp, nCurLevelExp = LoungeConfig:getMedalLevelInfo(self.m_nPageIndex)
    self.m_listMedalInfoNodes[index].imageProgress.fillAmount = fProgress
    self.m_listMedalInfoNodes[index].TextMeshProCurChestPointProgress.text = 
                                    nPlayerExp .. "/" .. nCurLevelExp

                                    
    self.m_listMedalInfoNodes[index].goBonusNode:SetActive(true)
    self.m_listMedalInfoNodes[index].goBonusAvailableIn:SetActive(true)
    if nStar >= 4 then
        self.m_listMedalInfoNodes[index].goBtnUnlockFreeBonusTip:SetActive(false)
        -- 领奖倒计时更新等等。。
        -- self:UpdateFreeBonusNode() -- 有个协程会每秒钟调用
    else
        self.m_listMedalInfoNodes[index].goBonusLockedNode:SetActive(true)
        self.m_listMedalInfoNodes[index].goBonusAvailableIn:SetActive(false)

        self.m_listMedalInfoNodes[index].goBtnUnlockFreeBonusTip:SetActive(true)
    end

    local bCompleteFlag = false
    if nStar == 5 then
        bCompleteFlag = true
    end
    self.m_listMedalInfoNodes[index].goProgressNode:SetActive(not bCompleteFlag)
    self.m_listMedalInfoNodes[index].goMedalCompleted:SetActive(bCompleteFlag)

    for i=1, 5 do
        if i <= nStar then
            self.m_listMedalInfoNodes[index].listGoMedalLogos[i]:SetActive(true)
            self.m_listMedalInfoNodes[index].listGoStars[i]:SetActive(true)
        else
            self.m_listMedalInfoNodes[index].listGoMedalLogos[i]:SetActive(false)
            self.m_listMedalInfoNodes[index].listGoStars[i]:SetActive(false)
        end
    end
    
    for i=1, 8 do
        local logos = self.m_listMedalLogos[i]
        for j=1, 5 do
            logos[j]:SetActive(false)
        end
    end

    local medalLogos = self.m_listMedalLogos[self.m_nPageIndex]
    for i=1, nStar do
        medalLogos[i]:SetActive(true)
    end
end

function MedalMasterMainUI:RefreshRightUI()
    if not self:isActiveShow() then
        return
    end

    
    local playerData = LoungeHandler.data.activityData.listMedalMasterData
    
    self:UpdateFreeChestNode()
    
    for i=1, 4 do
        local  nodes = self.m_listChestItemNodes[i]
        local nChestNum = playerData.listChestCount[i]
        if nChestNum > 0 then
            nodes.goRedBG:SetActive(true)
            nodes.goGreenBG:SetActive(false)
            nodes.goItemName:SetActive(false)
            nodes.goTextMeshProCollectAll:SetActive(true)
            nodes.goNumNode:SetActive(true)
            nodes.TextMeshProChestCount.text = nChestNum

            nodes.aniChest:SetInteger("nPlayMode", 1)
        else
            nodes.goRedBG:SetActive(false)
            nodes.goGreenBG:SetActive(true)
            nodes.goItemName:SetActive(true)
            nodes.goTextMeshProCollectAll:SetActive(false)
            nodes.goNumNode:SetActive(false)
            nodes.TextMeshProChestCount.text = nChestNum
            
            nodes.aniChest:SetInteger("nPlayMode", 0)
        end
    end
end

function MedalMasterMainUI:RefreshUI()
    -- self.m_nPageIndex
    
    if self.goUnlockChestBonusTip.activeSelf then
        self.goUnlockChestBonusTip:SetActive(false)
    end
    if self.goCollectChestBonusTip.activeSelf then
        self.goCollectChestBonusTip:SetActive(false)
    end
    
    local index = 1
    if self.m_nPageIndex <= 3 then
        index = 1
    elseif self.m_nPageIndex <= 6 then
        index = 2
    else
        index = 3
    end

    self.m_listMedalInfoNodes[index].goBonusLockedNode:SetActive(true)
    self.m_listMedalInfoNodes[index].goBtnCollect:SetActive(false)
    self.m_listMedalInfoNodes[index].aniBtnCollect.transform.gameObject:SetActive(false)
    self.m_listMedalInfoNodes[index].TextMeshProCountDown.text = "00:00:00"
    
    -- 更新左侧区域
    self:RefreshLeftUI()
    --
    
    -- 更新右侧区域
    self:RefreshRightUI()
    --

    -- 更新中间区域
    self:RefreshMiddleUI()

    -- 更新5星之后的传奇箱子进度。。
    self:UpdateLengendaryNode()

end

-- 领奖倒计时更新等等。。
function MedalMasterMainUI:UpdateFreeChestNode()
    
    local playerData = LoungeHandler.data.activityData.listMedalMasterData
    local diffTime = playerData.nFreeChestLastLocalTime + LoungeConfig.FREECHESTTIME - TimeHandler:GetServerTimeStamp()
    if diffTime <= 0 then
        self.m_FreeChestNodes.goRedBG:SetActive(true)
        self.m_FreeChestNodes.goGreenBG:SetActive(false)
        self.m_FreeChestNodes.goCountDownNode:SetActive(false)

        self.m_btnFreeChestItem.interactable = true
    else
        self.m_FreeChestNodes.goRedBG:SetActive(false)
        self.m_FreeChestNodes.goGreenBG:SetActive(true)
        self.m_FreeChestNodes.goCountDownNode:SetActive(true)
        local strCountDown = LoungeConfig:formatDiffTime(diffTime)
        self.m_FreeChestNodes.TextMeshProCountDown.text = strCountDown
        
        self.m_btnFreeChestItem.interactable = false
    end

end

-- 领奖倒计时更新等等。。
function MedalMasterMainUI:UpdateFreeBonusNode()
    local index = 1
    if self.m_nPageIndex <= 3 then
        index = 1
    elseif self.m_nPageIndex <= 6 then
        index = 2
    else
        index = 3
    end
    
    local nStar, fProgress, nPlayerExp, nCurLevelExp = LoungeConfig:getMedalLevelInfo(self.m_nPageIndex)
    if nStar < 4 then
        if self.m_listMedalInfoNodes[index].goBtnCollect.activeSelf then
            self.m_listMedalInfoNodes[index].goBtnCollect:SetActive(false)
            self.m_listMedalInfoNodes[index].aniBtnCollect.transform.gameObject:SetActive(false)
        end
        return
    end
    -- 4星以内的不用更新倒计时。。

     -- 有几个赛季的数据
    local lastLocalTime = LoungeHandler.data.activityData.listMedalMasterData.listFreeBonusLastLocalTime[self.m_nPageIndex]
    local diffTime = (lastLocalTime + LoungeConfig.FREEBONUSTIME) - TimeHandler:GetServerTimeStamp()
    if diffTime <= 0 then
        self.m_listMedalInfoNodes[index].goBonusLockedNode:SetActive(false)
        self.m_listMedalInfoNodes[index].goBtnCollect:SetActive(true)

        local bFlag = CollectFreeBonusUI:isActiveShow()
        self.m_listMedalInfoNodes[index].aniBtnCollect.transform.gameObject:SetActive(not bFlag)
        
        if not self.goCollectChestBonusTip.activeSelf then
            self.goCollectChestBonusTip:SetActive(true)
        end

    else
        self.m_listMedalInfoNodes[index].goBonusLockedNode:SetActive(true)
        self.m_listMedalInfoNodes[index].goBtnCollect:SetActive(false)
        self.m_listMedalInfoNodes[index].aniBtnCollect.transform.gameObject:SetActive(false)
        
        if self.goCollectChestBonusTip.activeSelf then
            self.aniCollectChestBonusTip:Play("CollectChestBonusTiptuichu", -1, 0)
            LeanTween.delayedCall(0.9, function()
                self.goCollectChestBonusTip:SetActive(false)
            end)
        end

        local strDiffTime = LoungeConfig:formatDiffTime(diffTime) -- 把秒转换为类似 "02:10:21"
        self.m_listMedalInfoNodes[index].TextMeshProCountDown.text = strDiffTime
    end
    
end

function MedalMasterMainUI:onBtnTipClick(btnTip)
    
    btnTip.interactable = false
    LeanTween.delayedCall(1.0, function()
        btnTip.interactable = true
    end)

    GlobalAudioHandler:PlayBtnSound()
    MedalPayTable:Show()

    -- paytable
end

function MedalMasterMainUI:onBtnLeftClick()
    -- 预览上一页
    self.m_nPageIndex = self.m_nPageIndex - 1
    if self.m_nPageIndex < 1 then
        self.m_nPageIndex = 1
    end
    
    if self.m_nPageIndex == 1 then
        --self.m_btnLeftPage.interactable = false
        self.m_btnLeftPage.transform.gameObject:SetActive(false)
    else
        --self.m_btnLeftPage.interactable = true
        self.m_btnLeftPage.transform.gameObject:SetActive(true)
    end

    --self.m_btnRightPage.interactable = true
    self.m_btnRightPage.transform.gameObject:SetActive(true)
    
    self:RefreshUI()
end

function MedalMasterMainUI:onBtnRightClick()
    -- 预览下一页
    self.m_nPageIndex = self.m_nPageIndex + 1
    if self.m_nPageIndex > 8 then
        self.m_nPageIndex = 8
    end
    
    if self.m_nPageIndex == 8 then
        -- self.m_btnRightPage.interactable = false
        self.m_btnRightPage.transform.gameObject:SetActive(false)
    else
        -- self.m_btnRightPage.interactable = true
        self.m_btnRightPage.transform.gameObject:SetActive(true)
    end

    --self.m_btnLeftPage.interactable = true
    self.m_btnLeftPage.transform.gameObject:SetActive(true)

    self:RefreshUI()
end

function MedalMasterMainUI:onFreeChestItemBtnClick()
    -- 每12小时领取一个
    local listProbs = {10000, 2000, 200, 2} -- 对应4种enumCHESTTYPE类型的概率
    local index = LuaHelper.GetIndexByRate(listProbs)
    PopStackViewHandler:Show(MedalChestPopEffect, index, true, 1)
    
    LeanTween.delayedCall(1.5, function()
        local playerData = LoungeHandler.data.activityData.listMedalMasterData
        playerData.nFreeChestLastLocalTime = TimeHandler:GetServerTimeStamp()

        LoungeHandler:addChest(index, 1)
        LoungeHandler:SaveDb()
    end)

    self:UpdateFreeChestNode()
end

function MedalMasterMainUI:onGetChestsBtnClick()
    -- 打开商店
    BuyView:Show()
end

function MedalMasterMainUI:onUseChestsBtnClick(index)
    if UseMedalChestUI.m_coLevelUpAni ~= nil then
        return -- 上一个动画还没有运行结束
    end

    -- 1234 
    -- CommonItem -- RareItem -- EpicItem -- LegendaryItem
    
    local playerData = LoungeHandler.data.activityData.listMedalMasterData
    local nChestNum = playerData.listChestCount[index]
    if nChestNum <= 0 then
        -- tip
        local goTip = self.m_listChestItemNodes[index].goChestTipNode
        if not goTip.activeSelf then
            goTip:SetActive(true)
            self.m_listChestItemNodes[index].btnChest.interactable = false
            LeanTween.delayedCall(5.0, function()
                goTip:SetActive(false)
                self.m_listChestItemNodes[index].btnChest.interactable = true
            end)

            for i=1, 4 do
                if i ~= index then
                    self.m_listChestItemNodes[i].goChestTipNode:SetActive(false)
                    self.m_listChestItemNodes[i].btnChest.interactable = true
                end
            end
        end
        
    else
        -- 加数据。。做动画等..
        local enumChestType = index -- LoungeConfig.enumCHESTTYPE
        LoungeHandler:addChest(enumChestType, -nChestNum)
        
        local nChestPoint = LoungeConfig.listChestPoints[index]

        local nTotalLoungePoint = 0
        for j = 1, nChestNum do
            local fcoef = 1 + (math.random() - 0.5) * 1.3
            nTotalLoungePoint = nTotalLoungePoint + fcoef * nChestPoint
        end
        
        local nSeasonID = #LoungeHandler.data.activityData.listMedalMasterData
        local data = LoungeHandler.data.activityData.listMedalMasterData[nSeasonID]
        -- 返回8个medal分别分配到的点数
        local listLoungePoints = LoungeConfig:DistributeLoungePoint(nTotalLoungePoint)
        
        -- 结果预览界面上需要展示的数据
        self.listDistributionLoungePoints = listLoungePoints
        -- getLevelUpRewardCoins 这里会把分配的点数加到每个徽章上去了 
        -- 加完点数 获得的金币也加给玩家了 只是没有更新UI --  返回升级奖励值
        self.listLevelUpRewardCoins = LoungeConfig:getLevelUpRewardCoins(listLoungePoints)
        --

        UseMedalChestUI:Show(index)
        
    end

end

function MedalMasterMainUI:CheckGrandPrizeClaim()
    local bFlag = LoungeConfig:isAllMedalCompleted()
    if bFlag then
        
        local playerData = LoungeHandler.data.activityData.listMedalMasterData
        if not playerData.bGrandPrizeClaimed then
            AllMedalLevelTo5StarsUI:Show()
        end
    end
end

function MedalMasterMainUI:onUnlockFreeBonusTipBtnClick(btnUnlockFreeBonusTip)
    if not self.goUnlockChestBonusTip.activeSelf then
        self.goUnlockChestBonusTip:SetActive(true)
        btnUnlockFreeBonusTip.interactable = false
        LeanTween.delayedCall(3.5, function()
            self.goUnlockChestBonusTip:SetActive(false)
            btnUnlockFreeBonusTip.interactable = true
        end)
    end
end

function MedalMasterMainUI:onFreeBonusCollectBtnClick(btnCollect) -- 24小时领一次的奖
    btnCollect.interactable = false
    LeanTween.delayedCall(1.0, function()
        btnCollect.interactable = true
    end)
    
    CollectFreeBonusUI:Show(self.m_nPageIndex)
end

-- 需要有转屏操作就传一个ture，不需要的话就别传了
function MedalMasterMainUI:Hide(normalHide)
    LoungeAudioHandler:StopBackMusic()
    ViewAlphaAni:Hide(self.transform.gameObject)
end
