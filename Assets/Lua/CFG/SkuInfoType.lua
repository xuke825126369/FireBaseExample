SkuInfo = 
{
   nType = 0,
   productId = "",
   nDollar = 0,
   vipPoint = 0,

   baseCoins = 0,
   finalCoins = 0,
   baseDiamonds = 0,
   finalDiamonds = 0,
}

function SkuInfo:New()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

SkuInfoType = {
    None = 0,
    ShopCoins = 1,
    ShopDiamonds = 2,
    DealOfFun = 3,
    MegaBall = 4,
    BoostMe = 5,
    BingoBooster = 6,
    BingoWild = 7,
    BingoSuperBingo = 8,
    RoyalPassSale = 9,
    RoyalPassShop = 10,
    LuckyEggSale = 11,
    FlashBooster = 12,
    MissionStarBooster = 13,
    Bingo = 14,
    CookingFever = 15,
    RainbowPick = 16,
    LoungeCashBackPurchase = 17,
    BoardQuest = 18,
    RocketForune = 19,
    FreeBonusGame_ForLuckyWheel = 20,  
    FreeBonusGame_ForMegaBall = 21,
}

