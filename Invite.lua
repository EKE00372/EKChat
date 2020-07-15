local addon, ns = ...
local C, F, G, L = unpack(ns)

local strlower = string.lower
local C_BattleNet_GetAccountInfoByID = C_BattleNet.GetAccountInfoByID

-- [[ 按alt組隊邀請，ctrl公會邀請 ]] --

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(frame, link, _, button)
	local type, value = link:match("(%a+):(.+)")
	local hide
	
	if button == "LeftButton" and IsModifierKeyDown() then
		if type == "player" then
			local unit = value:match("([^:]+)")
			if IsAltKeyDown() then
				InviteToGroup(unit)
				hide = true
			elseif IsControlKeyDown() then
				GuildInvite(unit)
				hide = true
			end
		elseif type == "BNplayer" then
			local _, bnID = value:match("([^:]*):([^:]*):")
			if not bnID then return end
			local accountInfo = C_BattleNet.GetAccountInfoByID(bnID)
			if not accountInfo then return end
			
			local _, _, _, _, _, gameID = BNGetFriendInfoByID(bnID)
			
			if gameID and CanCooperateWithGameAccount(gameID) then
				if IsAltKeyDown() then
					BNInviteFriend(gameID)
					hide = true
				elseif IsControlKeyDown() then
					local _, charName, _, realmName = BNGetGameAccountInfo(gameID)
					GuildInvite(charName.."-"..realmName)
					hide = true
				end
			end
		end
	else
		return
	end
	
	-- 別打開輸入框
	if hide then ChatEdit_ClearChat(ChatFrame1.editBox) end
end)
	
	
-- [[ 密語關鍵字邀請 ]] --

local WhisperInvite = CreateFrame("Frame", UIParent)
WhisperInvite:RegisterEvent("CHAT_MSG_WHISPER")
WhisperInvite:RegisterEvent("CHAT_MSG_BN_WHISPER")
-- EVENT 返回值 1密語 2角色id 12guid 13戰網好友的角色id
WhisperInvite:SetScript("OnEvent",function(self, event, msg, name, _, _, _, _, _, _, _, _, _, _, presenceID)
	for _, word in pairs(C.InviteKey) do
		if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strlower(msg) == strlower(word) then
			if event == "CHAT_MSG_BN_WHISPER" then
				local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
				if accountInfo then
					local gameAccountInfo = accountInfo.gameAccountInfo
					local gameID = gameAccountInfo.gameAccountID
					if gameID then
						local charName = gameAccountInfo.characterName
						local realmName = gameAccountInfo.realmName
						if CanCooperateWithGameAccount(accountInfo) then
							BNInviteFriend(gameID)
						end
					end
				end
			else
				InviteToGroup(name)
			end
		end
	end
	
	for _, Gword in pairs(C.GuildInviteKey) do
		if (not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strlower(msg) == strlower(Gword) then
			if event == "CHAT_MSG_BN_WHISPER" then
				local accountInfo = C_BattleNet_GetAccountInfoByID(presenceID)
				if accountInfo then
					local gameAccountInfo = accountInfo.gameAccountInfo
					local gameID = gameAccountInfo.gameAccountID
					if gameID then
						local charName = gameAccountInfo.characterName
						local realmName = gameAccountInfo.realmName
						if CanCooperateWithGameAccount(accountInfo) then
							GuildInvite(charName.."-"..realmName)
						end
					end
				end
			else
				print(name)
				GuildInvite(name)
			end
		end
	end
end)