NUM_DISPLAYED_BATTLEGROUNDS = 5;
NUM_DISPLAYED_BATTLEGROUND_INSTANCES = 5;

function PVPBattleground_UpdateBattlegrounds()
	local frame;
	local localizedName, canEnter, isHoliday;
	local tempString, BGindex, isBig;
	local currentFrameNum = 1;
	
	local offset = FauxScrollFrame_GetOffset(PVPBattlegroundFrameTypeScrollFrame);
	for i=1,GetNumBattlegroundTypes() do
		frame = _G["BattlegroundType"..currentFrameNum];
		if ( not frame ) then	--We have filled up all of our open spaces.
			break;
		end
		
		BGindex = i+offset
		localizedName, canEnter, isHoliday = GetBattlegroundInfo(BGindex);
		tempString = localizedName;
		if ( localizedName and canEnter ) then
			frame.disabled = false;
			frame.BGindex = BGindex;
			if ( not PVPBattlegroundFrame.selectedBG ) then
				PVPBattlegroundFrame.selectedBG = BGindex;
			end
			frame:Enable();
			if ( isHoliday ) then
				tempString = tempString.." ("..BATTLEGROUND_HOLIDAY..")";
			end
		
			frame.title:SetText(tempString);
			frame:Show();
			
			currentFrameNum = currentFrameNum + 1;
			
			if ( BGindex == PVPBattlegroundFrame.selectedBG ) then
				frame:LockHighlight();
			else
				frame:UnlockHighlight();
			end
		else
			frame:Hide();
		end
	end
	
	if ( currentFrameNum <= NUM_DISPLAYED_BATTLEGROUNDS ) then
		isBig = true;	--Espand the highlight to cover where the scroll bar usually is.
	end
	
	for i=1,NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["BattlegroundType"..i];
		if ( isBig ) then
			frame:SetWidth(315);
		else
			frame:SetWidth(295);
		end
	end
	
	for i=currentFrameNum,NUM_DISPLAYED_BATTLEGROUNDS do
		frame = _G["BattlegroundType"..i];
		frame:Hide();
	end
	
	local mapName, mapDescription, maxGroup = GetBattlefieldInfo();
	if ( mapDescription ~= PVPBattlegroundFrameZoneDescriptionText:GetText() ) then
		PVPBattlegroundFrameZoneDescriptionText:SetText(mapDescription);
		PVPBattlegroundFrameZoneDescriptionScrollFrame:SetVerticalScroll(0);
	end
	if ( maxGroup and maxGroup == 5 ) then
		PVPBattlegroundFrameGroupJoinButton:SetText(JOIN_AS_PARTY);
	else
		PVPBattlegroundFrameGroupJoinButton:SetText(JOIN_AS_GROUP);		
	end
	
	PVPBattlegroundFrame_UpdateGroupAvailable();
	FauxScrollFrame_Update(PVPBattlegroundFrameTypeScrollFrame, currentFrameNum, NUM_DISPLAYED_BATTLEGROUNDS, 16);
end

function PVPBattleground_UpdateInstances(BGindex)
	if ( type(BGindex) ~= "number" ) then
		BGindex = PVPBattlegroundFrame.selectedBG;
	end
	
	local frame, localizedName, InstanceIndex, instanceID, isBig;
	
	local BGname = GetBattlegroundInfo(BGindex);
	local numInstanceChoices = GetNumBattlefields(BGindex) + 1;
	
	if ( numInstanceChoices <= NUM_DISPLAYED_BATTLEGROUND_INSTANCES ) then
		isBig = true;	--Espand the highlight to cover where the scroll bar usually is.
	end
	
	local offset = FauxScrollFrame_GetOffset(PVPBattlegroundFrameInstanceScrollFrame);
	for i=1,NUM_DISPLAYED_BATTLEGROUND_INSTANCES do
		frame = _G["BattlegroundInstance"..i];
		InstanceIndex = i + offset;
		
		if ( isBig ) then
			frame:SetWidth(315);
		else
			frame:SetWidth(295);
		end
		
		if ( InstanceIndex == 1 ) then
			frame:Show();
			frame:Enable();
			frame.title:SetText(FIRST_AVAILABLE);
			
			if ( InstanceIndex == PVPBattlegroundFrame.selectedInstance ) then
				frame:LockHighlight();
			else
				frame:UnlockHighlight();
			end
			
			frame.localizedName = BGname;
		else
			instanceID = GetBattlefieldInstanceInfo(InstanceIndex - 1)
			if ( instanceID ) then
				localizedName = BGname.." "..instanceID;
				frame:Show();
				if ( PVPBattlegroundFrame.currentData ) then
					frame:Enable();
					frame.title:SetText(localizedName);
					frame.localizedName = localizedName;
				else
					frame:Hide();
					frame.localizedName = nil;
				end
				
				if ( InstanceIndex == PVPBattlegroundFrame.selectedInstance and PVPBattlegroundFrame.currentData ) then
					frame:LockHighlight();
				else
					frame:UnlockHighlight();
				end
			else
				frame:Hide();
			end
		end
	end
	
	PVPBattleground_UpdateInstancesStatus();
	FauxScrollFrame_Update(PVPBattlegroundFrameInstanceScrollFrame, numInstanceChoices, NUM_DISPLAYED_BATTLEGROUND_INSTANCES, 16);
