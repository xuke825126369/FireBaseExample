--
-- strict.lua
-- checks uses of undeclared global variables
-- All global variables must be 'declared' through a regular assignment
-- (even assigning nil will do) in a main chunk before being used
-- anywhere or assigned to inside a function.
--

-- 此Lua 可以避免 在Lua 函数中 赋值/调用 未声明的 全局变量 _G

local mt = getmetatable(_G)
if mt == nil then
  mt = {}
  setmetatable(_G, mt)
end

__STRICT = true
mt.__declared = {}

mt.__newindex = function (t, n, v)
  if __STRICT and not mt.__declared[n] then
    local w = debug.getinfo(2, "S").what
    if w ~= "main" and w ~= "C" then
      error("assign to undeclared global variable '"..n.."'", 2)
    end
    mt.__declared[n] = true
  end
  rawset(t, n, v)
end

mt.__index = function (t, n)
  if __STRICT and not mt.__declared[n] then
    local w = debug.getinfo(2, "S").what
    if w ~= "main" and w ~= "C" then
        error("undeclared global variable '"..n.."'", 2)
    end
  end

  return rawget(t, n)
end

--mt.__index = function (t, n)
   --if not mt.__declared[n] then
--     local w = debug.getinfo(2, "S").what
--     if w ~= "main" and w ~= "C" then
--         error("variable '"..n.."' is not declared", 2)
--     end
--   end
--   return rawget(t, n)
-- end

function global(...)
   for _, v in ipairs{...} do mt.__declared[v] = true end
end