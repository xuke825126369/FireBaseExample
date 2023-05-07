AppAdsEventHandler = {}

-------------------------- 投放广告 要求的游戏事件 -----------------------------
function AppAdsEventHandler:SendBuyEvent(productId)
    local skuInfo, nIndex = GameHelper:GetSimpleSkuInfoById(productId)
    local nDollar = skuInfo.nDollar
    CS.AppsFlyerEvent.SendBuyEvent(productId, nDollar)
    CS.FireBaseEvent.SendBuyEvent(productId, nDollar)
end 

function AppAdsEventHandler:SendLevelUpEvent(strEventName, paramDic)
    
end     

-------------------------- 自定义游戏事件 -----------------------------
function AppAdsEventHandler:SendCustomEvent(strEventName, paramDic)
    CS.AppsFlyerEvent.SendCustomEvent(strEventName, paramDic)
    CS.FireBaseEvent.SendCustomEvent(strEventName, paramDic)
end

