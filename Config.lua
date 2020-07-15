----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
	
	--if Kiminfo == nil then Kiminfo = {} end
	
local C, F, G, L = unpack(ns)

local MediaFolder = "Interface\\AddOns\\oUF_Ruri\\Media\\"

------------
-- Golbal --
------------
	
	G.Tex = "Interface\Buttons\WHITE8X8"
	G.Glow = MediaFolder.."glow.tga"

	C.Font = STANDARD_TEXT_FONT
	C.FontSize = 18
	C.FontFlag = "OUTLINE"
	
	C.MaxLine = 1024
	C.Flash = false
	C.Copy = false
	C.Invite = false
	
	C.InviteKey = {
		"111",
		"+++",
		"inv",
		}
		
	C.GuildInviteKey = {
		"g++",
		"ginv",
		"加公會",
		"加公会",
		}
F.CreateBG = function(parent, size, offset, a)
	local frame = parent
	if parent:GetObjectType() == "Texture" then
		frame = parent:GetParent()
	end
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:ClearAllPoints()
	bg:SetPoint("TOPLEFT", parent, -size, size)
	bg:SetPoint("BOTTOMRIGHT", parent, size, -size)
	bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	bg:SetBackdrop({
			bgFile = G.Tex,
			tile = false,
			edgeFile = G.Glow,	-- 陰影邊框
			edgeSize = offset,	-- 邊框大小
			insets = { left = offset, right = offset, top = offset, bottom = offset },
		})
	bg:SetBackdropColor(0, 0, 0, a)
	bg:SetBackdropBorderColor(0, 0, 0, 1)
	
	return bg
end

F.Dummy = function() end

-------------
-- Credits --
-------------
--[[
	credit:
	neavo的sora's ui - https://git.oschina.net/Neavo/sora
	zork rchat
	NeavUI nchat
	MonoUI m_chat
	https://tw.piliapp.com/symbol/
	https://www.wowinterface.com/forums/showthread.php?t=52673
]]--
