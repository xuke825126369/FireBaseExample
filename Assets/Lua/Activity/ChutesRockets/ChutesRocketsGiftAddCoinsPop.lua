

ChutesRocketsGiftAddCoinsPop = {}
ChutesRocketsGiftAddCoinsPop.m_btnCollect = nil
ChutesRocketsGiftAddCoinsPop.m_rewardText = nil

function ChutesRocketsGiftAddCoinsPop:Show(parentTransform)
    if self.transform.gameObject == nil then
        local strPath = "Assets/ActiveNeedLoad/ChutesRockets/ChutesRocketsGiftAddCoinsPop.prefab"
        local prefabObj = Util.getChutesRocketsPrefab(strPath)
        self.transform.gameObject = Unity.Object.Instantiate(prefabObj)
        self.transform = self.transform.gameObject.transform
        local trCollect = self.transform:FindDeepChild("CollectBtn")
        local btnCollect = trCollect:GetComponent(typeof(UnityUI.Button))
        btnCollect.onClick:AddListener(function()
            self:onKeepBtnClick()
        end)
        DelegateCache:addOnClickButton(btnCollect)
        self.m_btnCollect = btnCollect
        self.popController = PopController:new(self.transform.gameObject)
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
    end

    self.m_btnCollect.interactable = true

    self.m_rewardText = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
    
    if ChutesRocketsLevelManager.strGift == "gift1" then
        self.m_rewardText.text = MoneyFormatHelper.numWithCommas(ChutesRocketsDataHandler:getBaseTB()).." COINS"
    elseif ChutesRocketsLevelManager.strGift == "gift2" then
        self.m_rewardText.text = MoneyFormatHelper.numWithCommas(ChutesRocketsDataHandler:getBaseTB() * 2).." COINS"
    end
    parentTransform = parentTransform or LobbyScene.popCanvas
    self.transform:SetParent(parentTransform, false)
    ViewScaleAni:Show(self.transform.gameObject)
end

function ChutesRocketsGiftAddCoinsPop:onKeepBtnClick()
    self.m_btnCollect.interactable = false
    -- 奖励早已经加给玩家了 这里仅仅做动画展示...
    local ftime = 2.5
    local coinPos = self.m_rewardText.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12)

    LeanTween.delayedCall(ftime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
        ChutesRocketsMainUIPop:showWheel()
    end)
end

function ChutesRocketsGiftAddCoinsPop:OnDestroy()
    
end