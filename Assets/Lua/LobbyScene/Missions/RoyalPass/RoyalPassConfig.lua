RoyalPassConfig = {}
RoyalPassConfig.N_MIN_STARS = 100 -- 最少star数
RoyalPassConfig.N_UPGRADE_INTERVAL_STARS = 50 -- 每N_UPGRADE_INTERVAL_LEVEL级 升级所需star数上升N_UPGRADE_INTERVAL_STARS个
RoyalPassConfig.N_UPGRADE_INTERVAL_LEVEL = 10 -- 每N_UPGRADE_INTERVAL_LEVEL级 升级所需star数上升N_UPGRADE_INTERVAL_STARS个
RoyalPassConfig.N_INTERVAL_LIMITED_TIME = 72 * 60 * 60
RoyalPassConfig.N_UPGRADE_LASTCHEST_STARS = 750
RoyalPassConfig.N_MIN_CHEST_REWARD = 8 -- 商店1美元的等值金币倍
RoyalPassConfig.MAP_LEVEL_STAR = {}
RoyalPassConfig.MAP_LEVEL_DIAMOND = {}
RoyalPassConfig.N_UNLOCK_LEVEL = 10
if GameConfig.PLATFORM_EDITOR then
    RoyalPassConfig.N_UNLOCK_LEVEL = 2
end

RoyalPassConfig.PrizeType = {
    None = 0,
    Coins = 1,
    Diamond = 2,
    VipPoint = 3,
    DoubleExp = 4,
    SlotsCards = 5,
    Activty = 6,
    Coupon = 7, -- 优惠卷{nType = RoyalPassConfig.PrizeType.Coupon, nTime = 3 * 60 * 60, fRatio = 1.5}
    MissionStarBooster = 8, 
    FlashBooster = 9,
    CoinsAndVip = 10,
    DiamondCoupon = 11,
    LoungePoint = 12,
    LoungeDayPass = 13,
    LoungeChest = 14,
}

RoyalPassConfig.PrizeName = LuaHelper.GetKeyValueSwitchTable(RoyalPassConfig.PrizeType)

-- 实际上有101个
RoyalPassConfig.m_mapFreePass = {
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Common} },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 100} },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Three} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Common} }, -- 4

    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 100} },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Three} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Common} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 9
    
    { 
        {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 100},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    }, -- nCount 指 给卡包的个数
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 9
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Common} },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 100} },
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.5} }, -- 14
    
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Common} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Three} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 19
    
    { 
        {nType = RoyalPassConfig.PrizeType.CoinsAndVip, productId = AllBuyCFG[1].productId, nPointCount = 100 },
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Five}
    },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Three} },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Four} }, -- 24
    
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 30, nChestType = LoungeConfig.enumCHESTTYPE.Common} },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Four} },
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.5} },
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 1} }, -- 29

    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 200} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 30, nChestType = LoungeConfig.enumCHESTTYPE.Common} }, -- 34
    
    { {nType = RoyalPassConfig.PrizeType.FlashBooster, nTime = 12 * 60 * 60} },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 200} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 50, nChestType = LoungeConfig.enumCHESTTYPE.Common} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 39

    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Four} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 50, nChestType = LoungeConfig.enumCHESTTYPE.Common} },
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 100} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 44
    
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 300} },
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 1} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Rare} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 49
    
    { 
        {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId}, -- 9
        {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId}
    },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 300} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Rare} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 54

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.DiamondCoupon, nTime = 12 * 60 * 60, fRatio = 1.6} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Rare} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 59

    { 
        {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 30, nChestType = LoungeConfig.enumCHESTTYPE.Rare},
        {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.5}
    },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 300} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Rare} },
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 100} }, -- 64

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Four} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Rare} }, -- 69

    { 
        {nType = RoyalPassConfig.PrizeType.MissionStarBooster, nTime = 60 * 60 * 2},
        {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId}
    },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 30, nChestType = LoungeConfig.enumCHESTTYPE.Rare} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 74

    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} },
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 1} },
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.5} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 5, nChestType = LoungeConfig.enumCHESTTYPE.Epic} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 79
    
    { 
        {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 500}, -- 500 个钻石
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Five}
    },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 5, nChestType = LoungeConfig.enumCHESTTYPE.Epic} }, -- 84

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 5, nChestType = LoungeConfig.enumCHESTTYPE.Epic} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 5, nChestType = LoungeConfig.enumCHESTTYPE.Epic} }, -- 89

    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId}
    },
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 1} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Epic} },
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.5} }, -- 94

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} },
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} }, -- 99

    { 
        {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 2},
        {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId}, -- 9
    }
}

