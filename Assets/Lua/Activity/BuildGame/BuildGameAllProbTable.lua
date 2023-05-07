BuildGameAllProbTable = {}

BuildGameAllProbTable.DepotsType = {
    Common = 0,    --30~60 Points
    Rare = 1,      --Open it to get at least:67 Silver Points
    Epic = 2,      --Open it to get at least:360 Silver Points + 200 Gold Points
    Legendary = 3  --Open it to get at least:6700 Silver Points + 3160 Gold Points
}

BuildGameAllProbTable.IsGetDepotsProb = {
    actions = {1, 2}, --1代表没获取，2代表获取
    probs = {100, 1}
}

BuildGameAllProbTable.GetDepotsProb = {
    depotsType = {0, 1, 2, 3}, --对应DepotsType
    probs = {18000, 12000, 100, 1}
}

BuildGameAllProbTable.DepotsForBuild = {
    BuildsType = {"Silver1","Silver2","Silver3","Gold1","Gold2","Gold3","Diamond1","Diamond2"},
    probs = {10, 10, 10, 10, 10, 10, 10, 10}
}

--为刷新数据，把概率调整回原来
BuildGameAllProbTable.DepotsForBuildAgain = {
    BuildsType = {"Silver1","Silver2","Silver3","Gold1","Gold2","Gold3","Diamond1","Diamond2"},
    probs = {10, 10, 10, 10, 10, 10, 10, 10}
}
