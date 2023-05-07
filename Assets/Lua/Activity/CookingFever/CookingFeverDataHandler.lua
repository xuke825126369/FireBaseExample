CookingFeverDataHandler = {}

CookingFeverDataHandler.data = {}
CookingFeverDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/CookingFever.txt"
CookingFeverDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 5

CookingFeverDataHandler.m_mapPrize = {} --LevelFinal的金币奖励
CookingFeverDataHandler.m_mapDishPrize = {} --每道菜的金币奖励

CookingFeverDataHandler.fFinalPrizeRatio = 100
CookingFeverDataHandler.fIngredientRatio = 0.1
CookingFeverDataHandler.tableFLevelPrizeRatio = {5, 10, 15, 20, 25}
CookingFeverDataHandler.tableFDishPrizeRatio = {1.0, 1.5, 2.0, 2.5, 3.0}

function CookingFeverDataHandler:Init()
    if not GameConfig.COOKINGFEVER_FLAG then
        return
    end
    self:readFile()
    if self.data.endTime ~= ActiveManager.nActivityEndTime then --新赛季重置数据
        self:reset()
        self.data.endTime = ActiveManager.nActivityEndTime
    end

    self:updatePrize()
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    --self:Simulation()
end

function CookingFeverDataHandler:reset()
    self.data = {}
    self.data.m_nVersion = 1
    self.data.nAction = 15
    self.data.fProgress = 0 --收集进度

    self.data.bFirstTime = true

    self.data.m_nEndTime = self.m_nEndTime
    self.data.tableNBoosterEndTime = {0, 0}
    self.data.nWildBasketCount = 0
    self.data.fFinalPrizeRatioMutiplier = 1
    self:resetGameData()

    if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 1 then
        self.data.nAction = 50
    end
    if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 2 then
        self.data.nAction = 1000
        self.data.nWildBasketCount = 1000
    end
end

function CookingFeverDataHandler:resetGameData()
    self.data.nLevel = 1
    -- if GameConfig.PLATFORM_EDITOR then
    --     self.data.nLevel = 5
    --     self.data.nWildBasketCount = 1000
    -- end
    --仓库里的物品数量
    self.data.tableNIngredientCount =  LuaHelper.GetTable(0, CookingFeverConfig.N_INGREDIENT) 
    --是否煮过这道菜了
    self.data.tableBCooked =  LuaHelper.GetTable(false, CookingFeverConfig.N_DISH)
    self.data.tableNeedIngredient = self:getNeedIngredient(self.data.nLevel)
end

function CookingFeverDataHandler:getNetData()
    local netData = {}
    --netData.endTime = self.data.endTime
    netData.nAction = self.data.nAction
    --netData.nLevel = self.data.nLevel
    netData.tableNBoosterEndTime = self.data.tableNBoosterEndTime
    netData.nWildBasketCount = self.data.nWildBasketCount
    return netData
end

function CookingFeverDataHandler:synNetData(netData)
    --self.data.endTime = netData.endTime
    self.data.nAction = netData.nAction
    --self.data.nLevel = netData.nLevel
    self.data.tableNBoosterEndTime = netData.tableNBoosterEndTime
    self.data.nWildBasketCount = netData.nWildBasketCount
    -- if self.data.endTime ~= ActiveManager.nActivityEndTime then --新赛季重置数据
    --     self:reset()
    --     self.data.endTime = ActiveManager.nActivityEndTime
    -- end
    self:writeFile()
end

function CookingFeverDataHandler:writeFile()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function CookingFeverDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end
    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.data = rapidjson.decode(strData)
    Debug.LogLuaTable(self.data, "readFile")
end

function CookingFeverDataHandler:getNeedIngredient(nLevel)
    local tableDishes = CookingFeverConfig.LevelInfo[nLevel]
    local tableNeedIngredient =  LuaHelper.GetTable(0, CookingFeverConfig.N_INGREDIENT)
    for i = 1, #tableDishes do
        local tableIngredients = CookingFeverConfig.Recipe[tableDishes[i]].Ingredient
        local tableCount = CookingFeverConfig.Recipe[tableDishes[i]].Count
        for j = 1, #tableIngredients do
            local nIngredientId = tableIngredients[j]
            local nCount = tableCount[j]
            tableNeedIngredient[nIngredientId] = tableNeedIngredient[nIngredientId] + nCount * 10
        end
    end
    return tableNeedIngredient
end

