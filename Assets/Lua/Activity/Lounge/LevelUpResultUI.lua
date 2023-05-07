LevelUpResultUI = {}
LevelUpResultUI.m_bInitFlag = false

function LevelUpResultUI:Show()
    if not LuaHelper.OrGameObjectExist(self.transform) then
        local goPrefab = AssetBundleHandler:LoadGoldenLoungeAsset("LevelUpResultUI.prefab")
        local goPanel = Unity.Object.Instantiate(goPrefab)
        self.transform = goPanel.transform
        self.transform:SetParent(LobbyScene.popCanvas, false)
        self.transform.localScale = Unity.Vector3.one
        self.transform.localPosition = Unity.Vector3.zero
        LuaAutoBindMonoBehaviour.Bind(self.transform.gameObject, self)
        self.transform.gameObject:SetActive(false)

        self.m_trContent = self.transform:FindDeepChild("Content")
        local btnClose = self.transform:FindDeepChild("BtnClose"):GetComponent(typeof(UnityUI.Button))
        DelegateCache:addOnClickButton(btnClose)
        btnClose.onClick:AddListener(function()
            GlobalAudioHandler:PlayBtnSound()
            self:Hide()
        end)

        self:initUI()
        self:initUIAllMedalLogos() -- 8关每个星级对应的徽章图
    end

    ViewAlphaAni:Show(self.transform.gameObject)
    self:RefreshUI()
    LoungeAudioHandler:PlaySound("showResult")
end

-- 只缓存资源节点 不更新界面参数
function LevelUpResultUI:initUI()
    -- PlatinumUI -- RoyalUI -- MasterUI
    local listNames = {"PlatinumUI1", "PlatinumUI2", "PlatinumUI3", "RoyalUI1",
                            "RoyalUI2", "RoyalUI3", "MasterUI1", "MasterUI2"}

    self.m_listMedalInfoNodes = {}
    for i=1, 8 do
        local tr = self.transform:FindDeepChild(listNames[i])
        local goNode = tr.gameObject
        local imageProgress = tr:FindDeepChild("imageProgress"):GetComponent(typeof(UnityUI.Image))
        local TextMeshProName = tr:FindDeepChild("TextMeshProName"):GetComponent(typeof(TextMeshProUGUI))
        local TextMeshProCurChestPointProgress = tr:FindDeepChild("TextMeshProCurChestPointProgress"):GetComponent(typeof(TextMeshProUGUI))
    
        local listGoStars = {}
        for nStarIndex=1, 5 do
            local name = "StarNode" .. nStarIndex
            local trStarNode = tr:FindDeepChild(name)
            local goStar = trStarNode:FindDeepChild("imageStar").gameObject
            table.insert(listGoStars, goStar)
        end

        local listGoMedalLogos = {}
        for i=1, 5 do
            local name = "MedalStar" .. i
            local goMedalLogo = tr:FindDeepChild(name).gameObject
            table.insert(listGoMedalLogos, goMedalLogo)
        end

        local goProgressNode = tr:FindDeepChild("ProgressNode").gameObject
        local goMedalCompleted = tr:FindDeepChild("MedalCompleted").gameObject
        
        -- TextMeshProLoungePointsAdd -- +900,000
        local TextMeshProLoungePointsAdd = tr:FindDeepChild("TextMeshProLoungePointsAdd"):GetComponent(typeof(TextMeshProUGUI))

        -- LevelUpRewardNode
        local goLevelUpRewardNode = tr:FindDeepChild("LevelUpRewardNode").gameObject

        -- TextLevelUpRewardCoins
        local TextLevelUpRewardCoins = tr:FindDeepChild("TextLevelUpRewardCoins"):GetComponent(typeof(UnityUI.Text))

        -- LengendaryNode
        local trLengendaryNode = tr:FindDeepChild("LengendaryNode")
        local goLengendaryNode = trLengendaryNode.gameObject
        local imageLengendaryProgress = trLengendaryNode:FindDeepChild("imageLengendaryProgress"):GetComponent(typeof(UnityUI.Image))
        local TextMeshProLengendaryProgress = trLengendaryNode:FindDeepChild("TextMeshProLengendaryProgress"):GetComponent(typeof(TextMeshProUGUI))

        local nodes = { goNode = goNode,
            imageProgress = imageProgress, TextMeshProName = TextMeshProName, 
            TextMeshProCurChestPointProgress = TextMeshProCurChestPointProgress,
            listGoStars = listGoStars, listGoMedalLogos = listGoMedalLogos,
            goProgressNode = goProgressNode, goMedalCompleted = goMedalCompleted,
            TextMeshProLoungePointsAdd = TextMeshProLoungePointsAdd,
            goLevelUpRewardNode = goLevelUpRewardNode, 
            TextLevelUpRewardCoins = TextLevelUpRewardCoins,
            goLengendaryNode = goLengendaryNode, imageLengendaryProgress = imageLengendaryProgress,
            TextMeshProLengendaryProgress = TextMeshProLengendaryProgress,
        }

        table.insert(self.m_listMedalInfoNodes, nodes)
    end
