LuaUtil = {}

function LuaUtil.indexForArray(array, element)
    for index, value in pairs(array) do
        if value == element then
            return index
        end
    end
    return nil
end

function LuaUtil.arrayContainsElement(array, element)
    if array == nil then
        return false
    end

    if LuaUtil.arraySize(array) == 0 then
        return false
    end
    
    for index, value in pairs(array) do
        if value == element then
            return true
        end
    end
    return false
end

function LuaUtil.removeElementFromArray(array, element)
    local index = LuaUtil.indexForArray(array, element)
    if(index) then
        table.remove(array, index)
    end
end

function LuaUtil.removeElementByKey(tbl,element)
    local newTbl = {}
    for k,v in pairs(tbl) do
        if v ~= element then
            newTbl[k] = v
        end
    end
    tbl = nil
    return newTbl
end

function LuaUtil.arraySize(array)
	local size = 0
    for index in pairs(array) do
        size = size + 1
    end
    return size
end

function LuaUtil.tableSize(t)
	local size = 0
    for index in pairs(t) do
        size = size + 1
    end
    return size
end

function LuaUtil.RandSort(t)
    table.sort(t, function(a, b)
      return math.random(1, 10) < 5
    end)

    return t
end

function LuaUtil.shuffle(oldTable)
    local newTable = {}
    for i=1, #oldTable do
        local cnt = #newTable
        if cnt == 0 then
            newTable[1] = oldTable[1]
        else
            table.insert(newTable, math.random(#newTable), oldTable[i])
        end
    end

    return newTable
end

-- nCoins: 123456000 digitNum: 6 转为类似这样: 123,456K
-- nCoins: 123456000 digitNum: 5 转为类似这样: 123M
-- nCoins: 123456000 digitNum: 9 转为类似这样: 123,456,000
function LuaUtil.formatCoins(nCoins, digitNum)
    -- nCoins 金币总数
    -- digitNum 最多留几位数字
    local result = nCoins
    local index = 0
    while ( (result >= 10^digitNum) or (index%3 ~= 0) ) do
        result = result / 10
        index = index + 1
        if index == 12 then
            break
        end
    end

    -- index 是3的整数倍
    local str = LuaUtil.numWithCommas(result)
    if index == 0 then
        return str
    end
    -- 
    local cnt = math.floor(index / 3)
    local temp = {"K", "M", "B", "T"}
    local str = str .. temp[cnt]
    return str
end

-- 从高位往低位保留最多digitNum个非零数字
function LuaUtil.normalizeCoinCount(count, digitNum)
    digitNum = digitNum or 3
    local result = count
    local index = 0
    while(result >= 10^digitNum) do
        result = result / 10
        index = index + 1
    end
    result = math.floor(result)
    result = result * (10^index)
    return result
end

-- 四舍五入保留小数点后n位
function LuaUtil.keepNDecimalPlaces(decimal, n)
    local nBase = 1
    local fCoef = 1.0
    for i = 1, n do
        nBase = nBase * 10
        fCoef = fCoef / 10.0
    end
    local decimal = math.floor((decimal * nBase) + 0.5) * fCoef

    return decimal
end

--==============================--
--@return string 
--e.g: 123000 -> 123K
--==============================---
function LuaUtil.coinCountOmit(count)
    count = LuaUtil.normalizeCoinCount(count, 3) -- 从高位开始保留3位非零数字

   -- quadrillion -- 千万亿
    local trillion = 1000 * 1000 * 1000 * 1000 -- 万亿
    local billion = 1000 * 1000 * 1000
    local million = 1000 * 1000
    local thousand = 1000
    if count >= trillion then
        if(count % trillion == 0) then
            return string.format( "%dT", count / trillion)
        else
            return (count / trillion).."T"
        end
    elseif count >= billion then
        if(count % billion == 0) then
            return string.format( "%dB", count / billion)
        else
            return (count / billion).."B"
        end
    elseif count >= million then
        if(count % million == 0) then
            return string.format( "%dM", count / million)
        else
            return (count / million).."M"
        end
    elseif count >= thousand then
        if(count % thousand == 0) then
            return string.format( "%dK", count / thousand)
        else
            return (count / thousand).."K"
        end
    else 
        return string.format( "%d", count)
    end
end

--==============================--
--desc:Format number return string with commas
--e.g: 28999333 -> 28,999,333
--==============================----
function LuaUtil.numWithCommas(n)
  return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end

local timeZoneOffset = os.difftime(os.time(), os.time(os.date("!*t", os.time())))
--[[
    @desc: 
    author:{author}
    time:2021-05-18 19:10:47
    --@utcDate: 
    @return:以后网络时间效验用parseNetUtcDate
]]
function LuaUtil.parseUtcDate(utcDate)
    -- local datetime = "2011-10-25 00:29:55"
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)"
    local Y, M, D, h, m, s = utcDate:match(pattern)
    local second = os.time({year = Y, month = M, day = D, hour = h, min = m, sec = s}) + timeZoneOffset
    -- local tab = os.date("*t", second);
    -- print(tab.year, tab.month, tab.day, tab.hour, tab.min, tab.sec)
    return second
end

function LuaUtil.parseNetUtcDate(utcDate)
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)"
    local Y, M, D, h, m, s = utcDate:match(pattern)
    local second = os.time({year = Y, month = M, day = D, hour = h, min = m, sec = s})
    return second
