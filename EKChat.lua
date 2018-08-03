-- [[ ChatFrame ]] --

	-- credit:
	-- neavo的sora's ui - https://git.oschina.net/Neavo/sora
	-- zork rchat
	-- NeavUI nchat
	-- MonoUI m_chat
	-- https://tw.piliapp.com/symbol/

-- [[ config ]] --

local font 			= STANDARD_TEXT_FONT
local fontsize 		= 18
local fontstyle 	= "OUTLINE"
local bottomflash	= false		-- high cpu usage.
local maxLines		= 1024
local maxWidth, maxHeight = UIParent:GetWidth(), UIParent:GetHeight()

-- [[ global ]] --

local _G = _G


-- 框架透明
--[[_G.DEFAULT_CHATFRAME_ALPHA = 0
_G.DEFAULT_CHATFRAME_COLOR = {r = 0, g = 0, b = 0, a = 0}
-- TAB淡出
_G.CHAT_TAB_SHOW_DELAY = 0
_G.CHAT_TAB_HIDE_DELAY = 5
_G.CHAT_FRAME_FADE_TIME = 1
_G.CHAT_FRAME_FADE_OUT_TIME = 1
_G.CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
_G.CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
_G.CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
_G.CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0.6
_G.CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.6
_G.CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0]]--


-- [[ 頻道縮寫 & 去除名字引號 ]] --

local gsub = _G.string.gsub
local newAddMsg = {}
local function AddMessage(frame, text, ...)
	text = gsub(text, "(|HBNplayer.-|h)%[(.-)%]|h", "%1%2|h")		-- 戰網名字去引號
	text = gsub(text, "(|Hplayer.-|h)%[(.-)%]|h", "%1%2|h")			-- 角色名字去引號
	text = gsub(text, "%[(%d0?)%. (.-)%]", "[%1]")					-- 頻道縮寫
	return newAddMsg[frame:GetName()](frame, text, ...)
end
do
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then	-- 跳過戰鬥紀錄
			local frame = _G[format("%s%d", "ChatFrame", i)]
			newAddMsg[format("%s%d", "ChatFrame", i)] = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	end
end

-- [[ core ]] --

-- CVAR
local function DefaultCVar()
	SetCVar("chatStyle", "classic")
	SetCVar("showTimestamps", "|cff64C2F5%H:%M:%S|r ")
	SetCVar("whisperMode", "inline")
end

--改良toastframe
local BNToastFrame = BNToastFrame
BNToastFrame:SetClampedToScreen(true)
BNToastFrame:SetClampRectInsets(-15, 15, 15, -15)
BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 0, 25)
end)
	
