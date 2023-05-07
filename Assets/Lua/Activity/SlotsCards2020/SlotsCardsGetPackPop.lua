SlotsCardsGetPackPop = {}

--常驻内存的，预制体应该在Hot内
function SlotsCardsGetPackPop:Show(packType, bInQueue, count)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadSlotsCardsAsset("SlotsCardsGetPackPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(GlobalScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("PackContainer")
        self.countText = self.transform:FindDeepChild("PackCount"):GetComponent(typeof(UnityUI.Text))
    end 

    for i = 0,self.m_trContent.childCount - 1 do
        self.m_trContent:GetChild(i).gameObject:SetActive(i + 1 == packType)
    end
    
    self.countText.text = "+ "..count

    self.transform:SetAsLastSibling()
    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        GlobalAudioHandler:PlaySound("cardpack_receive_pop")
        LeanTween.delayedCall(2,function()
            self:Hide()
        end)
    end)

end

function SlotsCardsGetPackPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
    EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
end