end

function LuaUtil.timeToDaySecond(timeSecond)
    local timeTable = os.date("*t", timeSecond)
	local daySecond = os.time({year = timeTable.year, month = timeTable.month, day = timeTable.day, hour = 0, sec = 0})
    return daySecond
end

function LuaUtil.parseSecond(timeSecond)
    local days = timeSecond // (3600*24)
    local hours = timeSecond // 3600 - 24 * days
    local minutes = timeSecond // 60 - 60 * hours
    local seconds = timeSecond % 60
    return days, hours, minutes, seconds
end

function LuaUtil.formatSecond(timeSecond)
    local days, hours, minutes, seconds = LuaUtil.parseSecond(timeSecond)
    local strTimeInfo
    if days > 0 then
        if days == 1 then
            strTimeInfo = string.format("Time Left %d day!",days)
        else
            strTimeInfo = string.format("Time Left %d days!",days)
        end
    else
        strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end
    return strTimeInfo
end

function LuaUtil.secondToUtcDate(second)
    local pattern = "%Y-%m-%dT%H:%M:%S+0000"
    return os.date(pattern,second)
end

function LuaUtil.waitForEndOfFrame(func)
    local yield_return = (require 'cs_coroutine').yield_return
    local co = coroutine.create(function()
        yield_return(Unity.WaitForEndOfFrame())
        func()
    end)
    assert(coroutine.resume(co))
end

function LuaUtil.StringSplit(oriStr, patternStr)
    local result = {}
    local nSearchIndex =  1
    local startIndex, endIndex = 1, 1
    while endIndex < #oriStr do
        startIndex, endIndex = string.find(oriStr, patternStr, nSearchIndex)
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

function LuaUtil.GetComponentsInChildren(go, CType)
    local childList = {}
    
    local arrayList = go:GetComponentsInChildren(CType, true)
    for i = 0, arrayList.Length - 1 do
        table.insert(childList, arrayList[i])
    end

    return childList
end

