SweetBlastBaseGameSymbolsPool = {} -- 单棋盘的情况 。。。 元素放回缓存就检查一下group。。

SweetBlastBaseGameSymbolsPool.m_trSymbolsPool = nil -- "SymbolsPoolBaseGame"
-- 这一关特殊 只要是调用 SymbolObjectPool:UnspawnFunc 就把元素放到 "SymbolsPoolBaseGame" 目录

function SweetBlastBaseGameSymbolsPool:initSymbolPool() -- BaseGame 使用
    -- 进关卡 不是短线重连要直接进FreeSpin的情况就调用
    -- 放一堆元素来 self.m_trSymbolsPool 下
    -- 2020-10-27 暂时不用了...
end
