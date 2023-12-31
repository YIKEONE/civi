GoodyHutHelper = {};

local m_PendingGoodyHut = nil;

GoodyHutHelper.GetPending = function()
    return m_PendingGoodyHut;
end

GoodyHutHelper.Reset = function()
    m_PendingGoodyHut = nil;
end

function OnUnitTriggerGoodyHut(playerId:number, unitId:number, goodyHutType:number)
    local unit:object = UnitManager.GetUnit(playerId, unitId);
    if unit ~= nil then
        local row = GameInfo.GoodyHutSubTypes[goodyHutType];
        if row ~= nil then
            m_PendingGoodyHut = {
                Time = Automation.GetTime(),
                PlayerId = playerId,
                PlotX = unit:GetX(),
                PlotY = unit:GetY(),
                SubType = row.SubTypeGoodyHut
            };
        end
    end
end

function ARGH_Initialize()
    GameEvents.UnitTriggerGoodyHut.Add(OnUnitTriggerGoodyHut);
end
ARGH_Initialize();

ExposedMembers.ARGH = ExposedMembers.ARGH or {};
ExposedMembers.ARGH.GoodyHutHelper = GoodyHutHelper;