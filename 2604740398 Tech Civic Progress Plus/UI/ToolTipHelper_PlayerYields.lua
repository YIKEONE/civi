-- ===========================================================================
-- Shared code to get the tool tip for the local player's gold.
--
-- May want to merge this with ToolTipHelper, though it that file is quite large
-- and the files that currently need the yields tool tip don't require all that
-- extra baggge.
-- ===========================================================================

-- ===========================================================================
function GetExtendedGoldTooltip()
	local szReturnValue = "";

	local localPlayerID = Game.GetLocalPlayer();
	if (localPlayerID ~= -1) then
		local playerTreasury:table	= Players[localPlayerID]:GetTreasury();
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_NET", playerTreasury:GetGoldYield() - playerTreasury:GetTotalMaintenance());
		szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE]";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_GROSS", playerTreasury:GetGoldYield());
		szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE]";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_COSTS", playerTreasury:GetTotalMaintenance());
		szReturnValue = szReturnValue .. "[NEWLINE]  ";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_COSTS_BUILDINGS", playerTreasury:GetBuildingMaintenance());
		szReturnValue = szReturnValue .. "[NEWLINE]  ";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_COSTS_DISTRICTS", playerTreasury:GetDistrictMaintenance());
		szReturnValue = szReturnValue .. "[NEWLINE]  ";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_COSTS_UNITS", playerTreasury:GetUnitMaintenance());
		szReturnValue = szReturnValue .. "[NEWLINE]  ";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_COSTS_WMDS", playerTreasury:GetWMDMaintenance());
		szReturnValue = szReturnValue .. "[NEWLINE]  ";
		local inferredSiphonFundsAmount = playerTreasury:GetTotalMaintenance() - playerTreasury:GetBuildingMaintenance() - playerTreasury:GetDistrictMaintenance() - playerTreasury:GetUnitMaintenance() - playerTreasury:GetWMDMaintenance();
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD_TOOLTIP_COSTS_HOSTILE_SPIES", inferredSiphonFundsAmount);
	end
	return szReturnValue;
end

-- ===========================================================================
function GetGoldTooltip()
	local szReturnValue = "";

	local localPlayerID = Game.GetLocalPlayer();
	if (localPlayerID ~= -1) then
		local playerTreasury:table	= Players[localPlayerID]:GetTreasury();

		local income_tt_details = playerTreasury:GetGoldYieldToolTip();
		local expense_tt_details = playerTreasury:GetTotalMaintenanceToolTip();

		szReturnValue = Locale.Lookup("LOC_TOP_PANEL_GOLD_YIELD");
		szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE]";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_INCOME", playerTreasury:GetGoldYield());
		if(#income_tt_details > 0) then
			szReturnValue = szReturnValue .. "[NEWLINE]" .. income_tt_details;
		end

		szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE]";
		szReturnValue = szReturnValue .. Locale.Lookup("LOC_TOP_PANEL_GOLD_EXPENSE", -playerTreasury:GetTotalMaintenance());
		if(#expense_tt_details > 0) then
			szReturnValue = szReturnValue .. "[NEWLINE]" .. expense_tt_details;
		end
	end
	return szReturnValue;
end

localTurnTech = 0
localCurTech = -1
localCurTechProgress = -1
localTurnTechComputed = false

-- ===========================================================================
function GetScienceTooltip()
	local szReturnValue = "";

	local localPlayerID = Game.GetLocalPlayer();
	if (localPlayerID ~= -1) then
		local playerTechnology		:table	= Players[localPlayerID]:GetTechs();
		local currentScienceYield	:number = playerTechnology:GetScienceYield();

		szReturnValue = Locale.Lookup("LOC_TOP_PANEL_SCIENCE_YIELD");
		local science_tt_details = playerTechnology:GetScienceYieldToolTip();
		if(#science_tt_details > 0) then
			szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE]" .. science_tt_details;

			pPlayerTechs = Players[localPlayerID]:GetTechs()
			local scienceYield = pPlayerTechs:GetScienceYield()
			if scienceYield > 0 then

                curTech = pPlayerTechs:GetResearchingTech()
                curProgress = -1
                if curTech then
                    curProgress = pPlayerTechs:GetResearchProgress(curTech)
                end

                if localTurnTech < Game.GetCurrentGameTurn() then
                    localTurnTech = Game.GetCurrentGameTurn()
                    localTurnTechComputed = false
                    localCurTech = curTech
                    localCurTechProgress = curProgress
                elseif (curTech ~= localCurTech or curProgress ~= localCurTechProgress) and (not localTurnTechComputed) then
                    localTurnTechComputed = true
                    ExposedMembers.TechCivicProgress.GetTechOverflow()
                end

                overflow = ExposedMembers.TechCivicProgress.overflow_tech

                local yield_icon;
                local yield_name;
                local yield = GameInfo.Yields["YIELD_SCIENCE"];
                if yield then
                    yield_name = yield.Name;
                    yield_icon = yield.IconString;
                end
                szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE] " ..
                    Locale.Lookup("LOC_RESEARCH_OVERFLOW") ..
                    Locale.Lookup(" {1_Overflow} {2_Icon} {3_Name}", string.format("%.1f", overflow), yield_icon, yield_name)
			end
		end
	end
	return szReturnValue;
