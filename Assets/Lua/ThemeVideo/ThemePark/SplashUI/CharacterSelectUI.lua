--[[
    author:coldflag
    time:2021-08-27 14:23:16
]]

local CharacterSelectUI = {}


CharacterSelectUI.obj = nil
CharacterSelectUI.nSelectedCharacterID = nil
CharacterSelectUI.mapTrCharacterButton = nil


function CharacterSelectUI:Init()
    local assetPath = "FigureSelect.prefab"
    local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

    self.obj = Unity.Object.Instantiate(goPrefab)
    self.obj.transform:SetParent(ThemeVideo2020Scene.mPopScreenCanvas, false)
    self.obj.transform.localScale = Unity.Vector3.one
    -- self.m_transform = self.obj.transform

    -- 

    self:SelectedCharacterBtn_AddListener() -- 给四个选择按钮注册监听事件
    
    self.obj:SetActive(false)
end

--[[
    @desc: 修改界面上显示的人物的Start Prize
    author:coldflag
    time:2021-08-27 11:46:19
    @return: 都成功修改了，返回true，否则返回false
]]
function CharacterSelectUI:ChangeCharacterPrize()
    local trSceneSelectCharacter = self.obj.transform
    local arrayPrize = ThemeParkFreeSpin:GetArrayOfCharacterPrize()
    local bRV = false
    for i = 1, 4 do
        local textMeshName = "PrizeValue" .. i
        local trPrizeValue = trSceneSelectCharacter:FindDeepChild(textMeshName)
        local textMesh = trPrizeValue:GetComponent(typeof(Unity.TextMesh))
        if textMesh ~= nil then
            textMesh.text = arrayPrize[i]
            bRV = true
        else
            bRV = false
            break
        end
    end

    return bRV
end

function CharacterSelectUI:Show()
    if self.obj ~= nil then
        self:ChangeCharacterPrize()
        self.obj:SetActive(true)
    else
        self:Init()
        self:Show()
    end
end

function CharacterSelectUI:Hide()
    self.obj:SetActive(false)
end

function CharacterSelectUI:SelectedCharacterBtn_AddListener()
    
    if self.obj ~= nil then
        for i = 1, 4 do
            local sBtnName = "BtnSelectChar" .. i
            local trBtn = self.obj.transform:FindDeepChild(sBtnName)
            if trBtn ~= nil then
                local Btn = trBtn:GetComponent(typeof(UnityUI.Button))
                DelegateCache:addOnClickButton(Btn)
                Btn.onClick:AddListener(function()
                    self:onSelCharacterBtnClick(i)
                end)
            end
        end
    end
end

function CharacterSelectUI:onSelCharacterBtnClick(index)
    self.nSelectedCharacterID = index
    self:setSelectedCharIDToDB(self.nSelectedCharacterID) -- 保存本次选择的人物的信息，FreeSpin结束需要置空nil
    Debug.Log("SelectedCharacterID: " .. index)
    -- 隐藏本界面，显示地图
    ThemeParkFreeSpinUI:PlayMapStartScene()
    self:Hide()
end

function CharacterSelectUI:GetSelectedCharacterID()
    if self.nSelectedCharacterID ~= nil then
        return self.nSelectedCharacterID
    else
        Debug.Log("Did not get nSelectedCharacterID!!!!!!!!")
    end
end

function CharacterSelectUI:FlushCharacterID(nCharacterID)
    self.nSelectedCharacterID = nCharacterID
    self:setSelectedCharIDToDB(nCharacterID)
end

--------------------------------------------数据库保存-------------------------------------------------------

function CharacterSelectUI:setSelectedCharIDToDB(nCharacterID)
    local sLevelName = ThemeLoader.themeKey
    if LevelDataHandler.m_Data.LevelParams[sLevelName] == nil then
       LevelDataHandler.m_Data.LevelParams[sLevelName] = {} 
    end
    LevelDataHandler.m_Data.LevelParams[sLevelName].nCharacterID = nCharacterID
    LevelDataHandler:persistentData()
    if nCharacterID ~= nil then
        Debug.Log("Save nCharacterID: " .. nCharacterID)
    end
end

function CharacterSelectUI:getSelectedCharIDFromDB()
    local param = LevelDataHandler.m_Data
    if param == nil then
        return nil
    end

    if param.nCharacterID == nil then
        return nil
    end
    Debug.Log("Archieve nCharacterID: " .. param.nCharacterID)
    return param.nCharacterID
end

return CharacterSelectUI