-- ChoosableGoodyHuts
-- Author: Konomi
-- DateCreated: 7/24/2023 11:48:49
--------------------------------------------------------------

-- ===========================================================================
--	MEMBERS
-- ===========================================================================
local GAME_SPEED = GameConfiguration.GetGameSpeedType()
local GAME_SPEED_MULTIPLIER = GameInfo.GameSpeeds[GAME_SPEED].CostMultiplier

local m_ChooseResult = nil
local m_UnitID = nil
local m_X, m_Y = nil, nil

local m_IsAutoRecordModActive = Modding.IsModActive("185e05a2-c6ac-4e09-b257-2bdb1f3714cd")
local m_ModifierAmountCache = {};

local m_IsDoubleGoodyModActive = Modding.IsModActive("0d252723-1f9f-441c-a447-0c866a55d9bf")
local m_IsDouble = false;
-- ===========================================================================
function IsMinOneCity(playerID)
	if Players[playerID] == nil then
		return false
	end
	return Players[playerID]:GetCities():GetCount() > 0
end
-- ===========================================================================
function GetModifierAmount(modifierId)
    local amount = m_ModifierAmountCache[modifierId];
    if amount ~= nil then
        return amount;
    end
    for row in GameInfo.ModifierArguments() do
        if row.ModifierId == modifierId and row.Name == "Amount" then
            local rawValue = row.Value or 0;
            amount = math.floor(rawValue * GAME_SPEED_MULTIPLIER / 100);
            -- Cache it.
            m_ModifierAmountCache[modifierId] = amount;
        end
    end
    return amount;
