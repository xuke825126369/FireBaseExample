-- 主要是处理一些活动事件
AppLocalEventHandler = {}

function AppLocalEventHandler:AddBaseSpinWinCoins(fUseCoins, fWinCoins)
    local data = {nTotalBet = fUseCoins, nWinCoins = fWinCoins}
    EventHandler:Brocast("BaseSpinWinCoins", data)
end

function AppLocalEventHandler:AddThemeSpinCount()
    EventHandler:Brocast("AddSpin")
end

function AppLocalEventHandler:AddThemeWinMoneyCount(nMoneyCount)
    local data = {nWinCoins = nMoneyCount}
    EventHandler:Brocast("WinCoins", data)
end

function AppLocalEventHandler:AddThemeUsedMoneyCount(fUseCoins)
    local listTotalBet = FormulaHelper:GetTotalBetList()
	local nTotalBetIndex = ThemeHelper:GetTotalBetIndex(listTotalBet, fUseCoins)

    local data = {nTotalBet = fUseCoins}
    EventHandler:Brocast("AddBaseSpin", data)
    EventHandler:Brocast("UseCoins", data)
end

function AppLocalEventHandler:AddThemeBigWinCount()
    local data = {}
    EventHandler:Brocast("AddBigWinTime", data)
end

function AppLocalEventHandler:AddThemeMegaWinCount()
    local data = {}
    EventHandler:Brocast("AddBigWinTime", data)
end

function AppLocalEventHandler:AddThemeEpicWinCount()
    local data = {}
    EventHandler:Brocast("AddBigWinTime", data)
end

function AppLocalEventHandler:AddCollectFreeCoinsCount(nMoneyCount)

end

function AppLocalEventHandler:AddActivityDays()
    
end 

function AppLocalEventHandler:OnLevelUp()
    EventHandler:Brocast("onLevelUp")

    if not GameConfig.PLATFORM_EDITOR then
        if AdsConfigHandler:orTriggerAdsInThemeLevelUp() then
            GoogleAdsHandler:Show_InterstitialAds()
        end
    end
end

function AppLocalEventHandler:OnPlayLuckyWheelEvt()
    EventHandler:Brocast("PlayLuckyWheel")
end

function AppLocalEventHandler:OnPlayLuckyMegaBallEvt()
    EventHandler:Brocast("PlayLuckyMegaball")
end

-- 看广告完成事件
function AppLocalEventHandler:OnWatchRewardAdsFinishEvt()
    EventHandler:Brocast("WatchAD")
end

-------------------------- 购买完成事件 -----------------------------
function AppLocalEventHandler:OnDealOfWheelBuyFinish(productId)
    local skuInfo, nIndex = GameHelper:GetSimpleSkuInfoById( productId)
    local nDollar = skuInfo.nDollar
end

function AppLocalEventHandler:OnStoreBuyFinish(productId)
    local skuInfo, nIndex = GameHelper:GetSimpleSkuInfoById( productId)
    local nDollar = skuInfo.nDollar
end