--点击菜篮子给的材料种类和数量
function CookingFeverDataHandler:getRewardIngredients(nBasketIndex, nLevel)
    local nIngredientCount
    local nMin
    local nMax

    if nBasketIndex == 1 then
        nIngredientCount = math.random(4, 6) --期望值5个
        nMin = 3
        nMax = 5
    elseif nBasketIndex == 2 then
        nIngredientCount = math.random(9, 15) --期望值12个
        nMin = 5
        nMax = 7
    else
        nIngredientCount = math.random(21, 29) --期望值25个
        nMin = 7
        nMax = 10
    end
    
    return self:pickIngredient(nIngredientCount, nMin, nMax)
end

function CookingFeverDataHandler:pickIngredient(nPickCount, nMin, nMax)
    local tableNeedIngredient = self.data.tableNeedIngredient
    local nKind = math.random(nMin, nMax)
    local tableNIngredient =  LuaHelper.GetTable(0, CookingFeverConfig.N_INGREDIENT)
    local tablePick = LuaHelper.PickByWeight(tableNeedIngredient, nKind)
    local tablePickWeight =  LuaHelper.GetTable(0, CookingFeverConfig.N_INGREDIENT)
    for i = 1, #tablePick do
        local nIngredient = tablePick[i]
        tableNIngredient[nIngredient] = tableNIngredient[nIngredient] + 1
        tableNeedIngredient[nIngredient] = tableNeedIngredient[nIngredient] - 2
        tableNeedIngredient[nIngredient] = math.max(tableNeedIngredient[nIngredient], 1)
        tablePickWeight[nIngredient] = tableNeedIngredient[nIngredient]
    end
    nPickCount = nPickCount - #tablePick

    while nPickCount > 0 do
        local tablePick2 = LuaHelper.PickByWeight(tablePickWeight, nPickCount)
        for i = 1, #tablePick2 do
            local nIngredient = tablePick2[i]
            tableNIngredient[nIngredient] = tableNIngredient[nIngredient] + 1
            tableNeedIngredient[nIngredient] = tableNeedIngredient[nIngredient] - 2
            tableNeedIngredient[nIngredient] = math.max(tableNeedIngredient[nIngredient], 1)
            tablePickWeight[nIngredient] = tableNeedIngredient[nIngredient]
        end
        nPickCount = nPickCount - #tablePick2
    end
    return tableNIngredient
end

--是否有足够的材料做一道菜
function CookingFeverDataHandler:checkCanCook(nId)
    local tableIngredient = CookingFeverConfig.Recipe[nId].Ingredient
    local tableCount = CookingFeverConfig.Recipe[nId].Count
    local bCanCook = true
    for i = 1, #tableIngredient do
        local nIngredientId = tableIngredient[i]
        if self.data.tableNIngredientCount[nIngredientId] < tableCount[i] then
            bCanCook = false 
            break
        end
    end
    return bCanCook
end

