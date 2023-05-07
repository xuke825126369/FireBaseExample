require("Lua.Activity.ChutesRockets.ChutesRocketsReadyToPlayPop")
require("Lua.Activity.ChutesRockets.ChutesRocketsMaxSpinCountPop")

ChutesRocketsDataHandler = {}
ChutesRocketsDataHandler.data = {}
ChutesRocketsDataHandler.data.m_nVersion = 0
ChutesRocketsDataHandler.bIsShowHint = true --运行时参数，记录是否弹出提醒框
ChutesRocketsDataHandler.m_bInitData = false
ChutesRocketsDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 15
ChutesRocketsDataHandler.m_nMaxSpinCount = 21
ChutesRocketsDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/ChutesRocketsData.txt"

function ChutesRocketsDataHandler:reset()
    self.data = {}
    self.data.m_nVersion = 1
    self.data.bIsGetCompletedGift = false
    self.data.nAction = 5

    self.data.nSuperSpinCount = 0
    self.data.m_nChutesRocketsBoosterEndTime = 0
    self.data.m_nChutesRocketsRemoveSliderEndTime = 0

    self.data.fAddSpinCountProgress = 0
    self.data.nLevel = 1 -- 第几关
    self.data.nLevelProgress = 1 -- 某一关的第几个格子
    self.data.fRewardMultiple = 1
    self.data.m_nEndTime = self.m_nEndTime --已测试
    self.data.nStartPlayerLevel = PlayerHandler.nLevel --记录活动开启时玩家等级（玩家过关不更新等级）
    self.data.nPlayerLevel = PlayerHandler.nLevel -- 解锁关卡时候记录玩家等级
end

function ChutesRocketsDataHandler:refreshAddSpinProgress(data)
    ChutesRocketsUnloadedUI.m_bIsReadyToPlay = false
    if ChutesRocketsUnloadedUI.m_bIsMaxSpinCount then
        ChutesRocketsUnloadedUI.m_bIsReadyToPlay = true
        return
    end

    --根据押注大小增加进度
    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.ChutesRockets)
    
    self.data.fAddSpinCountProgress = self.data.fAddSpinCountProgress + value
    
    local isMax = self.data.fAddSpinCountProgress >= 1

    if isMax then
        while self.data.fAddSpinCountProgress >= 1 do
            self.data.fAddSpinCountProgress = self.data.fAddSpinCountProgress - 1
        end
        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.ChutesRockets)
        if self:checkInBoosterTime() then
            nAddCount = nAddCount * 2
        end
        self:addSpinCount(nAddCount)
        if self.data.nAction >= self.m_nMaxSpinCount then
            ChutesRocketsUnloadedUI.m_bIsReadyToPlay = true
            self.data.fAddSpinCountProgress = 1
            ChutesRocketsUnloadedUI.m_bIsMaxSpinCount = true
            isMax = false
            --TODO 显示最大SpinCount页面
            -- ChutesRocketsMaxSpinCountPop:Show()
        elseif self.bIsShowHint then
            ChutesRocketsUnloadedUI.m_bIsReadyToPlay = true
            -- ChutesRocketsReadyToPlayPop:Show()
        end
    end
    if self.data.nAction < self.m_nMaxSpinCount and ChutesRocketsMaxSpinCountPop.transform ~= nil and ChutesRocketsMaxSpinCountPop.m_bIsTip then
        ChutesRocketsMaxSpinCountPop.m_bIsTip = false
    end
    self:writeFile()
    ChutesRocketsUnloadedUI:refreshUI(isMax)
end

function ChutesRocketsDataHandler:Init()
    if not GameConfig.CHUTESROCKETS_FLAG then
        return
    end
    if self.m_bInitData then
        return
    end
    self.bIsShowHint = true
    self.m_bInitData = true
    self:readFile()
    if self.data.m_nEndTime ~= self.m_nEndTime then
        self:reset()
    end
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
end

function ChutesRocketsDataHandler:synNetData(chutesRocketsData)
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

function ChutesRocketsDataHandler:writeFile()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function ChutesRocketsDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end

    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.data = rapidjson.decode(strData)
end

function ChutesRocketsDataHandler:addSpinCount(count)
    self.data.nAction = self.data.nAction + count
    self:writeFile()
end

function ChutesRocketsDataHandler:addSuperSpinCount(count)
    self.data.nSuperSpinCount = self.data.nSuperSpinCount + count
    self:writeFile()
end

function ChutesRocketsDataHandler:AddBoosterEndTime()
    self.data.m_nChutesRocketsBoosterEndTime = TimeHandler:GetServerTimeStamp() + 60 * 60 * 2 -- 2个小时
    self:writeFile()
end

function ChutesRocketsDataHandler:checkInBoosterTime()
    return self.data.m_nChutesRocketsBoosterEndTime > TimeHandler:GetServerTimeStamp()
end

function ChutesRocketsDataHandler:SetRemoveSliderEndTime()
    self.data.m_nChutesRocketsRemoveSliderEndTime = TimeHandler:GetServerTimeStamp() + 60 * 60 * 2 -- 2个小时
    self:writeFile()
end

function ChutesRocketsDataHandler:checkInRemoveSliderTime()
    return self.data.m_nChutesRocketsRemoveSliderEndTime > TimeHandler:GetServerTimeStamp()
end

function ChutesRocketsDataHandler:addMultiple(fMultiple)
    self.data.fRewardMultiple = self.data.fRewardMultiple + fMultiple
    self:writeFile()
end

--[[
    @desc: 收集进度与玩家下注大小有关
    author:{author}
    time:2019-04-01 15:55:25
    @return:
]]
function ChutesRocketsDataHandler:getBaseTB(nLevel) -- 设置任务难度的一个参考
    -- 2020-9-14 以后类似需求都取商店一美元的金币数作为参考
    
    local strSKuKey = AllBuyCFG[1].productId
    local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nCoins1 = skuInfo.baseCoins

    local nBaseTB = nCoins1 * 0.5
    
    return nBaseTB
end

function ChutesRocketsDataHandler:getChutesRocketsSpinCount(strSkuKey)
    local bFind = false
    local spinCount = 0
    for i=1,#self.m_skuToChutesRocketsSpin do
        if self.m_skuToChutesRocketsSpin[i].productId == strSkuKey then
            spinCount = self.m_skuToChutesRocketsSpin[i].spinCount
            bFind = true
            break
        end
    end

    Debug.Assert(bFind, strSkuKey)
    return spinCount
end

function ChutesRocketsDataHandler:onPurchaseDoneNotifycation(data)
    if ActiveManager.activeType ~= ActiveType.ChutesRockets then return end
    local skuInfo = data.skuInfo
    local nAction = ChutesRocketsIAPConfig.skuMapOther[data.productId]
    ActivityHelper:AddMsgCountData("nAction", nAction)
    self:writeFile()
end