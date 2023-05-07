require("Lua/Handler/ThemeReturnRateDyncmaicStage")
require("Lua/Handler/ThemeReturnRateHelper")
require("Lua/Handler/ThemeReturnRateDyncmaicConfig1Handler")
require("Lua/Handler/ThemeReturnRateDyncmaicConfig2Handler")
require("Lua/Handler/ThemeReturnRateDyncmaicConfig3Handler")

ThemeReturnRateDyncmaicSwitch = {}
ThemeReturnRateDyncmaicSwitch.nMaxReturnRateDyncmaicType = 3
ThemeReturnRateDyncmaicSwitch.bTest = false

function ThemeReturnRateDyncmaicSwitch:Init()
    self.nStage = ThemeReturnRateDyncmaicStage.Other
    self.nReturnRateDyncmaicType = math.random(1, self.nMaxReturnRateDyncmaicType)
    ThemeReturnRateDyncmaicConfig1Handler:Init()
    ThemeReturnRateDyncmaicConfig2Handler:Init()
    ThemeReturnRateDyncmaicConfig3Handler:Init()
end

function ThemeReturnRateDyncmaicSwitch:orInReturnRateDyncmaicType(nReturnRateRandomType)
    return self.nStage == ThemeReturnRateDyncmaicStage["ReturnRateRandom"..nReturnRateRandomType]
end

function ThemeReturnRateDyncmaicSwitch:orInReturnRateDyncmaicType(nReturnRateRandomType)
    return self.nStage == ThemeReturnRateDyncmaicStage["ReturnRateRandom"..nReturnRateRandomType]
end

function ThemeReturnRateDyncmaicSwitch:GetFeatureReturnType()
    self.nStage = ThemeReturnRateDyncmaicStage.Other
    if PlayerHandler.nLevel < GameConst.nInitCashBackLevel then   
        return 3
    end
    
    -- 如果不充值，就让他输
    local bRequestRecharge, fPercent = RechargeHandler:orInRechargeRequestTime()
    if bRequestRecharge then
        local n50RateValue = 10 * fPercent
        n50RateValue = LuaHelper.GetInteger(n50RateValue)
        n50RateValue = math.max(n50RateValue, 3)
        local tableRate = {n50RateValue, 1, 1}
        return LuaHelper.GetIndexByRate(tableRate)
    else
        if ThemeSingleLevelDataHandler:orInEveryMonthCashBackFeature() then
            return 3
        end

        self.nStage = ThemeReturnRateDyncmaicStage["ReturnRateRandom"..self.nReturnRateDyncmaicType]
        if _G["ThemeReturnRateDyncmaicConfig"..self.nReturnRateDyncmaicType.."Handler"]:orInFeature() then
            return _G["ThemeReturnRateDyncmaicConfig"..self.nReturnRateDyncmaicType.."Handler"]:GetFeatureReturnType()
        else
            _G["ThemeReturnRateDyncmaicConfig"..self.nReturnRateDyncmaicType.."Handler"]:RandomFeature()
            self.nReturnRateDyncmaicType = self.nReturnRateDyncmaicType + 1
            if self.nReturnRateDyncmaicType > self.nMaxReturnRateDyncmaicType then
                self.nReturnRateDyncmaicType = 1
            end
        end
    end

    local tableRate = {300, 200, 130}
    return LuaHelper.GetIndexByRate(tableRate)
end
