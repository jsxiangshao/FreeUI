local F, C, L = unpack(select(2, ...))

local module = F:GetModule('Misc')



function module:CMGuildBest()
	local CHALLENGE_MODE_POWER_LEVEL = CHALLENGE_MODE_POWER_LEVEL
	local CHALLENGE_MODE_GUILD_BEST_LINE = CHALLENGE_MODE_GUILD_BEST_LINE
	local CHALLENGE_MODE_GUILD_BEST_LINE_YOU = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	local Ambiguate, GetContainerNumSlots, GetContainerItemInfo = Ambiguate, GetContainerNumSlots, GetContainerItemInfo
	local C_ChallengeMode_GetMapUIInfo, C_ChallengeMode_GetGuildLeaders = C_ChallengeMode.GetMapUIInfo, C_ChallengeMode.GetGuildLeaders
	local format, strsplit, strmatch, tonumber, pairs, wipe = string.format, string.split, string.match, tonumber, pairs, table.wipe
	local frame

	local function UpdateTooltip(self)
		local leaderInfo = self.leaderInfo
		if not leaderInfo then return end

		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		local name = C_ChallengeMode_GetMapUIInfo(leaderInfo.mapChallengeModeID)
		GameTooltip:SetText(name, 1, 1, 1)
		GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel))
		for i = 1, #leaderInfo.members do
			local classColorStr = C.ClassColors[leaderInfo.members[i].classFileName].colorStr
			GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr,leaderInfo.members[i].name));
		end
		GameTooltip:Show()
	end

	local function CreateBoard()
		frame = CreateFrame('Frame', nil, ChallengesFrame)
		frame:SetPoint('BOTTOMRIGHT', -6, 80)
		frame:SetSize(170, 105)
		F.CreateBD(frame, .3)
		F.CreateFS(frame, {C.font.normal, 14}, GUILD, nil, nil, true, 'TOPLEFT', 16, -6)

		frame.entries = {}
		for i = 1, 4 do
			local entry = CreateFrame('Frame', nil, frame)
			entry:SetPoint('LEFT', 10, 0)
			entry:SetPoint('RIGHT', -10, 0)
			entry:SetHeight(18)
			entry.CharacterName = F.CreateFS(entry, {C.font.normal, 12}, '', nil, nil, true, 'LEFT', 6, 0)
			entry.CharacterName:SetPoint('RIGHT', -30, 0)
			entry.CharacterName:SetJustifyH('LEFT')
			entry.Level = F.CreateFS(entry, {C.font.normal, 12}, '', nil, nil, true)
			entry.Level:SetJustifyH('LEFT')
			entry.Level:ClearAllPoints()
			entry.Level:SetPoint('LEFT', entry, 'RIGHT', -22, 0)
			entry:SetScript('OnEnter', UpdateTooltip)
			entry:SetScript('OnLeave', F.HideTooltip)
			if i == 1 then
				entry:SetPoint('TOP', frame, 0, -26)
			else
				entry:SetPoint('TOP', frame.entries[i-1], 'BOTTOM')
			end

			frame.entries[i] = entry
		end
	end

	local function SetUpRecord(self, leaderInfo)
		self.leaderInfo = leaderInfo
		local str = CHALLENGE_MODE_GUILD_BEST_LINE
		if leaderInfo.isYou then
			str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
		end

		local classColorStr = C.ClassColors[leaderInfo.classFileName].colorStr
		self.CharacterName:SetText(format(str, classColorStr, leaderInfo.name))
		self.Level:SetText(leaderInfo.keystoneLevel)
	end

	local resize
	local function UpdateGuildBest(self)
		if not frame then CreateBoard() end
		if self.leadersAvailable then
			local leaders = C_ChallengeMode_GetGuildLeaders()
			if leaders and #leaders > 0 then
				for i = 1, #leaders do
					SetUpRecord(frame.entries[i], leaders[i])
				end
				frame:Show()
			else
				frame:Hide()
			end
		end

		if not resize and IsAddOnLoaded('AngryKeystones') then
			local scheduel = select(5, self:GetChildren())
			frame:SetWidth(246)
			frame:ClearAllPoints()
			frame:SetPoint('BOTTOMLEFT', scheduel, 'TOPLEFT', 0, 10)

			self.WeeklyInfo.Child.Label:SetPoint('TOP', -135, -25)
			local affix = self.WeeklyInfo.Child.Affixes[1]
			if affix then
				affix:ClearAllPoints()
				affix:SetPoint('TOPLEFT', 20, -55)
			end

			resize = true
		end
	end

	local iconColor = BAG_ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_EPIC or 4]
	local function AddKeystoneIcon()
		local texture = select(10, GetItemInfo(158923)) or 525134
		local button = CreateFrame('Frame', nil, ChallengesFrame.WeeklyInfo)
		button:SetPoint('BOTTOMLEFT', 10, 67)
		button:SetSize(35, 35)
		F.PixelIcon(button, texture, true)
		button:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
		button:SetScript('OnEnter', function(self)
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:AddLine(L['ACCOUNT_KEYSTONES'])
			for name, info in pairs(FreeUIGlobalConfig['keystoneInfo']) do
				local name = Ambiguate(name, 'none')
				local mapID, level, class, faction = strsplit(':', info)
				local color = F.HexRGB(F.ClassColor(class))
				local factionColor = faction == 'Horde' and '|cffff5040' or '|cff00adf0'
				local dungeon = C_ChallengeMode_GetMapUIInfo(tonumber(mapID))
				GameTooltip:AddDoubleLine(format(color..'%s:|r', name), format('%s%s(%s)|r', factionColor, dungeon, level))
			end
			GameTooltip:Show()
		end)
		button:SetScript('OnLeave', F.HideTooltip)
		button:SetScript('OnMouseUp', function(_, btn)
			if btn == 'MiddleButton' then
				wipe(FreeUIGlobalConfig['KeystoneInfo'])
			end
		end)
	end

	local function ChallengesOnLoad(event, addon)
		if addon == 'Blizzard_ChallengesUI' then
			hooksecurefunc('ChallengesFrame_Update', UpdateGuildBest)
			AddKeystoneIcon()

			F:UnregisterEvent(event)
		end
	end
	F:RegisterEvent('ADDON_LOADED', ChallengesOnLoad)

	-- Keystone Info
	local myFaction = UnitFactionGroup('player')
	local myFullName = C.Name..'-'..C.Realm
	local function GetKeyInfo()
		for bag = 0, 4 do
			local numSlots = GetContainerNumSlots(bag)
			for slot = 1, numSlots do
				local slotLink = select(7, GetContainerItemInfo(bag, slot))
				local itemString = slotLink and strmatch(slotLink, '|Hkeystone:([0-9:]+)|h(%b[])|h')
				if itemString then
					return slotLink, itemString
				end
			end
		end
	end

	local function UpdateBagInfo()
		local link, itemString = GetKeyInfo()
		if link then
			local _, mapID, level = strsplit(':', itemString)
			FreeUIGlobalConfig['keystoneInfo'][myFullName] = mapID..':'..level..':'..C.Class..':'..myFaction
		else
			FreeUIGlobalConfig['keystoneInfo'][myFullName] = nil
		end
	end
	UpdateBagInfo()
	F:RegisterEvent('BAG_UPDATE', UpdateBagInfo)
end