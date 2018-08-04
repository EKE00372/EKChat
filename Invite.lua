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
	else return end
	-- 別打開輸入框
	if hide then ChatEdit_ClearChat(ChatFrame1.editBox) end
end)
	
	
-- [[ 密語關鍵字邀請 ]] --

local WhisperInvite = CreateFrame("Frame", UIParent)
WhisperInvite:RegisterEvent("CHAT_MSG_WHISPER")
WhisperInvite:RegisterEvent("CHAT_MSG_BN_WHISPER")
-- EVENT 返回值 1密語 2角色id 12guid 13戰網好友的角色id
WhisperInvite:SetScript("OnEvent",function(self, event, msg, name, _, _, _, _, _, _, _, _, _, _, presenceID)
	-- 關鍵字
	if msg == "+++" or msg == "111" then
		-- 不在團隊中或者有組人權限
		if not IsInGroup() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			if GetNumSubgroupMembers() >= 4 and not IsInRaid() then
				ConvertToRaid()
			end
			-- BN
			if event == "CHAT_MSG_BN_WHISPER" then
				local gameID = select(6, BNGetFriendInfoByID(presenceID))
				if CanCooperateWithGameAccount(gameID) then
					BNInviteFriend(gameID)
				end
			else
				if name then
					InviteToGroup(name)
					--InviteUnit(name)
				end
			end
		end
	end
end)