--做一道菜,所有的数据处理都放在这里
function CookingFeverDataHandler:cook(nDishId)
    --减少材料
    local tableIngredient = CookingFeverConfig.Recipe[nDishId].Ingredient
    local tableCount = CookingFeverConfig.Recipe[nDishId].Count
    for i = 1, #tableIngredient do
        local nIngredientId = tableIngredient[i]
        if self.data.tableNIngredientCount[nIngredientId] < tableCount[i] then
            Debug.Log(string.format("self.data.tableNIngredientCount[nIngredientId] %s tableCount[i] %s nIngredientId %s", 
            self.data.tableNIngredientCount[nIngredientId], tableCount[i], nIngredientId))
        end
        self.data.tableNIngredientCount[nIngredientId] = self.data.tableNIngredientCount[nIngredientId] - tableCount[i]
    end
    --菜的奖励
    local nDishCoin = self.m_mapDishPrize[self.data.nLevel]
    PlayerHandler:AddCoin(nDishCoin)
    --弹窗
    CookingFeverFinishedDishUI:show(nDishId, nDishCoin, PlayerHandler.nGoldCount)
    --记录已经做过的菜
    self.data.tableBCooked[nDishId] = true
    CookingFeverMainUIPop:SetItem(self.data.nLevel)
    --完成一关的奖励
    local bAllCooked = self:checkAllCooked(self.data.nLevel)
    if bAllCooked then
        local nLevelWinCoin = self.m_mapPrize[self.data.nLevel]
        --把以后用不到的材料换成钱
        local nIngredientsCoin = 0 
        -- local tableIngredientUsed =  LuaHelper.GetTable(false, CookingFeverConfig.N_INGREDIENT)
        -- for nLevel = self.data.nLevel + 1, CookingFeverConfig.N_MAX_LEVEL do
        --     local tableDishes = CookingFeverConfig.LevelInfo[nLevel]
        --     for i = 1, #tableDishes do
        --         local tableIngredient = CookingFeverConfig.Recipe[tableDishes[i]].Ingredient
        --         for j = 1, #tableIngredient do
        --             local nIngredientId = tableIngredient[j]
        --             tableIngredientUsed[nIngredientId] = true
        --         end
        --     end
        -- end
        for i = 1, CookingFeverConfig.N_INGREDIENT do
            local nCount = self.data.tableNIngredientCount[i]
            if nCount > 0 then
                nIngredientsCoin = nIngredientsCoin + nCount * self.nIngredientPrize    
                self.data.tableNIngredientCount[i] = 0
            end
        end
        --奖钱
        local nToalWinCoin = nLevelWinCoin + nIngredientsCoin
        PlayerHandler:AddCoin(nToalWinCoin)
        --奖卡包
        --检测卡牌是否开启
        local bIsSlotsCardsOpen = SlotsCardsManager:orActivityOpen()
        if bIsSlotsCardsOpen then
            local nPackType = CookingFeverConfig.LevelRewardCardPack[self.data.nLevel].nPackType
            local nCount = CookingFeverConfig.LevelRewardCardPack[self.data.nLevel].nCount
            SlotsCardsGiftManager:getStampPackInActive(nPackType, nCount)

            CookingFeverLevelPrizeSplashUI:show(nLevelWinCoin, nIngredientsCoin, PlayerHandler.nGoldCount, nPackType, nCount)
        else
            CookingFeverLevelPrizeSplashUI:show(nLevelWinCoin, nIngredientsCoin, PlayerHandler.nGoldCount)
        end

        self.data.nLevel = self.data.nLevel + 1
        if self.data.nLevel <= CookingFeverConfig.N_MAX_LEVEL then
            self.data.tableNeedIngredient = self:getNeedIngredient(self.data.nLevel)
            CookingFeverFinalPrizeUI:show(self.data.nLevel)
        else --完成所有关卡
            PlayerHandler:AddCoin(self.nFinalPrize)

            if SlotsCardsManager:orActivityOpen() then
                local nPackType = CookingFeverConfig.FinalPrizeRewardCardPack.nPackType
                local nCount = CookingFeverConfig.FinalPrizeRewardCardPack.nCount
                SlotsCardsGiftManager:getStampPackInActive(nPackType, nCount)
                --弹窗
                CookingFeverFinalPrizeSplashUI:show(self.nFinalPrize, PlayerHandler.nGoldCount, nPackType, nCount)
            else
                CookingFeverFinalPrizeSplashUI:show(self.nFinalPrize, PlayerHandler.nGoldCount)
            end

            self:resetGameData()
            self.data.fFinalPrizeRatioMutiplier = self.data.fFinalPrizeRatioMutiplier + 0.1
            self:updatePrize()
            CookingFeverFinalPrizeUI:show(self.data.nLevel)
        end
    end
    self:writeFile()
end

function CookingFeverDataHandler:checkAllCooked(nLevel)
    local bAllCooked = true
    local tableNDishes = CookingFeverConfig.LevelInfo[nLevel]
    for i = 1, #tableNDishes do
        if not self.data.tableBCooked[tableNDishes[i]] then
            bAllCooked = false
            break
        end
    end
    return bAllCooked
end

function CookingFeverDataHandler:addWildBasketCount(count)
    self.data.nWildBasketCount = self.data.nWildBasketCount + count
    self:writeFile()
end

function CookingFeverDataHandler:AddBoosterEndTime(nAddTime, i)
    if self.data.tableNBoosterEndTime[i] > TimeHandler:GetServerTimeStamp() then
        self.data.tableNBoosterEndTime[i] = self.data.tableNBoosterEndTime[i] + nAddTime
    else
        self.data.tableNBoosterEndTime[i] = TimeHandler:GetServerTimeStamp() + nAddTime
    end
end

function CookingFeverDataHandler:checkInBoosterTime(i)
    return self.data.tableNBoosterEndTime[i] and self.data.tableNBoosterEndTime[i] > TimeHandler:GetServerTimeStamp()
end

