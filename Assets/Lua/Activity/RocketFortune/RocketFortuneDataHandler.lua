require("Lua.Activity.RocketFortune.RocketFortuneReadyToPlayPop")
require("Lua.Activity.RocketFortune.RocketFortuneMaxSpinCountPop")

RocketFortuneDataHandler = {}
RocketFortuneDataHandler.data = {}
RocketFortuneDataHandler.data.m_nVersion = 0
RocketFortuneDataHandler.bIsShowHint = true --运行时参数，记录是否弹出提醒框
RocketFortuneDataHandler.m_bInitData = false
RocketFortuneDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 15
RocketFortuneDataHandler.m_nMaxSpinCount = 21
RocketFortuneDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/RocketFortune.txt"
RocketFortuneDataHandler.activeType = ActiveType.RocketFortune

function RocketFortuneDataHandler:Init()
    if not GameConfig.CHUTESROCKETS_FLAG then
        return
    end
    if self.m_bInitData then
        return
    end
    self.bIsShowHint = true
    self.m_bInitData = true
    self:readFile()
    if self.data.endTime ~= ActiveManager.nActivityEndTime then --新赛季重置数据
        self:reset()
        self.data.endTime = ActiveManager.nActivityEndTime
    end
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
end

function RocketFortuneDataHandler:reset()
    self.data = {}
    self.data.m_nVersion = 1
    self.data.bIsGetCompletedGift = false
    self.data.nAction = 5

    self.data.nSuperSpinCount = 0
    self.data.m_nRocketFortuneBoosterEndTime = 0
    self.data.m_nRocketFortuneRemoveSliderEndTime = 0

    self.data.fAddSpinCountProgress = 0
    self.data.nLevel = 1 -- 第几关
    self.data.nLevelProgress = 1 -- 某一关的第几个格子
    self.data.fRewardMultiple = 1
    self.data.m_nEndTime = self.m_nEndTime --已测试
    self.data.nStartPlayerLevel = PlayerHandler.nLevel --记录活动开启时玩家等级（玩家过关不更新等级）
    self.data.nPlayerLevel = PlayerHandler.nLevel -- 解锁关卡时候记录玩家等级
end

function RocketFortuneDataHandler:refreshAddSpinProgress(data)

    --根据押注大小增加进度
    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.RocketFortune)
    
    self.data.fAddSpinCountProgress = self.data.fAddSpinCountProgress + value
    
    local isMax = self.data.fAddSpinCountProgress >= 1

    if isMax then
        while self.data.fAddSpinCountProgress >= 1 do
            self.data.fAddSpinCountProgress = self.data.fAddSpinCountProgress - 1
        end
        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.RocketFortune)
        if self:checkInBoosterTime() then
            nAddCount = nAddCount * 2
        end
        self:addSpinCount(nAddCount)
        if self.data.nAction >= self.m_nMaxSpinCount then
            RocketFortuneUnloadedUI.m_bIsReadyToPlay = true
            self.data.fAddSpinCountProgress = 1
            isMax = false
            --TODO 显示最大SpinCount页面
            -- RocketFortuneMaxSpinCountPop:Show()
        elseif self.bIsShowHint then
            RocketFortuneUnloadedUI.m_bIsReadyToPlay = true
            -- RocketFortuneReadyToPlayPop:Show()
        end
    end
    if self.data.nAction < self.m_nMaxSpinCount and RocketFortuneMaxSpinCountPop.transform ~= nil and RocketFortuneMaxSpinCountPop.m_bIsTip then
        RocketFortuneMaxSpinCountPop.m_bIsTip = false
    end
    self:writeFile()
    RocketFortuneUnloadedUI:refreshUI(isMax)
end

function RocketFortuneDataHandler:synNetData(chutesRocketsData)
    if self.m_bInitData then
        return
    end
    --chutesRocketsData不可能为空
    self.data = chutesRocketsData
    self.data.m_nVersion = 1
    if self.data.m_nEndTime ~= self.m_nEndTime then
        self:reset()
    end
    self.m_bInitData = true
    self:writeFile()
