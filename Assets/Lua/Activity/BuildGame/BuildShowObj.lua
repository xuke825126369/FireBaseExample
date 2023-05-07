BuildShowObj = {}



function BuildShowObj:new(gameObject,strType)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.gameObject = gameObject
    o.transform = gameObject.transform

    local configInfo = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][strType]
    
    -- o.transform:FindDeepChild("NameText"):GetComponent(typeof(TextMeshProUGUI)).text = configInfo.name
    
    -- 不显示名字了 2019-11-25
    o.transform:FindDeepChild("NameContainer").gameObject:SetActive(false)


    --TODO 初始化旧的建筑的数据
    o.strType = strType
    local buildObj = BuildGameMainUIPop.m_mapBuildObjects[strType]
    if buildObj == nil then
        o.level = 0
        o.progress = 0
    else
        o.level = buildObj.level
        o.progress = buildObj.progress
    end
    o.levelProgress = BuildGameMainUIPop.m_mapBuildObjects[strType].levelProgress --升级需要的进度
    o.levelUpPs = o.transform:FindDeepChild("LevelUpAni"):GetComponent(typeof(Unity.Animator))
    o.levelUpCount = 0  --用于显示房屋
    o.lastLevel = o.level  --用于显示奖励

    o.progressContainer = o.transform:FindDeepChild("ProgressContainer"):GetComponent(typeof(Unity.CanvasGroup)) --用于隐藏进度和星数
    o.progressText = o.transform:FindDeepChild("ProgressText"):GetComponent(typeof(TextMeshProUGUI))
    o.progressImg = o.transform:FindDeepChild("JinDuTiao"):GetComponent(typeof(UnityUI.Image))
    o.starContainer = o.transform:FindDeepChild("StarContainer") --用于升级时变换UI星数
    o.buildContainer = o.transform:FindDeepChild("BuildContainer")
    o.build = o.transform:FindDeepChild("Build") --用于升级时显示房屋
    o.building = o.transform:FindDeepChild("Building") --用于升级时隐藏房屋

    o.noLevel = o.transform:FindDeepChild("NoLevel").gameObject --无星数的时候显示
    o.transform:FindDeepChild("GiftBoxContainer").gameObject:SetActive(false)
	return o
end

function BuildShowObj:refreshUI(value)
    if self.levelProgress == nil then
        return
    end
    self.progressText.text = self.progress.."/"..self.levelProgress
    self.progressImg.fillAmount = (value == nil) and (self.progress/self.levelProgress) or (value/self.levelProgress)
end

function BuildShowObj:updateStar()
    for i=0, self.starContainer.childCount-1 do
        local star = self.starContainer:GetChild(i).gameObject
        if not star.activeSelf then
            star:SetActive(i < self.level)
            if i < self.level then
                local ani = self.starContainer:GetChild(i):GetComponent(typeof(Unity.Animator))
                ani:SetTrigger(Unity.Animator.StringToHash("ShowEffect"))
            end
        end
    end
end

function BuildShowObj:updateBuild()
    for i=0, self.build.childCount-1 do
        self.build:GetChild(i).gameObject:SetActive(i < (self.level - self.levelUpCount))     --每一个Building中有5处地方
    end
    if self.level > 0 then
        self.noLevel:SetActive(false)
        for i=0, self.building.childCount-1 do
            self.building:GetChild(i).gameObject:SetActive((self.level - self.levelUpCount) < (i+2))
        end
    else
        self.noLevel:SetActive(true)
        for i=0, self.building.childCount-1 do
            self.building:GetChild(i).gameObject:SetActive(false)
        end
    end
end

function BuildShowObj:levelUpToZeroRefreshDataAndUI()
    AudioHandler:PlayBuildGameSound("item_levelup")
    self.levelUpPs:SetTrigger(Unity.Animator.StringToHash("ShowEffect"))
    self.levelUpCount = self.levelUpCount + 1
    self.level = self.level + 1
    if self.level >= 5 then
        self.progress = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][self.strType].levels["level5"]
        self.levelProgress = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][self.strType].levels["level5"]
        self:refreshUI()
        self:updateStar()
        return
    end
    self.progress = 0
    local levelName = "level"..(self.level+1)
    self.levelProgress = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][self.strType].levels[levelName]
    -- Debug.Log("升级！！！！！！！！！！")
    self:refreshUI()
    self:updateStar()
end

function BuildShowObj:updateProgress()
    -- local data = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][self.strType]
    -- self.progress = data.progress
    -- local levelName = "level"..data.level
    -- self.levelProgress = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][self.strType].levels[levelName]
    self:refreshUI()
end

function BuildShowObj:skipBtnClicked()
    --TODO 直接刷新数据
    self.level = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][self.strType].level
    if self.level >= 5 then
        return
    end

    self.progress = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason][self.strType].progress
    local levelName = "level"..(self.level+1)
    self.levelProgress = BuildGameConfig.Build[BuildGameDataHandler.m_curSeason][self.strType].levels[levelName]
    self.levelUpCount = 0
    self.lastLevel = self.level
    self:refreshUI()
end