ThemeReturnRateHelper = {}

function ThemeReturnRateHelper:AutoGetTableFeatureSpinCountRate()
    local tableFeatureSpinCount = {0, 0, 0}
    tableFeatureSpinCount[2] = math.random(10, 90) * 10
    tableFeatureSpinCount[1] = math.random(10, 90) * 10

    local GetReturnRate = function()
        return (tableFeatureSpinCount[1] * 0.5 + tableFeatureSpinCount[2] * 0.95 + tableFeatureSpinCount[3] * 2.0) / (tableFeatureSpinCount[1] + tableFeatureSpinCount[2] + tableFeatureSpinCount[3])
    end
    
    local bFindBest = false
    for i = 0.005, 0.02, 0.005 do
        local nBeginCount = 1
        local nEndCount = tableFeatureSpinCount[1] + tableFeatureSpinCount[2]
        local fMin = (0.95 - i)
        local fMax = (0.95 + i)
        while nBeginCount <= nEndCount do
            local nMiddleCount = (nEndCount + nBeginCount) // 2
            tableFeatureSpinCount[3] = nMiddleCount

            local fReturnRate = GetReturnRate()
            if fReturnRate >= fMin and fReturnRate <= fMax then
                bFindBest = true
                break
            elseif fReturnRate < fMin then
                nBeginCount = nMiddleCount + 1
            elseif fReturnRate > fMax then
                nEndCount = nMiddleCount - 1
            end
        end

        if bFindBest then
            break
        end
    end 

    if bFindBest then
        if Debug.bOpen then
            Debug.LogLuaTable(tableFeatureSpinCount, "返还率组合: "..GetReturnRate())
        end

        return tableFeatureSpinCount
    else
        if Debug.bOpen then
            Debug.Assert(false, "没有计算出合理的返还率组合")
        end
        
        tableFeatureSpinCount = {300, 200, 130}
        return tableFeatureSpinCount
    end
end

function ThemeReturnRateHelper:AutoGetTableFeatureSpinCountRate1()
    local nTargetIndex = math.random(1, 3)
    local tableFeatureSpinCount = {0, 0, 0}
    for i = 1, 3 do
        if i ~= nTargetIndex then
            tableFeatureSpinCount[i] = math.random(10, 90) * 10
        end
    end 
    
    local GetSumCount = function()
        return (tableFeatureSpinCount[1] + tableFeatureSpinCount[2] + tableFeatureSpinCount[3])
    end

    local GetFixedSumCount = function()
        local nCount = 0
        for i = 1, 3 do
            if i ~= nTargetIndex then
                nCount = nCount + tableFeatureSpinCount[i]
            end
        end
        return nCount
    end

    local GetReturnRate = function()
        return (tableFeatureSpinCount[1] * 0.5 + tableFeatureSpinCount[2] * 0.95 + tableFeatureSpinCount[3] * 2.0) / GetSumCount()
    end

    local bFindBest = false
    for i = 0.005, 0.02, 0.005 do
        local fMin = (0.95 - i)
        local fMax = (0.95 + i)

        local nBeginCount = 1
        local nEndCount = GetFixedSumCount() * 100
        while nBeginCount <= nEndCount do
            local nMiddleCount = (nEndCount + nBeginCount) // 2
            tableFeatureSpinCount[nTargetIndex] = nMiddleCount

            local fReturnRate = GetReturnRate()
            if fReturnRate >= fMin and fReturnRate <= fMax then
                bFindBest = true
                break
            else
                if fReturnRate < fMin then
                    nBeginCount = nMiddleCount + 1
                elseif fReturnRate > fMax then
                    nEndCount = nMiddleCount - 1
                end
            end
        end

        if not bFindBest then
            local nBeginCount = 1
            local nEndCount = GetFixedSumCount() * 100
            while nBeginCount <= nEndCount do
                local nMiddleCount = (nEndCount + nBeginCount) // 2
                tableFeatureSpinCount[nTargetIndex] = nMiddleCount

                local fReturnRate = GetReturnRate()
                if fReturnRate >= fMin and fReturnRate <= fMax then
                    bFindBest = true
                    break
                else
                    if fReturnRate < fMin then
                        nEndCount = nMiddleCount - 1
                    elseif fReturnRate > fMax then
                        nBeginCount = nMiddleCount + 1
                    end
                end
            end
        end

        if bFindBest then
            break
        end
    end     

    if bFindBest then
        Debug.LogLuaTable(tableFeatureSpinCount, "返还率组合: "..GetReturnRate())
        return tableFeatureSpinCount
    else
        Debug.Assert(false, "没有计算出合理的返还率组合: ")
        Debug.LogLuaTable(tableFeatureSpinCount, "错误的返还率组合: "..GetReturnRate())

        tableFeatureSpinCount = {300, 200, 130}
        return tableFeatureSpinCount
    end

end