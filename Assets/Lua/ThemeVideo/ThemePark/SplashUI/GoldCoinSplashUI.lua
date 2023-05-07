--[[
    author:coldflag
    time:2021-09-08 19:27:23
]]

local GoldCoinSplashUI = {}

function GoldCoinSplashUI:Init()
    local assetPath = "JinBiDog.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

    self.obj = Unity.Object.Instantiate(goPrefab)
    self.obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    self.obj.transform.localScale = Unity.Vector3.one

    -- 
    
    self.obj:SetActive(false)
    self.trCoin = self.obj.transform:FindDeepChild("PCoin")
    self.trCoin.gameObject:SetActive(false)

    self.trDog = self.obj.transform:FindDeepChild("PDog")
    self.trDog.gameObject:SetActive(false)

    self.trArchery = self.obj.transform:FindDeepChild("PFeibiao")
    self.trArchery.gameObject:SetActive(false)

    self.trGoldCoinValue = self.obj.transform:FindDeepChild("JinBiValue")
    self.cptextValue = self.trGoldCoinValue:GetComponent(typeof(UnityUI.Text))
    self.trGoldCoinValue.gameObject:SetActive(true)

end

function GoldCoinSplashUI:Show(nRewardID, fPrize)
    local textPrize = MoneyFormatHelper.numWithCommas(fPrize)
    self.cptextValue.text = textPrize

    self.trCoin.gameObject:SetActive(false)
    self.trDog.gameObject:SetActive(false)
    self.trArchery.gameObject:SetActive(false)

    if nRewardID == 1 then  --- 金币
        self.trCoin.gameObject:SetActive(true)
    end

    if nRewardID == 2 then -- 狗（气球）
        self.trDog.gameObject:SetActive(true)
    end

    if nRewardID == 5 then -- 箭靶
        self.trArchery.gameObject:SetActive(true)
    end
    self.obj:SetActive(true)
end

function GoldCoinSplashUI:Hide()
    self.obj:SetActive(false)
    ThemeParkFreeSpin.bMapRewardFinish = true
end

return GoldCoinSplashUI