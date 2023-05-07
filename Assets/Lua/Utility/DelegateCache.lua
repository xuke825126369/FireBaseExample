DelegateCache = {}

--这里面缓存的都是C# 引用 Lua里的方法 的这些组件，只要是Lua传递给C#的方法都会存在Dispose报错的问题
function DelegateCache:init()
    self.onClickButtons = {}
    self.onValueChanged = {}
    self.onOtherObject = {}
    self.onOtherKey = {}
end

function DelegateCache:addOnClickButton(button)
    Debug.Assert(button ~= nil, "---error!--DelegateCache:addOnClickButton----")
    if GameConfig.PLATFORM_EDITOR then
        Debug.Assert(button.onClick ~= nil, "---error!--DelegateCache:addOnClickButton key----")
    end
    table.insert(self.onClickButtons, button)
end

function DelegateCache:addOnValueChanged(object)
    Debug.Assert(object ~= nil, "---error!--DelegateCache:addOnValueChanged----")
    if GameConfig.PLATFORM_EDITOR then
        Debug.Assert(object["onValueChanged"] ~= nil, "---error!--DelegateCache:addOnValueChanged key----")
    end
    table.insert(self.onValueChanged, object)
end

function DelegateCache:addOther(object, key)
    Debug.Assert(object ~= nil, "---error!--DelegateCache:addOther----")
    if GameConfig.PLATFORM_EDITOR then
        Debug.Assert(object[key] ~= nil, "---error!--DelegateCache:addOther key----")
    end
    table.insert(self.onOtherObject, object)
    table.insert(self.onOtherKey, key)
end

function DelegateCache:dispose()
    for i, v in ipairs(self.onClickButtons) do
        v.onClick = nil
    end

    for i, v in ipairs(self.onValueChanged) do
        v.onValueChanged = nil
    end
    
    for i, v in ipairs(self.onOtherObject) do
        v[self.onOtherKey[i]] = nil
    end
end

DelegateCache:init()