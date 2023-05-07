MedalChestPopEffect = PopStackViewBase:New()

-- 放在 hot 里
function MedalChestPopEffect:Show(enumChestType, bInQueue, count)
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LoungeMedalChestEffect/MedalChestPopEffect.prefab")
        local go = Unity.Object.Instantiate(goPrefab)
        self.transform = go.transform
        self.transform:SetParent(GlobalScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero

        self.m_trContent = self.transform:FindDeepChild("ChestContianer")
        self.countText = self.transform:FindDeepChild("TextChestCountInfo"):GetComponent(typeof(TextMeshProUGUI))
        self.m_light = self.transform:FindDeepChild("Guang")
    end

    for i = 0, self.m_trContent.childCount - 1 do
        self.m_trContent:GetChild(i).gameObject:SetActive(i + 1 == enumChestType)
    end 
    
    local listName = {"Common", "Rare", "Epic", "Legendary"}
    local str = listName[enumChestType]
    self.countText.text = "+ "..count.." "..str.." CHEST"

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        GlobalAudioHandler:PlaySound("get_vault")
        LeanTween.delayedCall(2.0, function()
            self:Hide()
        end)
    end)
    
end

function MedalChestPopEffect:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end