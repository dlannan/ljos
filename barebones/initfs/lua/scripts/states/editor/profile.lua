-- Profile.lua
--  by David Lannan
--  copyright 2012
--
--  Profile.lua provides the API for users to log in using a number of internet based profile systems.
--  Supported:
--		Twitter, Facebook, OpenID, GoogleID (same as OpenID), MSN / Hotmail, ICQ
-- 		Profile information can be shared. 
-- 		Each profile must provide a content window where data must be entered 

local profileData = 
{
	projectInfo = 
	{
		name 		= "Default",
		thumbnail 	= "",
		datafolders = {
			"byt3d/data"
		}
	},
	
	projectConfig = 
	{
		windows7	= {
		},
		osx			= {
		},
		ios			= {
		},
		android		= {
		},
		blackberry	= {
		},
		linux		= {
		}
	}
}


return profileData