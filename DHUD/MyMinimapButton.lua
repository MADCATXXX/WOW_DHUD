--[[ MyMinimapButton v1.0

	This is an embedded library intended to be used by other mods.
	It's not a standalone mod.

	See MyMinimapButton_API_readme.txt for more info.
]]

local version = 10.11

if not MyMinimapButton or MyMinimapButton.Version<version then

  MyMinimapButton = {

	Version = version,		-- for version checking

	-- Dynamically create a button
	--   modName = name of the button (mandatory)
	--   modSettings = table where SavedVariables are stored for the button (optional)
	--   initSettings = table of default settings (optional)
	Create = function(self,modName,modSettings,initSettings)
		if not modName or getglobal(modName.."MinimapButton") then
			return
		end
		initSettings = initSettings or {}
		modSettings = modSettings or {}
		self.Buttons = self.Buttons or {}

		local frameName = modName.."MinimapButton"
		local frame = CreateFrame("Button",frameName,Minimap)
		frame:SetWidth(31)
		frame:SetHeight(31)
		frame:SetFrameStrata("MEDIUM")
		frame:SetToplevel(1) -- enabled in 1.10.2
		frame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
		frame:SetPoint("CENTER",Minimap,"CENTER")
		local icon = frame:CreateTexture(frameName.."Icon","BACKGROUND")
		icon:SetTexture(initSettings.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
		icon:SetWidth(20)
		icon:SetHeight(20)
		icon:SetPoint("TOPLEFT",frame,"TOPLEFT",7,-5)
		local overlay = frame:CreateTexture(frameName.."Overlay","OVERLAY")
		overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
		overlay:SetWidth(53)
		overlay:SetHeight(53)
		overlay:SetPoint("TOPLEFT",frame,"TOPLEFT")

		frame:RegisterForClicks("LeftButtonUp","RightButtonUp")
		frame:SetScript("OnClick",self.OnClick)

		frame:SetScript("OnMouseDown",self.OnMouseDown)
		frame:SetScript("OnMouseUp",self.OnMouseUp)
		frame:SetScript("OnEnter",self.OnEnter)
		frame:SetScript("OnLeave",self.OnLeave)

		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart",self.OnDragStart)
		frame:SetScript("OnDragStop",self.OnDragStop)

		frame.tooltipTitle = modName
		frame.leftClick = initSettings.left
		frame.rightClick = initSettings.right
		frame.tooltipText = initSettings.tooltip

		local firstUse = 1
		for i in pairs(modSettings) do
			firstUse = nil -- modSettings has been populated before
		end
		if firstUse then
			-- define modSettings from initSettings or default
			modSettings.enabled = initSettings.enabled or 1
			modSettings.position = initSettings.position or self:GetDefaultPosition()
			modSettings.locked = initSettings.locked or nil
		end
		frame.modSettings = modSettings

		table.insert(self.Buttons,modName)
		self:SetEnable(modName,modSettings.enabled)
	end,

	-- Changes the icon of the button.
	--   value = texture path, ie: "Interface\\AddOn\\MyMod\\MyModIcon"
	SetIcon = function(self,modName,value)
		if value and getglobal(modName.."MinimapButton") then
			getglobal(modName.."MinimapButtonIcon"):SetTexture(value)
		end
	end,

	-- Sets the left-click function.
	--   value = function
	SetLeftClick = function(self,modName,value)
		if value and getglobal(modName.."MinimapButton") then
			getglobal(modName.."MinimapButton").leftClick = value
		end
	end,

	-- Sets the right-click function.
	--  value = function
	SetRightClick = function(self,modName,value)
		if value and getglobal(modName.."MinimapButton") then
			getglobal(modName.."MinimapButton").rightClick = value
		end
	end,

	-- Locks minimap button from moving
	--   value = 0/nil/false or 1/non-nil/true
	SetLock = function(self,modName,value)
		local button = getglobal(modName.."MinimapButton")
		if value==0 then value = nil end
		if button then
			button.modSettings.locked = (value and 1) or nil
		end
	end,

	-- Enables or disables the minimap button
	--    value = 0/nil/false or 1/non-nil/true
	SetEnable = function(self,modName,value)
		local button = getglobal(modName.."MinimapButton")
		if value==0 then value = nil end
		if button then
			button.modSettings.enabled = (value and 1) or nil
			if value then
				button:Show()
				self:Move(modName,nil,1)
			else
				button:Hide()
			end
		end
	end,

	-- Returns a setting of this minimap button
	--   setting = "LOCKED", "ENABLED", "DRAG" or "POSITION"
	GetSetting = function(self,modName,setting)
		local button = getglobal(modName.."MinimapButton")
		setting = string.lower(setting or "")
		if button and button.modSettings[setting] then
			return button.modSettings[setting]
		end
	end,

	-- Sets the tooltip text.
	--   value = string (can include \n)
	SetTooltip = function(self,modName,value)
		local button = getglobal(modName.."MinimapButton")
		if button and value then
			button.tooltipText = value
		end
	end,

	-- list with shapes, copied from LibDBIcon-1.0.lua
	minimapShapes = {
		["ROUND"] = {true, true, true, true},
		["SQUARE"] = {false, false, false, false},
		["CORNER-TOPLEFT"] = {false, false, false, true},
		["CORNER-TOPRIGHT"] = {false, false, true, false},
		["CORNER-BOTTOMLEFT"] = {false, true, false, false},
		["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
		["SIDE-LEFT"] = {false, true, false, true},
		["SIDE-RIGHT"] = {true, false, true, false},
		["SIDE-TOP"] = {false, false, true, true},
		["SIDE-BOTTOM"] = {true, true, false, false},
		["TRICORNER-TOPLEFT"] = {false, true, true, true},
		["TRICORNER-TOPRIGHT"] = {true, false, true, true},
		["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
		["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
	},

	-- Moves the button.
	--  newPosition = degree angle to display the button (optional)
	--  force = force move irregardless of locked status
	Move = function(self,modName,newPosition,force)
		local button = getglobal(modName.."MinimapButton")
		if button and (not button.modSettings.locked or force) then
			button.modSettings.position = newPosition or button.modSettings.position
			local angle = math.rad(button.modSettings.position)
			local x, y, q = math.cos(angle), math.sin(angle), 1
			if x < 0 then q = q + 1 end
			if y > 0 then q = q + 2 end
			local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
			local quadTable = MyMinimapButton.minimapShapes[minimapShape]
			local w = (Minimap:GetWidth() / 2) + 5
			local h = (Minimap:GetHeight() / 2) + 5
			if quadTable[q] then
				x, y = x*w, y*h
			else
				local diagRadiusW = math.sqrt(2*(w)^2)-10
				local diagRadiusH = math.sqrt(2*(h)^2)-10
				x = math.max(-w, math.min(x*diagRadiusW, w))
				y = math.max(-h, math.min(y*diagRadiusH, h))
			end
			--print("final x " .. x .. ", y " .. y);
			button:SetPoint("CENTER", Minimap, "CENTER", x, y)
		end
	end,

	-- Debug. Use no parameters to list all created buttons.
	Debug = function(self,modName)
		DEFAULT_CHAT_FRAME:AddMessage("MyMinimapButton version = "..self.Version)
		if modName then
			DEFAULT_CHAT_FRAME:AddMessage("Button: \""..modName.."\"")
			local button = getglobal(modName.."MinimapButton")
			if button then
				DEFAULT_CHAT_FRAME:AddMessage("positon = "..tostring(button.modSettings.position))
				DEFAULT_CHAT_FRAME:AddMessage("enabled = "..tostring(button.modSettings.enabled))
				DEFAULT_CHAT_FRAME:AddMessage("locked = "..tostring(button.modSettings.locked))
			else
				DEFAULT_CHAT_FRAME:AddMessage("button not defined")
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("Buttons created:")
			for i=1,table.getn(self.Buttons) do
				DEFAULT_CHAT_FRAME:AddMessage("\""..self.Buttons[i].."\"")
			end
		end
	end,

	--[[ Internal functions: do not call anything below here ]]

	-- this gets a new default position by increments of 20 degrees
	GetDefaultPosition = function(self)
		local position,found = 0,1,0

		while found do
			found = nil
			for i=1,table.getn(self.Buttons) do
				if getglobal(self.Buttons[i].."MinimapButton").modSettings.position==position then
					position = position + 20
					found = 1
				end
			end
			found = (position>340) and 1 or found -- leave if we've done full circle
		end
		return position
	end,

	OnMouseDown = function(frame)
		getglobal(frame:GetName().."Icon"):SetTexCoord(.1,.9,.1,.9)
	end,

	OnMouseUp = function(frame)
		getglobal(frame:GetName().."Icon"):SetTexCoord(0,1,0,1)
	end,

	OnEnter = function(frame)
		GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
		GameTooltip:AddLine(frame.tooltipTitle)
		GameTooltip:AddLine(frame.tooltipText,.8,.8,.8,1)
		GameTooltip:Show()
	end,

	OnLeave = function(frame)
		GameTooltip:Hide()
	end,

	OnDragStart = function(frame)
		MyMinimapButton.OnMouseDown(frame)
		frame:LockHighlight()
		frame:SetScript("OnUpdate",MyMinimapButton.OnUpdate)
	end,

	OnDragStop = function(frame)
		frame:SetScript("OnUpdate",nil)
		frame:UnlockHighlight()
		MyMinimapButton.OnMouseUp(frame)
	end,

	OnUpdate = function(frame)
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale
		frame.modSettings.position = math.deg(math.atan2(py - my, px - mx)) % 360
		local modName = string.gsub(frame:GetName() or "","MinimapButton$","")
		MyMinimapButton:Move(modName)
	end,

	OnClick = function(frame, arg1)
		if arg1=="LeftButton" and frame.leftClick then
			frame.leftClick()
		elseif arg1=="RightButton" and frame.rightClick then
			frame.rightClick()
		end
	end

  }

end
