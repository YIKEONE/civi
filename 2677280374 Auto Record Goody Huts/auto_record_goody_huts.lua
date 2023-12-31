ExposedMembers.ARGH = ExposedMembers.ARGH or {};
local GoodyHutHelper = ExposedMembers.ARGH.GoodyHutHelper;

g_IsXP1Active = Modding.IsModActive("1B28771A-C749-434B-9053-D1380C553DE9");

local firstCivicBoosted = nil;
local firstTechBoosted = nil;
local pendingText = nil;
local overrideIcon = nil;

local m_ModifierAmountCache = {};

function PlaceMapPin(hut, infoText)
    local playerCfg = PlayerConfigurations[hut.PlayerId];
    local mapPin = playerCfg:GetMapPin(hut.PlotX, hut.PlotY);
    if mapPin ~= nil then
        local mapPinCfg = playerCfg:GetMapPinID(mapPin:GetID());
        if mapPinCfg:GetIconName() == "ICON_MAP_PIN_TRIANGLE" or mapPinCfg:GetIconName() == "ICON_NOTIFICATION_DISCOVER_GOODY_HUT" then
            local currentTurn = string.format("%02d", Game.GetCurrentGameTurn());
            mapPinCfg:SetName("[COLOR_LIGHTBLUE]" .. currentTurn .. "T[ENDCOLOR] " .. infoText);
            mapPinCfg:SetIconName(overrideIcon or "ICON_NOTIFICATION_DISCOVER_GOODY_HUT");
            Network.BroadcastPlayerInfo();
        end
    end
    -- Reset after adding pin.
    firstCivicBoosted = nil;
    firstTechBoosted = nil;
    pendingText = nil;
    overrideIcon = nil;
    GoodyHutHelper.Reset();
end

function GetModifierAmount(modifierId)
    local amount = m_ModifierAmountCache[modifierId];
    if amount ~= nil then
        return amount;
    end
    for row in GameInfo.ModifierArguments() do
        if row.ModifierId == modifierId and row.Name == "Amount" then
            local rawValue = row.Value or 0;
            local gameSpeed = GameConfiguration.GetGameSpeedType();
            local costMultiplier = GameInfo.GameSpeeds[gameSpeed].CostMultiplier;
            amount = math.floor(rawValue * costMultiplier / 100);
            -- Cache it.
            m_ModifierAmountCache[modifierId] = amount;
        end
    end
    return amount;
end

-- GOODY_CULTURE_GRANT_ONE_CIVIC_BOOST
-- GOODY_CULTURE_GRANT_TWO_CIVIC_BOOSTS
function OnCivicBoostTriggered(playerId, boostedCivic)
    if playerId ~= Game.GetLocalPlayer() then
        return;
    end
    local pendingHut = GoodyHutHelper.GetPending();
    if pendingHut ~= nil then
        local modifierId = GameInfo.GoodyHutSubTypes[pendingHut.SubType].ModifierID;
        if modifierId == "GOODY_CULTURE_GRANT_ONE_CIVIC_BOOST" then
            local civicName = GameInfo.Civics[boostedCivic].Name;
            pendingText = "[ICON_CivicBoosted]" .. Locale.Lookup(civicName);
        elseif modifierId == "GOODY_CULTURE_GRANT_TWO_CIVIC_BOOSTS" then
            local civicName = GameInfo.Civics[boostedCivic].Name;
            if firstCivicBoosted == nil then
                firstCivicBoosted = boostedCivic;
                pendingText = "[ICON_CivicBoosted]" .. Locale.Lookup(civicName);
            else
                pendingText = pendingText .. "&" .. Locale.Lookup(civicName);
                firstCivicBoosted = nil;
            end
        end
    end
end

-- GOODY_SCIENCE_GRANT_ONE_TECH_BOOST
-- GOODY_SCIENCE_GRANT_TWO_TECH_BOOSTS
function OnTechBoostTriggered(playerId, boostedTech)
    if playerId ~= Game.GetLocalPlayer() then
        return;
    end
    local pendingHut = GoodyHutHelper.GetPending();
    if pendingHut ~= nil then
        local modifierId = GameInfo.GoodyHutSubTypes[pendingHut.SubType].ModifierID;
        if modifierId == "GOODY_SCIENCE_GRANT_ONE_TECH_BOOST" then
            local techName = GameInfo.Technologies[boostedTech].Name;
            pendingText = "[ICON_TechBoosted]" .. Locale.Lookup(techName);
        elseif modifierId == "GOODY_SCIENCE_GRANT_TWO_TECH_BOOSTS" then
            local techName = GameInfo.Technologies[boostedTech].Name;
            if firstTechBoosted == nil then
                firstTechBoosted = boostedTech;
                pendingText = "[ICON_TechBoosted]" .. Locale.Lookup(techName);
            else
                pendingText = pendingText .. "&" .. Locale.Lookup(techName);
                firstTechBoosted = nil;
            end
        end
    end
end

-- GOODY_SCIENCE_GRANT_ONE_TECH
function OnResearchCompleted(playerId, techIndex)
    if playerId ~= Game.GetLocalPlayer() then
        return;
    end
    local pendingHut = GoodyHutHelper.GetPending();
    if pendingHut ~= nil then
        local modifierId = GameInfo.GoodyHutSubTypes[pendingHut.SubType].ModifierID;
        if modifierId == "GOODY_SCIENCE_GRANT_ONE_TECH" then
            local techName = GameInfo.Technologies[techIndex].Name;
            pendingText = Locale.Lookup(techName);
        end
    end
end

