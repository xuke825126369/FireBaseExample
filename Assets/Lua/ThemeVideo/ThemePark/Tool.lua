--[[
    author:coldflag
    time:2021-08-18 09:31:48
]]
Tool = {}

--[[
    @desc: 对任意表先进行排序，之后将重复的元素删除
    @Warnning：本方法仅对索引是整形的表做单一化
    author:coldflag
    time:2021-08-18 09:52:28
    --@table: in:需要处理的表
    @return: 单一化后的表
]]
function Tool:IntIndexSimplification(targetTable)
    local arrayIndexOfNeedToRemove = {}
    table.sort(targetTable)
    Debug.Assert(#targetTable)
    for i = 1, #targetTable do
        if targetTable[i - 1] == targetTable[i] then
            table.insert(arrayIndexOfNeedToRemove, i) -- 保存需要删除的索引
        end
    end

    for k = 1, #arrayIndexOfNeedToRemove do -- 删除索引对应的元素
        --  越界问题解决了
        table.remove(targetTable, arrayIndexOfNeedToRemove[k] - k) -- 此处要注意targetTable的长度并非一成不变的，每次删除一个元素，表的长度都会减一
    end
end


--[[
    @desc: 判断elem是否在table中
    author:coldflag
    time:2021-08-31 14:20:36
    --@elem: 
	--@table: 
    @return:
]]
function Tool:IsElemInTable(elem, table)
    local bResult
    local bResult = false
    for k, v in pairs(table) do
        if v == elem then
            bResult = true
            break
        end
    end

    return bResult
end


function Tool:ReturnChildDataInTableByID(ID, table)
    if ID ~= nil and table ~= nil then
        for k, v in pairs(table) do
            if k == ID then
                return v
            end
        end
    end

    return nil
end


function Tool:ReturnDataByIteration(key, table)
    if key == nil or table == nil then
        return nil
    end

    for k, v in pairs(table) do
        if k == key then
            return v
        else
            self:ReturnDataByIteration(key, v)
        end
    end
end