

ChutesRocketsCompletedAllWinPop = {}
ChutesRocketsCompletedAllWinPop.m_btnCollect = nil
ChutesRocketsCompletedAllWinPop.m_rewardText = nil

function ChutesRocketsCompletedAllWinPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsCompletedAllWinPop.prefab"
        local prefabObj = Util.getChutesRocketsPrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        local trCollect = self.transform:FindDeepChild("CollectBtn")
        local btnCollect = trCollect:GetComponent(typeof(UnityUI.Button))
        btnCollect.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:onCollectBtnClick()
        end)
        DelegateCache:addOnClickButton(btnCollect)
        self.m_btnCollect = btnCollect
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    self.m_btnCollect.interactable = true
    self.m_rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    self.m_rewardText.text = MoneyFormatHelper.numWithCommas(ChutesRocketsChoiceLevelPop.COMPLETEDALLCOINS).." +"
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChutesRocketsCompletedAllWinPop:onCollectBtnClick()
    --TODO 更新数据，play animation数据在前面更新了，这里制作动画
    self.m_btnCollect.interactable = false
    local ftime = 2.5
    local coinPos = self.m_rewardText.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)

    LeanTween.delayedCall(ftime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
        
        if(not BuyView:isActiveShow()) then
            BuyView:Show()
        end
    end)

    LeanTween.delayedCall(ftime + 1.2, function()
        local strSkuKey = DynamicConfig.coinSkuInfoArray[1].productId
        local data = {productId = strSkuKey}
        ShopStampCardUI:onPurchaseDoneNotifycation(data)
    end)
end

function ChutesRocketsCompletedAllWinPop:OnDestroy()
    
end