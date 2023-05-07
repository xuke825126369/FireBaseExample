

CouponTipPop = {}


function CouponTipPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function CouponTipPop:createAndShow()
    if(not self.gameObject) then
        self.tableName = "CouponTipPop"
        self.gameObject = Unity.Object.Instantiate(Util.getHotPrefab("Assets/BaseHotAdd/CouponTip/CouponTipPop.prefab"))
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
    
    self.shopDiscountEndTime = BonusUtil.shopDiscountEndTime()
    self.moreCoinCountText.text =  string.format("%.0f%%", (BonusUtil.shopDiscountRatio() - 1) * 100)
    self.transform:SetParent(LobbyScene.popCanvas, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function CouponTipPop:Update(dt)
    local nowSecond = os.time()
    if nowSecond > self.shopDiscountEndTime then
        self.hourBonusCountDownText.text = "00:00:00"
    else
        local timeDiff = self.shopDiscountEndTime - nowSecond
        local hours = timeDiff //  3600
        local minutes = timeDiff // 60 - 60 * hours
        local seconds = timeDiff % 60
        self.countDownText.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end
end

function CouponTipPop:onCloseBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function CouponTipPop:onGoStoreBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
    if(not BuyView:isActiveShow()) then
		BuyView:Show()
	end
end

