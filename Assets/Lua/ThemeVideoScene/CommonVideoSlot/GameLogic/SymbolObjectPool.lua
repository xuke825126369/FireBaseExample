local SymbolObjectPool = {}

function SymbolObjectPool:reset()
    self.m_mapPooledObjects = {} ---Dictionary<GameObject, List<GameObject> >()
    self.m_mapSpawnedObjects = {} --Dictionary<GameObject, GameObject>()

    self.m_listPool = {} --List<PoolItem>()
    self.m_transform = nil --
    
    self.m_mapCurveItem = {} --Dictionary<GameObject, CurveItem>()
    self.m_mapCurveSpineItem = {} --Dictionary<GameObject, CurveItem>()
    self.m_mapgoblurCurveItem = {} 
    
    --闪烁特效
    self.m_mapCurveItemGoLight = {} --Dictionary<GameObject, GameObject>()
    self.m_mapCurveItemGoDark = {} --Dictionary<GameObject, GameObject>()
    --动画
    self.m_mapSpinEffect = {} --Dictionary<GameObject, SpineEffect>()
    self.m_mapMultiClipEffect = {} --Dictionary<GameObject, MultiClipEffectObj>()
    
    --2018-2-10
    --给Spine元素加一个静帧图 滚动过程中使用
    self.m_mapSpineElemFrame0 = {}  --Dictionary<GameObject, GameObject>() "Frame0"
    self.m_mapSpineNode = {} -- 停止时候使用。。 "SpineNode"

    --2018-7-17 
    self.m_mapGOElemTransform = {} -- Dictionary<GameObject, Transform>()

    self.m_mapSortingGroup = {}
end

function SymbolObjectPool:AddPoolItem(Symbol, nSize)
    local strLevelName = ThemeLoader.themeKey
    if not GameConst.RELEASE_VERSION and strLevelName == "CollectLucky" then
        self:CheckSymbolPrefabStruct(Symbol)
    end

    local goPrefab = Symbol.prfab
    local bFind = false
    for k, v in pairs(self.m_listPool) do
        if v.prefab == goPrefab then
            bFind = true
            break
        end
    end

    if not bFind then
        table.insert(self.m_listPool, {goPrefab, nSize})
    end
end

function SymbolObjectPool:CheckSymbolPrefabStruct(Symbol)
    local nSymbolIndex = Symbol.m_nSymbolID
    local goSymbol = Symbol.prfab
    if Symbol.type == SymbolType.NullSymbol then
        return
    end

    if goSymbol.transform:FindDeepChild("goNormal") == nil then
        Debug.LogError("Error, 符号"..goSymbol.name.."： goNormal 不存在 ！！！")
    end

    if goSymbol.transform:FindDeepChild("goblur") == nil then
        Debug.LogError("Error, 符号"..goSymbol.name.."： goblur 不存在 ！！！")
    elseif goSymbol.transform:FindDeepChild("goblur").gameObject.activeSelf == false then
        Debug.LogError("Error, 符号"..goSymbol.name.."： goblur  activeSelf  should be true ！！！")
    end

    for i = 0, goSymbol.transform.childCount - 1 do
        local tranChild = goSymbol.transform:GetChild(i)
        if tranChild.localPosition.z ~= 0 then
            Debug.LogError("Error, 符号"..goSymbol.name.." | "..tranChild.name.."： Z 轴存在问题 ！！！")
        end
    end

    for i=0, goSymbol.transform.childCount - 1 do
        local tranChild = goSymbol.transform:GetChild(i)
        local curveItem = tranChild:GetComponent(typeof(CS.CurveItem))
        if curveItem ~= nil then
            if curveItem.sortingOrder >=0 or  curveItem.sortingOrder <= -100 then
                Debug.LogError("Error, 符号层级 不符合规定： [-100 ~ 0 : -50] "..goSymbol.name.." | "..curveItem.name)
            end
        end
        
        local curveSpineItem = tranChild:GetComponent(typeof(CS.CurveSpine))
        if curveSpineItem ~= nil then
            if curveSpineItem.sortingOrder >=0 or  curveSpineItem.sortingOrder <= -100 then
                Debug.LogError("Error, 符号层级 不符合规定： [-100 ~ 0 : -50] "..goSymbol.name.." | "..curveSpineItem.name)
            end
        end
    end
