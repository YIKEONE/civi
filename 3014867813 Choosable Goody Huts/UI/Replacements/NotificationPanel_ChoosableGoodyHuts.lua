-- NotificationPanel_ChoosableGoodyHuts
-- Author: Konomi
-- DateCreated: 7/29/2023 1:07:21
--------------------------------------------------------------

-- ===========================================================================
-- CACHE BASE FUNCTIONS
-- ===========================================================================
local BASE_RegisterHandlers = RegisterHandlers;
local BASE_LateInitialize = LateInitialize;

local m_RewardNotificationInfo = GameInfo.Notifications['NOTIFICATION_KNM_CHOOSE_GOODYHUT']
local m_NotificationID = -1
-- ===========================================================================
function Dismiss_CGH()
	if m_NotificationID ~= -1 then
		local playerID = Game.GetLocalPlayer()
		NotificationManager.Dismiss(playerID, m_NotificationID)
		m_NotificationID = -1
	end
end
-- ===========================================================================
function OnNotificationAdd_CGH( pNotification:table )
	--print('OnNotificationAdd', pNotification:GetValue('UnitID'), pNotification:GetID())
	OnDefaultAddNotification(pNotification)
	if pNotification and Players[pNotification:GetPlayerID()] and Players[pNotification:GetPlayerID()]:IsTurnActive() then
		local unitID = pNotification:GetValue('UnitID')
		m_NotificationID = pNotification:GetID()
		local x, y = pNotification:GetLocation()
		if x >= 0 and y >= 0 then
			UI.LookAtPlot(x, y)
		end
		LuaEvents.NotificationPanel_ChooseGoodyHut(unitID, x, y, pNotification:GetValue('Double'))
	end
end
-- ===========================================================================
function OnNotificationActivate_CGH( notificationEntry:NotificationType, notificationID:number, activatedByUser:boolean )
	--print('OnNotificationActivate', notificationEntry, notificationID, activatedByUser)
	if notificationEntry and notificationEntry.m_PlayerID == Game.GetLocalPlayer() then
		local pNotification:table = GetActiveNotificationFromEntry(notificationEntry, notificationID)
		if pNotification then
			local unitID = pNotification:GetValue('UnitID')
			m_NotificationID = notificationID
			local x, y = pNotification:GetLocation()
			if x >= 0 and y >= 0 then
				UI.LookAtPlot(x, y)
			end
			LuaEvents.NotificationPanel_ChooseGoodyHut(unitID, x, y, pNotification:GetValue('Double'))
		end
	end
end
-- ===========================================================================
function RegisterHandlers()

	BASE_RegisterHandlers();

	if m_RewardNotificationInfo then
		local hash = m_RewardNotificationInfo.Hash
		g_notificationHandlers[hash]						= MakeDefaultHandlers();
		g_notificationHandlers[hash].Add					= OnNotificationAdd_CGH;
		g_notificationHandlers[hash].Activate				= OnNotificationActivate_CGH;
		g_notificationHandlers[hash].AddSound				= "ALERT_POSITIVE";
		g_notificationHandlers[hash].TryDismiss				= function() return; end;
	end
end
-- ===========================================================================
function LateInitialize()
	BASE_LateInitialize();

	LuaEvents.ChoosableGoodyHuts_Dismiss.Add(Dismiss_CGH);
end
