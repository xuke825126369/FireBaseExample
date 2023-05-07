

SupperSaleTipPop = {}


function SupperSaleTipPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function SupperSaleTipPop:createAndShow()
    self.lastPopTime = self.lastPopTime or 0
    local lastPopDiff = os.time() - self.lastPopTime
    if lastPopDiff < 120 then
        SaleAdHandler:showAllSale()
        return
    else
        self.lastPopTime = os.time()
    end

    local bIsActive = self:checkIsActive()
    if not bIsActive then
        SaleAdHandler:showAllSale()
        return
    end

    if(not self.gameObject) then
        self.tableName = "SupperSaleTipPop"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/SupperSaleTip/SupperSaleTipPop.prefab"))
        self.transform = self.gameObject.transform
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
       LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.popController = PopController:new(self.gameObject)
        self.countDownText = self.transform:FindDeepChild("CountDownText"):GetComponent(typeof(TextMeshProUGUI))
        self.moreCoinCountText = self.transform:FindDeepChild("NumMore"):GetComponent(typeof(TextMeshProUGUI))
        local btn = self.transform:FindDeepChild("CloseButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)   
        btn.onClick:AddListener(function()
            self:onCloseBtnClicked()
        end)
        local btn = self.transform:FindDeepChild("GoStoreButton"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)   
        btn.onClick:AddListener(function()
            self:onGoStoreBtnClicked()
        end)
    end
    self.shopDiscountEndTime = BonusUtil.shopAllSalesEndTime()
    
    local rate = math.floor((BonusUtil.shopAllSalesRatio()[1] - 1)*100 + 0.5)/100
    local strRatio = tostring(math.modf(rate*100))
    local text = ""
    local size = 160
    for i=1,#strRatio do
        -- if i+1 > #strRatio then
        --     break
        -- end
        text = text.."<size="..size..">"..string.sub(strRatio, i, i ).."</size>"
        size = size * 0.7
    end
    self.moreCoinCountText.text = text.."<size=60>%</size>"
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController:show(nil, nil, true)
end

function SupperSaleTipPop:Update(dt)
    local nowSecond = os.time()
    if nowSecond > self.shopDiscountEndTime then
        self.hourBonusCountDownText.text = "00:00:00"
    else
        local timeDiff = self.shopDiscountEndTime - nowSecond
        local days = timeDiff // (3600*24)
        local hours = timeDiff // 3600 - 24 * days
        local minutes = timeDiff // 60 - 24 * days * 60 - 60 * hours
        local seconds = timeDiff % 60
        if days > 0 then
            self.countDownText.text = string.format("Time Left %d days!",days)
        else
            self.countDownText.text = string.format("%02d:%02d:%02d", hours, minutes, seconds) --os.date("%H:%M:%S", time)
        end
    end
end

function SupperSaleTipPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function SupperSaleTipPop:onGoStoreBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
    if(not BuyView:isActiveShow()) then
		BuyView:Show()
	end
end

function SupperSaleTipPop:checkIsActive()
    local shopDiscountRatio = BonusUtil.shopDiscountRatio()
    local isSales = shopDiscountRatio == 1
    local allSalesRatio = nil
    if isSales then
        allSalesRatio = BonusUtil.shopAllSalesRatio()
    end
    if isSales and allSalesRatio ~= nil then
        return true
    end
    return false
end