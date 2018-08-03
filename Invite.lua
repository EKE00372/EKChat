-- [[ 按alt邀請 ]] --

local sub = string.sub
local match = string.match

local AltInvite = SetItemRef
SetItemRef = function(link, text, button)
	local linkType = string.sub(link, 1, 6)
	if IsAltKeyDown() and linkType == "player" then
		local name = string.match(link, "player:([^:]+)")
		InviteUnit(name)
		return nil
	end
	return AltInvite(link,text,button)
end

-- [[ 密語關鍵字邀請 ]] --

local INV = CreateFrame("Frame", UIParent)
INV:RegisterEvent("CHAT_MSG_WHISPER")
INV:RegisterEvent("CHAT_MSG_BN_WHISPER")
-- EVENT 返回值 1密語 2角色id 12guid 13戰網好友的角色id
INV:SetScript("OnEvent",function(self, event, msg, name, _, _, _, _, _, _, _, _, _, _, presenceID)
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
					InviteUnit(name)
				end
			end
		end
	end
end)