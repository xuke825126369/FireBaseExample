ChutesRocketsIAPConfig = {}

ChutesRocketsIAPConfig.TYPE = {
    DICE_BOOSTER = 1,
    MORE_CANNON = 2,
    CANNON_BOOSTER = 3
}

ChutesRocketsIAPConfig.TYPE_NAME = LuaHelper.GetKeyValueSwitchTable(ChutesRocketsIAPConfig.TYPE)

ChutesRocketsIAPConfig.F_COIN_RATIO = 0.5 --在活动的商店里购买给的金币会比在外面购买给的少，这是倍率
ChutesRocketsIAPConfig.N_FIRE_AGAIN_DIAMOND = 100 --大炮再次开火的价格

--商品的价格,每次杀进程后刷新
function ChutesRocketsIAPConfig:getSku()
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

ChutesRocketsIAPConfig.skuMap = {
    [ChutesRocketsIAPConfig.TYPE.DICE_BOOSTER] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 15, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 30, nAction = 15},
        [AllBuyCFG[1].productId] = {nTime = 60 * 60, nAction = 20},
    },
    [ChutesRocketsIAPConfig.TYPE.MORE_CANNON] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 12, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 20, nAction = 15},
        [AllBuyCFG[1].productId] = {nTime = 60 * 30, nAction = 20},
    },
    [ChutesRocketsIAPConfig.TYPE.CANNON_BOOSTER] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 10, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 15, nAction = 15},
        [AllBuyCFG[1].productId] = {nTime = 60 * 20, nAction = 20},
    },
}

--活动期间游戏里其它内购给的
ChutesRocketsIAPConfig.skuMapOther = {
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 15,
    [AllBuyCFG[1].productId] = 15,
    [AllBuyCFG[1].productId] = 15,
    [AllBuyCFG[1].productId] = 20,
    [AllBuyCFG[1].productId] = 20,
    [AllBuyCFG[1].productId] = 20,
    [AllBuyCFG[1].productId] = 25,
    [AllBuyCFG[1].productId] = 25,
    [AllBuyCFG[1].productId] = 30,
    [AllBuyCFG[1].productId] = 30,
    [AllBuyCFG[1].productId] = 35,
    [AllBuyCFG[1].productId] = 35,
    [AllBuyCFG[1].productId] = 50,
}