-- 进度条走满加5个
function CookingFeverDataHandler:refreshAddSpinProgress(data)
    --根据押注大小增加进度
    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.CookingFever)
    
    self.data.fProgress = self.data.fProgress + value
    
    local isMax = self.data.fProgress >= 1
    local isCoinReachMax = false
    if isMax then
        while self.data.fProgress >= 1 do
            self.data.fProgress = self.data.fProgress - 1
        end
        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.CookingFever)
        if self:checkInBoosterTime(1) then
            nAddCount = nAddCount * 2
        end

        --收集了硬币，然后硬币到达了上限
        if self.data.nAction + nAddCount >= CookingFeverConfig.N_MAX_ACTION then
            isCoinReachMax = true
            nAddCount = math.max(CookingFeverConfig.N_MAX_ACTION - self.data.nAction, 0)
        end
        self.data.nAction = self.data.nAction + nAddCount
    end
    self:writeFile()
    return isMax, isCoinReachMax
end

function CookingFeverDataHandler:onPurchaseDoneNotifycation(data)
    if ActiveManager.activeType ~= ActiveType.CookingFever then return end
    local skuInfo = data.skuInfo
    if skuInfo.nType == SkuInfoType.CookingFever then
        --CookingFever里的商店内购
        local skuMap = CookingFeverIAPConfig.skuMap[skuInfo.nActiveIAPType]
        local info = skuMap[data.productId]
        ActivityHelper:AddMsgCountData("nAction", info.nAction)
        if skuInfo.nActiveIAPType == CookingFeverIAPConfig.Type.CoinBooster then
            self:AddBoosterEndTime(info.nTime, 1)
        elseif skuInfo.nActiveIAPType == CookingFeverIAPConfig.Type.BasketBooster then
            self:AddBoosterEndTime(info.nTime, 2)
        elseif skuInfo.nActiveIAPType == CookingFeverIAPConfig.Type.WildBasket then
            ActivityHelper:AddMsgCountData("nWildBasketCount", info.nWildBasketCount)
        end
    else
        --CookingFever以外的内购给Cook币
        local nAction = CookingFeverIAPConfig.skuMapOther[data.productId]
        ActivityHelper:AddMsgCountData("nAction", nAction)
    end
    self:writeFile()
end

--以1美金为参考
function CookingFeverDataHandler:getBasePrize()
    local strSKuKey = AllBuyCFG[1].productId
    local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nBasePrize = skuInfo.baseCoins
    return nBasePrize
end

function CookingFeverDataHandler:updatePrize()
    local fBasePrize = self:getBasePrize()   
    self.nFinalPrize = fBasePrize * self.fFinalPrizeRatio * self.data.fFinalPrizeRatioMutiplier --完成所有关给的奖励
    self.nFinalPrize = math.floor( self.nFinalPrize +0.1 )
    self.nIngredientPrize = fBasePrize * self.fIngredientRatio --一个材料的奖励
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        self.m_mapPrize[i] = fBasePrize * self.tableFLevelPrizeRatio[i] * self.data.fFinalPrizeRatioMutiplier --完成一关给的奖励
        self.m_mapDishPrize[i] = fBasePrize * self.tableFDishPrizeRatio[i] --做一道菜给的奖励
    end

    --完成一轮能赚相当于多少美元的钱
    self.nTotalWin = self.fFinalPrizeRatio + LuaHelper.GetSum(self.tableFLevelPrizeRatio)
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        local nDishCount = #CookingFeverConfig.LevelInfo[i]
        self.nTotalWin = self.nTotalWin + self.tableFDishPrizeRatio[i] * nDishCount
    end
end

