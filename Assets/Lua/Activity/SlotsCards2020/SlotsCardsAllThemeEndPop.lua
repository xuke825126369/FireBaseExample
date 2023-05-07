SlotsCardsAllThemeEndPop = {}
SlotsCardsAllThemeEndPop.m_btnCollect = nil
SlotsCardsAllThemeEndPop.m_imgLogo = nil
SlotsCardsAllThemeEndPop.m_textReward = nil

function SlotsCardsAllThemeEndPop:Show() --cards指的是获得的卡牌数组,gift指的是获得的东西,access指的是获得途径
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("SlotsCardsAllThemeEndPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_imgLogo = self.transform:FindDeepChild("ALOGO"):GetComponent(typeof(UnityUI.Image))
        self.m_textReward = self.transform:FindDeepChild("Reward"):GetComponent(typeof(UnityUI.Text))
        self.m_btnCollect = self.transform:FindDeepChild("CollectBtn"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(self.m_btnCollect)
        self.m_btnCollect.onClick:AddListener(function()
            self:collectBtnClicked()
        end)
    end

    local strActiveAlbumKey = SlotsCardsManager.album
    local curAlbumRunningData = SlotsCardsHandler.data.activityData[strActiveAlbumKey]
    self.m_textReward.text = MoneyFormatHelper.numWithCommas(curAlbumRunningData.m_nCompleteAllReward)
    self.m_btnCollect.interactable = true
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        SlotsCardsAudioHandler:PlaySound("album_all_completed_pop")
    end)

end

function SlotsCardsAllThemeEndPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function SlotsCardsAllThemeEndPop:collectBtnClicked()
    self.m_btnCollect.interactable = false
    local ftime = 2.5
    local coinPos = self.m_btnCollect.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)
    
    local strActiveAlbumKey = SlotsCardsManager.album
    LeanTween.delayedCall(ftime, function()
        self:Hide()
        SlotsCardsMainUIPop:refreshCompleteUI()
    end)
end