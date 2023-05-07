WheelOfFunPopView = {}
WheelOfFunPopView.m_bDailyTaskBonusFlag = false -- 每日任务完成的任务点数500点时候有概率奖励WheelOfFun

WheelOfFunPopView.m_nCurrentBasePrize = 1750000

local nBasePrize = 1750000 --以这个为主
WheelOfFunPopView.mapMul = { 50, 5, 3, 5, 15, 3, 2, 20, 5, 3, 5, 10, 5, 2, 20 }

function WheelOfFunPopView:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
	local assetPath = "NowDealOfFun/WheelOfFunPop.prefab"
	local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
	local goPanel = Unity.Object.Instantiate(goPrefab)
    
    local goParent = LobbyScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
	self.transform.localPosition = Unity.Vector3.zero
	LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
	self.transform.gameObject:SetActive(false)

    self.popAni = self.transform:GetComponent(typeof(Unity.Animator))
    self.basePrizeText = self.transform:FindDeepChild("BasePrizeText"):GetComponent(typeof(TextMeshProUGUI))

    self.grayImage1 = self.transform:FindDeepChild("Gray1"):GetComponent(typeof(UnityUI.Image))
    self.grayImage2 = self.transform:FindDeepChild("Gray2"):GetComponent(typeof(UnityUI.Image))
    self.wheelRectTransform = self.transform:FindDeepChild("Wheel")
    self.wheelBonusContainer = self.transform:FindDeepChild("WheelBonusContainer")
    self.spinButton = self.transform:FindDeepChild("SpinButton"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.spinButton) 
    self.spinButton.onClick:AddListener(function()
        self:onSpinBtnClicked()
    end)

    self.pressedId = Unity.Animator.StringToHash("pressed")
    self.endId = Unity.Animator.StringToHash("end")
    self.aniBasePrizePop = self.transform:FindDeepChild("BasePrizePop"):GetComponent(typeof(Unity.Animator))
    self.spinPressedAnimator = self.transform:FindDeepChild("SpinPressedEffect"):GetComponent(typeof(Unity.Animator))
    self.spinEndAnimator = self.transform:FindDeepChild("SpinEndEffect"):GetComponent(typeof(Unity.Animator))
    self.flyEffect = self.transform:FindDeepChild("flyEffect").gameObject
    self.boomEffect = self.transform:FindDeepChild("boomEffect").gameObject
    self.getGiftEffect = self.transform:FindDeepChild("zhongjianglizi").gameObject
    self.trMulTextContainer = self.transform:FindDeepChild("MulTextContainer")
    self.trZhiZhen = self.transform:FindDeepChild("JiaoTou")
    self.goSpinLogo = self.transform:FindDeepChild("Spin").gameObject
    self.mulImg = self.transform:FindDeepChild("jinDuTiao"):GetComponent(typeof(UnityUI.Image))
end