-- 框架優化
local function skinChat(self)
	if not self or (self and self.styled) then return end
	local name = self:GetName()
	-- chat
	self:SetSpacing(4)					-- 行距
	-- 淡出
	self:SetFading(true)				-- 啟用淡出
	self:SetFadeDuration(2)				-- 淡出動畫持續時間
	self:SetTimeVisible(20)				-- 可見時間
	-- 尺寸
	self:SetFrameLevel(8)				-- 框體層級
	self:SetClampedToScreen(false)		-- 固定在螢幕內
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetMinResize(128, 64)
	self:SetMaxResize(maxWidth, maxHeight)
	-- 文字
	self:SetFont(font, fontsize, fontstyle)
	self:SetShadowOffset(0, 0)			-- 陰影
	self:SetShadowColor(0, 0, 0, 0)
	-- 最大行數
	if self:GetMaxLines() < maxLines then
		self:SetMaxLines(maxLines)
	end

	-- editbox
	local EditBox = _G[name.."EditBox"]
	EditBox:SetAltArrowKeyMode(false)	
	-- 大小
	EditBox:ClearAllPoints()
	EditBox:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 6, 24)
	EditBox:SetPoint("TOPRIGHT", self, "TOPRIGHT", -24, 56)
	-- 只留一個深色背景
	EditBox:SetBackdrop(
	{bgFile = [[Interface\Buttons\WHITE8X8]],
	insets = { left = 2, right = 2, top = 2, bottom = 2 },}
	)
	EditBox:SetBackdropColor(0, 0, 0, 0.5)
	EditBox:SetShadowOffset(0, 0)
	-- 幹掉材質
	for i = 3, 8 do
		select(i, EditBox:GetRegions()):SetAlpha(0)
	end

	--輸入法(中/英 字)
	local lang = _G[name.."EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:ClearAllPoints()
	lang:SetPoint("TOPLEFT", EditBox, "TOPRIGHT", -2, 0)
	lang:SetPoint("BOTTOMRIGHT", EditBox, "BOTTOMRIGHT", 28, 0)
	lang:SetBackdrop(
	{bgFile = [[Interface\Buttons\WHITE8X8]],
	insets = { left = 2, right = 2, top = 2, bottom = 2 },}
	)
	lang:SetBackdropColor(0, 0, 0, 0.5)
	--右鍵聊天選項小按鈕
	lang:HookScript("OnMouseUp", function(_, btn)
		if btn == "RightButton" then
			ChatMenu:ClearAllPoints()
			ChatMenu:SetPoint("BOTTOMRIGHT", EditBox, 0, 30)
			ToggleFrame(ChatMenu)
		end
	end)
			
	-- tab
	local Tab = _G[name.."Tab"]		
	-- 初始透明度
	Tab:SetAlpha(1)
	Tab.noMouseAlpha = 0
	-- 幹掉材質
	for i = 1, 10 do
		if i ~= 7 then -- skip msg highlight
			select(i, Tab:GetRegions()):SetTexture(nil)
		end
	end		
	-- 文字
	local TabText = Tab:GetFontString()
	TabText:SetTextColor(1, .8, 0)
	TabText:SetFont(font, fontsize-2, fontstyle)
	TabText:SetShadowOffset(0, 0)
	TabText:SetShadowColor(0, 0, 0, 0)

	self.styled = true
end
		
-- [[ 未置底閃光(高cpu占用) ]] --

local function Flash()
	hooksecurefunc("ChatFrame_OnUpdate", function(self, elapsedSec)
		local flash = _G[self:GetName().."ButtonFrameBottomButtonFlash"]
		if (not flash) then return end
		if (not self.BottomFlash) then
			self.BottomFlash = self:CreateTexture()
			self.BottomFlash:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
			self.BottomFlash:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -4, 24)
			self.BottomFlash:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -6)
			self.BottomFlash:SetBlendMode("ADD")
			self.BottomFlash:SetGradientAlpha("VERTICAL", 0.2, 0.5, 0.9, 0.6, 0.2, 0.5, 0.9, 0)
		end
		if (flash:IsShown()) then
			self.BottomFlash:Show()
		else
			self.BottomFlash:Hide()
		end
	end)
end

-- [[ ctrl滾動首尾 shift滾動三行 ]] --

hooksecurefunc("FloatingChatFrame_OnMouseScroll", function(self, delta, ...)
	if delta > 0 then
		if IsControlKeyDown() then
			self:ScrollToTop()
		elseif IsShiftKeyDown() then
			self:ScrollUp()
			self:ScrollUp()
		end
	else
		if IsControlKeyDown() then
			self:ScrollToBottom()
		elseif IsShiftKeyDown() then
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end)

-- [[ 載入事件 ]] --

local Event = CreateFrame("Frame", nil, UIParent)
Event:RegisterEvent("PLAYER_ENTERING_WORLD")
Event:RegisterEvent("PLAYER_LOGIN")
Event:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD"  then
		DefaultCVar()
		
		for i = 1, NUM_CHAT_WINDOWS do
			skinChat(_G["ChatFrame"..i])
		end
		-- 動態視窗(戰寵ETC)
		hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in next, CHAT_FRAMES do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				skinChat(frame)
			end
		end
	end)
	
		if bottomflash then
			Flash()
		else return end
	end

	for i = 1, 15 do
		CHAT_FONT_HEIGHTS[i] = i + 9
	end
	
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
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function(msg) return true end)					-- 忙碌
end)