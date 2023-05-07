TEST = {}
TEST.a = 1
TEST.b = 2
TEST.c = 3

function TEST:new(bflag)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    if bflag then
        o.a = 100
    else
        o.b = 200
    end
    
    self:AAA()

    return o
end

function TEST:AAA()
    print(self.a)
    print("--------------a------")
end

local TestA = TEST:new(true)
local TestB = TEST:new(false)

print(TestA.a)
print(TestA.b)
print(TestA.c)

print(TestB.a)
print(TestB.b)
print(TestB.c)


-- {\"userLevelInfo\":{\"level\":506,\"levelProgress\":0.3220070232817229},\"piggyBank\":{\"strSkuKey\":\"com.sinuo.iap050\",\"nCoins\":31440504920},\"coin\":19927038960,\"updateCSCodeInfo\":{\"CSVersion\":0,\"CSVersion_Reward\":0},\"sendFriendFreeCoinInfo\":{},\"iapData\":{\"com.sinuo.iap004\":3,\"com.sinuo.iap008\":1,\"totalPrice\":176.24000000000053,\"com.sinuo.iap001\":55,\"com.sinuo.iap005\":7,\"com.sinuo.iap002\":4,\"com.sinuo.iap009\":1,\"com.sinuo.iap010\":5},\"hasConnectedFB\":false,\"vipPoint\":3945,\"deviceId\":\"34F9E3FA-55A-636849044333415890\",\"askFriendFreeCoinInfo\":{},\"shopStampData\":{\"nBonusCoins\":6480000000,\"nStampCount\":0,\"bValid\":true,\"nValidTime\":2332800,\"nStartLocalTime\":1556847334,\"nStartNetTime\":1556843734},\"rateThemeInfo\":{\"MermaidMischief\":3,\"CashRespins\":4,\"ColossalDog\":3},\"exp\":488800605,\"dailyChallangeInfo\":{\"challangeData\":{\"playedThemes\":[\"CashRespins\"],\"reSpinVideoSlots\":40,\"spinVideoSlots\":300,\"megaWin\":4,\"freeSpinVideoSlots\":40,\"collectHourlyBonus\":3,\"buyCoins\":1},\"rewardCount\":0,\"daySecond\":1552194000},\"storeBonusParam\":{\"nDayIndex\":67,\"nBonus\":0},\"hourlyBonusInfo\":{\"lastHourBonusLocalTime\":1556896098,\"lastHourBonusNetTime\":1556892498,\"index\":1},\"tableCollectFreeCoinInfo\":{\"daySecond\":1556769600,\"count\":2},\"setting\":{\"notification\":true,\"mute\":false},\"dataVersion\":2672260,\"dailyBonusList\":[1549256400,1549342800,1549429200,1549515600,1549602000,1549688400,1549774800,1549861200,1549947600,1550034000,1550120400,1550206800,1550293200,1550379600,1550466000,1550552400,1550638800,1550725200,1550811600,1550898000,1550984400,1551070800,1551157200,1551243600,1551330000,1551416400,1551502800,1551589200,1551675600,1551762000,1551848400,1551934800,1552021200,1552107600,1552194000,1552276800,1552363200,1552449600,1552536000,1552622400,1552708800,1552795200,1552881600,1552968000,1553054400,1553140800,1553227200,1553313600,1553400000,1553486400,1553572800,1553659200,1553745600,1553832000,1553918400,1554004800,1554091200,1554177600,1554264000,1554350400,1554436800,1554523200,1554609600,1554696000,1554782400,1554868800,1554955200,1555041600,1555128000,1555214400,1555300800,1555387200,1555473600,1555560000,1555646400,1555732800,1555819200,1555905600,1555992000,1556078400,1556164800,1556251200,1556337600,1556424000,1556510400,1556596800,1556683200,1556769600,1556856000],\"levelBoosterData\":{\"fXP\":2,\"bValid\":true,\"nStartLocalTime\":1556896626,\"nBoosterTime\":7200},\"rateInfo\":{\"popTime\":1549324880,\"ratedStoreVersion\":1,\"ratedTime\":1549324888}}