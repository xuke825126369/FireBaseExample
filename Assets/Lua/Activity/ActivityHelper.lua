ActivityHelper = {}

function ActivityHelper:GetDeckCenter()
	self.tableV3DeckCenter = self.tableV3DeckCenter or {}
	if self.tableV3DeckCenter[ThemeLoader.themeKey] == nil then
		local TopObj = Unity.GameObject.Find("NewGameNode/LevelInfo/LevelBG/BiaoChi/TOP").gameObject
		local BottomObj = Unity.GameObject.Find("NewGameNode/LevelInfo/LevelBG/BiaoChi/BOTTOM").gameObject
		local RightObj = Unity.GameObject.Find("NewGameNode/LevelInfo/LevelBG/BiaoChi/RIGHT").gameObject
		local LeftObj = Unity.GameObject.Find("NewGameNode/LevelInfo/LevelBG/BiaoChi/LEFT").gameObject
        
		local fCentBoardX = (LeftObj.transform.position.x + RightObj.transform.position.x) / 2.0
		local fCentBoardY = (TopObj.transform.position.y + BottomObj.transform.position.y) / 2.0
        if GameLevelUtil:is3DModelCurvedLevel() or GameLevelUtil:is3DLevel() then
            local cameraZ = Unity.Camera.main.transform.position.z
            local uiZ = ActiveThemeEntry.transform.position.z
            local deckZ = 0
            local ratio = (cameraZ - deckZ)/(uiZ - deckZ)
            local x = fCentBoardX / ratio
            local y = fCentBoardY / ratio
            local z = uiZ   
            self.tableV3DeckCenter[ThemeLoader.themeKey] = Unity.Vector3(x, y, ActiveThemeEntry.transform.position.z)
        else
            self.tableV3DeckCenter[ThemeLoader.themeKey] = Unity.Vector3(fCentBoardX, fCentBoardY, 0)
        end
	end
	return self.tableV3DeckCenter[ThemeLoader.themeKey]
end

function ActivityHelper:GetPrefabFromPool(strKey)
    if not self.prefabPool then
        self.prefabPool = {}
    end

    if not self.prefabPool[strKey] then
        self.prefabPool[strKey] = {}
    end

    --用来分类存放的父物体
    if not self.prefabParent then
        self.prefabParent = {}       
    end
    
    if not self.prefabParent[strKey] then     
		if self.trPrefabPool == nil then
			local go = Unity.GameObject()
			go.transform:SetParent(GlobalScene.popCanvas, false)
			go.transform.localScale = Unity.Vector3.one
			go.transform.localPosition = Unity.Vector3.zero
			go.name = "prefabPool"
			self.trPrefabPool = go.transform
		end

		local obj = Unity.GameObject()
        obj.transform:SetParent(self.trPrefabPool, false)
        obj.transform.localPosition = Unity.Vector3.zero
        obj.name = strKey.."s"
        self.prefabParent[strKey] = obj.transform
    end 

    local UsedObj = table.remove(self.prefabPool[strKey])
    if UsedObj then
        UsedObj.transform:SetParent(self.prefabParent[strKey], false)
        return UsedObj
    else
        local goPrefab = AssetBundleHandler:LoadActivityCommonAsset(strKey)
        if goPrefab == nil then
            Debug.Log("GetHotPrefabFromPool goPrefab == nil  "..strKey)
        end

        local obj = Unity.Object.Instantiate(goPrefab)
        obj.name = strKey
        obj.transform:SetParent(self.prefabParent[strKey], false)
        obj:SetActive(false)
        table.insert(self.prefabPool[strKey], obj)
        return self:GetPrefabFromPool(strKey)
    end

end	

function ActivityHelper:RecyclePrefabToPool(UsedObj)
    if UsedObj == nil then
        return 
    end

    UsedObj:SetActive(false)
    UsedObj.transform:SetParent(self.prefabParent[UsedObj.name], false)
    table.insert(self.prefabPool[UsedObj.name], UsedObj)
end

function ActivityHelper:DestroyPrefabPoolAllObj()
    if LuaHelper.OrGameObjectExist(self.trPrefabPool) then
        Unity.Object.Destroy(self.trPrefabPool.gameObject)
        self.prefabParent = {}
        self.prefabPool = {}
    end
end

