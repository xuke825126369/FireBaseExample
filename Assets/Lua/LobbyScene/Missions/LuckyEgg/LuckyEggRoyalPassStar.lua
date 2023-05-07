LuckyEggRoyalPassStar = {}

function LuckyEggRoyalPassStar:new(gameObject, nRoyalStars)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o:Init(gameObject, nRoyalStars)
    return o
end

function LuckyEggRoyalPassStar:Init(gameObject, nRoyalStars)
    self.transform = gameObject.transform
    LuaAutoBindMonoBehaviour.Bind(gameObject, self)
    self.goRoyalStarsFreeNode = self.transform:FindDeepChild("RoyalStarsLogoFree").gameObject
    self.textRoyalStarsFree = self.transform:FindDeepChild("TextRoyalstarFree"):GetComponent(typeof(TextMeshProUGUI))

    self.goRoyalStarsPurchaseNode = self.transform:FindDeepChild("RoyalStarsLogoPurchase").gameObject
    self.textRoyalStarsPurchase = self.transform:FindDeepChild("TextRoyalstarPurchase"):GetComponent(typeof(TextMeshProUGUI))
    self.textRoyalStarsMorePercent = self.transform:FindDeepChild("TextMeshProMorePercent"):GetComponent(typeof(TextMeshProUGUI))

    self.nRoyalStars = nRoyalStars
    self.fMultiplier = 1
    self:updateUI()
end

function LuckyEggRoyalPassStar:Update()
    local bInBooster = CommonDbHandler:orInMissionStarBoosterTime()
    if bInBooster then
        local fMultiplier = 2.5
        if self.fMultiplier ~= fMultiplier then
            self.fMultiplier = fMultiplier
            self:updateUI()
        end
        if self.goRoyalStarsFreeNode.activeSelf then
            self.goRoyalStarsFreeNode:SetActive(false)
        end
        if not self.goRoyalStarsPurchaseNode.activeSelf then
            self.goRoyalStarsPurchaseNode:SetActive(true)
        end
    else
        self.fMultiplier = 1
        if not self.goRoyalStarsFreeNode.activeSelf then
            self.goRoyalStarsFreeNode:SetActive(true)
        end
        if self.goRoyalStarsPurchaseNode.activeSelf then
            self.goRoyalStarsPurchaseNode:SetActive(false)
        end
    end
end

function LuckyEggRoyalPassStar:updateUI()
    if not RoyalPassHandler:orUnLock() then
        self.transform.gameObject:SetActive(false)
    else
        if not self.transform.activeSelf then
            self.transform.gameObject:SetActive(true)
        end
        self.textRoyalStarsFree.text = string.format("%d", self.nRoyalStars * self.fMultiplier)
        self.textRoyalStarsPurchase.text = string.format("%d", self.nRoyalStars * self.fMultiplier)
        self.textRoyalStarsMorePercent.text = string.format("%d", (self.fMultiplier - 1) * 100).."%"
    end
end

function LuckyEggRoyalPassStar:updateRoyalStars(nRoyalStars)
    self.nRoyalStars = nRoyalStars
end

function LuckyEggRoyalPassStar:getFinalRoyalStars()
    return self.nRoyalStars * self.fMultiplier
end