end

function RocketFortuneDataHandler:writeFile()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function RocketFortuneDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end

    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.data = rapidjson.decode(strData)
end

-- function RocketFortuneDataHandler:addSpinCount(count)
--     self.data.nAction = self.data.nAction + count
--     self:writeFile()
-- end

function RocketFortuneDataHandler:addSuperSpinCount(count)
    self.data.nSuperSpinCount = self.data.nSuperSpinCount + count
    self:writeFile()
end

function RocketFortuneDataHandler:AddBoosterEndTime()
    self.data.m_nRocketFortuneBoosterEndTime = TimeHandler:GetServerTimeStamp() + 60 * 60 * 2 -- 2个小时
    self:writeFile()
end

function RocketFortuneDataHandler:checkInBoosterTime()
    return self.data.m_nRocketFortuneBoosterEndTime > TimeHandler:GetServerTimeStamp()
end

function RocketFortuneDataHandler:SetRemoveSliderEndTime()
    self.data.m_nRocketFortuneRemoveSliderEndTime = TimeHandler:GetServerTimeStamp() + 60 * 60 * 2 -- 2个小时
    self:writeFile()
end

function RocketFortuneDataHandler:checkInRemoveSliderTime()
    return self.data.m_nRocketFortuneRemoveSliderEndTime > TimeHandler:GetServerTimeStamp()
end

function RocketFortuneDataHandler:addMultiple(fMultiple)
    self.data.fRewardMultiple = self.data.fRewardMultiple + fMultiple
    self:writeFile()
end

--[[
    @desc: 收集进度与玩家下注大小有关
    author:{author}
    time:2019-04-01 15:55:25
    @return:
]]
function RocketFortuneDataHandler:getBaseTB(nLevel) -- 设置任务难度的一个参考
    -- 2020-9-14 以后类似需求都取商店一美元的金币数作为参考
    
    local strSKuKey = AllBuyCFG[1].productId
    local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nCoins1 = skuInfo.baseCoins

    local nBaseTB = nCoins1 * 0.5
    
    return nBaseTB
end

function RocketFortuneDataHandler:getRocketFortuneSpinCount(strSkuKey)
    local bFind = false
    local spinCount = 0
    for i=1,#self.m_skuToRocketFortuneSpin do
        if self.m_skuToRocketFortuneSpin[i].productId == strSkuKey then
            spinCount = self.m_skuToRocketFortuneSpin[i].spinCount
            bFind = true
            break
        end
    end

    Debug.Assert(bFind, strSkuKey)
    return spinCount
end

function RocketFortuneDataHandler:onPurchaseDoneNotifycation(data)
    if ActiveManager.activeType ~= ActiveType.RocketFortune then return end
    local skuInfo = data.skuInfo
    if skuInfo.nType == SkuInfoType.RocketForune then
        --活动商店内购
        local activeInfo = skuInfo.activeInfo
        ActivityHelper:AddMsgCountData("nAction", activeInfo.nAction)
        if skuInfo.nActiveIAPType == RocketFortuneIAPConfig.TYPE.WHEEL_SPINS_BOOSTER then
            self:AddBoosterEndTime(activeInfo.nTime, 1)
        elseif skuInfo.nActiveIAPType == RocketFortuneIAPConfig.Type.SUPER_WHEEL_SPINS then
            ActivityHelper:AddMsgCountData("nSuperWheelSpins", activeInfo.nCount)
        elseif skuInfo.nActiveIAPType == RocketFortuneIAPConfig.Type.CHUTES_REMOVED then
            self:AddBoosterEndTime(activeInfo.nTime, 2)
        end
    else
        --其它内购
        local nAction = RainbowPickIAPConfig.skuMapOther[data.productId]
        ActivityHelper:AddMsgCountData("nAction", nAction)
    end
    self:writeFile()
end