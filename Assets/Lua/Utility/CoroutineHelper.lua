CoroutineHelper = {}

function CoroutineHelper.waitForEndOfFrame(func)
    local co = StartCoroutine(function()
        yield_return(Unity.WaitForEndOfFrame())
        func()
    end)
end