function CookingFeverDataHandler:Simulation()
    self:resetGameData()
    --正常测试,过一关之前，会把能做的菜都做了

    --每关每种菜做一道需要的材料
    local tableNNeedIngredient = {}
    for nLevel = 1, CookingFeverConfig.N_MAX_LEVEL do
        local tableDishes = CookingFeverConfig.LevelInfo[nLevel]
        tableNNeedIngredient[nLevel] =  LuaHelper.GetTable(0, CookingFeverConfig.N_INGREDIENT)
        for i = 1, #tableDishes do
            local nDishId = tableDishes[i]
            local tableIngredients = CookingFeverConfig.Recipe[nDishId].Ingredient
            local tableCount = CookingFeverConfig.Recipe[nDishId].Count
            for k, nIngredientId in pairs(tableIngredients) do
                tableNNeedIngredient[nLevel][nIngredientId] = tableNNeedIngredient[nLevel][nIngredientId] + tableCount[k]
            end
        end
        --Debug.LogTable(tableNNeedIngredient[nLevel])
    end
    --每关及以后的关需要用到的材料种类，完成一关时将以后不需要的材料变成钱时需要用到
    local tableIngredientUsed = {} 
    for nLevel = 2, CookingFeverConfig.N_MAX_LEVEL + 1 do
        tableIngredientUsed[nLevel] =  LuaHelper.GetTable(false, CookingFeverConfig.N_INGREDIENT)
        if nLevel <= CookingFeverConfig.N_MAX_LEVEL then
            for i = nLevel, CookingFeverConfig.N_MAX_LEVEL do
                for nIngredientId = 1, CookingFeverConfig.N_INGREDIENT do
                    if tableNNeedIngredient[i][nIngredientId] > 0 then
                        tableIngredientUsed[nLevel][nIngredientId] = true
                    end
                end
            end
        end
    end

    local tableExtraDishCount =  LuaHelper.GetTable(0, CookingFeverConfig.N_MAX_LEVEL)
    local tableExtraIngredientCount =  LuaHelper.GetTable(0, CookingFeverConfig.N_MAX_LEVEL, CookingFeverConfig.N_INGREDIENT)
    local nExtraDishWin = 0
    local nExtraIngredientsWin = 0
    local nTestTime = 20
    local nWildBasketCount = 0
    local tableBasketRate = {1, 1, 1} 
    local tableNBasket =  LuaHelper.GetTable(0, CookingFeverConfig.N_MAX_LEVEL, 3) --买篮子的数量
    for c = 1, nTestTime do
        self:resetGameData()
        --需要的材料的数量
        for nLevel = 1, CookingFeverConfig.N_MAX_LEVEL do 
            self.data.tableNeedIngredient = self:getNeedIngredient(nLevel)
            --循环购买篮子，并判断
            for i = 1, 1000 do
                local nBasketIndex = LuaHelper.GetIndexByRate(tableBasketRate)
                local tableNIngredient = self:getRewardIngredients(nBasketIndex, nLevel)
                tableNBasket[nLevel][nBasketIndex] = tableNBasket[nLevel][nBasketIndex] + 1
                for i = 1, CookingFeverConfig.N_INGREDIENT do
                    self.data.tableNIngredientCount[i] = self.data.tableNIngredientCount[i] + tableNIngredient[i]
                end 
        
                local nNeedIngredient = 0 --还差多少个材料能收集完
                for i = 1, CookingFeverConfig.N_INGREDIENT do
                    if tableNNeedIngredient[nLevel][i] > self.data.tableNIngredientCount[i] then
                        nNeedIngredient = nNeedIngredient + (tableNNeedIngredient[nLevel][i] - self.data.tableNIngredientCount[i])
                    end
                end
        
                if nNeedIngredient <= nWildBasketCount then
                    --扣除用掉的材料
                    for i = 1, CookingFeverConfig.N_INGREDIENT do
                        self.data.tableNIngredientCount[i] = self.data.tableNIngredientCount[i] - tableNNeedIngredient[nLevel][i]
                        self.data.tableNIngredientCount[i] = math.max(self.data.tableNIngredientCount[i], 0)
                        --在CookMore之前剩余的材料
                        if self.data.tableNIngredientCount[i] > 0 then
                            tableExtraIngredientCount[nLevel][i] = tableExtraIngredientCount[nLevel][i] + self.data.tableNIngredientCount[i]
                        end
                    end
                    --用剩余的材料做菜
                    local tableDishes = CookingFeverConfig.LevelInfo[nLevel]
                    local nDishIndex = 1
                    while nDishIndex <= #tableDishes do
                        local nDishId = tableDishes[nDishIndex]
                        local tableIngredients = CookingFeverConfig.Recipe[nDishId].Ingredient
                        local tableCount = CookingFeverConfig.Recipe[nDishId].Count
                        local bCanCook = true
                        for i = 1, #tableIngredients do
                            local nIngredientId = tableIngredients[i]
                            if self.data.tableNIngredientCount[nIngredientId] < tableCount[i] then
                                bCanCook = false
                            end
                        end
                        if bCanCook then
                            --减少材料，增加金币
                            for i = 1, #tableIngredients do
                                local nIngredientId = tableIngredients[i]
                                self.data.tableNIngredientCount[nIngredientId] = self.data.tableNIngredientCount[nIngredientId] - tableCount[i]
                                nExtraDishWin = nExtraDishWin + self.tableFDishPrizeRatio[nLevel]
                                tableExtraDishCount[nLevel] = tableExtraDishCount[nLevel] + 1
                            end
                        else
                            nDishIndex = nDishIndex + 1
                        end
                    end

                    --以后关卡用不到的材料都换成金币
                    for nIngredientId = 1, CookingFeverConfig.N_INGREDIENT do
                        if self.data.tableNIngredientCount[nIngredientId] > 0 then
                            nExtraIngredientsWin = nExtraIngredientsWin + self.data.tableNIngredientCount[nIngredientId] * self.fIngredientRatio
                            self.data.tableNIngredientCount[nIngredientId] = 0
                        end
                    end
                    break
                end
            end
        end
    end
    self:resetGameData()
    local strFile = ""
    strFile = strFile.."不断地买指定的菜篮子，直到本关所有的菜都可以做一道，然后点完所有的CookMore，然后进入下一关\n"

    strFile = strFile.."每关可以用 "..(nWildBasketCount).."个WildBasket 的话\n"

    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        for j = 1, 3 do
            tableNBasket[i][j] = tableNBasket[i][j] / nTestTime
        end
    end

    local nTotalCoinCount = 0
    local nTotalCount1 = 0
    local nTotalCount2 = 0
    local nTotalCount3 = 0
    local nPrice1 = CookingFeverConfig.tableBasketPrice[1]
    local nPrice2 = CookingFeverConfig.tableBasketPrice[2]
    local nPrice3 = CookingFeverConfig.tableBasketPrice[3]
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        local nCount1= tableNBasket[i][1]
        local nCount2= tableNBasket[i][2]
        local nCount3= tableNBasket[i][3]
        strFile = strFile..string.format("过第%s关平均需要 %s 个 %s块 %s 个 %s块 %s 个 %s块的篮子", i, nCount1, nPrice1, nCount2, nPrice2, nCount3, nPrice3).."\n"
        nTotalCoinCount = nTotalCoinCount + nCount1 * nPrice1
        nTotalCoinCount = nTotalCoinCount + nCount2 * nPrice2
        nTotalCoinCount = nTotalCoinCount + nCount3 * nPrice3
        nTotalCount1 = nTotalCount1 + nCount1
        nTotalCount2 = nTotalCount2 + nCount2
        nTotalCount3 = nTotalCount3 + nCount3
    end
    strFile = strFile..string.format("完成一轮平均需要 %s 个 %s块 %s 个 %s块 %s 个 %s块的篮子", nTotalCount1, nPrice1, nTotalCount2, nPrice2, nTotalCount3, nPrice3).."\n"
    strFile = strFile..string.format("完成一轮平均需要 %s块", nTotalCoinCount).."\n"

    strFile = strFile.."\n"
    nExtraDishWin = nExtraDishWin / nTestTime
    nExtraIngredientsWin = nExtraIngredientsWin / nTestTime
    strFile = strFile.."每种菜各煮一道+完成一关+完成所有关卡 赚的钱"..(self.nTotalWin).."\n"
    strFile = strFile.."CookMore 赚的钱 "..string.format("%0.2f", nExtraDishWin).."\n"
    strFile = strFile.."多余材料 赚的钱 "..string.format("%0.2f", nExtraIngredientsWin).."\n"
    local nTotalWin = self.nTotalWin + nExtraDishWin + nExtraIngredientsWin
    strFile = strFile.."完成一轮能赚相当于 "..string.format("%0.2f", nTotalWin).." 美元的钱\n"
    strFile = strFile..string.format("%0.3f个硬币能换1美元的钱\n", nTotalCoinCount / nTotalWin)

    strFile = strFile.."\n"
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        strFile = strFile..string.format("第%s关可以CookMore的数量 %s\n", i, tableExtraDishCount[i]/nTestTime)
    end
    strFile = strFile.."\n"

    --每关每种菜都做一道后多余的材料
    for nLevel = 1, CookingFeverConfig.N_MAX_LEVEL do
        strFile = strFile..string.format("第%s关每种菜都做一道后多余的材料\n", nLevel)
        local tableNIngredientCount = tableExtraIngredientCount[nLevel]
        for k, v in pairs(tableNIngredientCount) do
            if v > 0 then
                strFile = strFile..string.format("%s 数量%s\n", CookingFeverConfig:getIngredientNameById(k) , v / nTestTime)
            end
        end
        strFile = strFile.."\n"
    end

    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir..string.format("CookingFever.txt")
    local file = io.open(path, "w")
    if file ~= nil then
        file:write(strFile)
        file:close()
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end
end

