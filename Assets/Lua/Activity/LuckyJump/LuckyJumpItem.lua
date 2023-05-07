local yield_return = (require 'cs_coroutine').yield_return

LuckyJumpItem = {}

function LuckyJumpItem:new(gameObject, row, col, itemType)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.gameObject = gameObject
    o.transform = gameObject.transform
    o.transform.localScale = Unity.Vector3.zero
    o.canvasGroup = o.transform:GetComponent(typeof(Unity.CanvasGroup))
    o.canvasGroup.alpha = 0
    o.row = row
    o.col = col

    if itemType == LuckyJumpType.PrizeNormalCoins then
        o.itemTypeGo = gameObject.transform:FindDeepChild("NormalCoins").gameObject
        local text = o.itemTypeGo.transform:FindDeepChild("TextMeshPro Text"):GetComponent(typeof(TextMeshProUGUI))
        o.prizeCoins = LuckyJumpDataHandler:getBasePrize() * self:getRandomRatio()
        text.text = MoneyFormatHelper.coinCountOmit(o.prizeCoins)
    elseif itemType == LuckyJumpType.None then
        gameObject:SetActive(false)
    elseif itemType == LuckyJumpType.PrizeMiddleCoins then
        o.itemTypeGo = gameObject.transform:FindDeepChild("MiddleCoins").gameObject
        local text = o.itemTypeGo.transform:FindDeepChild("Text"):GetComponent(typeof(UnityUI.Text))
        o.prizeCoins = LuckyJumpDataHandler:getBasePrize()*10 * self:getRandomRatio()
        text.text = MoneyFormatHelper.coinCountOmit(o.prizeCoins)
    elseif itemType == LuckyJumpType.PrizeBigCoins then
        o.itemTypeGo = gameObject.transform:FindDeepChild("BigCoins").gameObject
        local text = o.itemTypeGo.transform:FindDeepChild("Text"):GetComponent(typeof(UnityUI.Text))
        o.prizeCoins = LuckyJumpDataHandler:getBasePrize()*20 * self:getRandomRatio()
        text.text = MoneyFormatHelper.coinCountOmit(o.prizeCoins)
    elseif itemType == LuckyJumpType.PrizeCards then
        o.itemTypeGo = gameObject.transform:FindDeepChild("Cards").gameObject
        local params = {}
        params.cardCount = 3
        params.threeStarMinCount = 1
        o.cardsPrizeParam = params
    elseif itemType == LuckyJumpType.PrizeMove then
        o.itemTypeGo = gameObject.transform:FindDeepChild("Move").gameObject
        o.prizeMoveCount = 2
        local text = o.itemTypeGo.transform:FindDeepChild("TextMeshPro Text"):GetComponent(typeof(TextMeshProUGUI))
        text.text = "+"..o.prizeMoveCount
    elseif itemType == LuckyJumpType.PrizeGift then
        o.itemTypeGo = gameObject.transform:FindDeepChild("Gift").gameObject
        --TODO 奖励是金币或者双倍金币
        o.prizeCoins = LuckyJumpDataHandler:getBasePrize() *10 * self:getRandomRatio()
        -- o.prizeDouble = 2
    elseif itemType == LuckyJumpType.RandomMove then
        -- o.randomPos = 
        -- o.itemTypeGo = gameObject.transform:FindDeepChild("Double").gameObject
    elseif itemType == LuckyJumpType.Begin then
        o.itemTypeGo = gameObject.transform:FindDeepChild("YuanSuBG2").gameObject
        table.insert( LuckyJumpPickATilePop.m_mapBeginPos, {row,col} )
    elseif itemType == LuckyJumpType.End then
        o.itemTypeGo = gameObject.transform:FindDeepChild("End").gameObject
        o.bIsEnd = true
    end

    if o.itemTypeGo ~= nil then
        o.itemTypeGo:SetActive(true)
    end

    -- o.transform:SetParent(LuckyJumpGamePop.m_content)
    -- o.transform.localScale = Unity.Vector3.one
    -- local factor = col%2-1
    -- o.transform.anchoredPosition = Unity.Vector2( (col-1)*87.5*(3/2), (-((row-1)*156)+(78*factor)) )

	return o
end

function LuckyJumpItem:showBegin()
    local centerX = math.floor( (#LuckyJumpConfig[LuckyJumpDataHandler.data.nLevel][1])/2 )+1
    local centerY = math.floor( (#LuckyJumpConfig[LuckyJumpDataHandler.data.nLevel])/2 )
    local offsetX = math.abs( self.row - centerY )
    local offsetY = math.abs( self.col - centerX )
    local offset = 0
    if offsetX == 0 or offsetY == 0 then
        offset = (offsetX+offsetY)
    else
        offset = (offsetX+offsetY-1)
    end
    LeanTween.scale(self.gameObject, Unity.Vector3.one,0.5):setDelay(offset*0.2):setEase(LeanTweenType.easeOutBack)
    LeanTween.value(0, 1, 0.5):setDelay(offset*0.2):setOnUpdate(function(value)
        if self.gameObject:Equals(nil) then
            return
        end
        self.canvasGroup.alpha = value
    end)
end

function LuckyJumpItem:checkPrize()
    if self.itemTypeGo == nil then
        return
    end
    if self.prizeCoins ~= nil then
        LuckyJumpManager.m_nWinCoins = LuckyJumpManager.m_nWinCoins + self.prizeCoins
        PlayerHandler:AddCoin(self.prizeCoins)
    end
    if self.prizeMoveCount ~= nil then
        LuckyJumpDataHandler:addMoveCount(self.prizeMoveCount)
    end
    -- if self.prizeDouble ~= nil then
    --     LuckyJumpManager.m_nWinCoins = LuckyJumpManager.m_nWinCoins * self.prizeDouble
    -- end
    if self.cardsPrizeParam ~= nil then
        self.getCardsParams = SlotsCardsGiftManager:getStampPackInActive(SlotsCardsAllProbTable.PackType.Two)
    end
    if self.bIsEnd then
        PlayerHandler:AddCoin(LuckyJumpDataHandler.m_mapPrize["Level"..LuckyJumpDataHandler.data.nLevel])
        LuckyJumpDataHandler:toNextLevel()
    end
end

function LuckyJumpItem:showAniEndMove()
    if self.itemTypeGo == nil then
        return
    end
    if self.prizeCoins ~= nil then
        --TODO 金币飞向WinsCoins，coins开始涨幅
        LuckyJumpGamePop:coinFly(self.transform.position, 6)
    end
    if self.prizeMoveCount ~= nil then
        --TODO 显示获得了Move
        LuckyJumpGamePop:refreshText()
    end
    -- if self.prizeDouble ~= nil then
    --     --TODO 显示x2飞向WinsCoins，coins开始涨幅
    --     LuckyJumpGamePop:coinFly(self.transform.position, 6)
    -- end
    if self.getCardsParams ~= nil then
        SlotsCardsGetPackPop:Show(self.getCardsParams.packType, true, self.getCardsParams.packCount)
        self.getCardsParams = nil
    end
    if self.randomPos ~= nil then
        
    end
    if self.bIsEnd then
        LuckyJumpWinCollectPop:Show(function()
            if LuckyJumpDataHandler.data.nLevel > #LuckyJumpConfig then
                LuckyJumpEndAllPop:Show()
            else
                LuckyJumpEndPop:Show()
            end
        end)
    end
end

function LuckyJumpItem:getRandomRatio()
    local ratioTable = {0.8, 0.9, 1}
    local index = math.random(1, 3)
    return ratioTable[index]
end