end

function SymbolObjectPool:CreateStartupPools()
    local strPoolDirPath = "NewGameNode/LevelInfo/SymbolsPool"
    local poolObj = ThemeVideoScene.transform:FindDeepChild(strPoolDirPath)
    self.m_transform = poolObj.transform
    
    self.m_mapPooledObjects = {}
    self.m_mapSpawnedObjects = {}

    local nSymbols = #self.m_listPool
    if nSymbols <= 0 then
        return
    end 
    
    for i = 1, nSymbols do
        self:CreatePool(self.m_listPool[i][1], self.m_listPool[i][2])
    end
end

function SymbolObjectPool:CreatePool(prefab, initialPoolSize)
    if initialPoolSize <= 0 then
        return
    end

    if prefab == nil then
        return
    end

    for k, v in pairs(self.m_mapPooledObjects) do
        if k == prefab then
            return
        end
    end

    local list = {}
    while #list < initialPoolSize do
        local obj = Unity.Object.Instantiate(prefab)
        local tr = obj.transform
        self.m_mapGOElemTransform[obj] = tr
        tr:SetParent(self.m_transform)
        tr.localPosition = Unity.Vector3.zero
        table.insert(list, obj)
        self:CacheGlobalEffect(obj)
        obj:SetActive(false)
    end
    self.m_mapPooledObjects[prefab] = list
end

function SymbolObjectPool:CacheGlobalEffect(obj)
    self:ChacheSpineEffect(obj)
    self:ChacheCurveItem(obj)
    self:ChacheGoLight(obj)
    self:CacheMultiClipEffect(obj)

    self:CacheSpineElemSpin0(obj) -- 2018-2-10
    
    -- 2018-3-6 比如CashRespins关卡的LockElemNormal等元素里的gemValue节点的TextProMesh
    self:CacheCustomNode(obj)
    self:CacheSortingGroup(obj)
end

function SymbolObjectPool:CacheSortingGroup(obj)
    local sortGroup = obj:GetComponentInChildren(typeof(Unity.Rendering.SortingGroup))
    if sortGroup ~= nil then
        self.m_mapSortingGroup[obj] = sortGroup 
    end
end

function SymbolObjectPool:CacheCustomNode(obj)
    local strLevelkey = ThemeLoader.themeKey
    if strLevelkey == "CashRespins" then
        CashRespinsFunc:CacheLockElemGemValueInfo(obj)
    elseif strLevelkey == "Phoenix" then
        PhoenixFunc:CachePhoenixCollectElemInfo(obj)
    end
end

function SymbolObjectPool:ResetCacheGlobalEffect(obj)
    local curveItem = self.m_mapCurveItem[obj]
    if curveItem ~= nil then
        curveItem.alpha = 1.0
    end

    local goblurcurveItem = self.m_mapgoblurCurveItem[obj]
    if goblurcurveItem ~= nil then
        goblurcurveItem.alpha = 0
    end

    local curveItemLight = self.m_mapCurveItemGoLight[obj]
    if curveItemLight ~= nil then
        curveItemLight.alpha = 0
    end

    local curveItemDark = self.m_mapCurveItemGoDark[obj]
    if curveItemDark ~= nil then
        curveItemDark.alpha = 0
    end

    --SpineEffect 放到缓存池中，必须重置掉
    local curveSpineItem = self.m_mapCurveSpineItem[obj]
    if curveSpineItem ~= nil then
        curveSpineItem.alpha = 1
    end
    
    local spineEffect = self.m_mapSpinEffect[obj]
    if spineEffect ~= nil then
        spineEffect:Reset()
    end

    local goFrame0 = self.m_mapSpineElemFrame0[obj]
    if goFrame0 ~= nil then
        goFrame0:SetActive(true)
    end
    local goSpineNode = self.m_mapSpineNode[obj]
    if goSpineNode ~= nil then
        goSpineNode:SetActive(false)
    end
