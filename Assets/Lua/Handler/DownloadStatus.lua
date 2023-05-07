DownloadStatus =  
{
	NotStart = 1,
	Downloading = 2,
	Downloaded = 3
}

BundleInfo = 
{
	mBundleConfigItem = nil,
    downloadStatus = DownloadStatus.NotStart,
    downloadingProgress = 0,
}

function BundleInfo:New()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end