end
-- ===========================================================================
function OnOKButton()
	if m_ChooseResult == nil or m_ChooseResult.Index == -1 then
		return
	end
	local kParameters:table = {
		OnStart = 'KnmChooseGoody',
		UnitID = m_UnitID,
		RequiresUnit = m_ChooseResult.RequiresUnit,
		ModifierID = m_ChooseResult.ModifierID,
		SubType = m_ChooseResult.SubType,
	}
	
	if m_IsDoubleGoodyModActive and not m_IsDouble then
		kParameters.Double = true
		kParameters.X = m_X
		kParameters.Y = m_Y
	end

	UI.RequestPlayerOperation(Game.GetLocalPlayer(), PlayerOperations.EXECUTE_SCRIPT, kParameters)
	LuaEvents.ChoosableGoodyHuts_Dismiss()
	Close()

	if m_IsAutoRecordModActive then
		local playerID = Game.GetLocalPlayer()
		local pPlayerCfg = PlayerConfigurations[playerID]
		local pMapPin = pPlayerCfg:GetMapPin(m_X, m_Y)
		if pMapPin then
			local infoText = Locale.Lookup("LOC_GAMESUMMARY_UNKNOWN")

			-- Type GOODYHUT_CULTURE
			if m_ChooseResult.ModifierID == "GOODY_CULTURE_GRANT_ONE_RELIC" then
				infoText = "[ICON_GreatWork_Relic]" .. Locale.Lookup("LOC_GREAT_WORK_OBJECT_RELIC_NAME");
			elseif m_ChooseResult.ModifierID == "GOODY_CULTURE_GRANT_TWO_CIVIC_BOOSTS" then
				infoText = Locale.Lookup("LOC_KNM_CHOOSE_GOODYHUT_TWO_CIVIC_BOOSTS");
			elseif m_ChooseResult.ModifierID == "GOODY_CULTURE_GRANT_ONE_CIVIC_BOOST" then
				infoText = Locale.Lookup("LOC_KNM_CHOOSE_GOODYHUT_ONE_CIVIC_BOOST");
			elseif m_ChooseResult.ModifierID == "SAILOR_GOODY_CULTURE_GRANT_ONE_CIVIC" then
				infoText = Locale.Lookup("LOC_KNM_CHOOSE_GOODYHUT_SAILOR_ONE_CIVIC");
			-- Type GOODYHUT_GOLD
			elseif m_ChooseResult.ModifierID == "GOODY_GOLD_LARGE_MODIFIER" 
				or m_ChooseResult.ModifierID == "GOODY_GOLD_MEDIUM_MODIFIER" 
				or m_ChooseResult.ModifierID == "GOODY_GOLD_SMALL_MODIFIER" then
					local amount = GetModifierAmount(m_ChooseResult.ModifierID);
					infoText = amount .. "[ICON_Gold]";
			-- Type GOODYHUT_FAITH
			elseif m_ChooseResult.ModifierID == "GOODY_FAITH_LARGE_MODIFIER" 
				or m_ChooseResult.ModifierID == "GOODY_FAITH_MEDIUM_MODIFIER" 
				or m_ChooseResult.ModifierID == "GOODY_FAITH_SMALL_MODIFIER" then
					local amount = GetModifierAmount(m_ChooseResult.ModifierID);
					infoText = amount .. "[ICON_Faith]";
			-- Type GOODYHUT_MILITARY
			elseif m_ChooseResult.ModifierID == "GOODY_MILITARY_GRANT_SCOUT" then
				infoText = Locale.Lookup("LOC_UNIT_SCOUT_NAME");
			--elseif m_ChooseResult.SubType == "GOODY_MILITARY_GRANT_UPGRADE" then
				--infoText = Locale.Lookup("LOC_UNITOPERATION_UPGRADE_DESCRIPTION");
			elseif m_ChooseResult.ModifierID == "GOODY_MILITARY_GRANT_EXPERIENCE" then
				infoText = Locale.Lookup("LOC_HUD_UNIT_PANEL_XP");
			elseif m_ChooseResult.ModifierID == "GOODY_MILITARY_HEAL" then
				infoText = Locale.Lookup("LOC_TECH_FILTER_HEALTH"); -- Not ideal but ok.
			-- Type GOODYHUT_SCIENCE
			elseif m_ChooseResult.ModifierID == "GOODY_SCIENCE_GRANT_ONE_TECH" then
				infoText = Locale.Lookup("LOC_KNM_CHOOSE_GOODYHUT_ONE_TECH");
			elseif m_ChooseResult.ModifierID == "GOODY_SCIENCE_GRANT_TWO_TECH_BOOSTS" then
				infoText = Locale.Lookup("LOC_KNM_CHOOSE_GOODYHUT_TWO_TECH_BOOSTS");
			elseif m_ChooseResult.ModifierID == "GOODY_SCIENCE_GRANT_ONE_TECH_BOOST" then
				infoText = Locale.Lookup("LOC_KNM_CHOOSE_GOODYHUT_ONE_TECH_BOOST");
			-- Type GOODYHUT_SURVIVORS
			elseif m_ChooseResult.ModifierID == "GOODY_SURVIVORS_ADD_POPULATION" then
				infoText = "[ICON_Citizen]" .. Locale.Lookup("LOC_CIVINFO_POPULATION");
			elseif m_ChooseResult.ModifierID == "GOODY_SURVIVORS_GRANT_BUILDER" then
				infoText = Locale.Lookup("LOC_UNIT_BUILDER_NAME");
			elseif m_ChooseResult.ModifierID == "GOODY_SURVIVORS_GRANT_TRADER" then
				infoText = Locale.Lookup("LOC_UNIT_TRADER_NAME");
			elseif m_ChooseResult.ModifierID == "GOODY_SURVIVORS_GRANT_SETTLER" then
				infoText = Locale.Lookup("LOC_UNIT_SETTLER_NAME");
			-- Type GOODYHUT_DIPLOMACY
			elseif m_ChooseResult.ModifierID == "GOODY_DIPLOMACY_GRANT_GOVERNOR_TITLE" then
				infoText = "[Icon_Governor]" .. Locale.Lookup("LOC_ACTION_PANEL_GOVERNOR_OPPORTUNITY");
			elseif m_ChooseResult.ModifierID == "GOODY_DIPLOMACY_GRANT_ENVOY" then
				infoText = "[ICON_Envoy]" .. Locale.Lookup("LOC_ENVOY_NAME");
			elseif m_ChooseResult.ModifierID == "GOODY_DIPLOMACY_GRANT_FAVOR" then
				infoText = "[ICON_Favor]" .. Locale.Lookup("LOC_DIPLOMATIC_FAVOR_NAME");
			elseif m_ChooseResult.ModifierID == "GOODY_MILITARY_ADJUST_STRATEGIC_RESOURCES" then
				infoText = Locale.Lookup("LOC_HUD_REPORTS_STRATEGICS");
			end
			local currentTurn = string.format("%02d", Game.GetCurrentGameTurn());
			pMapPin:SetName("[COLOR_LIGHTBLUE]" .. currentTurn .. "T[ENDCOLOR] " .. Locale.Lookup("LOC_OPTIONS_SELECT") .. ' ' .. infoText);
			pMapPin:SetIconName("ICON_NOTIFICATION_DISCOVER_GOODY_HUT");
			Network.BroadcastPlayerInfo();
		end
	end

	m_ChooseResult = nil
