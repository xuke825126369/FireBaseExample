LuckyEggGetHammerPop = PopStackViewBase:New()

LuckyEggGetHammerPop.enumHammerType = 
{
    enumSilver = 1,
    enumGold = 2,
}

--常驻内存的，预制体应该在Hot内
function LuckyEggGetHammerPop:Show(hammerType, bInQueue, count)--hammerType == 1是银锤子
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadMissionAsset("Missions/LuckyEgg/GetHammerPop.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(GlobalScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)
        
        self.goldText = self.transform:FindDeepChild("GoldHammerCount"):GetComponent(typeof(UnityUI.Text))
        self.silverText = self.transform:FindDeepChild("SilverHammerCount"):GetComponent(typeof(UnityUI.Text))

        self.goGold = self.transform:FindDeepChild("GoldContainer").gameObject
        self.goSilver = self.transform:FindDeepChild("SilverContainer").gameObject
    end

    if hammerType == self.enumHammerType.enumSilver then
        self.silverText.text = "+"..count.."SILVER HAMMER"
        self.goGold:SetActive(false)
        self.goSilver:SetActive(true)
    else
        self.goldText.text = "+"..count.."GOLD HAMMER"
        self.goGold:SetActive(true)
        self.goSilver:SetActive(false)
    end

    ViewScaleAni:Show(self.transform.gameObject, nil, function()
        GlobalAudioHandler:PlaySound("cardpack_receive_pop")
        LeanTween.delayedCall(2.5,function()
            self:Hide()
        end)
    end)

end

function LuckyEggGetHammerPop:Hide()
    ViewScaleAni:Hide(self.transform.gameObject)
end