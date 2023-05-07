SlotsCardsAllProbTable = {}

SlotsCardsAllProbTable.PackType = {
    One = 1,    
    Two = 2,      
    Three = 3,      
    Four = 4,
    Five = 5
}

SlotsCardsAllProbTable.PackTypeToGift = {
    {setCardCount = 2,  starCount = 2,   minCardCount = 1}, -- 这个不用配置，因为如果是一星卡包就随机数量
    {setCardCount = 3,  starCount = 2,   minCardCount = 1}, -- 这个不用配置，因为如果是二星卡包就随机数量
    {setCardCount = 4,  starCount = 3,   minCardCount = 1}, -- 对应SlotsCardsAllProbTable.PackType.Three
    {setCardCount = 5,  starCount = 4,   minCardCount = 1}, -- 对应SlotsCardsAllProbTable.PackType.Four
    {setCardCount = 6,  starCount = 5,   minCardCount = 1}  -- 对应SlotsCardsAllProbTable.PackType.Five
}

-- 获取PackStamp的概率
SlotsCardsAllProbTable.GetPackProb = {
    content = {1, 2}, --1代表没有Pack，2代表获得Pack
    probs = {50, 1}
}

SlotsCardsAllProbTable.GetPackTypeProb = {
    probs = {200, 90, 20, 5, 1}
}

-- 一个pack中有多少个card
SlotsCardsAllProbTable.PackCardsCount = {
    content = {1, 2, 3, 4, 5, 6}, --一个pack中有card的数量
    probs = {10, 180, 260, 350, 50, 20} --相应数量的概率
}

--可以通过修改它，来控制获得卡牌星数的概率
SlotsCardsAllProbTable.GetCardFromStar = {
    content = {1, 2, 3, 4, 5}, --根据星数，随机获取卡牌
    probs = {280, 160, 60, 30, 10} --概率
}

--金牌根据星数概率不同
SlotsCardsAllProbTable.GetGoldCard = {
    content = {1, 2}, --1代表没有获得金牌，2代表获得金牌
    probs = {25, 1}
} 

-- 1 3 5 7 9 是黄格子 奖励是金币加卡包  
-- 2 4 6 8 10 是白格子 奖励只有金币
--CuprumWheelGame概率 -- 7
SlotsCardsAllProbTable.CuprumWheelConfig = {
    steps = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, -- 转轮格子(格子ID: 1 2 3 4 5 6..)对应的礼物倍数不同，UI上1，3，5，7，9是有盒子的

    probs = {5, 25, 5, 25, 1, 25, 5, 25, 5, 2}, -- 随机到每个格子的概率是不一样的

    -- 玩家获得的金币是 multiple * 1BASE
    -- 系数 multiple 最多不能大于 1
    multiple = {0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1}, -- 格子ID对应的奖励倍数,想要调整奖励金额，可以改这里
}

--SliverWheelGame概率 -- 20
SlotsCardsAllProbTable.SliverWheelConfig = {
    steps = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, -- 转轮格子(格子ID: 1 2 3 4 5 6..)对应的礼物倍数不同，UI上1，3，5，7，9是有盒子的

    probs = {7, 25, 7, 25, 7, 25, 7, 25, 7, 2}, -- 随机到每个格子的概率是不一样的

    -- 玩家获得的金币是 multiple * 3BASE
    -- 系数 multiple 最多不能大于 1
    multiple = {0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1}, -- 格子ID对应的奖励倍数,想要调整奖励金额，可以改这里
}

--GoldWheelGame概率 -- 70
SlotsCardsAllProbTable.GoldWheelConfig = {
    steps = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, -- 转轮格子(格子ID: 1 2 3 4 5 6..)对应的礼物倍数不同，UI上1，3，5，7，9是有盒子的

    probs = {5, 25, 5, 25, 2, 25, 5, 25, 5, 5}, -- 随机到每个格子的概率是不一样的

    -- 玩家获得的金币是 multiple * 15BASE
    -- 系数 multiple 最多不能大于 1
    multiple = {0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1}, -- 格子ID对应的奖励倍数,想要调整奖励金额，可以改这里
}

--FrenzySpinGameProb概率 如果转到了卡包就一定是5星卡包
SlotsCardsAllProbTable.frenzySpinGameProb = {500, 220, 60, 5} --对应1: Coins, 2: CoinRespin, 3:StampPack, 4:WildCard概率
SlotsCardsAllProbTable.frenzySpinGameRandomProb = {90, 80, 60, 20} --对应1: Coins, 2: CoinRespin, 3:StampPack, 4:WildCard概率,这个是滚动出现元素概率