function CookingFeverDataHandler:SimulationOld()
    self:resetGameData()
    --正常测试,过一关之前，会把能做的菜都做了

    --每关每种菜做一道需要的材料
    local tableNNeedIngredient = {}
    for nLevel = 1, CookingFeverConfig.N_MAX_LEVEL do
        local tableDishes = CookingFeverConfig.LevelInfo[nLevel]
        tableNNeedIngredient[nLevel] =  LuaHelper.GetTable(0, CookingFeverConfig.N_INGREDIENT)
        for i = 1, #tableDishes do
            local nDishId = tableDishes[i]
            local tableIngredients = CookingFeverConfig.Recipe[nDishId].Ingredient
            local tableCount = CookingFeverConfig.Recipe[nDishId].Count
            for k, nIngredientId in pairs(tableIngredients) do
                tableNNeedIngredient[nLevel][nIngredientId] = tableNNeedIngredient[nLevel][nIngredientId] + tableCount[k]
            end
        end
        --Debug.LogTable(tableNNeedIngredient[nLevel])
    end
    --每关及以后的关需要用到的材料种类，完成一关时将以后不需要的材料变成钱时需要用到
    local tableIngredientUsed = {} 
    for nLevel = 2, CookingFeverConfig.N_MAX_LEVEL + 1 do
        tableIngredientUsed[nLevel] =  LuaHelper.GetTable(false, CookingFeverConfig.N_INGREDIENT)
        if nLevel <= CookingFeverConfig.N_MAX_LEVEL then
            for i = nLevel, CookingFeverConfig.N_MAX_LEVEL do
                for nIngredientId = 1, CookingFeverConfig.N_INGREDIENT do
                    if tableNNeedIngredient[i][nIngredientId] > 0 then
                        tableIngredientUsed[nLevel][nIngredientId] = true
                    end
                end
            end
        end
    end

    local tableExtraDishCount =  LuaHelper.GetTable(0, CookingFeverConfig.N_MAX_LEVEL)
    local tableExtraIngredientCount =  LuaHelper.GetTable(0, CookingFeverConfig.N_MAX_LEVEL, CookingFeverConfig.N_INGREDIENT)
    local nExtraDishWin = 0
    local nExtraIngredientsWin = 0
    local nTestTime = 50
    local nWildBasketCount = 0
    local tableNBasket =  LuaHelper.GetTable(0, CookingFeverConfig.N_MAX_LEVEL) --买篮子的数量
    local nBasketIndex = 3
    for c = 1, nTestTime do
        self:resetGameData()
        --需要的材料的数量
        for nLevel = 1, CookingFeverConfig.N_MAX_LEVEL do 
            --循环购买篮子，并判断
            for i = 1, 1000 do
                tableNBasket[nLevel] = tableNBasket[nLevel] + 1
                local tableNIngredient = self:getRewardIngredients(nBasketIndex, nLevel)
                for i = 1, CookingFeverConfig.N_INGREDIENT do
                    self.data.tableNIngredientCount[i] = self.data.tableNIngredientCount[i] + tableNIngredient[i]
                end 
        
                local nNeedIngredient = 0 --还差多少个材料能收集完
                for i = 1, CookingFeverConfig.N_INGREDIENT do
                    if tableNNeedIngredient[nLevel][i] > self.data.tableNIngredientCount[i] then
                        nNeedIngredient = nNeedIngredient + (tableNNeedIngredient[nLevel][i] - self.data.tableNIngredientCount[i])
                    end
                end
        
                if nNeedIngredient <= nWildBasketCount then
                    --扣除用掉的材料
                    for i = 1, CookingFeverConfig.N_INGREDIENT do
                        self.data.tableNIngredientCount[i] = self.data.tableNIngredientCount[i] - tableNNeedIngredient[nLevel][i]
                        self.data.tableNIngredientCount[i] = math.max(self.data.tableNIngredientCount[i], 0)
                        --在CookMore之前剩余的材料
                        if self.data.tableNIngredientCount[i] > 0 then
                            tableExtraIngredientCount[nLevel][i] = tableExtraIngredientCount[nLevel][i] + self.data.tableNIngredientCount[i]
                        end
                    end
                    --用剩余的材料做菜
                    local tableDishes = CookingFeverConfig.LevelInfo[nLevel]
                    local nDishIndex = 1
                    while nDishIndex <= #tableDishes do
                        local nDishId = tableDishes[nDishIndex]
                        local tableIngredients = CookingFeverConfig.Recipe[nDishId].Ingredient
                        local tableCount = CookingFeverConfig.Recipe[nDishId].Count
                        local bCanCook = true
                        for i = 1, #tableIngredients do
                            local nIngredientId = tableIngredients[i]
                            if self.data.tableNIngredientCount[nIngredientId] < tableCount[i] then
                                bCanCook = false
                            end
                        end
                        if bCanCook then
                            --减少材料，增加金币
                            for i = 1, #tableIngredients do
                                local nIngredientId = tableIngredients[i]
                                self.data.tableNIngredientCount[nIngredientId] = self.data.tableNIngredientCount[nIngredientId] - tableCount[i]
                                nExtraDishWin = nExtraDishWin + self.tableFDishPrizeRatio[nLevel]
                                tableExtraDishCount[nLevel] = tableExtraDishCount[nLevel] + 1
                            end
                        else
                            nDishIndex = nDishIndex + 1
                        end
                    end

                    --以后关卡用不到的材料都换成金币
                    for nIngredientId = 1, CookingFeverConfig.N_INGREDIENT do
                        if self.data.tableNIngredientCount[nIngredientId] > 0 then
                            if not tableIngredientUsed[nLevel + 1][nIngredientId] then
                                nExtraIngredientsWin = nExtraIngredientsWin + self.data.tableNIngredientCount[nIngredientId] * self.fIngredientRatio
                                self.data.tableNIngredientCount[nIngredientId] = 0
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    self:resetGameData()
    local strFile = ""
    strFile = strFile.."不断地买指定的菜篮子，直到本关所有的菜都可以做一道，然后点完所有的CookMore，然后进入下一关\n"

    strFile = strFile.."每关可以用 "..(nWildBasketCount).."个WildBasket 的话\n"

    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        tableNBasket[i] = tableNBasket[i]/nTestTime
    end
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        strFile = strFile..string.format("第%s关平均需要 %s 个指定的篮子能过关", i, tableNBasket[i]).."\n"
    end
    local nTotalBasketCount = LuaHelper.GetSum(tableNBasket)
    local nBasketPrize = CookingFeverConfig.tableBasketPrice[nBasketIndex]
    local nTotalCoinCount = nTotalBasketCount * nBasketPrize
    strFile = strFile..string.format("平均需要 %s 个%s块篮子， %s 个硬币 完成一轮\n", nTotalBasketCount, nBasketPrize, nTotalCoinCount)

    strFile = strFile.."\n"
    nExtraDishWin = nExtraDishWin / nTestTime
    nExtraIngredientsWin = nExtraIngredientsWin / nTestTime
    strFile = strFile.."每种菜各煮一道+完成一关+完成所有关卡 赚的钱"..(self.nTotalWin).."\n"
    strFile = strFile.."CookMore 赚的钱 "..string.format("%0.2f", nExtraDishWin).."\n"
    strFile = strFile.."多余材料 赚的钱 "..string.format("%0.2f", nExtraIngredientsWin).."\n"
    local nTotalWin = self.nTotalWin + nExtraDishWin + nExtraIngredientsWin
    strFile = strFile.."完成一轮能赚相当于 "..string.format("%0.2f", nTotalWin).." 美元的钱\n"
    strFile = strFile..string.format("%0.3f个硬币能换1美元的钱\n", nTotalCoinCount / nTotalWin)

    strFile = strFile.."\n"
    for i = 1, CookingFeverConfig.N_MAX_LEVEL do
        strFile = strFile..string.format("第%s关可以CookMore的数量 %s\n", i, tableExtraDishCount[i]/nTestTime)
    end
    strFile = strFile.."\n"

    --每关每种菜都做一道后多余的材料
    for nLevel = 1, CookingFeverConfig.N_MAX_LEVEL do
        strFile = strFile..string.format("第%s关每种菜都做一道后多余的材料\n", nLevel)
        local tableNIngredientCount = tableExtraIngredientCount[nLevel]
        for k, v in pairs(tableNIngredientCount) do
            if v > 0 then
                strFile = strFile..string.format("%s 数量%s\n", CookingFeverConfig:getIngredientNameById(k) , v / nTestTime)
            end
        end
        strFile = strFile.."\n"
    end

    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir..string.format("CookingFever%s.txt", nBasketIndex)
    local file = io.open(path, "w")
    if file ~= nil then
        file:write(strFile)
        file:close()
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end
end


