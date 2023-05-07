BoardQuestIAPConfig = {}

BoardQuestIAPConfig.TYPE = {
    DICE_BOOSTER = 1,
    MORE_CANNON = 2,
    CANNON_BOOSTER = 3
}

BoardQuestIAPConfig.TYPE_NAME = LuaHelper.GetKeyValueSwitchTable(BoardQuestIAPConfig.TYPE)

BoardQuestIAPConfig.F_COIN_RATIO = 0.5 --在活动的商店里购买给的金币会比在外面购买给的少，这是倍率
BoardQuestIAPConfig.N_FIRE_AGAIN_DIAMOND = 100 --大炮再次开火的价格

--商品的价格,每次杀进程后刷新
function BoardQuestIAPConfig:getSku()
    local tableSku = {
        AllBuyCFG[1].productId,
        AllBuyCFG[1].productId,
        AllBuyCFG[1].productId
    }

    local time = BoardQuestDataHandler.data.endTime - TimeHandler:GetServerTimeStamp()
    local days = time // (3600 * 24)
    local nIndex = days % 3 + 1
    local productId = tableSku[nIndex]

    return productId
end 

BoardQuestIAPConfig.skuMap = {
    [BoardQuestIAPConfig.TYPE.DICE_BOOSTER] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 15, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 30, nAction = 15},
        [AllBuyCFG[1].productId] = {nTime = 60 * 60, nAction = 20},
    },
    [BoardQuestIAPConfig.TYPE.MORE_CANNON] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 12, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 20, nAction = 15},
        [AllBuyCFG[1].productId] = {nTime = 60 * 30, nAction = 20},
    },
    [BoardQuestIAPConfig.TYPE.CANNON_BOOSTER] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 10, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 15, nAction = 15},
        [AllBuyCFG[1].productId] = {nTime = 60 * 20, nAction = 20},
    },
}

--活动期间游戏里其它内购给的
BoardQuestIAPConfig.skuMapOther = {
    [AllBuyCFG[1].productId] = 1,
    [AllBuyCFG[1].productId] = 2,
    [AllBuyCFG[1].productId] = 2,
    [AllBuyCFG[1].productId] = 2,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 9,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 11,
    [AllBuyCFG[1].productId] = 12,
    [AllBuyCFG[1].productId] = 13,
    [AllBuyCFG[1].productId] = 14,
    [AllBuyCFG[1].productId] = 15,
    [AllBuyCFG[1].productId] = 16,
    [AllBuyCFG[1].productId] = 18,
    [AllBuyCFG[1].productId] = 20,
    [AllBuyCFG[1].productId] = 22,
    [AllBuyCFG[1].productId] = 25,
}