end

--缓存所有的节点Child 的层级
function SymbolObjectPool:CacheSortLayer(obj)
    -- for i=0, obj.transform.childCount - 1 do
    --     local tranChild = obj.transform:GetChild(i)

    --     local curveItem = tranChild:GetComponent(typeof(CS.CurveItem))
    --     if curveItem ~= nil then
    --         self.mapGoSymbolSortingOrder[obj][tranChild.gameObject] =  curveItem.sortingOrder
    --     end
        
    --     local curveSpineItem = tranChild:GetComponent(typeof(CS.CurveSpine))
    --     if curveSpineItem ~= nil then
    --         self.mapGoSymbolSortingOrder[obj][tranChild.gameObject] = curveSpineItem.sortingOrder
    --     end
    -- end
end

function SymbolObjectPool:CacheSpineElemSpin0(obj)
    local trFrame0 = obj.transform:FindDeepChild("Frame0")
    if trFrame0 == nil then
        return
    end

    local goFrame0 = trFrame0.gameObject
    self.m_mapSpineElemFrame0[obj] = goFrame0
    goFrame0:SetActive(true)

    local goSpineNode = obj.transform:FindDeepChild("SpineNode").gameObject
    self.m_mapSpineNode[obj] = goSpineNode
    goSpineNode:SetActive(false)
end

--m_mapGoLight
function SymbolObjectPool:ChacheGoLight(obj)
    local curveItemLight = obj.transform:FindDeepChild("goNormal/highlight")
    if curveItemLight ~= nil then
        curveItemLight = curveItemLight:GetComponent(typeof(CS.CurveItem))
    end
    if curveItemLight ~= nil then
        curveItemLight.alpha = 0
        self.m_mapCurveItemGoLight[obj] = curveItemLight
    end

    local curveItemDark = obj.transform:FindDeepChild("goNormal/dark")
    if curveItemDark ~= nil then
        curveItemDark = curveItemDark:GetComponent(typeof(CS.CurveItem))
    end
    if curveItemDark ~= nil then
        curveItemDark.alpha = 0
        self.m_mapCurveItemGoDark[obj] = curveItemDark
    end
end

function SymbolObjectPool:ChacheCurveItem(obj)
    
    obj:SetActive(false)
    -- 把元素隐藏了。。否者会调用start--build--然后就会查找父节点中的group..
    -- 这个时候根本就没有group 元素还没有加到group里去... 
    -- 但是隐藏了会有别的问题吗？还得测试一下。。todo..8-25

    local curveItem = obj.transform:GetComponentInChildren(typeof(CS.CurveItem))
    if curveItem ~= nil then
        curveItem.alpha = 1
        self.m_mapCurveItem[obj] = curveItem
    end

    local curveSpineItem = obj.transform:GetComponentInChildren(typeof(CS.CurveSpine))
    if curveSpineItem ~= nil then
        curveSpineItem.alpha = 1
        self.m_mapCurveSpineItem[obj] = curveSpineItem
    end

    local goblurcurveItem = obj.transform:FindDeepChild("goblur")
    if goblurcurveItem ~= nil  then
        goblurcurveItem = goblurcurveItem:GetComponent(typeof(CS.CurveItem))
        if goblurcurveItem ~= nil then
            goblurcurveItem.alpha = 0
            self.m_mapgoblurCurveItem[obj] = goblurcurveItem
        end
    end
end

function SymbolObjectPool:CacheMultiClipEffect(obj)
    local clipEffect = MultiClipEffectObj:create(obj) 
    if clipEffect ~= nil then
        self.m_mapMultiClipEffect[obj] = clipEffect
    end
end

function SymbolObjectPool:ChacheSpineEffect(obj)
    local spinEffect = SpineEffect:create(obj) -- lua。。。
    if spinEffect ~= nil then
        self.m_mapSpinEffect[obj] = spinEffect
    end
end