-- GOODY_MILITARY_ADJUST_STRATEGIC_RESOURCES
function OnPlayerResourceChanged(playerId, resourceId)
    if playerId ~= Game.GetLocalPlayer() then
        return;
    end
    local pendingHut = GoodyHutHelper.GetPending();
    if pendingHut ~= nil then
        local modifierId = GameInfo.GoodyHutSubTypes[pendingHut.SubType].ModifierID;
        if modifierId == "GOODY_MILITARY_ADJUST_STRATEGIC_RESOURCES" then
            local resourceName = GameInfo.Resources[resourceId].Name;
            local amount = GetModifierAmount(modifierId);
            pendingText = amount .. Locale.Lookup(resourceName);
        end
    end
end

-- GOODY_METEOR_FREE_UNIT
function OnUnitAddedToMap(playerId, unitId)
    if playerId ~= Game.GetLocalPlayer() then
        return;
    end
    local pendingHut = GoodyHutHelper.GetPending();
    if pendingHut ~= nil then
        local modifierId = GameInfo.GoodyHutSubTypes[pendingHut.SubType].ModifierID;
        if modifierId == "GOODY_METEOR_FREE_UNIT" then
            local unit = UnitManager.GetUnit(playerId, unitId);
            pendingText = Locale.Lookup(GameInfo.Units[unit:GetType()].Name);
            if g_IsXP1Active then
                overrideIcon = "ICON_UNITCOMMAND_PARADROP";
            end
        end
    end
end

-- Handle rewards that don't have events.
function OnGoodyHutReward(playerId, unitId, type, subType)
    if playerId ~= Game.GetLocalPlayer() then
        return;
    end
    local pendingHut = GoodyHutHelper.GetPending();
    if pendingHut ~= nil then
        local infoText = pendingText or Locale.Lookup("LOC_GAMESUMMARY_UNKNOWN");
        local modifierId = GameInfo.GoodyHutSubTypes[pendingHut.SubType].ModifierID;
        -- Type GOODYHUT_CULTURE
        if modifierId == "GOODY_CULTURE_GRANT_ONE_RELIC" then
            infoText = "[ICON_GreatWork_Relic]" .. Locale.Lookup("LOC_GREAT_WORK_OBJECT_RELIC_NAME");
        -- Type GOODYHUT_GOLD
        elseif modifierId == "GOODY_GOLD_LARGE_MODIFIER" 
            or modifierId == "GOODY_GOLD_MEDIUM_MODIFIER" 
            or modifierId == "GOODY_GOLD_SMALL_MODIFIER" then
                local amount = GetModifierAmount(modifierId);
                infoText = amount .. "[ICON_Gold]";
        -- Type GOODYHUT_FAITH
        elseif modifierId == "GOODY_FAITH_LARGE_MODIFIER" 
            or modifierId == "GOODY_FAITH_MEDIUM_MODIFIER" 
            or modifierId == "GOODY_FAITH_SMALL_MODIFIER" then
                local amount = GetModifierAmount(modifierId);
                infoText = amount .. "[ICON_Faith]";
        -- Type GOODYHUT_MILITARY
        elseif modifierId == "GOODY_MILITARY_GRANT_SCOUT" then
            infoText = Locale.Lookup("LOC_UNIT_SCOUT_NAME");
        elseif modifierId == "GOODY_MILITARY_GRANT_UPGRADE" then
            infoText = Locale.Lookup("LOC_UNITOPERATION_UPGRADE_DESCRIPTION");
        elseif modifierId == "GOODY_MILITARY_GRANT_EXPERIENCE" then
            infoText = Locale.Lookup("LOC_HUD_UNIT_PANEL_XP");
        elseif modifierId == "GOODY_MILITARY_HEAL" then
            infoText = Locale.Lookup("LOC_TECH_FILTER_HEALTH"); -- Not ideal but ok.
        -- Type GOODYHUT_SURVIVORS
        elseif modifierId == "GOODY_SURVIVORS_ADD_POPULATION" then
            infoText = "[ICON_Citizen]" .. Locale.Lookup("LOC_CIVINFO_POPULATION");
        elseif modifierId == "GOODY_SURVIVORS_GRANT_BUILDER" then
            infoText = Locale.Lookup("LOC_UNIT_BUILDER_NAME");
        elseif modifierId == "GOODY_SURVIVORS_GRANT_TRADER" then
            infoText = Locale.Lookup("LOC_UNIT_TRADER_NAME");
        elseif modifierId == "GOODY_SURVIVORS_GRANT_SETTLER" then
            infoText = Locale.Lookup("LOC_UNIT_SETTLER_NAME");
        -- Type GOODYHUT_DIPLOMACY
        elseif modifierId == "GOODY_DIPLOMACY_GRANT_GOVERNOR_TITLE" then
            infoText = "[Icon_Governor]" .. Locale.Lookup("LOC_ACTION_PANEL_GOVERNOR_OPPORTUNITY");
        elseif modifierId == "GOODY_DIPLOMACY_GRANT_ENVOY" then
            infoText = "[ICON_Envoy]" .. Locale.Lookup("LOC_ENVOY_NAME");
        elseif modifierId == "GOODY_DIPLOMACY_GRANT_FAVOR" then
            infoText = "[ICON_Favor]" .. Locale.Lookup("LOC_DIPLOMATIC_FAVOR_NAME");
        end
        PlaceMapPin(pendingHut, infoText);
    end
end

function ARGH_Initialize()
    Events.CivicBoostTriggered.Add(OnCivicBoostTriggered);
    Events.TechBoostTriggered.Add(OnTechBoostTriggered);
    Events.ResearchCompleted.Add(OnResearchCompleted);
    Events.PlayerResourceChanged.Add(OnPlayerResourceChanged);
    Events.UnitAddedToMap.Add(OnUnitAddedToMap);
    Events.GoodyHutReward.Add(OnGoodyHutReward);
end

ARGH_Initialize();