end

function PVPBattleground_UpdateInstancesStatus()
	local queueStatus, queueMapName, queueInstanceID, frame;
	for i=1, NUM_DISPLAYED_BATTLEGROUND_INSTANCES do
		frame = _G["BattlegroundInstance"..i];
		frame.status:SetText("");
	end
	for i=1, MAX_BATTLEFIELD_QUEUES do
		queueStatus, queueMapName, queueInstanceID = GetBattlefieldStatus(i);
		for j=1, NUM_DISPLAYED_BATTLEGROUND_INSTANCES do
			frame = _G["BattlegroundInstance"..j];
			if ( frame.localizedName == queueMapName and queueInstanceID == 0 ) then
				if ( queueStatus == "queued" ) then
					frame.status:SetText(BATTLEFIELD_QUEUE_STATUS);
				end
			else
				if ( queueStatus ~= "none" and queueMapName.." "..queueInstanceID == frame.localizedName ) then
					if ( queueStatus == "queued" ) then
						frame.status:SetText(BATTLEFIELD_QUEUE_STATUS);
					elseif ( queueStatus == "confirm" ) then
						frame.status:SetText(BATTLEFIELD_CONFIRM_STATUS);
					end
				end
			end
		end
	end
end

function PVPBattleground_ResetInstances()
	FauxScrollFrame_SetOffset(PVPBattlegroundFrameInstanceScrollFrame, 0);
	FauxScrollFrame_OnVerticalScroll(PVPBattlegroundFrameInstanceScrollFrame, 0, 16, PVPBattleground_UpdateInstances);
	PVPBattlegroundFrame.selectedInstance = 1;
	
	RequestBattlegroundInstanceInfo(PVPBattlegroundFrame.selectedBG);
end

function PVPBattlegroundButton_OnClick(self)
	local offset = FauxScrollFrame_GetOffset(PVPBattlegroundFrameTypeScrollFrame);
	local id = self:GetID() + offset;

	for i=1,NUM_DISPLAYED_BATTLEGROUNDS do
		if ( id == i + offset ) then
			_G["BattlegroundType"..i]:LockHighlight();
		else
			_G["BattlegroundType"..i]:UnlockHighlight();
		end
	end
	
	if ( self.BGindex == PVPBattlegroundFrame.selectedBG ) then
		return;
	end
	
	PVPBattlegroundFrame.selectedBG = self.BGindex;
	
	PVPBattleground_ResetInstances();
end

function PVPBattlegroundButton_OnEnter(self)
	if ( self.disabled ) then
		self.highlight:Hide();
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
		GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, 1);
	else
		self.highlight:Show();
	end
end

function PVPBattlegroundInstanceButton_OnEnter(self)

end

function PVPBattlegroundInstanceButton_OnClick(self)
	local offset = FauxScrollFrame_GetOffset(PVPBattlegroundFrameInstanceScrollFrame)
	if ( self:GetID() + offset == PVPBattlegroundFrame.selectedInstance ) then
		return;
	end
	
	PVPBattlegroundFrame.selectedInstance = self:GetID() + offset;
	for i=1,NUM_DISPLAYED_BATTLEGROUND_INSTANCES do
		if ( self:GetID() == i ) then
			_G["BattlegroundInstance"..i]:LockHighlight();
		else
			_G["BattlegroundInstance"..i]:UnlockHighlight();
		end
	end
end

function PVPBattlegroundFrameJoinButton_OnClick(self)
	local joinAsGroup;
	if ( self == PVPBattlegroundFrameGroupJoinButton ) then
		joinAsGroup = true;
	end
	
	JoinBattlefield(PVPBattlegroundFrame.selectedInstance - 1, joinAsGroup);
end