end
-- ===========================================================================
function SetPullDown(targets:table)
	
	--instance.Target:LocalizeAndSetText('LOC_KAMOME_CHOOSE_RESOLUTION_ITEM', index)
	Controls.Pulldown:ClearEntries()

	if m_ChooseResult == nil then
		Controls.Pulldown:GetButton():LocalizeAndSetText('LOC_OPTIONS_SELECT')
		Controls.Pulldown:GetButton():SetToolTipString('')
	else
		Controls.Pulldown:GetButton():SetText(m_ChooseResult.Name)
		Controls.Pulldown:GetButton():SetToolTipString(m_ChooseResult.Description)
	end

	for pulldownIndex, target in ipairs(targets) do
		local entry:table = {};
		Controls.Pulldown:BuildEntry( "PullDownEntry", entry )
		entry.Button:SetVoid1( pulldownIndex )
		entry.Button:SetVoid2( target.Index )
		entry.Button:SetText(target.Name)
		entry.Button:SetToolTipString(target.Description)
	end
	Controls.Pulldown:RegisterSelectionCallback(
		function( pulldownIndex:number, index )
			--print(pulldownIndex, index)
			if index ~= -1 then
				local goodyInfo = targets[pulldownIndex]
				Controls.Pulldown:GetButton():SetText(goodyInfo.Name)
				Controls.Pulldown:GetButton():SetToolTipString(goodyInfo.Description)
				m_ChooseResult = goodyInfo
				Controls.OKButton:SetDisabled(not goodyInfo.Choosable)			
			else
				Controls.Pulldown:GetButton():LocalizeAndSetText('LOC_OPTIONS_SELECT')
				Controls.Pulldown:GetButton():SetToolTipString('')
				m_ChooseResult = nil
				Controls.OKButton:SetDisabled(true)	
			end
		end
	)
	Controls.Pulldown:CalculateInternals()
	
end
-- ===========================================================================
function Refresh(isMinOneCity:boolean, hasUnit:boolean)
	local targets = {}
	for row in GameInfo.GoodyHutSubTypes_Choose() do
		local name = Locale.Lookup('LOC_KNM_CHOOSE_' .. row.SubTypeGoodyHut)
		local desc = Locale.Lookup('LOC_KNM_CHOOSE_' .. row.SubTypeGoodyHut)
		local choosable = true
		if row.MinOneCity and not isMinOneCity then
			desc = desc .. '[NEWLINE][COLOR:Civ6Red]' .. Locale.Lookup('LOC_KNM_CHOOSE_GOODYHUT_DISABLE_CITY') .. '[ENDCOLOR]'
			choosable = false
		end
		if row.RequiresUnit and not hasUnit then
			desc = desc .. '[NEWLINE][COLOR:Civ6Red]' .. Locale.Lookup('LOC_KNM_CHOOSE_GOODYHUT_DISABLE_UNIT') .. '[ENDCOLOR]'
			choosable = false
		end
		if row.Turn > 0 and Game:GetCurrentGameTurn() < math.floor(row.Turn * GAME_SPEED_MULTIPLIER / 100) then
			desc = desc .. '[NEWLINE][COLOR:Civ6Red]' .. Locale.Lookup('LOC_KNM_CHOOSE_GOODYHUT_DISABLE_TURN', math.floor(row.Turn * GAME_SPEED_MULTIPLIER / 100)) .. '[ENDCOLOR]'
			choosable = false
		end
		if not choosable then
			name = name .. ' [COLOR:Civ6Red]' .. Locale.Lookup('LOC_KNM_CHOOSE_GOODYHUT_DISABLE') .. '[ENDCOLOR]'
		end
		table.insert(targets, {
			SubType = row.SubTypeGoodyHut,
			Name = name,
			Index = row.Index,
			Description = desc,
			Turn = row.Turn,
			ModifierID = row.ModifierID,
			Choosable = choosable,
			Sort = choosable and 0 or 1,
			RequiresUnit = row.RequiresUnit,
		})
	end
	table.sort(targets, function(a, b)
		return a.Sort < b.Sort
	end)
	
	table.insert(targets, 1, {
		Name = Locale.Lookup('LOC_OPTIONS_SELECT'),
		Index = -1,
		Description = '',
		Turn = -1,
		Choosable = false,
		Sort = -1
	})
	SetPullDown(targets)

	if not Players[Game.GetLocalPlayer()]:IsTurnActive() or m_ChooseResult == nil or m_ChooseResult.Index == -1 then
		Controls.OKButton:SetDisabled(true)
	else
		Controls.OKButton:SetDisabled(false)
	end
