local CannonTime = {}

function CannonTime:new(goCannon)
    local o = {}
	setmetatable(o, self)
	self.__index = self
    o:init(goCannon)
    return o
end

function CannonTime:init(goCannon)
    self.transform.gameObject = ActivityBundleHandler:GetAnimationObject("CannonTime", BoardQuestMainUIPop.trItemParent)
    self.transform.gameObject:SetActive(true)
    self.transform = self.transform.gameObject.transform
    self.transform.position = goCannon.transform.position + Unity.Vector3(0, -38, 0)
    self.transform.localScale = Unity.Vector3.one
    self.textTime = self.transform.gameObject:GetComponentInChildren(typeof(TextMeshProUGUI))
end

function CannonTime:set()

end

return CannonTime