RoyalPassConfig.m_mapRoyalPass = {
    { {nType = RoyalPassConfig.PrizeType.CoinsAndVip, productId = AllBuyCFG[1].productId, nPointCount = 50} }, --0

    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 100} }, --1
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.5} }, --2
    
    { {nType = RoyalPassConfig.PrizeType.CoinsAndVip, productId = AllBuyCFG[1].productId, nPointCount = 50} }, --3
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 3, nSlotsType = SlotsCardsAllProbTable.PackType.Three} }, -- 4

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 5
    { {nType = RoyalPassConfig.PrizeType.VipPoint, nPointCount = 50} }, -- 6
    { {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} }, -- 7
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} }, -- nTime 指 持续的时间 -- 8
    { {nType = RoyalPassConfig.PrizeType.MissionStarBooster, nTime = 60 * 60 * 2} }, -- 9
    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    }, -- nCount 指 给卡包的个数 -- 10

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 11
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 4, nSlotsType = SlotsCardsAllProbTable.PackType.Three} }, -- 12
    { {nType = RoyalPassConfig.PrizeType.DiamondCoupon, nTime = 12 * 60 * 60, fRatio = 1.5} }, -- 13
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 14
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Rare} }, -- 15
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Four} }, -- 16
    { {nType = RoyalPassConfig.PrizeType.FlashBooster, nTime = 6 * 60 * 60} }, -- 17
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 18
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 100} }, --19

    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    }, -- nCount 指 给卡包的个数 -- 20

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 9
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Rare} }, -- 22
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 5, nSlotsType = SlotsCardsAllProbTable.PackType.Three} }, -- 23
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 24
    
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 3, nSlotsType = SlotsCardsAllProbTable.PackType.Four} }, -- 25
    { {nType = RoyalPassConfig.PrizeType.VipPoint, nPointCount = 50} }, -- 26
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 150} }, --27

    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 30, nChestType = LoungeConfig.enumCHESTTYPE.Rare} }, -- 28
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, --29
    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 1, nSlotsType = SlotsCardsAllProbTable.PackType.Five}
    }, -- 30

    { {nType = RoyalPassConfig.PrizeType.MissionStarBooster, nTime = 60 * 60 * 2} }, -- 31
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} }, -- 32

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 33
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Epic} }, -- 34
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 9
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 150} }, -- 36
    { {nType = RoyalPassConfig.PrizeType.VipPoint, nPointCount = 50} }, -- 37
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 3, nSlotsType = SlotsCardsAllProbTable.PackType.Four} }, -- 38
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.5} }, -- 39
    
    {  
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    }, -- 40

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 41
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 5, nSlotsType = SlotsCardsAllProbTable.PackType.Three} }, -- 42
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, --43
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, --44
    
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 1} }, -- 45
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 10, nChestType = LoungeConfig.enumCHESTTYPE.Epic} }, -- 46
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 200} }, --47
    { {nType = RoyalPassConfig.PrizeType.VipPoint, nPointCount = 50} }, -- 48
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 3, nSlotsType = SlotsCardsAllProbTable.PackType.Four} }, -- 49

    { 
        {nType = RoyalPassConfig.PrizeType.CoinsAndVip, productId = AllBuyCFG[1].productId, nPointCount = 50},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    }, -- 50

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 51
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 9
    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 8, nSlotsType = SlotsCardsAllProbTable.PackType.Three} }, -- 53
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, --54
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 55
    { {nType = RoyalPassConfig.PrizeType.MissionStarBooster, nTime = 60 * 60 * 2} }, -- 56
    { {nType = RoyalPassConfig.PrizeType.DiamondCoupon, nTime = 12 * 60 * 60, fRatio = 1.6} }, -- 57
    { {nType = RoyalPassConfig.PrizeType.FlashBooster, nTime = 6 * 60 * 60} }, -- 58
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} }, --59

    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId}
    }, -- 60

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 61
    { {nType = RoyalPassConfig.PrizeType.VipPoint, nPointCount = 100} }, --62
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, --63
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },-- 64
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} }, -- 65
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 1} }, -- 66
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.7} }, -- 67
    { {nType = RoyalPassConfig.PrizeType.FlashBooster, nTime = 6 * 60 * 60} }, -- 68
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 300} }, --69
    
    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 2, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 3, nSlotsType = SlotsCardsAllProbTable.PackType.Five}
    }, -- 70
    { {nType = RoyalPassConfig.PrizeType.CoinsAndVip, productId = AllBuyCFG[1].productId, nPointCount = 50} }, -- 71

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, --72
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 9
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Epic} }, -- 74
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} },--75
    { {nType = RoyalPassConfig.PrizeType.DiamondCoupon, nTime = 12 * 60 * 60, fRatio = 1.8} }, -- 76
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} }, -- 77
    { {nType = RoyalPassConfig.PrizeType.FlashBooster, nTime = 6 * 60 * 60} }, -- 78
    { {nType = RoyalPassConfig.PrizeType.MissionStarBooster, nTime = 60 * 60 * 2} }, -- 79
    
    { 
        {nType = RoyalPassConfig.PrizeType.VipPoint, nPointCount = 100},
        {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId}
    }, -- 80

    { {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 3, nSlotsType = SlotsCardsAllProbTable.PackType.Five} }, -- 81

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 82
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 83
    { {nType = RoyalPassConfig.PrizeType.DiamondCoupon, nTime = 12 * 60 * 60, fRatio = 1.8} }, --84
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 300} }, --85
    { {nType = RoyalPassConfig.PrizeType.Coupon, nTime = 12 * 60 * 60, fRatio = 1.8} }, -- 86
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 87
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 20, nChestType = LoungeConfig.enumCHESTTYPE.Epic} }, -- 88
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 1} }, -- 89

    { 
        {nType = RoyalPassConfig.PrizeType.SlotsCards, nCount = 5, nSlotsType = SlotsCardsAllProbTable.PackType.Five},
        {nType = RoyalPassConfig.PrizeType.VipPoint, nPointCount = 100}
    }, -- 90

    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 91
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 500} }, --92
    { {nType = RoyalPassConfig.PrizeType.DiamondCoupon, nTime = 12 * 60 * 60, fRatio = 1.8} }, -- 93
    { {nType = RoyalPassConfig.PrizeType.FlashBooster, nTime = 12 * 60 * 60} }, -- 94
    { {nType = RoyalPassConfig.PrizeType.LoungeChest, nCount = 30, nChestType = LoungeConfig.enumCHESTTYPE.Epic} }, -- 95
    { {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 500} }, --96
    { {nType = RoyalPassConfig.PrizeType.LoungeDayPass, nCount = 2} }, -- 97
    { {nType = RoyalPassConfig.PrizeType.Coins, productId = AllBuyCFG[1].productId} }, -- 9
    { {nType = RoyalPassConfig.PrizeType.LoungePoint, nCount = 1000} }, -- 99

    { 
        {nType = RoyalPassConfig.PrizeType.Diamond, nCount = 600}, -- 600 个钻石
        {nType = RoyalPassConfig.PrizeType.Activty, productId = AllBuyCFG[1].productId} --TODO 这里的数值要修改
    }, -- 100
}

