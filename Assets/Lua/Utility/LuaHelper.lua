LuaHelper = {}

function LuaHelper.OrDbJsonStr(str)
    return string.find(str, "{") ~= nil and string.find(str, "}") ~= nil
end

function LuaHelper.IsNullOrWhiteSpace(str)
    if str == nil then
        return true
    end
    
    for i = 1, #str do
        if str[i] ~= "" then
            return false
        end
    end

    return true
end

function LuaHelper.OrGameObjectExist(gameObject)
    return gameObject and not gameObject:Equals(nil)
end

-- 这个方法治标不治本，本地数据库一旦建立，只能采取增加字段的方式
-- 开发环境很好用哦
function LuaHelper.FixSimpleDbError(dbData, dbInitData)
    Debug.Assert(dbData, "dbData == nil")   
    Debug.Assert(dbInitData, "dbInitData == nil")
    
    for k, v in pairs(dbInitData) do
        if type(dbData[k]) ~= type(dbInitData[k]) then
            dbData[k] = dbInitData[k]
        end
    end

    for k, v in pairs(LuaHelper.DeepCloneTable(dbData)) do
        if type(dbData[k]) ~= type(dbInitData[k]) then
            dbData[k] = dbInitData[k]
        end
    end
    
end

function LuaHelper.removeElementFromTable(array, element)
    local index = LuaHelper.indexOfTable(array, element)
    if index and index >= 1 then
        table.remove(array, index)
    end
end

function LuaHelper.tableContainsElement(array, element)
    for index, value in pairs(array) do
        if value == element then
            return true, index
        end
    end
        
    return false
end

function LuaHelper.indexOfTable(array, element)
    for index, value in ipairs(array) do
        if value == element then
            return index
        end
    end
    
    return -1
end

function LuaHelper.tableSize(t)
	local size = 0
    for index in pairs(t) do
        size = size + 1
    end
    return size
end

function LuaHelper.CopyTo(sourceTable, offset1, desTable, offset2, count)
	for i = 0, count - 1 do
        desTable[offset2 + i] = sourceTable[offset1 + i]
    end
end

function LuaHelper.GetTableString(t)
	return serpent.block(t)
end

-- 简单的 深克隆 table
function LuaHelper.DeepCloneTable(cpTable)
    LuaHelper.CheckOrSupportDeepCloneTable(cpTable)

    local newTable = {}
    for k, v in pairs(cpTable) do
        if type(v) == "table" then
            LuaHelper.DeepCloneChildTable(newTable, k, v)
        else
            newTable[k] = v
        end
    end 

    return newTable
end

function LuaHelper.CheckOrSupportDeepCloneTable(cpTable)
    local typeTable = { "number", "string", "boolean", "table"} 
    for k, v in pairs(cpTable) do
        if not LuaHelper.tableContainsElement(typeTable, type(v)) then
            Debug.LogError("此 Table 不支持 深拷贝: "..type(v))
            break
        end
    end
end

function LuaHelper.DeepCloneChildTable(parentTable, strKey, cpTable)
    LuaHelper.CheckOrSupportDeepCloneTable(cpTable)

    parentTable[strKey] = {}
    local newTable = parentTable[strKey]
    for k, v in pairs(cpTable) do
        if type(v) == "table" then
            LuaHelper.DeepCloneChildTable(newTable, k, v)
        else
            newTable[k] = v
        end
    end

end

function LuaHelper.GetIndexByRate(tableRate)
    local nSumRate = 0
    for k, v in pairs(tableRate) do
        nSumRate = nSumRate + v
    end
    
    local nTempTargetRate = nSumRate + 1
    if nSumRate >= 1 then
        nTempTargetRate = math.random(1, nSumRate)
    end

    local nTempRate = 0
    local nTargetIndex = -1
    for i=1, #tableRate do
        nTempRate = nTempRate + tableRate[i]
        if nTempRate >= nTempTargetRate then
            nTargetIndex = i
            break
        end
    end

    return nTargetIndex
end

