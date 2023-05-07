

VipInfoPop = {}

VipInfoPop.m_goJieShaoKuangCurrentVipPoint = nil
VipInfoPop.m_goJieShaoKuangCoinDeals = nil
VipInfoPop.m_goJieShaoKuangDailyBonus = nil
VipInfoPop.m_goJieShaoKuangLuckyWheel = nil
VipInfoPop.m_goJieShaoKuangFreeCoin = nil
VipInfoPop.m_goJieShaoKuangMegaballBonus = nil

function VipInfoPop:Show()
    local count = #VipHandler.VIPINFOS
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadAsset("Lobby", "View/VipInfoPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        local btn = self.transform:FindDeepChild("ButtonClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btn) 
        btn.onClick:AddListener(function()
            self:onBtnCloseClicked()
        end)

        self.vipLogo = self.transform:FindDeepChild("Logo"):GetComponent(typeof(UnityUI.Image))
        local vipInfoTableContent = self.transform:FindDeepChild("VipInfoTableContent")

        self.itemContentArray = {}
        for i = 0, count - 1 do
            local item = vipInfoTableContent:GetChild(i)
            local nVipLevel = count - i
            local itemContent = item:FindDeepChild ("ItemContent"):GetComponent(typeof(Unity.RectTransform))
            self.itemContentArray[nVipLevel] = itemContent
            local levelImage = itemContent:FindDeepChild("LevelImage"):GetComponent(typeof(UnityUI.Image))
            local titleText = itemContent:FindDeepChild ("TitleText"):GetComponent(typeof(TextMeshProUGUI))
            local shopBonusText = itemContent:FindDeepChild ("ShopBonusText"):GetComponent(typeof(TextMeshProUGUI))
            local dailyBonusText = itemContent:FindDeepChild ("DailyBonusText"):GetComponent(typeof(TextMeshProUGUI))
            local wheelofFunText = itemContent:FindDeepChild ("WheelofFunText"):GetComponent(typeof(TextMeshProUGUI))
            local freeCoinText = itemContent:FindDeepChild ("FreeCoinText"):GetComponent(typeof(TextMeshProUGUI))
            local megaballBonusText = itemContent:FindDeepChild ("MegaballBonusText"):GetComponent(typeof(TextMeshProUGUI))
            
            local vipInfo = VipHandler:GetVipInfo(nVipLevel)
            local fCoef = VipHandler:GetVipCoefInfo(nVipLevel) - 1
            local fCoefPercent = LuaHelper.GetInteger(fCoef * 100)
            local fCoefDes = "+"..string.format("%d",fCoefPercent).."%"
            VipHandler:SetVipImage(levelImage, nVipLevel)
            titleText.text = vipInfo.title
            shopBonusText.text = fCoefDes
            dailyBonusText.text = fCoefDes
            wheelofFunText.text =  fCoefDes
            freeCoinText.text = fCoefDes
            megaballBonusText.text = fCoefDes
        end
        
        self.highLight = self.transform:FindDeepChild("HighLight")
        local tr = self.transform:FindDeepChild("JieShaoKuangCurrentVipPoint")
        self.m_goJieShaoKuangCurrentVipPoint = tr.gameObject
        local tr = self.transform:FindDeepChild("JieShaoKuangCoinDeals")
        self.m_goJieShaoKuangCoinDeals = tr.gameObject
        local tr = self.transform:FindDeepChild("JieShaoKuangDailyBonus")
        self.m_goJieShaoKuangDailyBonus = tr.gameObject
        local tr = self.transform:FindDeepChild("JieShaoKuangLuckyWheel")
        self.m_goJieShaoKuangLuckyWheel = tr.gameObject
        local tr = self.transform:FindDeepChild("JieShaoKuangFreeCoin")
        self.m_goJieShaoKuangFreeCoin = tr.gameObject
        local tr = self.transform:FindDeepChild("JieShaoKuangMegaballBonus")
        self.m_goJieShaoKuangMegaballBonus = tr.gameObject

        self.m_listGoTips = {}
        table.insert(self.m_listGoTips, self.m_goJieShaoKuangCurrentVipPoint)
        table.insert(self.m_listGoTips, self.m_goJieShaoKuangCoinDeals)
        table.insert(self.m_listGoTips, self.m_goJieShaoKuangDailyBonus)
        table.insert(self.m_listGoTips, self.m_goJieShaoKuangLuckyWheel)
        table.insert(self.m_listGoTips, self.m_goJieShaoKuangFreeCoin)
        table.insert(self.m_listGoTips, self.m_goJieShaoKuangMegaballBonus)

        self.m_listTrButton = {}
        local trVipPoint = self.transform:FindDeepChild("ButtonCurrentVipPoint")
        table.insert(self.m_listTrButton, trVipPoint)

        local btnCurrentVipPoint = trVipPoint:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCurrentVipPoint) 
        btnCurrentVipPoint.onClick:AddListener(function()
            self:onBtnClicked(1)
            if not self.m_goJieShaoKuangCurrentVipPoint.activeSelf then
                self.m_goJieShaoKuangCurrentVipPoint:SetActive(true)
                local tr = self.m_goJieShaoKuangCurrentVipPoint.transform
                tr.localScale = Unity.Vector3.zero
                LeanTween.scale(self.m_goJieShaoKuangCurrentVipPoint, Unity.Vector3.one, 0.2):setEase(LeanTweenType.easeOutBack)
            else
                self.m_goJieShaoKuangCurrentVipPoint:SetActive(false)
            end
        end)

        local trCoinDeals = self.transform:FindDeepChild("ButtonJieShaoCoinDeals")
        table.insert(self.m_listTrButton, trCoinDeals)

        local btnCoinDeals = trCoinDeals:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnCoinDeals) 
        btnCoinDeals.onClick:AddListener(function()
            self:onBtnClicked(2)
            if not self.m_goJieShaoKuangCoinDeals.activeSelf then
                self.m_goJieShaoKuangCoinDeals:SetActive(true)
                local tr = self.m_goJieShaoKuangCoinDeals.transform
                tr.localScale = Unity.Vector3.zero
                LeanTween.scale(self.m_goJieShaoKuangCoinDeals, Unity.Vector3.one, 0.2):setEase(LeanTweenType.easeOutBack)
            else
                self.m_goJieShaoKuangCoinDeals:SetActive(false)
            end
        end)

        local trDailyBonus = self.transform:FindDeepChild("ButtonJieShaoDailyBonus")
        table.insert(self.m_listTrButton, trDailyBonus)

        local btnDailyBonus = trDailyBonus:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnDailyBonus) 
        btnDailyBonus.onClick:AddListener(function()
            self:onBtnClicked(3)
            if not self.m_goJieShaoKuangDailyBonus.activeSelf then
                self.m_goJieShaoKuangDailyBonus:SetActive(true)

                local tr = self.m_goJieShaoKuangDailyBonus.transform
                tr.localScale = Unity.Vector3.zero
                LeanTween.scale(self.m_goJieShaoKuangDailyBonus, Unity.Vector3.one, 0.2):setEase(LeanTweenType.easeOutBack)
            else
                self.m_goJieShaoKuangDailyBonus:SetActive(false)
            end
        end)

        local trLuckyWheel = self.transform:FindDeepChild("ButtonJieShaoLuckyWheel")
        table.insert(self.m_listTrButton, trLuckyWheel)
        local btnLuckyWheel = trLuckyWheel:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnLuckyWheel) 
        btnLuckyWheel.onClick:AddListener(function()
            self:onBtnClicked(4)
            if not self.m_goJieShaoKuangLuckyWheel.activeSelf then
                self.m_goJieShaoKuangLuckyWheel:SetActive(true)

                local tr = self.m_goJieShaoKuangLuckyWheel.transform
                tr.localScale = Unity.Vector3.zero
                LeanTween.scale(self.m_goJieShaoKuangLuckyWheel, Unity.Vector3.one, 0.2):setEase(LeanTweenType.easeOutBack)

            else
                self.m_goJieShaoKuangLuckyWheel:SetActive(false)
            end
        end)

        local trFreeCoin = self.transform:FindDeepChild("ButtonJieShaoFreeCoin")
        table.insert(self.m_listTrButton, trFreeCoin)
        
        local btnFreeCoin = trFreeCoin:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnFreeCoin) 
        btnFreeCoin.onClick:AddListener(function()
            self:onBtnClicked(5)
            if not self.m_goJieShaoKuangFreeCoin.activeSelf then
                self.m_goJieShaoKuangFreeCoin:SetActive(true)

                local tr = self.m_goJieShaoKuangFreeCoin.transform
                tr.localScale = Unity.Vector3.zero
                LeanTween.scale(self.m_goJieShaoKuangFreeCoin, Unity.Vector3.one, 0.2):setEase(LeanTweenType.easeOutBack)
                
            else
                self.m_goJieShaoKuangFreeCoin:SetActive(false)
            end
        end)  

        local trMegaballBonus = self.transform:FindDeepChild("ButtonJieShaoMegaballBonus")
        table.insert(self.m_listTrButton, trMegaballBonus)

        local btnMegaballBonus = trMegaballBonus:GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnMegaballBonus) 
        btnMegaballBonus.onClick:AddListener(function()
            self:onBtnClicked(6)
            if not self.m_goJieShaoKuangMegaballBonus.activeSelf then
                self.m_goJieShaoKuangMegaballBonus:SetActive(true)
                local tr = self.m_goJieShaoKuangMegaballBonus.transform
                tr.localScale = Unity.Vector3.zero
                LeanTween.scale(self.m_goJieShaoKuangMegaballBonus, Unity.Vector3.one, 0.2):setEase(LeanTweenType.easeOutBack)
            else
                self.m_goJieShaoKuangMegaballBonus:SetActive(false)
            end
        end)
    end

    local currentVipImage = self.transform:FindDeepChild("CurrrentLevelImage"):GetComponent(typeof(UnityUI.Image))
    local currentVipTitle = self.transform:FindDeepChild("CurrentLevelTitle"):GetComponent(typeof(TextMeshProUGUI))
    local nextVipImage = self.transform:FindDeepChild("NextLevelImage"):GetComponent(typeof(UnityUI.Image))
    local nextVipTitle = self.transform:FindDeepChild("NextLevelTitle"):GetComponent(typeof(TextMeshProUGUI))
    local vipProgressImage = self.transform:FindDeepChild("VipProgress"):GetComponent(typeof(UnityUI.Image))
    local vipPointText = self.transform:FindDeepChild("VipPointValueText"):GetComponent(typeof(TextMeshProUGUI))
    local vipNextPointText = self.transform:FindDeepChild("NextLevePointText"):GetComponent(typeof(TextMeshProUGUI))
    local VipPointProgressText = self.transform:FindDeepChild("VipPointProgressText"):GetComponent(typeof(TextMeshProUGUI))
    local nextVipContainer = self.transform:FindDeepChild("NextLevelContainer").gameObject

    local nCurrentVipLevel = VipHandler:GetVipLevel()
    local nNextVipLevel = nCurrentVipLevel + 1
    self.highLight.anchoredPosition = self.itemContentArray[nCurrentVipLevel].parent.transform.anchoredPosition

    VipHandler:SetVipImage(currentVipImage, nCurrentVipLevel)
    VipHandler:SetVipImage(self.vipLogo, nCurrentVipLevel)
    currentVipTitle.text = VipHandler:GetVipInfo().title
    vipPointText.text = MoneyFormatHelper.numWithCommas(PlayerHandler.nVipPoint)

    local width = 800
    local nNextLevelVipPoint = FormulaHelper:GetSumVipRankPoint(nNextVipLevel)
    local fProgress = PlayerHandler.nVipPoint / nNextLevelVipPoint
    if nCurrentVipLevel >= count then
        nextVipContainer:SetActive(false)
        vipNextPointText.text = ""
        vipProgressImage.rectTransform.sizeDelta = Unity.Vector2(width, 32)
    else
        nextVipContainer:SetActive(true)
        local nextVipInfo = VipHandler:GetVipInfo(nNextVipLevel)
        nextVipTitle.text = nextVipInfo.title
        VipHandler:SetVipImage(nextVipImage, nNextVipLevel)
        vipNextPointText.text = string.format("..of %s", MoneyFormatHelper.numWithCommas(nNextLevelVipPoint))
        vipProgressImage.rectTransform.sizeDelta = Unity.Vector2(fProgress * width, 32)
    end

    local fTemp = LuaHelper.GetInteger(fProgress * 100)
    local strProgress = fTemp .. "%"
    VipPointProgressText.text = strProgress

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        for i,v in ipairs(self.itemContentArray) do
            LeanTween.scale(v, Unity.Vector3(1.0, 2.0, 1), 0.12):setLoopPingPong(1):setDelay ((i + 1) * 0.08)
        end
    end)
    
end

function VipInfoPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
    -- LeanTween.delayedCall(0.5,function()
    --     SaleAdHandler:showNoramlSale()
    -- end)
end

function VipInfoPop:onBtnCloseClicked()
    GlobalAudioHandler:PlayBtnSound()
    self:Hide()
end

function VipInfoPop:onBtnClicked(index)
    GlobalAudioHandler:PlayBtnSound()

    for i=1, 6 do
        local go = self.m_listGoTips[i]
        if i ~= index then
            go:SetActive(false)
        end
    end
end

function VipInfoPop:Update(dt)
    if Unity.Input.GetMouseButtonUp(0) then
        local mousePosition =  Unity.Vector2(Unity.Input.mousePosition.x, Unity.Input.mousePosition.y)
          
        for i=1, 6 do
            local tr = self.m_listTrButton[i] -- 6个按钮
            
            local bMouseInBtn = Unity.RectTransformUtility.RectangleContainsScreenPoint(tr, mousePosition, Unity.Camera.main)
            if bMouseInBtn then
                return
            end
        end

        for i=1, 6 do
            local go = self.m_listGoTips[i] -- 6个弹窗
            go:SetActive(false)
        end
    end
end