GameHelper = {}

function GameHelper:getStreamingAssetsPathUrl(relativePath)
    if CS.GameConfig.PLATFORM_EDITOR then
        return "file:///"..Unity.Application.streamingAssetsPath..relativePath
    elseif CS.GameConfig.PLATFORM_ANDROID then
        return "file://"..Unity.Application.streamingAssetsPath..relativePath
    elseif CS.GameConfig.PLATFORM_IOS then
        return "file://"..Unity.Application.streamingAssetsPath..relativePath
    else
        Debug.Assert(false)
    end
end

function GameHelper:orInHoliday()
    local beginTime = CS.System.DateTime(2022, 12, 20, 0, 0, 0)
    local endTime = CS.System.DateTime(2022, 12, 31, 0, 0, 0)
    local now = TimeHandler:GetServerUtcDateTimeNow()
    return now >= beginTime and now < endTime
end

function GameHelper:GetSimpleSkuInfoById(productId)
    for k, v in pairs(AllBuyCFG) do
        if v.productId == productId then
            return self:GetSimpleSkuInfo(v)
        end
    end
    
    Debug.Assert(false, "productId: "..productId)
    return nil
end

function GameHelper:GetSimpleSkuInfo(cfgItem)
    local skuInfo = SkuInfo:New()
    skuInfo.nType = SkuInfoType.None
    skuInfo.productId = cfgItem.productId
    skuInfo.nDollar = cfgItem.nDollar
    skuInfo.vipPoint = FormulaHelper:GetAddVipPointBySpendDollar(cfgItem.nDollar)

    skuInfo.baseCoins = FormulaHelper:GetAddMoneyBySpendDollar(cfgItem.nDollar)
    skuInfo.finalCoins = skuInfo.baseCoins
    skuInfo.baseDiamonds = 0
    skuInfo.finalDiamonds = 0
    return skuInfo
end

function GameHelper:GetRankIndexDes(nRankIndex)
    if nRankIndex == 1 then
        return "1st"
    elseif nRankIndex == 2 then
        return "2nd"
    elseif nRankIndex == 3 then
        return "3rd"
    else
        return nRankIndex.."th"
    end
end

function GameHelper:GetXPMultuileDes(nAddExpMultuile)
    local textDes = ""
    if nAddExpMultuile == 1 then
        textDes = "DOUBLE XP"
    elseif nAddExpMultuile == 2 then
        textDes = "Triple XP"
    elseif nAddExpMultuile == 3 then
        textDes = "Quadruple XP"
    else
        Debug.Assert(false, nAddExpMultuile)
    end

    return textDes
end 

function GameHelper:getLevelMultiplier()
    local userLevel = PlayerHandler.nLevel
    local levelMultiplier =  1 + userLevel // 10
    return levelMultiplier
end

function GameHelper:orInTheme()
    return ThemeLoader.bInTheme
end

function GameHelper:GetRemainTimeDes(nTime)
    local days = nTime // (3600 * 24)
    local hours = nTime // 3600 - 24 * days
    local minutes = nTime // 60 - 60 * hours
    local seconds = nTime % 60

    if days > 0 then
        local strTimeInfo = math.floor(days+1) .. " day"
        if days > 1 then
            strTimeInfo = strTimeInfo .. "s"
        end

        return strTimeInfo
    end

    local strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    return strTimeInfo
end

function GameHelper:GetOneDollarCoins()
    return FormulaHelper:GetAddMoneyBySpendDollar(1)
end