function RoyalPassConfig:Init()
    for i=1, 100 do
        if i < 3 then
            self.MAP_LEVEL_STAR[i] = 100
            self.MAP_LEVEL_DIAMOND[i] = 50
        elseif i < 20 then
            self.MAP_LEVEL_STAR[i] = 200
            self.MAP_LEVEL_DIAMOND[i] = 100
        elseif i < 50 then
            self.MAP_LEVEL_STAR[i] = 250
            self.MAP_LEVEL_DIAMOND[i] = 150
        elseif i < 60 then
            self.MAP_LEVEL_STAR[i] = 300
            self.MAP_LEVEL_DIAMOND[i] = 200
        elseif i < 70 then
            self.MAP_LEVEL_STAR[i] = 400
            self.MAP_LEVEL_DIAMOND[i] = 250
        elseif i < 80 then
            self.MAP_LEVEL_STAR[i] = 500
            self.MAP_LEVEL_DIAMOND[i] = 300
        elseif i < 90 then
            self.MAP_LEVEL_STAR[i] = 600
            self.MAP_LEVEL_DIAMOND[i] = 350
        else
            self.MAP_LEVEL_STAR[i] = 750
            self.MAP_LEVEL_DIAMOND[i] = 400
        end
    end
end

function RoyalPassConfig:GetCurrentUpgradeLevelNeedStar()
    local nNext = RoyalPassHandler.m_nLevel + 1
    if nNext > 99 then
        nNext = 99
    end
    return self.MAP_LEVEL_STAR[nNext]
