BuyHandler = {}

BuyHandler.shopDiscountInfo = {
    {from = "2022/08/09 00:00:00",    to = "2022/08/09 00:00:00",   CoinsRatio = {1.6, 1.5, 1.4, 1.3, 1.2, 1.2},     DiamondRatio = {1.6, 1.5, 1.4, 1.3, 1.2, 1.2}},
    {from = "2022/08/09 00:00:00",    to = "2022/08/09 00:00:00",   CoinsRatio = {1.7, 1.6, 1.5, 1.3, 1.2, 1.2},     DiamondRatio = {1.6, 1.5, 1.4, 1.3, 1.2, 1.2}},
    {from = "2022/08/09 00:00:00",    to = "2022/08/09 00:00:00",   CoinsRatio = {1.6, 1.6, 1.3, 1.3, 1.2, 1.2},     DiamondRatio = {1.6, 1.5, 1.4, 1.3, 1.2, 1.2}},
    {from = "2022/08/09 00:00:00",    to = "2022/08/09 00:00:00",   CoinsRatio = {1.8, 1.6, 1.3, 1.3, 1.2, 1.2},     DiamondRatio = {1.6, 1.5, 1.4, 1.3, 1.2, 1.2}},
    {from = "2022/08/09 00:00:00",    to = "2022/08/09 00:00:00",   CoinsRatio = {1.6, 1.6, 1.4, 1.4, 1.2, 1.2},     DiamondRatio = {1.6, 1.5, 1.4, 1.3, 1.2, 1.2}},
}

function BuyHandler:Init()
    
end

function BuyHandler:orHaveRecharge()
    return PlayerHandler.nRecharge > 0
end

function BuyHandler:orDiscount(nSkuType)
    if PlayerHandler.nRecharge == 0 then
        return true, 3.0
    else
        local bDiscount = false
        local nFinalMultuile = 0
        if nSkuType == SkuInfoType.ShopCoins then
            bDiscount, nFinalMultuile = CommonDbHandler:checkHasCoinCouponFormShop()
        else
            bDiscount, nFinalMultuile = CommonDbHandler:checkHasDiamondCouponFormShop()
        end
        
        if bDiscount then
            return bDiscount, nFinalMultuile
        end
    end

    return false, 1.0 
end

function BuyHandler:GetMoneyCountByStore(nDollar)
    local shopDiscountRatio = self:GetDiscountRatio()
    local nGoldCount = FormulaHelper:GetAddMoneyBySpendDollar(nDollar)
    nGoldCount = nGoldCount * shopDiscountRatio
    return nGoldCount
end

function BuyHandler:getShopSkuInfo(productId, nSkuType)
    local bDiscount, nFinalMultuile = BuyHandler:orDiscount(nSkuType)
    local skuInfo = GameHelper:GetSimpleSkuInfoById(productId)
    local nDollar = skuInfo.nDollar

    if nSkuType == SkuInfoType.ShopCoins then
        skuInfo.nType = SkuInfoType.ShopCoins
        skuInfo.baseCoins = FormulaHelper:GetAddMoneyBySpendDollar(nDollar)
        skuInfo.finalCoins = skuInfo.baseCoins * nFinalMultuile
    else
        skuInfo.nType = SkuInfoType.ShopDiamonds
        skuInfo.baseDiamonds = FormulaHelper:GetAddSapphireBySpendDollar(nDollar)
        skuInfo.finalDiamonds = skuInfo.baseDiamonds * nFinalMultuile
    end

    return skuInfo
end 


