TimeLimitedSalePopManager = {}

TimeLimitedSalePopManager.tableTimeLimitedSalePop = {}

function TimeLimitedSalePopManager:init()
    if DBHandler.data.bHugeDiscountPop then
        if os.time() < DBHandler:getHugeDisEndTime() then
            table.insert(self.tableTimeLimitedSalePop, HugeDiscountPop)
        else
            HugeDiscountPop:onEnd()
        end
    end
    if DBHandler.data.bNoCoinsTimeLimitHugePackPop then
        if os.time() < DBHandler:getTimeLimitHugePackEndTime() then
            table.insert(self.tableTimeLimitedSalePop, NoCoinsTimeLimitHugePackPop)
        else
            NoCoinsTimeLimitHugePackPop:onEnd()
        end
    end
end

function TimeLimitedSalePopManager:Start(salePop)
	UITop.goButtonContainer:SetActive(false)
	UITop.goButtonContainerSale:SetActive(true)

	if not LuaHelper.tableContainsElement(self.tableTimeLimitedSalePop, salePop) then
		table.insert(self.tableTimeLimitedSalePop, salePop)
		if salePop == HugeDiscountPop then
			DBHandler.data.bHugeDiscountPop = true
		elseif salePop == NoCoinsTimeLimitHugePackPop then
			DBHandler.data.bNoCoinsTimeLimitHugePackPop = true
		end
		DBHandler:persistentData()
	end
end

function TimeLimitedSalePopManager:End(salePop)
	self.tableTimeLimitedSalePop = LuaUtil.removeElementByKey(self.tableTimeLimitedSalePop, salePop)
    salePop:onEnd()
    self:onSecond(os.time())
end

function TimeLimitedSalePopManager:onSecond(nowSecond)
	local nMinLeftTime 
	local nMaxLeftTime
	for k, v in pairs(self.tableTimeLimitedSalePop) do
		local nLeftTime = v:onSecond(nowSecond)
		nMinLeftTime = nMinLeftTime or nLeftTime
		nMaxLeftTime = nMaxLeftTime or nLeftTime
		if nMinLeftTime >= nLeftTime then
			nMinLeftTime = nLeftTime
			self.timeLimitedSalePop = v
		end
		nMaxLeftTime = math.max(nLeftTime, nMaxLeftTime) 
	end
    UITop:onSecond(nMinLeftTime, nMaxLeftTime)
end