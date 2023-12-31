include( "InstanceManager" );
include( "SupportFunctions" );

print('loading tech overflow checker')

ExposedMembers.TechCivicProgress = {}

function GetOverflowHelper(playerID, yield, itemId, minV, maxV, is_tech, research_cost)
    if math.abs(maxV - minV) < 0.05 then
        return (maxV + minV) / 2
    end
    if is_tech then
        playerTech = Players[playerID]:GetTechs()
    else
        playerCivic = Players[playerID]:GetCulture()
    end
    cost = (minV + maxV) / 2 + yield
    if is_tech then
        progress = research_cost - cost
        playerTech:SetResearchProgress(itemId, progress)
        turnsLeft = playerTech:GetTurnsToResearch(itemId)
    else
        progress = research_cost - cost
        playerCivic:SetCulturalProgress(itemId, progress)
        turnsLeft = playerCivic:GetTurnsLeftOnCurrentCivic()
    end
    minCand = cost - turnsLeft * yield
    maxCand = cost - (turnsLeft - 1) * yield
    if minCand > minV then
        minV = minCand
    end
    if maxCand < maxV then
        maxV = maxCand
    end
    return GetOverflowHelper(playerID, yield, itemId, minV, maxV, is_tech, research_cost)
end

function GetTechOverflow()
    playerID = Game.GetLocalPlayer()
    playerTech = Players[playerID]:GetTechs()
    local lastTechID = nil
    local scienceYield = playerTech:GetScienceYield()
    local overflow = 0

    for tech in GameInfo.Technologies() do
        local techID	:number = tech.Index;
        if techID and not playerTech:HasTech(techID) then
            lastTechID = techID
        end
    end

    if lastTechID and scienceYield > 0 then
        local savProgress = playerTech:GetResearchProgress(lastTechID)
        local techCost = playerTech:GetResearchCost(lastTechID)

        turnsLeft = playerTech:GetTurnsToResearch(lastTechID)

        while turnsLeft <= 1 do
            playerTech:SetResearchProgress(lastTechID, playerTech:GetResearchProgress(lastTechID) - scienceYield)
            turnsLeft = playerTech:GetTurnsToResearch(lastTechID)
        end

        if turnsLeft > 2 then
            playerTech:SetResearchProgress(lastTechID, playerTech:GetResearchProgress(lastTechID) + (turnsLeft - 2) * scienceYield)
        end

        turnsLeft = playerTech:GetTurnsToResearch(lastTechID)
        cost = playerTech:GetResearchCost(lastTechID) - playerTech:GetResearchProgress(lastTechID)
        min = cost - turnsLeft * scienceYield
        max = cost - (turnsLeft - 1) * scienceYield
        overflow = GetOverflowHelper(playerID, scienceYield, lastTechID, min, max, true, playerTech:GetResearchCost(lastTechID))
        playerTech:SetResearchProgress(lastTechID, savProgress)
    end
    if overflow < 0 then
        overflow = 0
    end
    ExposedMembers.TechCivicProgress.overflow_tech = overflow
end

function GetCivicOverflow()
    playerID = Game.GetLocalPlayer()
    playerCivic = Players[playerID]:GetCulture()

    local lastCivicID = nil
    local yield = playerCivic:GetCultureYield()
    local overflow = 0

    for civic in GameInfo.Civics() do
        local civicID	:number = civic.Index;
        if civicID and not playerCivic:HasCivic(civicID) then
            lastCivicID = civicID
        end
    end

    if lastCivicID and yield > 0 then
        curCivic = playerCivic:GetProgressingCivic()
        curQueue = ExposedMembers.TechCivicProgress.GetCivicQueue()

        local completeCivic = false
        if curCivic == -1 then
            overflow = nil
            ExposedMembers.TechCivicProgress.overflow_civic = overflow
            return
        end

        if ExposedMembers.TechCivicProgress.GetCivicProgress then
            local savProgress = ExposedMembers.TechCivicProgress.GetCivicProgress(lastCivicID)
            local civicCost = playerCivic:GetCultureCost(lastCivicID)
            local civicProgress = playerCivic:GetProgressingCivic()

            playerCivic:SetProgressingCivic(lastCivicID)
            turnsLeft = playerCivic:GetTurnsLeftOnCurrentCivic()

            local newProgress = savProgress
            while turnsLeft <= 1 do
                newProgress = newProgress - yield
                playerCivic:SetCulturalProgress(lastCivicID, newProgress)
                turnsLeft = playerCivic:GetTurnsLeftOnCurrentCivic()
            end

            if turnsLeft > 2 then
                newProgress = newProgress + (turnsLeft - 2) * yield
                playerCivic:SetCulturalProgress(lastCivicID, newProgress)
            end

            turnsLeft = playerCivic:GetTurnsLeftOnCurrentCivic()
            cost = playerCivic:GetCultureCost(lastCivicID) - newProgress
            min = cost - turnsLeft * yield
            max = cost - (turnsLeft - 1) * yield
            overflow = GetOverflowHelper(playerID, yield, lastCivicID, min, max, false, playerCivic:GetCultureCost(lastCivicID))
            playerCivic:SetCulturalProgress(lastCivicID, savProgress)
            playerCivic:SetProgressingCivic(curQueue)
        end
    end
    if overflow < 0 then
        overflow = 0
    end
    ExposedMembers.TechCivicProgress.overflow_civic = overflow
end

ExposedMembers.TechCivicProgress.overflow_tech = 0
ExposedMembers.TechCivicProgress.overflow_civic = 0
ExposedMembers.TechCivicProgress.GetTechOverflow = GetTechOverflow
-- ExposedMembers.TechCivicProgress.GetCivicOverflow = GetCivicOverflow
ExposedMembers.TechCivicProgress.GetCivicProgress = nil

localTechCompleted = -1
local function OnResearchCompleted( player:number, tech:number )
    if player == Game.GetLocalPlayer() and localTechCompleted ~= tech then
        localTechCompleted = tech
        ExposedMembers.TechCivicProgress.GetTechOverflow()
    end
end

Events.ResearchCompleted.Add(OnResearchCompleted);
