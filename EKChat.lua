-- [[ ChatFrame ]] --

	-- credit:
	-- neavo的sora's ui - https://git.oschina.net/Neavo/sora
	-- zork rchat
	-- NeavUI nchat
	-- MonoUI m_chat
	-- https://tw.piliapp.com/symbol/

-- [[ config ]] --

local font 			= STANDARD_TEXT_FONT
local fontsize 		= 16
local fontstyle 	= "OUTLINE"
local bottomflash	= false		-- high cpu usage.

local _G = _G
-- 更多字體大小
_G.CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}
-- 頻道保持
_G.ChatTypeInfo["SAY"].sticky = 1				-- 說
_G.ChatTypeInfo["PARTY"].sticky = 1				-- 小隊
_G.ChatTypeInfo["GUILD"].sticky = 1				-- 公會
_G.ChatTypeInfo["WHISPER"].sticky = 0			-- 密語
_G.ChatTypeInfo["BN_WHISPER"].sticky = 0		-- 戰網密語
_G.ChatTypeInfo["RAID"].sticky = 1				-- 團隊
_G.ChatTypeInfo["OFFICER"].sticky = 1			-- 幹部
_G.ChatTypeInfo["CHANNEL"].sticky = 1			-- 頻道
_G.ChatTypeInfo["INSTANCE_CHAT"].sticky = 1		-- 副本
_G.ChatTypeInfo["YELL"].sticky = 0				-- 喊
_G.ChatTypeInfo["BN_INLINE_TOAST_ALERT"].flashTab = false
_G.ChatTypeInfo["BN_INLINE_TOAST_BROADCAST"].flashTab = false
_G.ChatTypeInfo["BN_INLINE_TOAST_BROADCAST_INFORM"].flashTab = false
-- 框架透明
_G.DEFAULT_CHATFRAME_ALPHA = 0
_G.DEFAULT_CHATFRAME_COLOR = {r = 0, g = 0, b = 0}
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
_G.CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0


-- [[ 頻道縮寫&名字引號 ]] --

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

-- 全局的幹掉功能
local function kill(frame)
	if frame.UnregisterAllEvents then
		frame:UnregisterAllEvents()
	end
	frame:Hide()
	frame.Show = function() end
end

