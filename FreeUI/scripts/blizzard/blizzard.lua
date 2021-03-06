local F, C, L = unpack(select(2, ...))

local module = F:RegisterModule('blizzard')


function module:OnLogin()
	self:FontStyle()
	self:PetBattleUI()
	self:EnhanceColorPicker()
	self:PositionUIWidgets()
	self:QuestTracker()
	self:CooldownCount()
	self:PositionAlert()
	self:RemoveTalkingHead()
	self:RemoveBossBanner()
	self:SkipAzeriteAnimation()
	self:Errors()
	self:ArchaeologyBar()

	-- Unregister talent event
	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	else
		hooksecurefunc('TalentFrame_LoadUI', function()
			PlayerTalentFrame:UnregisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		end)
	end
end

-- reposition alert popup
function module:PositionAlert()
	if not C.general.alert then return end
	local function alertFrameMover(self, ...)
		_G.AlertFrame:ClearAllPoints()
		_G.AlertFrame:SetPoint(unpack(C.general.alert_Position))
	end
	hooksecurefunc(_G.AlertFrame, 'UpdateAnchors', alertFrameMover)
end

-- remove talking head
function module:RemoveTalkingHead()
	local f = CreateFrame('Frame')
	function f:OnEvent(event, addon)
		if C.general.hideTalkingHead then
			if addon == 'Blizzard_TalkingHeadUI' then
				hooksecurefunc('TalkingHeadFrame_PlayCurrent', function()
					TalkingHeadFrame:Hide()
				end)
				self:UnregisterEvent(event)
			end
		end
	end
	f:RegisterEvent('ADDON_LOADED')
	f:SetScript('OnEvent', f.OnEvent)
end

-- Remove Boss Banner
function module:RemoveBossBanner()
	if C.general.hideBossBanner then
		BossBanner:UnregisterAllEvents()
	end
end

function module:PositionUIWidgets()
	local function topCenterPosition(self, _, b)
		local holder = _G.TopCenterContainerHolder
		if b and (b ~= holder) then
			self:ClearAllPoints()
			self:SetPoint('CENTER', holder)
			self:SetParent(holder)
		end
	end

	local function belowMinimapPosition(self, _, b)
		local holder = _G.BelowMinimapContainerHolder
		if b and (b ~= holder) then
			self:ClearAllPoints()
			self:SetPoint('CENTER', holder, 'CENTER')
			self:SetParent(holder)
		end
	end

	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	local belowMiniMapcontainer = _G.UIWidgetBelowMinimapContainerFrame

	local topCenterHolder = CreateFrame('Frame', 'TopCenterContainerHolder', UIParent)
	topCenterHolder:SetPoint("TOP", UIParent, "TOP", 0, -30)
	topCenterHolder:SetSize(10, 58)

	local belowMiniMapHolder = CreateFrame('Frame', 'BelowMinimapContainerHolder', UIParent)
	belowMiniMapHolder:SetPoint('TOP', UIParent, 'TOP', 0, -120)
	belowMiniMapHolder:SetSize(128, 40)

	topCenterContainer:ClearAllPoints()
	topCenterContainer:SetPoint('CENTER', topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:SetPoint('CENTER', belowMiniMapHolder, 'CENTER')

	hooksecurefunc(topCenterContainer, 'SetPoint', topCenterPosition)
	hooksecurefunc(belowMiniMapcontainer, 'SetPoint', belowMinimapPosition)
end


-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G['RaidGroupButton'..i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute('type', 'target')
				bu:SetAttribute('unit', bu.unit)

				bu.clickFixed = true
			end
		end
	end

	local EventFrame = CreateFrame( 'Frame' )
	EventFrame:RegisterEvent('ADDON_LOADED')
	EventFrame:SetScript('OnEvent', function(self, event, addon)
		if event == 'ADDON_LOADED' and addon == 'Blizzard_RaidUI' then
			if not InCombatLockdown() then
				fixRaidGroupButton()
				self:UnregisterAllEvents()
			else
				self:RegisterEvent('PLAYER_REGEN_ENABLED')
			end
		elseif event == 'PLAYER_REGEN_ENABLED' then
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute('type') ~= 'target' then
				fixRaidGroupButton()
				self:UnregisterAllEvents()
			end
		end
	end)
end


function module:SkipAzeriteAnimation()
	if not (IsAddOnLoaded('Blizzard_AzeriteUI')) then
    	UIParentLoadAddOn('Blizzard_AzeriteUI')
    end
	hooksecurefunc(AzeriteEmpoweredItemUI,'OnItemSet',function(self)
		local itemLocation = self.azeriteItemDataSource:GetItemLocation()
		if self:IsAnyTierRevealing() then
			C_Timer.After(0.7,function() 
				OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation)
			end)
		end
	end)
end


