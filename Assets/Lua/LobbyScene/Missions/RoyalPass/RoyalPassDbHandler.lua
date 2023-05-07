RoyalPassDbHandler = {}
RoyalPassDbHandler.DATAPATH = Unity.Application.persistentDataPath.."/RoyalPassDbHandler.txt"

function RoyalPassDbHandler:Init()
    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        self.data = rapidjson.decode(strData)
    else
        self.data = self:GetDbInitData()
    end
        
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function RoyalPassDbHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function RoyalPassDbHandler:GetDbInitData()
    local data = {}
    data.m_nVersion = 1
    data.m_nLevel = 0
    data.nStars = 0
    data.m_bIsPurchase = false
    data.m_nSeason = -1
    data.m_nEndTime = 0
    data.m_nLastChestLevel = 0

    data.m_mapFreePassGet = {}
    for i = 1, 101 do
        data.m_mapFreePassGet[i] = {}
        local prize = RoyalPassConfig:GetFreePassLevelPrize(i)
        for j = 1 , LuaHelper.tableSize(prize) do
            data.m_mapFreePassGet[i][j] = {}
            data.m_mapFreePassGet[i][j].bGet = false
        end
    end
    
    data.m_mapRoyalPassGet = {}
    for i = 1, 101 do
        local prize = RoyalPassConfig:GetRoyalPassLevelPrize(i)
        data.m_mapRoyalPassGet[i] = {}
        for j = 1 , LuaHelper.tableSize(prize) do
            data.m_mapRoyalPassGet[i][j] = {}
            data.m_mapRoyalPassGet[i][j].bGet = false
        end
    end

    return data
end