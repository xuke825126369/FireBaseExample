BonusHandler = {}

function BonusHandler:getFreeCoinBonus()
    local fBonus = 2500000 * FormulaHelper:getVipAndLevelBonusMul()
    return fBonus
end
