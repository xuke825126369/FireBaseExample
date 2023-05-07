BingoIAPConfig = {}

BingoIAPConfig.Type = {
    BingoBooster = 1,
    SuperBall = 2,
    WildBall = 3,
}

BingoIAPConfig.skuMap = {
    [BingoIAPConfig.Type.BingoBooster] = 
    {
        {productId = AllBuyCFG[5].productId, nBingoBoosterTime = 60 * 15, nAction = 10},
        {productId = AllBuyCFG[10].productId, nBingoBoosterTime = 60 * 30, nAction = 15},
        {productId = AllBuyCFG[15].productId, nBingoBoosterTime = 60 * 50, nAction = 20},
    },
    [BingoIAPConfig.Type.SuperBall] = 
    {
        {productId = AllBuyCFG[5].productId, nSuperBallCount = 10, nAction = 10},
        {productId = AllBuyCFG[10].productId, nSuperBallCount = 15, nAction = 15},
        {productId = AllBuyCFG[15].productId, nSuperBallCount = 20, nAction = 20},
    },
    [BingoIAPConfig.Type.WildBall] = 
    {
        {productId = AllBuyCFG[5].productId, nWildBallCount = 2, nAction = 10},
        {productId = AllBuyCFG[10].productId, nWildBallCount = 3, nAction = 15},
        {productId = AllBuyCFG[15].productId, nWildBallCount = 5, nAction = 20},
    },
}

BingoIAPConfig.skuMapOther = {}
for k, v in pairs(AllBuyCFG) do
    local productId = v.productId
    local nDollar = v.nDollar
    local nCount = k
    BingoIAPConfig.skuMapOther[productId] = nCount
end