-- 框架優化
local function SkinChat(self,event,...)
	--幹掉通知視窗和快速加入
	kill(ChatFrameMenuButton)
	kill(QuickJoinToastButton)
	--改良toastframe
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetClampRectInsets(-15, 15, 15, -15)
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 0, 25)
	end)	
	
	for i = 1, NUM_CHAT_WINDOWS do
	
		-- chat
		local ChatFrame = _G["ChatFrame" .. i]
		ChatFrame1:SetUserPlaced(true)			-- 允許置底
		-- 透明
		FCF_SetWindowAlpha(ChatFrame, 0)
		ChatFrame:SetSpacing(4)					-- 行距
		-- 淡出
		ChatFrame:SetFading(true)				-- 啟用淡出
		ChatFrame:SetFadeDuration(2)			-- 淡出動畫持續時間
		ChatFrame:SetTimeVisible(20)			-- 可見時間
		-- 尺寸
		ChatFrame:SetFrameLevel(8)				-- 框體層級
		ChatFrame:SetClampedToScreen(false)		-- 固定在螢幕內
		ChatFrame:SetClampRectInsets(0, 0, 0, 0)
		ChatFrame:SetMinResize(128, 64)
		ChatFrame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
		-- 文字
		local _, size = ChatFrame:GetFont()
		ChatFrame:SetFont(font, fontsize, fontstyle)
		ChatFrame:SetShadowOffset(0, 0)			-- 陰影
		ChatFrame:SetShadowColor(0, 0, 0, 0)
		-- 幹掉材質
		kill(_G["ChatFrame" .. i .. "ButtonFrame"])
		kill(_G["ChatFrame" .. i .. "ButtonFrameBottomButton"])
		kill(_G["ChatFrame" .. i .. "TabLeft"])
		kill(_G["ChatFrame" .. i .. "TabRight"])
		kill(_G["ChatFrame" .. i .. "TabMiddle"])
		kill(_G["ChatFrame" .. i .. "TabSelectedLeft"])
		kill(_G["ChatFrame" .. i .. "TabSelectedRight"])
		kill(_G["ChatFrame" .. i .. "TabSelectedMiddle"])
		kill(_G["ChatFrame" .. i .. "TabHighlightLeft"])
		kill(_G["ChatFrame" .. i .. "TabHighlightRight"])
		kill(_G["ChatFrame" .. i .. "TabHighlightMiddle"])
		
		-- tab
		local Tab = _G["ChatFrame" .. i .. "Tab"]		
		--local TabGlow = _G["ChatFrame".. i .."TabGlow"]
		-- 初始透明度
		Tab:SetAlpha(0)
		Tab.noMouseAlpha = 0
		-- 文字
		local TabText = _G["ChatFrame" .. i .. "TabText"]
		TabText.SetTextColor = function() end
		TabText:SetFont(font, fontsize-2, fontstyle)
		TabText:SetShadowOffset(0, 0)
		TabText:SetShadowColor(0, 0, 0, 0)
		
		-- editbox
		local EditBox = _G["ChatFrame" .. i .. "EditBox"]
		local EditBoxHeader = _G["ChatFrame" .. i .. "EditBoxHeader"]
		EditBox:SetAltArrowKeyMode(false)
		--EditBox:EnableMouse(false)	-- 禁止滑鼠點擊		
		-- 大小
		EditBox:ClearAllPoints()
		EditBox:SetPoint("BOTTOMLEFT", ChatFrame, "TOPLEFT", 6, 24)
		EditBox:SetPoint("TOPRIGHT", ChatFrame, "TOPRIGHT", -30, 52)
		-- 文字
		EditBox:SetFont(font, fontsize, fontstyle)
		EditBoxHeader:SetFont(font, fontsize, fontstyle)
		-- 只留一個深色背景
		EditBox:SetBackdrop(
		{bgFile = [[Interface\Buttons\WHITE8X8]],
		insets = { left = 2, right = 2, top = 2, bottom = 2 },}
		)
		EditBox:SetBackdropColor(0, 0, 0, 0.5)
		--EditBox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
		EditBox:SetShadowOffset(0, 0)
		-- 幹掉材質
		kill(_G["ChatFrame" .. i .. "EditBoxMid"])
		kill(_G["ChatFrame" .. i .. "EditBoxLeft"])
		kill(_G["ChatFrame" .. i .. "EditBoxRight"])
		--kill(_G["ChatFrame" .. i .. "EditBoxLanguage"])	-- 保留輸入法
		kill(_G["ChatFrame" .. i .. "EditBoxFocusMid"])
		kill(_G["ChatFrame" .. i .. "EditBoxFocusLeft"])
		kill(_G["ChatFrame" .. i .. "EditBoxFocusRight"])
		
		--輸入法(中/英 字)
		local lang = _G["ChatFrame" .. i .. "EditBoxLanguage"]
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
		--[[lang:HookScript("OnMouseUp", function(_, btn)
			if btn == "RightButton" then
				ChatMenu:ClearAllPoints()
				ChatMenu:SetPoint("BOTTOMRIGHT", EditBox, 0, 30)
				ToggleFrame(ChatMenu)
			end
		end)]]--
	end
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

-- [[ 動態視窗 ]] --

local function TempChat()
	local frame = FCF_GetCurrentChatFrame()
	--關閉寵物戰鬥紀錄
	if _G[frame:GetName().."Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG) then
		FCF_Close(frame)
		else return
	end
end
hooksecurefunc("FCF_OpenTemporaryWindow", TempChat)

-- [[ 載入事件 ]] --

local Event = CreateFrame("Frame", nil, UIParent)
Event:RegisterEvent("PLAYER_ENTERING_WORLD")
--Event:RegisterEvent("PLAYER_LOGIN")
Event:SetScript("OnEvent", function(self, event, unit, ...)
	if event == "PLAYER_ENTERING_WORLD"  then
		DefaultCVar()
		SkinChat()
		if bottomflash then
			Flash()
		else return end
	end
end)