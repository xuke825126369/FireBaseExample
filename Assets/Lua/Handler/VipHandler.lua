VipHandler = {}

VipHandler.VIPINFOS = {
    {title = "Bronze"},
    {title = "Silver"},
    {title = "Gold"},
    {title = "Sapphire"},
    {title = "Ruby"},
    {title = "Emerald"},
    {title = "Diamond"},
    {title = "Black"}
}

function VipHandler:Init()
   
end

function VipHandler:getVipPoint()
    return PlayerHandler.nVipPoint
end

function VipHandler:GetVipLevel()
    local nVipLevel = 1
    for i = 1, 8 do
        local nNeedVipPoint = FormulaHelper:GetSumVipRankPoint(i)
        if self:getVipPoint() >= nNeedVipPoint then
            nVipLevel = i
        end
    end

    Debug.Assert(nVipLevel >= 1 and nVipLevel <= 8, nVipLevel)
    return nVipLevel
end

function VipHandler:GetVipCoefInfo(nVipLevel)
    if not nVipLevel then
        nVipLevel = VipHandler:GetVipLevel()
    end
        
    return 1.0 * nVipLevel
end

function VipHandler:GetVipInfo(nVipLevel)
    if not nVipLevel then
        nVipLevel = VipHandler:GetVipLevel()
    end
    return VipHandler.VIPINFOS[nVipLevel]
end

function VipHandler:SetVipImage(vipImage, nVipLevel)
    if not nVipLevel then
        nVipLevel = self:GetVipLevel()
    end
    
    local atlasPath = "Vip/Vip.spriteatlas"
    local spriteName = "Vip"..nVipLevel
    local sprite = AtlasHandler:GetSprite("global", atlasPath, spriteName)
    vipImage.sprite = sprite
end

