--介绍弹窗
local OpenNow = {}

function OpenNow:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("OpenNow")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("rainbow_closeWindow")
            self:hide()
        end
    end)

    local btnDiamond = self.transform:FindDeepChild("btnDiamond"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnDiamond)
    btnDiamond.onClick:AddListener(function()
        if self.bCanHide then
           self:onClickButton()
        end
    end)

    self.textDiamond = self.transform:FindDeepChild("textDiamond"):GetComponent(typeof(TextMeshProUGUI))
    self.textPlayerDiamond = self.transform:FindDeepChild("textPlayerDiamond"):GetComponent(typeof(TextMeshProUGUI))
end

function OpenNow:show(nChestPosition)
    if self.transform.gameObject == nil then
        self.m_bInitFlag = false
    else
        if self.transform.gameObject:Equals(nil) then
            self.m_bInitFlag = false
        end
    end
    if not self.m_bInitFlag then
        self.m_bInitFlag = true
        self:Init()
    end
    self.bCanHide = true
    ViewScaleAni:Show(self.transform.gameObject)

    ActivityAudioHandler:PlaySound("rainbow_normal_pop")

    local nChestType = RainbowPickDataHandler.data.tableChest[nChestPosition]
    local nDiamondPrice = RainbowPickConfig.tableChestUnlockDiamond[nChestType]
    self.nChestPosition = nChestPosition
    self.nDiamondPrice = nDiamondPrice
    self.nPlayerDiamond = PlayerHandler.nSapphireCount
    self.textDiamond.text = math.floor(self.nDiamondPrice)
    self.textPlayerDiamond.text = MoneyFormatHelper.numWithCommas(self.nPlayerDiamond)
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
end

function OpenNow:onClickButton()
    if PlayerHandler.nSapphireCount >= self.nDiamondPrice then
        PlayerHandler:AddSapphire(-self.nDiamondPrice)
        RainbowPickDataHandler.data.tableNChestLockTime[self.nChestPosition] = 0
        RainbowPickMainUIPop:updateChestTime(TimeHandler:GetServerTimeStamp())
        if UITop.uiTopDiamondCountText then
            UITop.uiTopDiamondCountText.text = MoneyFormatHelper.numWithCommas(PlayerHandler.nSapphireCount)
        end
        self:hide()
        LeanTween.delayedCall(0.7, function()
            RainbowPickMainUIPop:openChest(self.nChestPosition)   
        end)
    else
        BuyView:Show(BuyView.SHOP_VIEW_TYPE.GEMTYPE)
    end
end

function OpenNow:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    self.popController:hide(false, function()
        NotificationHandler:removeObserver(self)
    end)
end

function OpenNow:onPurchaseDoneNotifycation(data)
    self.textPlayerDiamond.text = MoneyFormatHelper.numWithCommas(PlayerHandler.nSapphireCount)
    self:hide()
end

return OpenNow