--非数组的table
function LuaHelper.GetIndexByRate2(tableRate)
    local tableKey = {}
    local tableValue = {}
    for k, v in pairs(tableRate) do
        table.insert(tableKey, k)
        table.insert(tableValue, v)
    end
    local nIndex = LuaHelper.GetIndexByRate(tableValue)
    return tableKey[nIndex]
end

function LuaHelper.StringSplit(oriStr, patternStr)
    local result = {}
    local nSearchIndex =  1
    local startIndex, endIndex = 1, 1
    while endIndex < #oriStr do
        startIndex, endIndex = string.find(oriStr, patternStr, nSearchIndex, true)
        if startIndex then
            table.insert(result, string.sub(oriStr, nSearchIndex, startIndex - 1))
            nSearchIndex = endIndex + 1
        else
            table.insert(result, string.sub(oriStr, nSearchIndex, #oriStr))
            break
        end
    end
    return result
end

function LuaHelper.ReleaseVariable(target)
    local tableNeedRemove = {}
    local nFunctionCount = 0
    for k, v in pairs(target) do
        if type(v) ~= "function" then
            table.insert(tableNeedRemove, k)
        else
            nFunctionCount = nFunctionCount + 1
        end
    end
        
    for k, v in pairs(tableNeedRemove) do
        target[v] = nil
    end
end

function LuaHelper.CancelLeanTween(m_LeanTweenIDs)
	local count = #m_LeanTweenIDs
	for i=1, count do
		local id = m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
end

function LuaHelper.GetComponentsInChildren(go, CType)
    local childList = {}
    
    local arrayList = go:GetComponentsInChildren(CType, true)
    if arrayList then
        for i = 0, arrayList.Length - 1 do
            table.insert(childList, arrayList[i])
        end
    end

    return childList
end

function LuaHelper.GetCSharpListTable(CSharpArray)
    local tempTable = {}
    for i = 0, CSharpArray.Length - 1 do
        table.insert(tempTable, CSharpArray[i])
    end
    return tempTable
end

function LuaHelper.GetCSharpDicTable(CSharpDic)
    local tempTable = {}
    for k, v in pairs(CSharpDic) do
        tempTable[k] = v
    end
    return tempTable
end

function LuaHelper.FloatEqual(A, B)
    return Unity.Mathf.Approximately(A, B)
end

-- 屏幕位置是否在 照相机 视椎体 内
function LuaHelper.orScreenPositionOutOfViewFrustumd(mousePosition)
    if not mousePosition then
        mousePosition = Input.mousePosition;
    end

    if mousePosition.x < 0 or mousePosition.x >= Unity.Screen.width or mousePosition.y < 0 or mousePosition.y >= Unity.Screen.height then
        return true
    end
        
    return false
end

function LuaHelper.removeElementFromArray(array, element)
    local index = LuaHelper.indexOfTable(array, element)
    if index and index > 0 then
        table.remove(array, index)
    end
end

function LuaHelper.GetRandomTable(oldTable)
    local newTable = {}

    local tableIndex = {}
    for i = 1, #oldTable do
        table.insert(tableIndex, i)
    end
            
    while #tableIndex > 0 do
        local nIndex = table.remove(tableIndex, math.random(1, #tableIndex))
        local value = oldTable[nIndex]
        table.insert(newTable, value)
    end

    return newTable
end

function LuaHelper.GetKeyValueSwitchTable(oldTable)
    local newTable = {}
    for k, v in pairs(oldTable) do
        newTable[v] = k
    end
    return newTable
end

function LuaHelper.Clamp(value, min, max)
    if value < min then
        value = min
    elseif value > max then
        value = max
    end
    return value
end

function LuaHelper.GetInteger(value)
    local t1 = math.modf(value)
    return t1
end

function LuaHelper.GetRate01ByRateTable(tableRate, nIndex)
    local nSumRate = 0
    for i = 1, #tableRate do
        nSumRate = nSumRate + tableRate[i]
    end
    
    return tableRate[nIndex] / nSumRate
end
