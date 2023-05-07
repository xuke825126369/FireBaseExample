InBoxHandler = {}

function InBoxHandler:GetInboxId()
    CommonDbHandler.data.nInboxId = CommonDbHandler.data.nInboxId + 1
    CommonDbHandler:SaveDb()
    return CommonDbHandler.data.nInboxId
end

function InBoxHandler:RemoveInboxArrayItem(tableInfo, nInboxId)
    Debug.Assert(nInboxId > 0, nInboxId)
    local nRemoveIndex = -1
    for k, v in pairs(tableInfo) do
        if v.nInboxId == nInboxId then
            nRemoveIndex = k
            break
        end
    end
    
    if nRemoveIndex > 0 then
        table.remove(tableInfo, nRemoveIndex)
    end
    CommonDbHandler:SaveDb()
end

function InBoxHandler:GetSmallTipCount()
    local totalCount = 0
    totalCount = totalCount + #CommonDbHandler.data.tableCollectFreeCoinInfo
    totalCount = totalCount + #CommonDbHandler.data.BonusParams
    totalCount = totalCount + LuaHelper.tableSize(CommonDbHandler.data.mapInboxTrophyRewardParams)
    totalCount = totalCount + LuaHelper.tableSize(CommonDbHandler.data.mapInboxRoyalPassRewardParams)
    totalCount = totalCount + LuaHelper.tableSize(CommonDbHandler.data.mapInboxFlashChallengeRewardParams)
    totalCount = totalCount + #CommonDbHandler.data.tableCoinCouponInfo
    totalCount = totalCount + #CommonDbHandler.data.tableDiamondCouponInfo
    totalCount = totalCount + #CommonDbHandler.data.LoungeLuckyPackParam
    
    if Unity.Application.version ~= PlayerHandler.strAppVersion then
        totalCount = totalCount + 1
    end

    if GMGiftHandler.data.nCompensationCoins > 0 then
        totalCount = totalCount + 1
    end

    return totalCount
end