function LuaUtil.GetRandomTable(oldTable)
    local newTable = {}
    while #oldTable > 0 do
        local value = table.remove(oldTable, math.random(1, #oldTable))
        table.insert(newTable, value)
    end
    
    return newTable
end

function LuaUtil.GetIndexByRate(tableRate)
    local nSumRate = 0
    for k, v in pairs(tableRate) do
        nSumRate = nSumRate + v
    end
    
    nSumRate = math.floor(nSumRate)
    
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
function LuaUtil.GetIndexByRate2(tableRate)
    local tableKey = {}
    local tableValue = {}
    for k, v in pairs(tableRate) do
        table.insert(tableKey, k)
        table.insert(tableValue, v)
    end
    local nIndex = LuaUtil.GetIndexByRate(tableValue)
    return tableKey[nIndex]
end

--从数组中随机挑选n个数 输入{5, 8, 0, 9} 2 有概率输出 {9, 0}
function LuaUtil.PickFromArray(array, n) 
    Debug.Assert(n >= 0)  
    if #array == 0 then
        return array
    end
    local nTotalNum = #array

    if n >= nTotalNum then
        n = nTotalNum
    end

    local tempArray = LuaUtil.DeepCloneTable(array)

    for i = 1, nTotalNum - n do
        table.remove(tempArray, math.random(1, #tempArray))
    end

    return tempArray
end

function LuaUtil.PickByWeight(tableNWeight, nPickNum)
    tableNWeight = LuaUtil.DeepCloneTable(tableNWeight)
    local tableNIndex = {}
    for i = 1, #tableNWeight do
        tableNIndex[i] = i
    end
    
    local temp = {}
    for i = 1, nPickNum do
        local nIndex = LuaUtil.GetIndexByRate(tableNWeight)
        if nIndex == -1 then
            break
        end
        table.insert(temp, tableNIndex[nIndex])
        table.remove(tableNWeight, nIndex)
        table.remove(tableNIndex, nIndex)
    end
    return temp
end

-- 屏幕位置是否在 照相机 视椎体 内
function LuaUtil:orScreenPositionOutOfViewFrustumd(mousePosition)
    if not mousePosition then
        mousePosition = Input.mousePosition;
    end

    if mousePosition.x < 0 or mousePosition.x >= Unity.Screen.width or mousePosition.y < 0 or mousePosition.y >= Unity.Screen.height then
        return true
    end
    
    return false
end

-- 简单的 深克隆 table
function LuaUtil.DeepCloneTable(cpTable)
    LuaUtil.CheckOrSupportDeepCloneTable(cpTable)

    local newTable = {}
    for k, v in pairs(cpTable) do
        if type(v) == "table" then
            LuaUtil.DeepCloneChildTable(newTable, k, v)
        else
            newTable[k] = v
        end
    end 
    
    return newTable
end

function LuaUtil.CheckOrSupportDeepCloneTable(cpTable)
    local typeTable = { "number", "string", "boolean", "table"} 
    for k, v in pairs(cpTable) do
        if not LuaUtil.arrayContainsElement(typeTable, type(v)) then
            Debug.LogError("此 Table 不支持 深拷贝: "..type(v))
            break
        end
    end
end

function LuaUtil.DeepCloneChildTable(parentTable, strKey, cpTable)
    LuaUtil.CheckOrSupportDeepCloneTable(cpTable)

    parentTable[strKey] = {}
    local newTable = parentTable[strKey]
    for k, v in pairs(cpTable) do
        if type(v) == "table" then
            LuaUtil.DeepCloneChildTable(newTable, k, v)
        else
            newTable[k] = v
        end
    end

end

function LuaUtil.FloatEqual(A, B)
    return Unity.Mathf.Approximately(A, B)
end

function LuaUtil.SupportsTextureFormat()
    return Unity.SystemInfo.SupportsTextureFormat(Unity.TextureFormat.ASTC_RGBA_4x4)
end

--table里有多少个指定元素
function LuaUtil.GetEqualElementCount(table, element)
    local nCount = 0
    for k, v in pairs(table) do
        if v == element then
            nCount = nCount + 1
        end
    end
    return nCount
end

--table指定元素的Key
function LuaUtil.GetEqualElementKey(_table, element)
    local tableKey = {}
    for k, v in pairs(_table) do
        if v == element then
            table.insert(tableKey, k)
        end
    end
    return tableKey
end

--数组所有数字之和
function LuaUtil.GetSum(table)
    local nCount = 0
    for k, v in pairs(table) do
        nCount = nCount + v
    end
    return nCount
end

--输入 5， 1， 4 输出 4
function LuaUtil.Clamp(value, min, max)
    if value < min then
        value = min
    elseif max and value > max then
        value = max
    end
    return value
end

--输入 5， 1， 4 输出 1 
--输入 3， 5， 10 输出 9
function LuaUtil.Loop(nValue, nMin, nMax)
    if nValue >= nMin and nValue <= nMax then
        return nValue
    end
    local nLength = nMax - nMin + 1
    nValue = nValue - nMin
    nValue = nValue % nLength
    nValue = nValue + nMin
    return nValue
end

function LuaUtil.GetFloorIndex(tableN, n)
    local nCount = #tableN
    if n >= tableN[nCount] then
        return nCount
    else
        local nIndex
        for i = 1, nCount do
            if n > tableN[i] then
                nIndex = i
            else
                break
            end
        end
        return nIndex
    end
end

function LuaUtil.ReleaseVariable(targetTable)
    local tableNeedRemove = {}
    local nFunctionCount = 0
    for k, v in pairs(targetTable) do
        if type(v) ~= "function" then
            table.insert(tableNeedRemove, k)
        else
            nFunctionCount = nFunctionCount + 1
        end
    end

    for k, v in pairs(tableNeedRemove) do
        targetTable[v] = nil
    end

    for k, v in pairs(targetTable) do
        if type(v) ~= "function" then
            Debug.Assert(false, "Not Full Clear variable")
        end
    end
end

--获取一个带初始值的Table, 输入 1， 3 输出{1, 1, 1}  输入 1， 2， 2 输出 {{1, 1}, {1, 1}}
function LuaUtil.GetTable(defaultValue, i, j)
    local table = {}
    if j == nil then
        for x = 1, i do
            table[x] = defaultValue
        end
    else
        for x = 1, i do
            table[x] = {}
            for y = 1, j do
                table[x][y] = defaultValue
            end
        end
    end
    return table
end

function LuaUtil.SetTable(table, defaultValue)
    for k,v in pairs(table) do
        table[k] = defaultValue
    end
end

--Table下标整体左移或右移，默认把下标从1的Table开始变成下标从0开始
function LuaUtil.ShiftIndex(tableOld, nOffset)
    if nOffset == nil then
        nOffset = -1
    end
    local tableNew = {}
    for k, v in pairs(tableOld) do
        tableNew[k + nOffset] = v
    end
    return tableNew
end

--键值对反转
function LuaUtil.ReverseTable(table)
    local newTable = {}
    for k, v in pairs(table) do
        newTable[v] = k
    end
    return newTable
end

function LuaUtil.GetTableFindChild(parentTransform, nLength, strName, type, bStartFromZero)
    Debug.Assert(parentTransform)
    Debug.Assert(nLength)
    local table = {}
    if strName == nil then
        strName = ""
    end
    if bStartFromZero then
        parentTransform = parentTransform:FindDeepChild(strName.."0").parent
        if type == nil then
            for i = 0, nLength - 1 do
                table[i] = parentTransform:Find(strName..i).gameObject
            end
        else
            for i = 0, nLength - 1 do
                local tr = parentTransform:Find(strName..i)
                if tr == nil then
                    Debug.Log("i "..i.." strName "..strName)
                end
                table[i] = tr:GetComponentInChildren(typeof(type))
            end
        end
    else
        parentTransform = parentTransform:FindDeepChild(strName.."1").parent
        if type == nil then
            for i = 1, nLength do
                table[i] = parentTransform:Find(strName..i).gameObject
            end
        else
            for i = 1, nLength do
                local tr = parentTransform:Find(strName..i)
                if tr == nil then
                    Debug.Log("i "..i.." strName "..strName)
                end
                table[i] = tr:GetComponentInChildren(typeof(type))
            end
        end
    end
    return table
end