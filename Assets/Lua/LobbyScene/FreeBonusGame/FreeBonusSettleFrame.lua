FreeBonusSettleFrame = {}
FreeBonusSettleFrame.m_bDailyTaskBonusFlag = false -- 每日任务完成的任务点数500点时候有概率奖励WheelOfFun

function FreeBonusSettleFrame:Init()
    if LuaHelper.OrGameObjectExist(self.transform) then
        return
    end

    local bundleName = "Lobby"
    local assetPath = "Assets/ResourceABs/Lobby/FreeBonusGameUI/FreeBonusSettleFrame.prefab"
    local goPrefab = AssetBundleHandler:LoadAsset(bundleName, assetPath)
    local goPanel = Unity.Object.Instantiate(goPrefab)

    local goParent = LobbyScene.popCanvas
    self.transform = goPanel.transform
    self.transform:SetParent(goParent, false)
    self.transform.localScale = Unity.Vector3.one
    self.transform.localPosition = Unity.Vector3.zero
    LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    self.transform.gameObject:SetActive(false)

    self.winFrameRectTransform = self.transform:FindDeepChild("WinFrame"):GetComponent(typeof(Unity.RectTransform))
    self.vipContainer = self.transform:FindDeepChild("VipContainer")
    self.vipMultiplyText = self.transform:FindDeepChild("VipMultiplyText"):GetComponent(typeof(TextMeshProUGUI))
    self.vipNameText = self.transform:FindDeepChild("VipName"):GetComponent(typeof(TextMeshProUGUI))
    self.totalBonusText = self.transform:FindDeepChild("TotalBonus"):GetComponent(typeof(TextMeshProUGUI))
    self.baseBonusText = self.transform:FindDeepChild("BaseBonusText"):GetComponent(typeof(TextMeshProUGUI))
    self.btnCollect = self.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
    DelegateCache:addOnClickButton(self.btnCollect)
    self.btnCollect.onClick:AddListener(function()
        self:onBtnCollectClicked()
    end)

    --ItemLoungeMulti
    self.goItemLoungeMulti = self.transform:FindDeepChild("ItemLoungeMulti").gameObject
end

function FreeBonusSettleFrame:Show(bonusValue, currentVipMultiply, hideCallBack)
    self:Init()
    self.transform:SetAsLastSibling()
    LobbyView:UpCoinsCanvasLayer(510, Unity.Vector2(-650, 0))
    if LoungeHandler:isLoungeMember() then
        self.goItemLoungeMulti:SetActive(true)
    else
        self.goItemLoungeMulti:SetActive(false)
    end
    
    self.hideCallBack = hideCallBack
    self.winFrameRectTransform.gameObject:SetActive(false)
    self.currentVipMultiply = VipHandler:GetVipCoefInfo()
    self.bonusValue = bonusValue

    local fLoungeCoef = 1.0
    if  LoungeHandler:isLoungeMember() then
        fLoungeCoef = 1.5
    end
    self.bonusValue = self.bonusValue * fLoungeCoef
    
    local currentVipLevelIndex = VipHandler:GetVipLevel()
    for i = 0, self.vipContainer.childCount - 1 do
        local nVipLevel = i + 1
        local vipFrameItem = self.vipContainer:GetChild(i)
        local vipMultiplierText = vipFrameItem:FindDeepChild("VipMultiplierText"):GetComponent(typeof(TextMeshProUGUI))
        local vipImage = vipFrameItem:FindDeepChild("Vip"):GetComponent(typeof(UnityUI.Image))
        local highlightImageGameObject = vipFrameItem:FindDeepChild("XuanZhongKuang").gameObject
        local fVipCoef = VipHandler:GetVipCoefInfo(nVipLevel) - 1
        vipMultiplierText.text = "+"..string.format("%d", (fVipCoef * 1000) // 10).."%"
        VipHandler:SetVipImage(vipImage, nVipLevel)
        highlightImageGameObject:SetActive(currentVipLevelIndex == nVipLevel)
    end
    
    self.vipNameText.text = VipHandler:GetVipInfo().title.." BONUS"
    self.vipMultiplyText.text = ""
    
    self.totalBonusText.text = ""
    self.btnCollect.transform.localScale = Unity.Vector3.zero
    self.btnCollect.interactable = true
    local totalBonus = self.bonusValue * self.currentVipMultiply

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        self.winFrameRectTransform.gameObject:SetActive(true)
        self.winFrameRectTransform.anchoredPosition = Unity.Vector2(0, -self.winFrameRectTransform.rect.height)
        
        LeanTween.moveY(self.winFrameRectTransform, 0, 0.3):setOnComplete(function()
            GlobalAudioHandler:PlaySound("coinUp")
            NumberTween:value(0, bonusValue, 1.0):setOnUpdate(function(value)
                self.baseBonusText.text = MoneyFormatHelper.numWithCommas(value)
            end):setOnComplete(function()
                self.vipMultiplyText.transform.localScale = Unity.Vector3.zero
                self.vipMultiplyText.text = MoneyFormatHelper.numWithCommas((self.currentVipMultiply - 1) * self.bonusValue)
                GlobalAudioHandler:PlaySound("buttonShow")
                LeanTween.scale(self.vipMultiplyText.transform, Unity.Vector3.one, 0.3)
                LeanTween.delayedCall(0.8, function( )
                    GlobalAudioHandler:PlaySound("coinUp")
                    NumberTween:value(0, totalBonus, 1.0):setOnUpdate(function(value)
                        self.totalBonusText.text = MoneyFormatHelper.numWithCommas(value)
                    end):setOnComplete(function ()
                        GlobalAudioHandler:PlaySound("buttonShow")
                        LeanTween.scale(self.btnCollect.gameObject, Unity.Vector3.one, 0.3):setEase(LeanTweenType.easeOutBack)
                    end)
                end)
            end)
            
        end)
    end)

end

function FreeBonusSettleFrame:onBtnCollectClicked()
    self.btnCollect.interactable = false
    GlobalAudioHandler:PlayBtnSound()
    local ftime = 3.0
    CoinFly:fly(self.totalBonusText.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 20, true)
    LeanTween.delayedCall(ftime, function()
        LeanTween.moveY(self.winFrameRectTransform, -self.winFrameRectTransform.rect.height, 0.5):setEase(LeanTweenType.easeOutBack):setOnComplete(function()
            self.winFrameRectTransform.gameObject:SetActive(false)
            LobbyView:DownCoinsCanvasLayer()
            ViewScaleAni:Hide(self.transform.gameObject)
            if self.hideCallBack then
                self.hideCallBack()
            end
        end)
    end)
end
