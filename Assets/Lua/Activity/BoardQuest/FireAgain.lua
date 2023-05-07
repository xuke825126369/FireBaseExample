--介绍弹窗
local FireAgain = {}

function FireAgain:Init()
    local prefabObj = AssetBundleHandler:LoadActivityAsset("FireAgain")
    self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
    self.transform.gameObject:SetActive(false)
    self.transform = self.transform.gameObject.transform
    self.transform:SetParent(LobbyScene.popCanvas, false)
    self.popController = PopController:new(self.transform.gameObject, nil, PopTweenType.alpha)

    local btnClose = self.transform:FindDeepChild("btnClose"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnClose)
    btnClose.onClick:AddListener(function()
        if self.bCanHide then
            ActivityAudioHandler:PlaySound("board_closeWindow")
            BoardQuestMainUIPop:setInAnimation(false)
            self:hide()
            GlobalAudioHandler:SwitchActiveBackgroundMusic("board_music")
        end
    end)

    local btnDiamond = self.transform:FindDeepChild("btnDiamond"):GetComponentInChildren(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(btnDiamond)
    btnDiamond.onClick:AddListener(function()
        if self.bCanHide then
            if PlayerHandler.nSapphireCount >= self.nDiamondPrice then
                ActivityAudioHandler:PlaySound("board_closeWindow")
                PlayerHandler:AddSapphire(-self.nDiamondPrice)
                local str = MoneyFormatHelper.numWithCommas(PlayerHandler.nSapphireCount)
                self.textPlayerDiamond.text = str
                UITop.uiTopDiamondCountText.text = str
                BoardQuestMainUIPop.AttackWheel:show(false, self.goCannonOnBoard)
                self:hide()
            else
                BuyView:Show()
            end
        end
    end)

    self.textDiamond = self.transform:FindDeepChild("textDiamond"):GetComponent(typeof(TextMeshProUGUI))
    self.textPlayerDiamond = self.transform:FindDeepChild("textPlayerDiamond"):GetComponent(typeof(TextMeshProUGUI))
end

function FireAgain:show(goCannonOnBoard)
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
    self.popController:show(nil , nil, true)

    self.nDiamondPrice = BoardQuestIAPConfig.N_FIRE_AGAIN_DIAMOND
    self.nPlayerDiamond = PlayerHandler.nSapphireCount
    self.textDiamond.text = math.floor(self.nDiamondPrice)
    self.textPlayerDiamond.text = MoneyFormatHelper.numWithCommas(self.nPlayerDiamond)
    self.goCannonOnBoard = goCannonOnBoard
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
end

function FireAgain:hide()
    if not self.bCanHide then
        return 
    end
    self.bCanHide = false
    NotificationHandler:removeObserver(self)
    ViewScaleAni:Hide(self.transform.gameObject)
end

function FireAgain:onPurchaseDoneNotifycation(data)
    self.textPlayerDiamond.text = MoneyFormatHelper.numWithCommas(PlayerHandler.nSapphireCount)
end

return FireAgain
