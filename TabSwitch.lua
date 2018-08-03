function ChatEdit_CustomTabPressed(self)
	if strsub(tostring(self:GetText()), 1, 1) == "/" then return end

	if  self:GetAttribute("chatType") == "SAY"  then
		if IsInGroup() then
			self:SetAttribute("chatType", "PARTY")
			ChatEdit_UpdateHeader(self)
		elseif IsInRaid() then
			self:SetAttribute("chatType", "RAID")
			ChatEdit_UpdateHeader(self)
		elseif (GetNumBattlefieldScores()>0) then
			self:SetAttribute("chatType", "BATTLEGROUND")
			ChatEdit_UpdateHeader(self)
		elseif IsInGuild() then
			self:SetAttribute("chatType", "GUILD");
			ChatEdit_UpdateHeader(self)
		else
			return
		end
	elseif self:GetAttribute("chatType") == "PARTY" then
		if IsInRaid() then
			self:SetAttribute("chatType", "RAID")
			ChatEdit_UpdateHeader(self)
		elseif GetNumBattlefieldScores()>0 then
			self:SetAttribute("chatType", "BATTLEGROUND")
			ChatEdit_UpdateHeader(self);
		elseif IsInGuild() then
			self:SetAttribute("chatType", "GUILD")
			ChatEdit_UpdateHeader(self)
		else
			self:SetAttribute("chatType", "SAY")
			ChatEdit_UpdateHeader(self)
		end			
	elseif self:GetAttribute("chatType") == "RAID" then
		if (GetNumBattlefieldScores()>0) then
			self:SetAttribute("chatType", "BATTLEGROUND")
			ChatEdit_UpdateHeader(self)
		elseif IsInGuild() then
			self:SetAttribute("chatType", "GUILD")
			ChatEdit_UpdateHeader(self)
		else
			self:SetAttribute("chatType", "SAY")
			ChatEdit_UpdateHeader(self)
		end
	elseif self:GetAttribute("chatType") == "BATTLEGROUND" then
		if IsInGuild then
			self:SetAttribute("chatType", "GUILD")
			ChatEdit_UpdateHeader(self)
		else
			self:SetAttribute("chatType", "SAY")
			ChatEdit_UpdateHeader(self)
		end
	elseif self:GetAttribute("chatType") == "GUILD" then
		self:SetAttribute("chatType", "SAY")
		ChatEdit_UpdateHeader(self)
	end
end


