RainbowPickIAPConfig = {}

RainbowPickIAPConfig.Type = {
    PickBooster = 1,
    CoinBooster = 2,
    SuperPick = 3,
}

RainbowPickIAPConfig.F_COIN_RATIO = 0.5

--商品的价格,每次杀进程后刷新
function RainbowPickIAPConfig:getSku()
    local tableSku = {
        AllBuyCFG[1].productId,
        AllBuyCFG[1].productId,
        AllBuyCFG[1].productId
    }
    local time = RainbowPickDataHandler.data.endTime - TimeHandler:GetServerTimeStamp()
    local days = time // (3600 * 24)
    local nIndex = days % 3 + 1
    local productId = tableSku[nIndex]
    return productId
end 


RainbowPickIAPConfig.skuMap = {
    [RainbowPickIAPConfig.Type.PickBooster] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 10, nAction = 8},
        [AllBuyCFG[1].productId] = {nTime = 60 * 18, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 28, nAction = 15},
    },
    [RainbowPickIAPConfig.Type.CoinBooster] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 10, nAction = 8},
        [AllBuyCFG[1].productId] = {nTime = 60 * 15, nAction = 10},
        [AllBuyCFG[1].productId] = {nTime = 60 * 20, nAction = 15},
    },
    [RainbowPickIAPConfig.Type.SuperPick] = 
    {
        [AllBuyCFG[1].productId] = {nSuperPickCount = 8, nAction = 8},
        [AllBuyCFG[1].productId] = {nSuperPickCount = 10, nAction = 10},
        [AllBuyCFG[1].productId] = {nSuperPickCount = 15, nAction = 15},
    },
}

--活动期间游戏里其它内购给的Cook币
RainbowPickIAPConfig.skuMapOther = {
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 3,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 7,
    [AllBuyCFG[1].productId] = 7,
    [AllBuyCFG[1].productId] = 7,
    [AllBuyCFG[1].productId] = 7,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 9,
    [AllBuyCFG[1].productId] = 9,
    [AllBuyCFG[1].productId] = 9,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 12,
    [AllBuyCFG[1].productId] = 15,
    [AllBuyCFG[1].productId] = 17,
    [AllBuyCFG[1].productId] = 20,
    [AllBuyCFG[1].productId] = 22,
    [AllBuyCFG[1].productId] = 25,
    [AllBuyCFG[1].productId] = 27,
    [AllBuyCFG[1].productId] = 30,
    [AllBuyCFG[1].productId] = 35,
    [AllBuyCFG[1].productId] = 40,
    [AllBuyCFG[1].productId] = 45,
    [AllBuyCFG[1].productId] = 50,
}