

MakeupPop = {}

function IapMakeupPop:isActiveShow()
    return self.gameObject and self.gameObject.activeInHierarchy
end

function IapMakeupPop:createAndShow(skuInfo)
    if(not self.gameObject) then
        self.tableName = "IapMakeupPop"
        self.gameObject = Unity.Object.Instantiate(Util.getBasePrefab("Assets/BaseHotAdd/IapMakeup/IapMakeup.prefab"))
        self.transform = self.gameObject.transform
        self.makeupText = self.transform:FindDeepChild ("makeupText"):GetComponent(typeof(TextMeshProUGUI))
        LuaAutoBindMonoBehaviour.Bind(self.gameObject, self)
        self.popController = PopController:new(self.gameObject)
        local btn = self.transform:FindDeepChild("ButtonOK"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn)
        btn.onClick:AddListener(function()
            self:onOKBtnClicked()
        end)
    end
    local netTimeString = NetHandler.netTimeString
    self.makeupClained = true
    if netTimeString then
        local netTimeSecond = TimeHandler:GetTimeStampFromDateString(netTimeString)
        local netDaySecond = LuaUtil.timeToDaySecond(netTimeSecond)
        if netDaySecond ~= DBHandler:getClainIapMakeupTime() then
            self.makeupClained = false
            local levelMultiplier =  1 + math.floor(userLevel / 20) / 20 
            local iapMultiplier = VipHandler:GetVipCoefInfo()
            local count = MoneyFormatHelper.normalizeCoinCount(10000000 * levelMultiplier * (1 + DBHandler:getTotalIapPrice() / 50))
            if count > 60000000 then
                count = 60000000
            end
            DBHandler:clainIapMakeup(count, netDaySecond)
            self.makeupText.text = string.format("You got %s free coins for today!", MoneyFormatHelper.numWithCommas(count))
        end
    end
    if self.makeupClained then
        self.makeupText.text = string.format("You have got compensation coins for today!")
    end
    self.transform:SetParent(LobbyScene.popCanvas, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function IapMakeupPop:onOKBtnClicked()
    GlobalAudioHandler:PlayBtnSound()
    ViewScaleAni:Hide(self.transform.gameObject)
    if not self.makeupClained then
        CoinFly:fly(self.makeupText.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 10)
    end
end