--获取组件并存储
function ActivityHelper:GetComponentInChildren(go, type)
	if self.componentPool == nil then
		self.componentPool = {}
	end
    if self.componentPool[go] == nil then
        self.componentPool[go] = {}
    end 
	local type2 = typeof(type)
	local strTypeName = type2.Name
    if self.componentPool[go][strTypeName] == nil then
        self.componentPool[go][strTypeName] = go:GetComponentInChildren(type2) 
    end
    return self.componentPool[go][strTypeName]
end

--查找子节点并存储
function ActivityHelper:FindDeepChild(go, strChildName)
    if self.goChildPool == nil then
        self.goChildPool = {}
    end
    if self.goChildPool[go] == nil then
        self.goChildPool[go] = {}
    end 

	if self.goChildPool[go][strChildName] == nil then
		local trChild = go.transform:FindDeepChild(strChildName)
		if trChild == nil then
			Debug.Log(go.name.." "..strChildName)
		end
        local goChild = trChild.gameObject
		self.goChildPool[go][strChildName] = goChild
		if goChild == nil then
			Debug.Assert(false, string.format("%s %s",go.name, strChildName))
		end
    end 
    return self.goChildPool[go][strChildName]
end

--根据动画名播放Clip动画
function ActivityHelper:PlayAni(goAnimator, strKey, nLayer)
    Debug.Assert(goAnimator)
	Debug.Assert(strKey)
    local animator = self:GetComponentInChildren(goAnimator, Unity.Animator)
    Debug.Assert(animator)
    if animator and goAnimator.activeInHierarchy then
		if nLayer == nil then
			nLayer = 0
		end
        animator:Play(strKey, nLayer, 0)
    end
end  

function ActivityHelper:SetTrigger(goAnimator, strKey)
    Debug.Assert(goAnimator)
    local animator = self:GetComponentInChildren(goAnimator, Unity.Animator)
    Debug.Assert(animator)
    if animator and goAnimator.activeInHierarchy then
        animator:SetTrigger(strKey)
	end
end

--以1美金为参考
function ActivityHelper:getBasePrize()
    local nBasePrize = FormulaHelper:GetAddMoneyBySpendDollar(0.5)
    return nBasePrize
end

function ActivityHelper:getBasePrizeDiamond()
    local nBasePrize = FormulaHelper:GetAddSapphireBySpendDollar(1)
    return nBasePrize
end

ActivityHelper.m_LeanTweenIDs = {}
function ActivityHelper:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

--用这个方法改变值，会刷新对应的UI
function ActivityHelper:AddMsgCountData(key, dv)
    local value = ActiveManager.dataHandler.data[key] + dv
    ActiveManager.dataHandler.data[key] = value
    ActiveManager.dataHandler:SaveDb()
    EventHandler:Brocast("onActiveMsgCountChanged")
end

function ActivityHelper:AddMsgCountDataBySku(sku)
    local active = ActiveManager.activeType
    local nAction = _G[active.."IAPConfig"].skuMapOther[sku]
    ActivityHelper:AddMsgCountData("nAction", nAction)
end

function ActivityHelper:GetAddMsgCountBySku(sku)
    local active = ActiveManager.activeType
    local nAction = _G[active.."IAPConfig"].skuMapOther[sku]
    return nAction
end

function ActivityHelper:FormatTime(nTime)
    local days = nTime // (3600*24)
    local hours = nTime // 3600 - 24 * days
    local minutes = nTime // 60 - 60 * hours
    local seconds = nTime % 60

    if days > 0 then
        local strTimeInfo = math.floor(days+1) .. " day"
        if days > 1 then
            strTimeInfo = strTimeInfo .. "s"
        end

        return strTimeInfo
    end

    local strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    return strTimeInfo
end

function ActivityHelper:isTriggerProgress(enumActiveType)
    local probs = {15, 1}
    local nRandomIndex = LuaHelper.GetIndexByRate(probs)
    if nRandomIndex == 1 then
        return false
    end
    return true
end

function ActivityHelper:getProgressFullAddCount(enumActiveType)
    local nAddCount = math.random(1, 3)
    return nAddCount
end

function ActivityHelper:getAddSpinProgressValue(data)
    local nBaseTB = self:getBasePrize()
    local fcoef = data.nTotalBet / nBaseTB
    fcoef = LuaHelper.Clamp(fcoef, 0, 0.02)
    return fcoef
end

function ActivityHelper:getAddSpinProgressBarValue(data)
    local fCoef = data.nTotalBet / self:getBasePrize()
    local fValue = LuaHelper.Clamp(fCoef, 0.0, 1.0)
    return fValue
end
