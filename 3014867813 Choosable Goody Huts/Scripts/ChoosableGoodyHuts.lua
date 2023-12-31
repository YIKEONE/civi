-- ChoosableGoodyHuts
-- Author: Konomi
-- DateCreated: 7/29/2023 00:39:30
--------------------------------------------------------------

--local GOODY_DUMMY_HASH	:number = DB.MakeHash('GOODYHUT_KNM_DUMMY');
local METEOR_GOODIES_HASH	:number = DB.MakeHash('METEOR_GOODIES');
local KEY_CGH_GOODY = 'CGH_GOODY'

local m_ImprovementGoodyInfo = GameInfo.Improvements['IMPROVEMENT_GOODY_HUT']
local m_RewardNotificationInfo = GameInfo.Notifications['NOTIFICATION_KNM_CHOOSE_GOODYHUT']

local m_PlayerID = nil
local m_UnitID = nil
local m_X, m_Y = nil, nil
local m_GoodyHuts = {}
-- ===========================================================================
function KnmChooseGoody(playerID:number, params:table)
	--print('KnmChooseGoody', params.UnitID, params.RequiresUnit, params.SubType, params.ModifierID)
	if Players[playerID] then
		if params.RequiresUnit then
			local pUnit = UnitManager.GetUnit(playerID, params.UnitID)
			if pUnit then
				local ability = 'ABILITY_KNM_CHOOSE_' .. params.SubType
				pUnit:GetAbility():ChangeAbilityCount(ability, 1)
				pUnit:GetAbility():ChangeAbilityCount(ability, -1)
			end
		else
			Players[playerID]:AttachModifierByID(params.ModifierID)
		end
		if params.Double and m_RewardNotificationInfo then
			local notificationData = {}
			notificationData[ParameterTypes.MESSAGE] = Locale.Lookup(m_RewardNotificationInfo.Message)
			notificationData[ParameterTypes.SUMMARY] = Locale.Lookup(m_RewardNotificationInfo.Summary)
			notificationData[ParameterTypes.LOCATION] = { x = params.X, y = params.Y }
			notificationData.UnitID = params.UnitID
			notificationData.Double = true
			NotificationManager.SendNotification(playerID, m_RewardNotificationInfo.Hash, notificationData)	
		end
	end
end
-- ===========================================================================
function InitializeData()
	if m_ImprovementGoodyInfo == nil then
		return
	end
	m_GoodyHuts = {}
	local mapWidth, mapHeight = Map.GetGridSize()
	for i = 0, mapWidth * mapHeight - 1, 1 do
		local pPlot = Map.GetPlotByIndex(i)
		if pPlot:GetImprovementType() == m_ImprovementGoodyInfo.Index then
			m_GoodyHuts[i] = -1
		end
	end
	Game:SetProperty(KEY_CGH_GOODY, m_GoodyHuts)
end
-- ===========================================================================
function GetGoodyHuts()
	m_GoodyHuts = Game:GetProperty(KEY_CGH_GOODY)
	if m_GoodyHuts == nil then
		InitializeData()
	end
end
-- ===========================================================================
function TrySendNotification()
	--print('TrySendNotification', m_PlayerID, m_UnitID, m_X, m_Y)
	if m_PlayerID ~= nil and m_UnitID ~= nil and m_X ~= nil and m_Y ~= nil then
		local pPlayer = Players[m_PlayerID]
		local pUnit = UnitManager.GetUnit(m_PlayerID, m_UnitID)
		if pPlayer then
			if pPlayer:IsHuman() and m_RewardNotificationInfo then
				local notificationData = {}
				notificationData[ParameterTypes.MESSAGE] = Locale.Lookup(m_RewardNotificationInfo.Message)
				notificationData[ParameterTypes.SUMMARY] = Locale.Lookup(m_RewardNotificationInfo.Summary)
				notificationData[ParameterTypes.LOCATION] = { x = m_X, y = m_Y }
				if pUnit then
					notificationData.UnitID = m_UnitID
				end
				NotificationManager.SendNotification(m_PlayerID, m_RewardNotificationInfo.Hash, notificationData)
			end
			m_PlayerID, m_UnitID = nil, nil
			m_X, m_Y = nil, nil
		end
	end
end
-- ===========================================================================
function OnGoodyHutReward(playerID:number, unitID:number, goodyHash:number, subGoodyHash:number)
	--print('OnGoodyHutReward', playerID, unitID, goodyHash, subGoodyHash, Game:GetCurrentGameTurn())
	if subGoodyHash ~= METEOR_GOODIES_HASH then
		--m_OnGoodyHutReward = true
		m_PlayerID = playerID
		m_UnitID = unitID
		TrySendNotification()
	end
end
-- ===========================================================================
function OnImprovementAddedToMap(iX:number, iY:number, eImprovement:number, playerID:number, a, b)
	--print('OnImprovementAddedToMap', iX, iY, eImprovement, playerID, a, b)
	if m_ImprovementGoodyInfo and m_ImprovementGoodyInfo.Index == eImprovement then
		local pPlot = Map.GetPlot(iX, iY)
		m_GoodyHuts[pPlot:GetIndex()] = playerID
		Game:SetProperty(KEY_CGH_GOODY, m_GoodyHuts)
	end
end
-- ===========================================================================
function OnImprovementRemovedFromMap(iX:number, iY:number, eOwner:number, a, b)
	--print('OnImprovementRemovedFromMap', iX, iY, eOwner, a, b)
	local pPlot = Map.GetPlot(iX, iY)
	if m_GoodyHuts[pPlot:GetIndex()] ~= nil then
		if eOwner ~= -1 then
			m_PlayerID = eOwner
		end
		m_X, m_Y = iX, iY
		m_GoodyHuts[pPlot:GetIndex()] = nil
		Game:SetProperty(KEY_CGH_GOODY, m_GoodyHuts)
		TrySendNotification()
	end
end
-- ===========================================================================
function Initialize()
	GameEvents.KnmChooseGoody.Add(KnmChooseGoody)
	Events.ImprovementAddedToMap.Add(OnImprovementAddedToMap)
	Events.GoodyHutReward.Add(OnGoodyHutReward)
	Events.ImprovementRemovedFromMap.Add(OnImprovementRemovedFromMap)

	GetGoodyHuts()
end
-- ===========================================================================
Events.LoadGameViewStateDone.Add(Initialize)
