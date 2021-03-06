local F, C = unpack(select(2, ...))

tinsert(C.themes["FreeUI"], function()
	local r, g, b = C.r, C.g, C.b

	CharacterModelFrame:DisableDrawLayer("BACKGROUND")
	CharacterModelFrame:DisableDrawLayer("BORDER")
	CharacterModelFrame:DisableDrawLayer("OVERLAY")

	-- [[ Item buttons ]]

	local function colourPopout(self)
		local aR, aG, aB
		local glow = self:GetParent().IconBorder

		if glow:IsShown() then
			aR, aG, aB = glow:GetVertexColor()
		else
			aR, aG, aB = r, g, b
		end

		self.arrow:SetVertexColor(aR, aG, aB)
	end

	local function clearPopout(self)
		self.arrow:SetVertexColor(1, 1, 1)
	end

	local function UpdateAzeriteItem(self)
		if not self.styled then
			self.AzeriteTexture:SetAlpha(0)
			self.RankFrame.Texture:SetTexture("")
			self.RankFrame.Label:ClearAllPoints()
			self.RankFrame.Label:SetPoint("TOPLEFT", self, 2, -1)
			self.RankFrame.Label:SetTextColor(1, .5, 0)
			FreeUI[1].SetFS(self.RankFrame.Label)

			self.styled = true
		end
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		self:GetHighlightTexture():SetAllPoints()
	end

	local function UpdateAzeriteEmpoweredItem(self)
		self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
		self.AzeriteTexture:SetAllPoints()
		self.AzeriteTexture:SetDrawLayer("BORDER", 1)
	end

	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]
		local border = slot.IconBorder

		_G[slot:GetName().."Frame"]:Hide()
		slot:SetNormalTexture("")
		slot:SetPushedTexture("")
		slot:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		slot.SetHighlightTexture = F.Dummy
		slot.icon:SetTexCoord(unpack(C.TexCoord))

		border:SetPoint("TOPLEFT", -C.Mult, C.Mult)
		border:SetPoint("BOTTOMRIGHT", C.Mult, -C.Mult)
		border:SetDrawLayer("BACKGROUND")
		F.CreateBDFrame(slot, .25)

		local popout = slot.popoutButton
		popout:SetNormalTexture("")
		popout:SetHighlightTexture("")

		local arrow = popout:CreateTexture(nil, "OVERLAY")
		if slot.verticalFlyout then
			arrow:SetSize(13, 8)
			arrow:SetTexture(C.media.arrowDown)
			arrow:SetPoint("TOP", slot, "BOTTOM", 0, 1)
		else
			arrow:SetSize(8, 14)
			arrow:SetTexture(C.media.arrowRight)
			arrow:SetPoint("LEFT", slot, "RIGHT", -1, 0)
		end
		popout.arrow = arrow

		popout:HookScript("OnEnter", clearPopout)
		popout:HookScript("OnLeave", colourPopout)

		hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
		hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
	end

	select(14, CharacterMainHandSlot:GetRegions()):Hide()
	select(14, CharacterSecondaryHandSlot:GetRegions()):Hide()

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		-- also fires for bag slots, we don't want that
		if button.popoutButton then
			button.IconBorder:SetTexture(C.media.backdrop)
			button.icon:SetShown(GetInventoryItemTexture("player", button:GetID()) ~= nil)
			colourPopout(button.popoutButton)
		end
	end)

	-- [[ Stats pane ]]

	local pane = CharacterStatsPane
	pane.ClassBackground:Hide()
	local category = {pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory}
	for _, v in pairs(category) do
		--v.Background:Hide()
		--F.CreateGradient(v)
		--F.CreateBD(v)

		v.Background:SetTexture('Interface\\LFGFrame\\UI-LFG-SEPARATOR')
		v.Background:SetTexCoord(0, .66, 0, .31)
		v.Background:SetVertexColor(r, g, b, .8)
		v.Background:SetPoint('BOTTOMLEFT', -30, -4)
	end


	-- [[ Sidebar tabs ]]

	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]

		if i == 1 then
			for i = 1, 4 do
				local region = select(i, tab:GetRegions())
				region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
				region.SetTexCoord = F.Dummy
			end
		end

		tab.Highlight:SetColorTexture(r, g, b, .2)
		tab.Highlight:SetPoint("TOPLEFT", 3, -4)
		tab.Highlight:SetPoint("BOTTOMRIGHT", -1, 0)
		tab.Hider:SetColorTexture(.3, .3, .3, .4)
		tab.TabBg:SetAlpha(0)

		select(2, tab:GetRegions()):ClearAllPoints()
		if i == 1 then
			select(2, tab:GetRegions()):SetPoint("TOPLEFT", 3, -4)
			select(2, tab:GetRegions()):SetPoint("BOTTOMRIGHT", -1, 0)
		else
			select(2, tab:GetRegions()):SetPoint("TOPLEFT", 2, -4)
			select(2, tab:GetRegions()):SetPoint("BOTTOMRIGHT", -1, -1)
		end

		tab.bg = F.CreateBDFrame(tab)
		tab.bg:SetPoint("TOPLEFT", 2, -3)
		tab.bg:SetPoint("BOTTOMRIGHT", 0, -2)

		tab.Hider:SetPoint("TOPLEFT", tab.bg, C.Mult, -C.Mult)
		tab.Hider:SetPoint("BOTTOMRIGHT", tab.bg, -C.Mult, C.Mult)
	end

	-- [[ Equipment manager ]]

	F.StripTextures(GearManagerDialogPopup.BorderBox)
	GearManagerDialogPopup.BG:Hide()
	F.CreateBD(GearManagerDialogPopup)
	F.CreateSD(GearManagerDialogPopup)
	GearManagerDialogPopup:SetHeight(525)
	F.StripTextures(GearManagerDialogPopupScrollFrame)
	F.ReskinScroll(GearManagerDialogPopupScrollFrameScrollBar)
	F.Reskin(GearManagerDialogPopupOkay)
	F.Reskin(GearManagerDialogPopupCancel)
	F.ReskinInput(GearManagerDialogPopupEditBox)
	F.ReskinScroll(PaperDollTitlesPaneScrollBar)
	F.ReskinScroll(PaperDollEquipmentManagerPaneScrollBar)
	F.StripTextures(PaperDollSidebarTabs)
	F.Reskin(PaperDollEquipmentManagerPaneEquipSet)
	F.Reskin(PaperDollEquipmentManagerPaneSaveSet)

	for i = 1, NUM_GEARSET_ICONS_SHOWN do
		local bu = _G["GearManagerDialogPopupButton"..i]
		local ic = _G["GearManagerDialogPopupButton"..i.."Icon"]

		bu:SetCheckedTexture(C.media.checked)
		select(2, bu:GetRegions()):Hide()

		local hl = bu:GetHighlightTexture()
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetAllPoints(ic)
		
		ic:SetPoint("TOPLEFT", C.Mult, -C.Mult)
		ic:SetPoint("BOTTOMRIGHT", -C.Mult, C.Mult)
		ic:SetTexCoord(unpack(C.TexCoord))

		F.CreateBD(bu, .25)
	end

	local sets = false
	PaperDollSidebarTab3:HookScript("OnClick", function()
		if sets == false then
			for i = 1, 9 do
				local bu = _G["PaperDollEquipmentManagerPaneButton"..i]
				local bd = _G["PaperDollEquipmentManagerPaneButton"..i.."Stripe"]
				local ic = _G["PaperDollEquipmentManagerPaneButton"..i.."Icon"]
				_G["PaperDollEquipmentManagerPaneButton"..i.."BgTop"]:SetAlpha(0)
				_G["PaperDollEquipmentManagerPaneButton"..i.."BgMiddle"]:Hide()
				_G["PaperDollEquipmentManagerPaneButton"..i.."BgBottom"]:SetAlpha(0)

				bu.HighlightBar:SetColorTexture(r, g, b, .1)
				bu.HighlightBar:SetDrawLayer("BACKGROUND")
				bu.SelectedBar:SetColorTexture(r, g, b, .2)
				bu.SelectedBar:SetDrawLayer("BACKGROUND")

				bd:Hide()
				bd.Show = F.Dummy
				ic:SetTexCoord(unpack(C.TexCoord))

				F.CreateBG(ic)
			end
			sets = true
		end
	end)

	local titles = false
	hooksecurefunc("PaperDollTitlesPane_Update", function()
		if titles == false then
			for i = 1, 17 do
				_G["PaperDollTitlesPaneButton"..i]:DisableDrawLayer("BACKGROUND")
			end
			titles = true
		end
	end)

	hooksecurefunc("PaperDollFrame_SetLevel", function()
		local primaryTalentTree = GetSpecialization()
		local classDisplayName, class = UnitClass("player")
		local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or C.ClassColors[class]
		local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
		local specName, _

		if primaryTalentTree then
			_, specName = GetSpecializationInfo(primaryTalentTree, nil, nil, nil, UnitSex("player"))
		end

		if specName and specName ~= "" then
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel("player"), classColorString, specName, classDisplayName)
		else
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, UnitLevel("player"), classColorString, classDisplayName)
		end
	end)

	PaperDollEquipmentManagerPaneEquipSet:SetWidth(PaperDollEquipmentManagerPaneEquipSet:GetWidth()-1)
	PaperDollEquipmentManagerPaneSaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 1, 0)
	GearManagerDialogPopup:SetPoint("LEFT", PaperDollFrame, "RIGHT", 1, 0)
end)