end

function LevelUpResultUI:initUIAllMedalLogos()
    self.m_listMedalLogos = {} -- 8个子表 每个子表5个元素
    for nLevel=1, 8 do
        local nodes = {}
        for nStar=1, 5 do
            local name = "Star" .. nStar .. "ElemLevel" .. nLevel
            local goLogo = self.transform:FindDeepChild(name).gameObject
            table.insert(nodes, goLogo)
            goLogo:SetActive(false)
        end
        table.insert(self.m_listMedalLogos, nodes)
    end
end

function LevelUpResultUI:RefreshUI()
    for i=1, 8 do
        self.m_listMedalInfoNodes[i].goNode:SetActive(false)
        self.m_listMedalInfoNodes[i].goLevelUpRewardNode:SetActive(false)

        local listGoStars = self.m_listMedalInfoNodes[i].listGoStars
        for j=1, 5 do
            listGoStars[j]:SetActive(false)
        end
    end
    
    for i=1, 8 do
        local logos = self.m_listMedalLogos[i]
        for j=1, 5 do
            logos[j]:SetActive(false)
        end
    end

    for i=1, 8 do
        local nPoints = MedalMasterMainUI.listDistributionLoungePoints[i]
        local nPrize = MedalMasterMainUI.listLevelUpRewardCoins[i]
        if nPoints > 0 then
            
            local index = i
            self.m_listMedalInfoNodes[index].goNode:SetActive(true)
            self.m_listMedalInfoNodes[index].TextMeshProName.text = LoungeConfig.listName[index]
        
            local nStar, fProgress, nPlayerExp, nCurLevelExp = LoungeConfig:getMedalLevelInfo(index)
            self.m_listMedalInfoNodes[index].imageProgress.fillAmount = fProgress
            self.m_listMedalInfoNodes[index].TextMeshProCurChestPointProgress.text = 
                                            nPlayerExp .. "/" .. nCurLevelExp
                                            
            local bCompleteFlag = false
            if nStar == 5 then
                bCompleteFlag = true
            end
            self.m_listMedalInfoNodes[index].goProgressNode:SetActive(not bCompleteFlag)
            self.m_listMedalInfoNodes[index].goMedalCompleted:SetActive(bCompleteFlag)
            self.m_listMedalInfoNodes[index].goLengendaryNode:SetActive(bCompleteFlag)
            if bCompleteFlag then
                local bFull, fLengendaryProgress = LoungeConfig:getLengendaryProgress(index)
                self.m_listMedalInfoNodes[index].imageLengendaryProgress.fillAmount = fLengendaryProgress
                local strInfo = math.floor(fLengendaryProgress * 100) .. "%"
                self.m_listMedalInfoNodes[index].TextMeshProLengendaryProgress.text = strInfo
            end
        
            for i=1, 5 do
                if i <= nStar then
                    self.m_listMedalInfoNodes[index].listGoMedalLogos[i]:SetActive(true)
                    self.m_listMedalInfoNodes[index].listGoStars[i]:SetActive(true)
                else
                    self.m_listMedalInfoNodes[index].listGoMedalLogos[i]:SetActive(false)
                    self.m_listMedalInfoNodes[index].listGoStars[i]:SetActive(false)
                end
            end
            
            local strPoint = MoneyFormatHelper.numWithCommas(nPoints)
            self.m_listMedalInfoNodes[index].TextMeshProLoungePointsAdd.text = "+" .. strPoint
            
            if nPrize > 0 then
                self.m_listMedalInfoNodes[index].goLevelUpRewardNode:SetActive(true)
                
                local strPrize = MoneyFormatHelper.numWithCommas(nPrize)
                self.m_listMedalInfoNodes[index].TextLevelUpRewardCoins.text = strPrize
            end
            
            local medalLogos = self.m_listMedalLogos[index]
            for a=1, nStar do
                medalLogos[a]:SetActive(true)
            end
        
        end

    end
end

-- 需要有转屏操作就传一个ture，不需要的话就别传了
function LevelUpResultUI:Hide()
    ViewAlphaAni:Hide(self.transform.gameObject)
end

