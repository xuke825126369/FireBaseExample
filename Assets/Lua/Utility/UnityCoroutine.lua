cs_coroutine = (require 'cs_coroutine')
yield_return = coroutine.yield

function StartCoroutine(fun)
    return cs_coroutine.start(fun)
end

function StopCoroutine(mCo)
	cs_coroutine.stop(mCo)
end