end

-- ===========================================================================
function Open(unitID, x, y, double)
	--UIManager:QueuePopup(ContextPtr, PopupPriority.Low);
	local isMinOneCity = IsMinOneCity(Game.GetLocalPlayer())
	local hasUnit = UnitManager.GetUnit(Game.GetLocalPlayer(), unitID) ~= nil
	m_UnitID = unitID
	m_X = x
	m_Y = y
	m_IsDouble = double
	Refresh(isMinOneCity, hasUnit)
	if not UIManager:IsInPopupQueue(ContextPtr) then
		-- Queue the screen as a popup, but we want it to render at a desired location in the hierarchy, not on top of everything.
		local kParameters = {};
		kParameters.RenderAtCurrentParent = true;
		kParameters.InputAtCurrentParent = true;
		kParameters.AlwaysVisibleInQueue = true;
		UIManager:QueuePopup(ContextPtr, PopupPriority.Low);
		UI.PlaySound("UI_Screen_Open");
	end

	-- From Civ6_styles: FullScreenVignetteConsumer
	Controls.ScreenAnimIn:SetToBeginning();
	Controls.ScreenAnimIn:Play();
end

-- ===========================================================================
function Close()
	if UIManager:DequeuePopup(ContextPtr) then
		UI.PlaySound("UI_Screen_Close");
	end
end
-- ===========================================================================
function OnInputHandler( pInputStruct:table )
	local uiMsg :number = pInputStruct:GetMessageType();
	if uiMsg == KeyEvents.KeyUp and pInputStruct:GetKey() == Keys.VK_ESCAPE then
		Close();
		return true;
	end
	return false;
end

-- ===========================================================================
function OnInit(isReload:boolean)
	LateInitialize();
end

-- ===========================================================================
function UpdateEffectsContainerSize()
	local newSizeY:number = Controls.ImageDescStack:GetSizeY();
	Controls.EventEffectsContainer:SetSizeY(Controls.MainContainer:GetSizeY() - newSizeY - 10);
end

-- ===========================================================================
function Subscribe()
	LuaEvents.NotificationPanel_ChooseGoodyHut.Add(Open)
end

-- ===========================================================================
function Unsubscribe()
	LuaEvents.NotificationPanel_ChooseGoodyHut.Remove(Open)
end

-- ===========================================================================
function OnShutdown()
	Unsubscribe();
end

-- ===========================================================================
function LateInitialize()
	Subscribe();
end

-- ===========================================================================
function Initialize()
	ContextPtr:SetInitHandler( OnInit );
	ContextPtr:SetInputHandler( OnInputHandler, true );
	ContextPtr:SetShutdown( OnShutdown );

	Controls.OKButton:RegisterCallback( Mouse.eLClick, OnOKButton )
	Controls.ContinueButton:RegisterCallback( Mouse.eLClick, Close )
	Controls.ScreenConsumer:RegisterCallback( Mouse.eRClick, Close )
end
Initialize();
