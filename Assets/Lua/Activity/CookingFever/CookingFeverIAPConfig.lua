CookingFeverIAPConfig = {}

CookingFeverIAPConfig.F_COIN_RATIO = 0.5 --在活动的商店里购买给的金币会比在外面购买给的少，这是倍率

--商品的价格,每次杀进程后刷新
function CookingFeverIAPConfig:getSku()
    local tableSku = {
        AllBuyCFG[1].productId,
        AllBuyCFG[1].productId,
        AllBuyCFG[1].productId
    }
    local time = CookingFeverDataHandler.data.endTime - TimeHandler:GetServerTimeStamp()
    local days = time // (3600 * 24)
    local nIndex = days % 3 + 1
    local productId = tableSku[nIndex]
    return productId
end 

CookingFeverIAPConfig.Type = {
    CoinBooster = 1,
    BasketBooster = 2,
    WildBasket = 3,
}

CookingFeverIAPConfig.skuMap = {
    [CookingFeverIAPConfig.Type.CoinBooster] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 20, nAction = 20},
        [AllBuyCFG[1].productId] = {nTime = 60 * 30, nAction = 30},
        [AllBuyCFG[1].productId] = {nTime = 60 * 50, nAction = 40},
    },
    [CookingFeverIAPConfig.Type.BasketBooster] = 
    {
        [AllBuyCFG[1].productId] = {nTime = 60 * 10, nAction = 20},
        [AllBuyCFG[1].productId] = {nTime = 60 * 15, nAction = 30},
        [AllBuyCFG[1].productId] = {nTime = 60 * 20, nAction = 40},
    },
    [CookingFeverIAPConfig.Type.WildBasket] = 
    {       
        [AllBuyCFG[1].productId] = {nWildBasketCount = 2, nAction = 20},
        [AllBuyCFG[1].productId] = {nWildBasketCount = 5, nAction = 30},
        [AllBuyCFG[1].productId] = {nWildBasketCount = 8, nAction = 40},
    },
}

--其它内购给的Cook币
CookingFeverIAPConfig.skuMapOther = {
    [AllBuyCFG[1].productId] = 2,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 5,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 6,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 8,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 10,
    [AllBuyCFG[1].productId] = 12,
    [AllBuyCFG[1].productId] = 15,
    [AllBuyCFG[1].productId] = 20,
    [AllBuyCFG[1].productId] = 25,
    [AllBuyCFG[1].productId] = 30,
    [AllBuyCFG[1].productId] = 35,
    [AllBuyCFG[1].productId] = 40,
    [AllBuyCFG[1].productId] = 45,
    [AllBuyCFG[1].productId] = 50,
    [AllBuyCFG[1].productId] = 55,
    [AllBuyCFG[1].productId] = 60,
    [AllBuyCFG[1].productId] = 65,
    [AllBuyCFG[1].productId] = 70,
    [AllBuyCFG[1].productId] = 75,
}