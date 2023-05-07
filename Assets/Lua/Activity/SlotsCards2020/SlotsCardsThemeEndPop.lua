SlotsCardsThemeEndPop = {}

function SlotsCardsThemeEndPop:Show(themeID) --cards指的是获得的卡牌数组,gift指的是获得的东西,access指的是获得途径
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("SlotsCardsThemeEndPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.mCommonResSerialization = self.transform:GetComponent(typeof(CS.CommonResSerialization))

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
    if themeID ~= 0 then
        SlotsCardsAudioHandler:PlaySound("album_completed_pop")
        local themeKey = SlotsCardsConfig[strActiveAlbumKey][themeID].ThemeKey
        local assetImagePath = themeKey.."LOGO"
        local sprite = self.mCommonResSerialization:GetSpriteByAtlas("Album", assetImagePath)
        self.m_imgLogo.sprite = sprite
        self.m_textReward.text = MoneyFormatHelper.numWithCommas(curAlbumRunningData.m_arraySetPrize[themeKey])
    end
    self.m_btnCollect.interactable = true
    ViewScaleAni:Show(self.transform.gameObject)

end

function SlotsCardsThemeEndPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end

function SlotsCardsThemeEndPop:collectBtnClicked()
    self.m_btnCollect.interactable = false
    local ftime = 2.5
    local coinPos = self.m_btnCollect.transform.position
    CoinFly:fly(coinPos, GlobalTempData.goUITopCollectMoneyEndPos.transform.position, 12, true)

    LeanTween.delayedCall(ftime, function()
        self:Hide()
        LeanTween.delayedCall(0.6, function()
            SlotsCardsHandler:checkThemeEnd()
        end)
    end)
end