function WheelOfFunPopView:Show(data)
    self:Init()
    self.transform:SetAsLastSibling()
    if data.bDailyTaskBonusFlag == nil then
        self.m_bDailyTaskBonusFlag = false
    else
        self.m_bDailyTaskBonusFlag =  data.bDailyTaskBonusFlag
    end
            
    self.goSpinLogo:SetActive(true)
    self.getGiftEffect:SetActive(false)
    self.flyEffect:SetActive(false)
    self.boomEffect:SetActive(false)
    local nMul, fProgress, nIndex = FreeBonusMultiplier:getMultiplier()
    self.nMul = nMul

    self.mulImg.fillAmount = fProgress
    self.spinPressedAnimator:SetBool(self.pressedId, false)
    self.spinEndAnimator:SetBool(self.endId, false)

    self.m_nCurrentBasePrize = nBasePrize * FormulaHelper:getVipAndLevelBonusMul()
    self.basePrizeText.text = MoneyFormatHelper.numWithCommas(self.m_nCurrentBasePrize)
    self.m_nCurrentBasePrize = self.m_nCurrentBasePrize * self.nMul

    self.baseWheelOfFunBonus = self:getWheelOfFunBonus()
    self.currentVipMultiply = VipHandler:GetVipCoefInfo()
    
    for i, v in ipairs(self.baseWheelOfFunBonus) do
        local bonusNumText = self.wheelBonusContainer:GetChild(i - 1):GetComponent(typeof(TextMeshProUGUI))
        bonusNumText.text = "x"..self.mapMul[i]
    end

    self.spinButton.interactable = false
    self.wheelRectTransform.localRotation = Unity.Quaternion.Euler(0, 0, 0)
    self.grayImage1:SetAlpha(0)
    self.grayImage2:SetAlpha(0)
    LeanTween.delayedCall(3.5, function()
        if nMul ~= 1 then
            local targetPos = self.trMulTextContainer:GetChild(nIndex-1).position
            self.flyEffect.transform.position = targetPos
            self.flyEffect:SetActive(true)
            LeanTween.move(self.flyEffect, self.basePrizeText.transform.position, 1):setOnComplete(function()
                self.basePrizeText.text = MoneyFormatHelper.numWithCommas(self.m_nCurrentBasePrize)
                self.aniBasePrizePop:Play("BasePrizePop")
                self.spinButton.interactable = true
            end)
            self.boomEffect.transform.position = targetPos
            self.boomEffect:SetActive(true)
            LeanTween.delayedCall(2, function()
                self.flyEffect:SetActive(false)
                self.boomEffect:SetActive(false)
            end)
        else
            self.spinButton.interactable = true
        end
    end)    

    self.transform.gameObject:SetActive(true)
    self.transform:SetAsLastSibling()

    GlobalAudioHandler:PlayBackMusic("wheel_loop")
    GlobalAudioHandler:PlaySound("popup2")
end

function WheelOfFunPopView:getWheelOfFunBonus()
    local bonus = {}
    for i = 1, #self.mapMul do
        local fBonus = self.mapMul[i] * self.m_nCurrentBasePrize
        bonus[i] = fBonus
    end
    return bonus
end

function WheelOfFunPopView:onSpinBtnClicked()
    self.goSpinLogo:SetActive(false)
    GlobalAudioHandler:PlaySound("wheel_spin")

    self.spinPressedAnimator:SetBool(self.pressedId, true)
    self.spinButton.interactable = false
    self.grayImage1:SetAlpha(0.5)
    local totalBonusCount = #(self.baseWheelOfFunBonus)
    local nTargetIndex = math.random (1, totalBonusCount)
    local bonusValue = self.baseWheelOfFunBonus[nTargetIndex]
    local vipMultiply = self.currentVipMultiply
    local totalBonus = vipMultiply * bonusValue -- * friendsMultiply

    PlayerHandler:AddCoin(totalBonus)
    AppLocalEventHandler:OnPlayLuckyWheelEvt()
         
    local toDegree = -360 * 10 - 360 / totalBonusCount * (nTargetIndex - 1)
    LeanTween.rotate(self.wheelRectTransform, toDegree, 8):setEase(LeanTweenType.easeInOutSine):setDelay(0.2):setOnStart(function()
        GlobalAudioHandler:PlaySound("wheelTick")
    end):setOnUpdate(function(value)
        self.wheelRectTransform.rotation = Unity.Quaternion.Euler(0, 0, value)
    end):setOnComplete(function()
        GlobalAudioHandler:PlaySound("wheel_cheer")
        LeanTween.alpha(self.grayImage2.rectTransform, 0.8, 0.5)
        self.spinEndAnimator:SetBool(self.endId, true)
        self.getGiftEffect:SetActive(true)
        LeanTween.delayedCall(1.5, function()
            FreeBonusSettleMultiplierFrame:Show(self.m_nCurrentBasePrize, vipMultiply, self.mapMul[nTargetIndex], function()
                self.getGiftEffect:SetActive(false)
                self.popAni:Play("Containertuichu")
                LeanTween.delayedCall(1, function()
                    self.transform.gameObject:SetActive(false)
                    DealOfFunPopView:Show()
                end)
            end)
        end)
    end)

end