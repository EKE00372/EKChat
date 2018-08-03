-- ChatCopy
-- Credit:
-- TinyChat by loudsoul: https://bbs.ngacn.cc/read.php?tid=10240957
-- CCopy by Borlox: https://www.wowinterface.com/downloads/info9507-CCopy.html
-- OChat by haste: https://github.com/haste/oChat/blob/master/copy.lua

-- [[ copy format rule ]] --

-- 文字格式
local ClearRules = {
	{ pat = "|c%x+|HChatCopy|h.-|h|r", repl = "" },													-- 去掉插件製造的雜物(包括"*"號)
	{ pat = "|c%x%x%x%x%x%x%x%x(.-)|r", repl = "%1" },												-- 替換所有顔色值
	{ pat = "|H.-|h(.-)|h", repl = "%1" },															-- 超連接
	{ pat = "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d):0|t", repl = "{rt%1}" },		-- 團隊標記
	{ pat = "|T.-|t", repl = "" }, 																	-- 非文字素材(icon)
	{ pat = "%|[rcTtHhkK]", repl = "" },															-- 去掉單獨的|r|c|K
	{ pat = "^%s+", repl = "" }, 																	-- 去掉空格
}

-- 替換字符
local function clearMessage(msg, button)
	for _, rule in ipairs(ClearRules) do
		if not rule.button or rule.button == button then
			msg = msg:gsub(rule.pat, rule.repl)
		end
	end
	return msg
end

-- [[ core ]] --

-- 顯示在輸入框
local function showMessage(msg, button)
	local editBox = ChatEdit_ChooseBoxForSend()
	msg = clearMessage(msg, button)
	ChatEdit_ActivateChat(editBox)
	editBox:SetText(editBox:GetText() .. msg)
	editBox:HighlightText()	-- 反白選取
end

-- 獲取該行內容
local function getMessage(...)
	local object
	for i = 1, select("#", ...) do
		object = select(i, ...)
		if object:IsObjectType("FontString") and MouseIsOver(object) then
			return object:GetText()
		end
	end
	return ""
end

-- [[ HACK ]] --

-- 處理點擊聊天框事件
local _SetItemRef = SetItemRef
SetItemRef = function(link, text, button, chatFrame)
	if link:sub(1,8) == "ChatCopy" then
		local msg = getMessage(chatFrame.FontStringContainer:GetRegions())
		return showMessage(msg, button)
	end
	_SetItemRef(link, text, button, chatFrame)
end

-- 點"*"複製
local function AddMessage(self, text, ...)
	if type(text) ~= "string" then
		text = tostring(text)
	end
	text = format("|cff68ccef|HChatCopy|h%s|h|r %s", "-", text)
	self.OrigAddMessage(self, text, ...)
end

-- 應用至所有分頁
local chatFrame
for i = 1, NUM_CHAT_WINDOWS do
	chatFrame = _G["ChatFrame" .. i]
	if chatFrame then
		chatFrame.OrigAddMessage = chatFrame.AddMessage
		chatFrame.AddMessage = AddMessage
	end
end