function SymbolObjectPool:Spawn(prefab)
    local obj = self:SpawnFunc(prefab, nil, Unity.Vector3.zero, Unity.Quaternion.identity)
    
    local strLevelkey = ThemeLoader.themeKey
    if strLevelkey == "CashRespins" then
        CashRespinsFunc:SpawnElem(obj) -- LockElem 普通模式与respin下 两种情况滚动的元素有差异。。 respin下掉落的元素不带字体
    end

    if strLevelkey == "Phoenix" then
        PhoenixFunc:SpawnElem(obj) -- 凤凰蛋上的数字随着下注的不同而不同 -- 收集后变成半透明。。
    end
        
    if strLevelkey == "GoldenEgypt" then
        GoldenEgyptFunc:SpawnElem(obj) -- 收集后变成半透明。。 取出的时候需要重置..
    end
        
    if strLevelkey == "GiantTreasure" then
        GiantTreasureFunc:SpawnElem(obj) -- 收集后变成半透明。。 取出的时候需要重置..
    end

    if strLevelkey == "BuffaloGold" then
        BuffaloGoldFunc:SpawnElem(obj)
    end
    
    return obj
end

function SymbolObjectPool:SpawnFunc(prefab, parent, position, rotation)
    if prefab == nil then
        return nil
    end

    local tr = nil
    local obj = nil
    local list = self.m_mapPooledObjects[prefab]
    if list ~= nil and #list > 0 then
        obj = list[1]
        table.remove(list, 1)
        assert(obj)
        
        if obj == nil or obj:Equals(nil) then
            Debug.Log("----error!!-----" .. prefab.name)
        end
        tr = obj.transform
        if parent then
            tr:SetParent(parent)
        end
        tr.localPosition = position
        tr.localRotation = rotation
        obj:SetActive(true)
    else
        obj = Unity.Object.Instantiate(prefab)
        tr = obj.transform
        self.m_mapGOElemTransform[obj] = tr
        
        if parent then
            tr:SetParent(parent)
        end
        tr.localPosition = position
        tr.localRotation = rotation

        self:CacheGlobalEffect(obj)
        obj:SetActive(true)

        if list == nil then
            Debug.LogError("-------list == nil ---------: " .. prefab.name)
        else
            local nSpawnCount = 0
            for k, v in pairs(self.m_mapSpawnedObjects) do
                if v == prefab then
                    nSpawnCount = nSpawnCount + 1
                end
            end
          --  Debug.Log("------------新 克隆符号---------------: " .. prefab.name.." | ".. #list.." | ".. nSpawnCount)
        end
    end

    self.m_mapSpawnedObjects[obj] = prefab --不管是克隆的，还是其他，统统加入缓存池
    return obj
end

function SymbolObjectPool:Unspawn(obj)
    local prefab = self.m_mapSpawnedObjects[obj]
    if prefab ~= nil then
        self:UnspawnFunc(obj, prefab)
    else
        if GameConst.PLATFORM_EDITOR then
           Debug.LogError(" ---error!!!---这个obj已经放回缓存了------。。。。。" .. obj.name)
        end
    end
    
end

function SymbolObjectPool:UnspawnFunc(obj, prefab)
    self:ResetCacheGlobalEffect(obj)

    obj.transform:SetParent(self.m_transform)
    obj.transform.localPosition = Unity.Vector3.zero
    obj.transform.localScale = Unity.Vector3.one
    obj:SetActive(false)
    table.insert(self.m_mapPooledObjects[prefab], obj)
    self.m_mapSpawnedObjects[obj] = nil

    if SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GiantTreasure then
        GiantTreasureX1SymbolsPool:UnspawnFunc(obj, prefab) -- 修改父节点 并且build..
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_SantaMania then
        SantaManiaBaseGameSymbolsPool:UnspawnFunc(obj, prefab)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_GoldenVegas then
        GoldenVegasFunc:UnspawnFunc(obj, prefab)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_LuckyClover then
        LuckyCloverFunc:UnspawnFunc(obj, prefab)
    elseif SlotsGameLua.m_enumLevelType == enumThemeType.enumLevelType_AztecAdventure then
        AztecAdventureFunc:UnspawnFunc(obj, prefab)
    end
end

return SymbolObjectPool
