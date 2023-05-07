BuildObj = {}



function BuildObj:new(gameObject,strType)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.gameObject = gameObject
    o.transform = gameObject.transform

    --TODO 初始化建筑的数据
    o.strType = strType
    local season = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason]
    o.level = season[strType].level 
    o.progress = season[strType].progress
    o.giftBoxTime = season[strType].getGiftBoxTime

    local configInfo = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][strType]
    o.transform:FindDeepChild("NameText"):GetComponent(typeof(TextMeshProUGUI)).text = configInfo.name
    if o.level >= 5 then
        o.levelProgress = o.progress
    else
        local levelName = "level"..(o.level+1)
        o.levelProgress = configInfo.levels[levelName]
    end
    
    -- 不显示名字了 2019-11-23
    o.transform:FindDeepChild("NameContainer").gameObject:SetActive(false)

    o.progressText = o.transform:FindDeepChild("ProgressText"):GetComponent(typeof(TextMeshProUGUI))
    o.progressImg = o.transform:FindDeepChild("JinDuTiao"):GetComponent(typeof(UnityUI.Image))
    o.starContainer = o.transform:FindDeepChild("StarContainer")
    o.buildContainer = o.transform:FindDeepChild("Build")
    o.buildingContainer = o.transform:FindDeepChild("Building")
    o.noLevel = o.transform:FindDeepChild("NoLevel").gameObject

    o.giftBoxContainer = o.transform:FindDeepChild("GiftBoxContainer").gameObject
    o.giftBoxUnLock = o.transform:FindDeepChild("WeiJieSuo").gameObject --未解锁
    o.giftBoxCollect = o.transform:FindDeepChild("LiHe").gameObject --可收集

    o.giftBoxText = o.transform:FindDeepChild("GiftBoxText"):GetComponent(typeof(TextMeshProUGUI))
    o.giftBoxBtn = o.transform:FindDeepChild("BtnCollect"):GetComponent(typeof(UnityUI.Button))
    o.giftBoxBtn.onClick:AddListener(function()
        BuildGameManager:getBuildLevelGiftClicked(o)
    end)
	return o
end

function BuildObj:refreshUI()
    self.progressText.text = self.progress.."/"..self.levelProgress
    self.progressImg.fillAmount = self.progress/self.levelProgress
    self:updateStarAndBuild()
    self:setGiftBoxUI()
end

function BuildObj:setGiftBoxUI()
    if self.level < 4 then
        self.giftBoxContainer:SetActive(false)
        return
    end
    self.giftBoxContainer:SetActive(true)
    self.giftBoxTime = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][self.strType].getGiftBoxTime

    local lastTime = self.giftBoxTime
    local diff = TimeHandler:GetServerTimeStamp() - lastTime
    if diff < BuildGameDataHandler.BUILDGIFTBOXTIMEDIFF then
        self.giftBoxBtn.interactable = false
        self.giftBoxCollect:SetActive(false)
        --TODO 开启倒计时
        if self.co ~= nil then
            return
        end
        self.co = StartCoroutine( function()
            self.giftBoxUnLock:SetActive(true)
            local waitTime = Unity.WaitForSeconds(1)
            local endTime = lastTime + BuildGameDataHandler.BUILDGIFTBOXTIMEDIFF
            while BuildGameMainUIPop.m_gameObject ~= nil do
                local nowSecond = TimeHandler:GetServerTimeStamp()
                local timediff = endTime - nowSecond

                local days = timediff // (3600*24)
                local hours = timediff // 3600 - 24 * days
                local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
                local seconds = timediff % 60
                self.giftBoxText.text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                yield_return(waitTime)
                if timediff <= 0 then
                    self.giftBoxUnLock:SetActive(false)
                    self.giftBoxCollect:SetActive(true)
                    self.giftBoxBtn.interactable = true
                    break
                end
            end
            self.co = nil
        end)
    else
        --TODO 不显示倒计时UI
        self.giftBoxUnLock:SetActive(false)
        self.giftBoxCollect:SetActive(true)
        self.giftBoxBtn.interactable = true
    end
end

function BuildObj:updateStarAndBuild()
    for i=0, self.starContainer.childCount-1 do
        self.starContainer:GetChild(i).gameObject:SetActive(i < self.level)
        self.buildContainer:GetChild(i).gameObject:SetActive(i < self.level)     --每一个Build中有5处地方
    end
    for i=0,self.buildingContainer.childCount-1 do
        self.buildingContainer:GetChild(i).gameObject:SetActive(self.level < (i+2))
    end
    if self.level == 0 then
        self.noLevel:SetActive(true)
        self.buildingContainer.gameObject:SetActive(false)
    else
        self.noLevel:SetActive(false)
        self.buildingContainer.gameObject:SetActive(true)
    end
end

function BuildObj:skipBtnClicked()
    local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][self.strType]
    self.level = data.level
    self.progress = data.progress
    self.giftBoxTime = data.getGiftBoxTime
    if data.level >= 5 then
        self.levelProgress = data.progress
    else
        local levelName = "level"..(self.level+1)
        self.levelProgress = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][self.strType].levels[levelName]
    end
    self:refreshUI()
end