end

function RoyalPassConfig:GetCurrentUpgradeLevelNeedDiamond()
    local nNext = RoyalPassHandler.m_nLevel + 1
    if nNext > 99 then
        nNext = 99
    end
    return self.MAP_LEVEL_DIAMOND[nNext]
end

function RoyalPassConfig:GetCurrentStar()
    if RoyalPassHandler.m_nLevel == 0 then
        return RoyalPassDbHandler.data.nStars
    end
    local nCount = 0
    local nLevel = RoyalPassHandler.m_nLevel > 99 and 99 or RoyalPassHandler.m_nLevel
    for i = 1, nLevel do
        nCount = nCount + self.MAP_LEVEL_STAR[i]
    end
    return RoyalPassDbHandler.data.nStars - nCount
end

function RoyalPassConfig:GetFreePassLevelPrize(nLevel)
    local result = {}
    for i = 1,LuaHelper.tableSize(self.m_mapFreePass[nLevel]) do
        if self.m_mapFreePass[nLevel][i].nType == self.PrizeType.SlotsCards then
            if not SlotsCardsManager:orUnLock() then
                local productId = nil
                if nLevel < 20 then
                    productId = AllBuyCFG[2].productId
                elseif nLevel < 40 then
                    productId = AllBuyCFG[3].productId
                elseif nLevel < 80 then
                    productId = AllBuyCFG[4].productId
                elseif nLevel <= 101 then
                    productId = AllBuyCFG[5].productId
                else
                    productId = AllBuyCFG[6].productId
                end
                table.insert( result, { nType = RoyalPassConfig.PrizeType.Coins, productId = productId } )
            else
                table.insert( result, self.m_mapFreePass[nLevel][i] )
            end
        elseif self.m_mapFreePass[nLevel][i].nType == self.PrizeType.Activty then
            local active = ActiveManager.activeType
            if active then
                table.insert( result, self.m_mapFreePass[nLevel][i] )
            else
                local productId = nil
                if nLevel < 20 then
                    productId = AllBuyCFG[2].productId
                elseif nLevel < 40 then
                    productId = AllBuyCFG[3].productId
                elseif nLevel < 80 then
                    productId = AllBuyCFG[4].productId
                elseif nLevel <= 101 then
                    productId = AllBuyCFG[5].productId
                else
                    productId = AllBuyCFG[6].productId
                end
                table.insert( result, { nType = RoyalPassConfig.PrizeType.Coins, productId = productId } )
            end
        else
            table.insert( result, self.m_mapFreePass[nLevel][i] )
        end
    end
    return result
end

function RoyalPassConfig:GetRoyalPassLevelPrize(nLevel)
    local result = {}
    for i = 1,LuaHelper.tableSize(self.m_mapRoyalPass[nLevel]) do
        if self.m_mapRoyalPass[nLevel][i].nType == self.PrizeType.SlotsCards then
            if not SlotsCardsManager:orUnLock() then
                local productId = nil
                if nLevel < 20 then
                    productId = AllBuyCFG[2].productId
                elseif nLevel < 40 then
                    productId = AllBuyCFG[3].productId
                elseif nLevel < 80 then
                    productId = AllBuyCFG[4].productId
                elseif nLevel <= 101 then
                    productId = AllBuyCFG[5].productId
                else
                    productId = AllBuyCFG[6].productId
                end
                table.insert( result, { nType = RoyalPassConfig.PrizeType.Coins, productId = productId } )
            else
                table.insert( result, self.m_mapRoyalPass[nLevel][i] )
            end
        elseif self.m_mapRoyalPass[nLevel][i].nType == self.PrizeType.Activty then
            local active = ActiveManager.activeType
            if active then
                table.insert(result, self.m_mapRoyalPass[nLevel][i] )
            else
                local productId = nil
                if nLevel < 20 then
                    productId = AllBuyCFG[2].productId
                elseif nLevel < 40 then
                    productId = AllBuyCFG[3].productId
                elseif nLevel < 80 then
                    productId = AllBuyCFG[4].productId
                elseif nLevel <= 101 then
                    productId = AllBuyCFG[5].productId
                else
                    productId = AllBuyCFG[6].productId
                end
                table.insert( result, { nType = RoyalPassConfig.PrizeType.Coins, productId = productId } )
            end
        else
            table.insert( result, self.m_mapRoyalPass[nLevel][i] )
        end
    end
    return result
end