function PVPBattlegroundFrame_OnLoad(self)
	self:RegisterEvent("PVPQUEUE_ANYWHERE_SHOW");
	self:RegisterEvent("NPC_PVPQUEUE_ANYWHERE");
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	
	PanelTemplates_SetTab(PVPParentFrame, 1);
	PVPBattlegroundFrame_UpdateVisible();
	
	BattlegroundType1:Click();
	BattlegroundInstance1:Click();
end

function PVPBattlegroundFrame_OnEvent(self, event, ...)
	if ( event == "PVPQUEUE_ANYWHERE_SHOW" or event == "NPC_PVPQUEUE_ANYWHERE") then
		self.currentData = true;
		PVPBattleground_UpdateBattlegrounds();
		if ( self.selectedBG ) then
			PVPBattleground_UpdateInstances(PVPBattlegroundFrame.selectedBG);
		end
		if ( event == "NPC_PVPQUEUE_ANYWHERE" ) then
			ShowUIPanel(PVPParentFrame);
			PVPFrame_SetJustBG(true);
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" ) then
		PVPBattleground_UpdateInstancesStatus();
	elseif ( event == "PVPQUEUE_ANYWHERE_UPDATE_AVAILABLE" or event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		
		FauxScrollFrame_SetOffset(PVPBattlegroundFrameTypeScrollFrame, 0);
		FauxScrollFrame_OnVerticalScroll(PVPBattlegroundFrameTypeScrollFrame, 0, 16, PVPBattleground_UpdateBattlegrounds); --We may be changing brackets, so we don't want someone to see an outdated version of the data.
		if ( self.selectedBG ) then
			PVPBattleground_ResetInstances();
		end
		PVPBattlegroundFrame_UpdateVisible();
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		PVPBattlegroundFrame_UpdateGroupAvailable();
	end
end

function PVPBattlegroundFrame_OnShow(self)
	if ( IsInInstance() ) then
		WintergraspTimer:Hide();
	else
		WintergraspTimer:Show();
	end
	PVPBattleground_UpdateBattlegrounds();
	RequestBattlegroundInstanceInfo(self.selectedBG or 1);
end

function PVPBattlegroundFrame_OnHide(self)
	CloseBattlefield();
end

function PVPBattlegroundFrame_UpdateVisible()
	for i=1, GetNumBattlegroundTypes() do
		local _, canEnter = GetBattlegroundInfo(i);
		if ( canEnter ) then
			if ( not PVPFrame_IsJustBG() ) then
				PVPParentFrameTab1:Show();
				PVPParentFrameTab2:Show();
			end
			return;
		end
	end
	PVPParentFrameTab1:Click();
	PVPParentFrameTab1:Hide();
	PVPParentFrameTab2:Hide();
end

function PVPBattlegroundFrame_UpdateGroupAvailable()
	if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
		-- If this is true then can join as a group
		PVPBattlegroundFrameGroupJoinButton:Enable();
	else
		PVPBattlegroundFrameGroupJoinButton:Disable();
	end
end

function WintergraspTimer_OnLoad(self)
	self.canQueue = false;
	self.tooltip = PVPBATTLEGROUND_WINTERGRASPTIMER_CANNOT_QUEUE;
	self.texture:SetTexCoord(0.0, 1.0, 0.0, 0.5);
end

function WintergraspTimer_OnUpdate(self, elapsed)
	local nextBattleTime = GetWintergraspWaitTime();
	if ( nextBattleTime and nextBattleTime > 60 ) then
		self.text:SetFormattedText(PVPBATTLEGROUND_WINTERGRASPTIMER, SecondsToTime(nextBattleTime, true));
	elseif ( nextBattleTime and nextBattleTime > 0 ) then
		self.text:SetFormattedText(PVPBATTLEGROUND_WINTERGRASPTIMER, SecondsToTime(nextBattleTime, false));
	else
		self.text:SetFormattedText(PVPBATTLEGROUND_WINTERGRASPTIMER, WINTERGRASP_IN_PROGRESS);
	end

	local canQueue = CanQueueForWintergrasp();
	if ( self.canQueue ~= canQueue ) then
		-- simple safeguard so we're not doing a bunch of unnecessary work for each OnUpdate
		if ( canQueue ) then
			self.tooltip = PVPBATTLEGROUND_WINTERGRASPTIMER_CAN_QUEUE;
			self.texture:SetTexCoord(0.0, 1.0, 0.5, 1.0);
		else
			self.tooltip = PVPBATTLEGROUND_WINTERGRASPTIMER_CANNOT_QUEUE;
			self.texture:SetTexCoord(0.0, 1.0, 0.0, 0.5);
		end
		self.canQueue = canQueue;
	end
end