end

localTurnCivic = 0
localCurCivic = -1
localCurCivicProgress = -1
localTurnCivicComputed = false

-- ===========================================================================
function GetCultureTooltip()
	local szReturnValue = "";

	local localPlayerID = Game.GetLocalPlayer();
	if (localPlayerID ~= -1) then
		local playerCulture			:table	= Players[localPlayerID]:GetCulture();
		local currentCultureYield	:number = playerCulture:GetCultureYield();

		szReturnValue = Locale.Lookup("LOC_TOP_PANEL_CULTURE_YIELD");
		local culture_tt_details = playerCulture:GetCultureYieldToolTip();
		if(#culture_tt_details > 0) then
            szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE]" .. culture_tt_details;

            -- if currentCultureYield > 0 then
            --     curCivic = playerCulture:GetProgressingCivic()
            --     curProgress = -1
            --     if curCivic then
            --         curProgress = playerCulture:GetCulturalProgress(curCivic)
            --     end

            --     if localTurnCivic < Game.GetCurrentGameTurn() then
            --         localTurnCivic = Game.GetCurrentGameTurn()
            --         localTurnCivicComputed = false
            --         localCurCivic = curCivic
            --         localCurCivicProgress = curProgress
            --     elseif (curCivic ~= localCurCivic or curProgress ~= localCurCivicProgress) and (not localTurnCivicComputed) then
            --         ExposedMembers.TechCivicProgress.GetCivicOverflow()
            --         overflow = ExposedMembers.TechCivicProgress.overflow_civic
            --         if overflow then
            --             localTurnCivicComputed = true
            --         end
            --     end

            --     overflow = ExposedMembers.TechCivicProgress.overflow_civic

            --     if overflow then
            --         local yield_icon;
            --         local yield_name;
            --         local yield = GameInfo.Yields["YIELD_CULTURE"];
            --         if yield then
            --             yield_name = yield.Name;
            --             yield_icon = yield.IconString;
            --         end
            --         szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE] " ..
            --             Locale.Lookup("LOC_CULTURE_OVERFLOW") ..
            --             Locale.Lookup(" {1_Overflow} {2_Icon} {3_Name}", string.format("%.1f", overflow), yield_icon, yield_name)
            --     else
            --         szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE] " ..
            --             Locale.Lookup("LOC_CULTURE_OVERFLOW_UNKNOWN")
            --     end
            -- end
		end
	end
	return szReturnValue;
end

-- ===========================================================================
function GetFaithTooltip()
	local szReturnValue = "";

	local localPlayerID = Game.GetLocalPlayer();
	if (localPlayerID ~= -1) then
		local playerReligion		:table	= Players[localPlayerID]:GetReligion();
		local faithYield			:number = playerReligion:GetFaithYield();
		local faithBalance			:number = playerReligion:GetFaithBalance();

		szReturnValue = Locale.Lookup("LOC_TOP_PANEL_FAITH_YIELD");
		local faith_tt_details = playerReligion:GetFaithYieldToolTip();
		if(#faith_tt_details > 0) then
			szReturnValue = szReturnValue .. "[NEWLINE][NEWLINE]" .. faith_tt_details;
		end
	end
	return szReturnValue;
end

function GetCivicProgress(civicId)
    local localPlayerID = Game.GetLocalPlayer();
    if (localPlayerID ~= -1) then
        local playerCulture			:table	= Players[localPlayerID]:GetCulture();
        return playerCulture:GetCulturalProgress(civicId)
    end
    return nil
end

function GetCivicQueue()
    local localPlayerID = Game.GetLocalPlayer();
    if (localPlayerID ~= -1) then
        local playerCulture			:table	= Players[localPlayerID]:GetCulture();
        return playerCulture:GetCivicQueue()
    end
    return nil
end

ExposedMembers.TechCivicProgress.GetCivicProgress = GetCivicProgress
ExposedMembers.TechCivicProgress.GetCivicQueue = GetCivicQueue
