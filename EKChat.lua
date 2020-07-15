local addon, ns = ...
local C, F, G, L = unpack(ns)
--[[
local CHAT_TAB_SHOW_DELAY, CHAT_TAB_HIDE_DELAY = CHAT_TAB_SHOW_DELAY, CHAT_TAB_HIDE_DELAY
local CHAT_FRAME_FADE_TIME, CHAT_FRAME_FADE_OUT_TIME = CHAT_FRAME_FADE_TIME, CHAT_FRAME_FADE_OUT_TIME
local CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA
local CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA
local CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA
]]--

local _G = _G
local gsub, strfind = string.gsub, string.find
local BNToastFrame = BNToastFrame
local maxWidth, maxHeight = UIParent:GetWidth(), UIParent:GetHeight()
--local newAddMsg = {}

local function AddMessage(frame, text, ...)
	-- mult color on self whisper text
	local r, g, b = ...
	if strfind(text, L.To.."|H[BN]*player.+%]") then
		r, g, b = r*.7, g*.7, b*.7
	end
	
	text = gsub(text, "(|HBNplayer.-|h)%[(.-)%]|h", "%1%2|h")	-- 戰網名字去引號
	text = gsub(text, "(|Hplayer.-|h)%[(.-)%]|h", "%1%2|h")		-- 角色名字去引號
	text = gsub(text, "%[(%d0?)%. (.-)%]", "[%1]")
	
	return frame.oldAddMsg(frame, text, r, g, b)
end

local function settings()
	-- Short name
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then	-- 跳過戰鬥紀錄
			--local frame = _G[format("%s%d", "ChatFrame", i)]
			local frame =_G["ChatFrame"..i]
			frame.oldAddMsg = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	end
	-- Font size list
	for i = 1, 15 do
		CHAT_FONT_HEIGHTS[i] = i + 9
	end
	-- CVAR
	SetCVar("chatStyle", "classic")
	SetCVar("showTimestamps", "|cff64C2F5%H:%M:%S|r ")
	SetCVar("whisperMode", "inline")
	-- Hide button
	ChatFrameMenuButton.Show = F.Dummy
	ChatFrameMenuButton:Hide()
	ChatFrameChannelButton.Show = F.Dummy
	ChatFrameChannelButton:Hide()
	QuickJoinToastButton.Show = F.Dummy
	QuickJoinToastButton:Hide()
	-- Toast
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetClampRectInsets(-15, 15, 15, -15)
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 0, C.FontSize*2)
	end)
	-- 頻道保持
	ChatTypeInfo["SAY"].sticky = 1				-- 說
	ChatTypeInfo["PARTY"].sticky = 1			-- 小隊
	ChatTypeInfo["GUILD"].sticky = 1			-- 公會
	ChatTypeInfo["WHISPER"].sticky = 0			-- 密語
	ChatTypeInfo["BN_WHISPER"].sticky = 0		-- 戰網密語
	ChatTypeInfo["RAID"].sticky = 1				-- 團隊
	ChatTypeInfo["OFFICER"].sticky = 1			-- 幹部
	ChatTypeInfo["CHANNEL"].sticky = 1			-- 頻道
	ChatTypeInfo["INSTANCE_CHAT"].sticky = 1	-- 副本
	ChatTypeInfo["YELL"].sticky = 0				-- 喊
	-- 不要閃光
	ChatTypeInfo["BN_INLINE_TOAST_ALERT"].flashTab = false
	ChatTypeInfo["BN_INLINE_TOAST_BROADCAST"].flashTab = false
	ChatTypeInfo["BN_INLINE_TOAST_BROADCAST_INFORM"].flashTab = false
	-- 訊息過濾
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", function(msg) return true end)		-- 進入頻道
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", function(msg) return true end)		-- 離開頻道
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", function(msg) return true end)		-- 頻道通知
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function(msg) return true end)					-- 暫離
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function(msg) return true end)				-- 忙碌
end

local function styleChat(self)
	-- Make sure it only run once
	if not self or (self and self.styled) then return end
	
	--[[ Chat frame ]]--
	
	-- Get frame name
	local name = self:GetName()

	-- Hide textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[name..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end
	
	-- Fade out
	self:SetFading(true)
	self:SetFadeDuration(2)
	self:SetTimeVisible(10)
	-- Size
	self:SetClampedToScreen(false)
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetMinResize(128, 64)
	self:SetMaxResize(maxWidth, maxHeight)
	-- Font
	self:SetFont(C.Font, C.FontSize, C.FontFlag)
	self:SetShadowOffset(0, 0)
	self:SetShadowColor(0, 0, 0, 0)
	self:SetSpacing(4)
	-- Max line
	if self:GetMaxLines() < C.MaxLine then
		self:SetMaxLines(C.MaxLine)
	end
	-- Hide button
	self.buttonFrame.Show = F.Dummy
	self.buttonFrame:Hide()
	self.ScrollBar.Show = F.Dummy
	self.ScrollBar:Hide()
	self.ScrollToBottomButton.Show = F.Dummy
	self.ScrollToBottomButton:Hide()
	_G[name.."ThumbTexture"].Show = F.Dummy
	_G[name.."ThumbTexture"]:Hide()
	
	--[[ Edit box ]]--
	
	-- Get frame name
	local eb = _G[name.."EditBox"]
	-- Allow arrow without alt
	eb:SetAltArrowKeyMode(false)
	-- Size
	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 4, 30)
	eb:SetPoint("TOPRIGHT", self, "TOPRIGHT", -24, 34+C.FontSize)
	eb.bg = F.CreateBG(eb, 3, 3, .5)
	-- Hide texture
	for i = 3, 8 do
		select(i, eb:GetRegions()):SetAlpha(0)
	end
	-- Language icon
	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	-- Size
	lang:ClearAllPoints()
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 5, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 28, 0)
	lang.bg = F.CreateBG(lang, 3, 3, .5)
	
	--[[ Chat tab ]]--
	
	-- Get frame name
	local tab = _G[name.."Tab"]
	-- Set alpha
	tab:SetAlpha(1)
	tab.noMouseAlpha = 0
	--tab.SetAlpha = UIFrameFadeRemoveFrame
	
	-- Hide texture
	for i = 1, 10 do
		if i ~= 7 then -- skip msg highlight texture
			select(i, tab:GetRegions()):SetTexture(nil)
		end
	end
	-- Tab text
	local text = tab:GetFontString()
	text:SetTextColor(1, .8, 0)
	text:SetFont(C.Font, C.FontSize-2, C.FontFlag)
	text:SetShadowOffset(0, 0)
	text:SetShadowColor(0, 0, 0, 0)

	self.styled = true
end

-- Open Temporary Window
local function OpenTemporaryWindow()
	for _, name in next, CHAT_FRAMES do
		local frame = _G[name]
		if frame.isTemporary then
			styleChat(frame)
		end
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", function(self)
		settings()
		
		for i = 1, NUM_CHAT_WINDOWS do
			styleChat(_G["ChatFrame"..i])
		end
		
		hooksecurefunc("FCF_OpenTemporaryWindow", OpenTemporaryWindow)
	end)
