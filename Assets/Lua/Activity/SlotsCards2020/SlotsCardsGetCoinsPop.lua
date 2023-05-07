

SlotsCardsGetCoinsPop = {}
SlotsCardsGetCoinsPop.m_textReward = nil
SlotsCardsGetCoinsPop.btnCollect = nil

function SlotsCardsGetCoinsPop:Show(rewardCount)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("SlotsCardsGetCoinsPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.m_textReward = self.transform:FindDeepChild("RewardText"):GetComponent(typeof(UnityUI.Text))
    end
    
    self.m_textReward.text = MoneyFormatHelper.numWithCommas(rewardCount)
    self.transform:SetParent(LobbyScene.popCanvas, false)
    ViewScaleAni:Show(self.transform.gameObject)
    SlotsCardsAudioHandler:PlaySound("gift_expands_explodes")
    LeanTween.delayedCall(2.5, function()
        self:Hide()
    end)

end

function SlotsCardsGetCoinsPop:Hide()
    local ftime = 2.5
    CoinFly:fly(self.m_textReward.transform.position, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)
    LeanTween.delayedCall(ftime, function()
        ViewScaleAni:Hide(self.transform.gameObject)
    end)
end