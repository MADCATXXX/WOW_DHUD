DHUDO_NUMTABS = 5;

function DHUDO_Header_OnLoad(x,y)
    this.setting_name = string.gsub( this:GetName() , "DHUD_", "");
    local text = getglobal( this:GetName().."Text");
    text:SetText( " "..(DHUDO_locale[this.setting_name] or "["..(this.setting_name).."]") );
    text:ClearAllPoints();
    text:SetHeight(20);
    text:SetPoint("TOPLEFT", "DHUDOptionsFrame" , "TOPLEFT", x, y);
end

function DHUDO_OnLoad()
    table.insert(UISpecialFrames, "DHUDOptionsFrame");
    PanelTemplates_SetNumTabs(this, DHUDO_NUMTABS);
    PanelTemplates_SetTab(this, 1);    
end

function DHUDO_DropDown_Initialize()
	local info = {};
	local index;
	
    index = string.gsub( this:GetName() , "DHUD_Edit_", "");
	index = string.gsub( index , "_Selection", "");
	index = string.gsub( index , "Button", "");
	
	local table = DHUDO_SELECTION[index]["table"];
    for key, text in ipairs(table) do
        info = {};
        info.text = text;
        info.func = DHUDO_DropDown_OnClick;
        info.arg1 = index;
        UIDropDownMenu_AddButton(info);
    end
end

function DHUDO_DropDown_OnClick(list)
    local sel = getglobal("DHUD_Edit_"..list.."_Selection");
    local box = getglobal("DHUD_Edit_"..list.."ScrollFrameText");
    local text = DHUDO_SELECTION[list]["values"][ this:GetID() ];
    box:SetText(text);
    UIDropDownMenu_SetSelectedID( sel , this:GetID() );
    DHUD:SetConfig( list, text );
    DHUDO_updateTexts(list);
    DHUD:init();
end

function DHUDO_updateTexts(name)
    DHUD:initTextfield(getglobal(name),name);
    DHUD:triggerTextEvent(name);
end
        
function DHUDO_FrameSlider_OnLoad(low, high, step)
    this.setting_name = string.gsub( this:GetName() , "DHUD_Slider_", "");
    this.st = step;
    if this.nullbase == 1 then
	   getglobal(this:GetName().."Low"):SetText( (low - low) );
	   getglobal(this:GetName().."High"):SetText( (high - low));     
	   this.low = low;  
    else
	   getglobal(this:GetName().."Low"):SetText(low);
	   getglobal(this:GetName().."High"):SetText(high);        
    end
	this:SetMinMaxValues(low, high);
	this:SetValueStep(this.st);
end

function DHUDO_FrameSlider_OnShow( key,text)
    getglobal(this:GetName()):SetValue(DHUD_Settings[key]);
    if this.nullbase == 1 then
        getglobal(this:GetName().."Text"):SetText(text.." "..(DHUD_Settings[key] - this.low ).." ");
    else
        getglobal(this:GetName().."Text"):SetText(text.." "..DHUD_Settings[key].." ");
    end
end

function DHUDO_FrameSlider_OnValueChanged(key,text)

     local m;
     local value;
     
     if this.st == nil then
        m = 0;
     end
     
     if this.st == 10 then
        m = 0.1;
     end
     
     if this.st == 1 then
        m = 0;
     end
     
     if this.st == 0.1 then
        m = 10;
     end
     
     if this.st == 0.01 then
        m = 100;
     end
     
     if this.st == 0.001 then
        m = 1000;
     end
                    
     if m > 0 then
         value =  math.floor( ( this:GetValue() + 0.00001) * m ) / m; 
     else
         value =  math.floor( this:GetValue() ); 
     end
     
	 DHUD:SetConfig( key, value );
    if this.nullbase == 1 then
        getglobal(this:GetName().."Text"):SetText(text.." "..(DHUD_Settings[key] - this.low ).." ");
    else
        getglobal(this:GetName().."Text"):SetText(text.." "..DHUD_Settings[key].." ");
    end
	 DHUD:init();
	 
    if this.triggertext then
        DHUD:triggerAllTextEvents();
    end
end

function DHUD_RadioButton_OnClick(index)
	DHUD_RADIO_layout1:SetChecked(nil);
	DHUD_RADIO_layout2:SetChecked(nil);
	if index == 1 then
		DHUD_RADIO_layout1:SetChecked(1);
		DHUD:transformFrames("DHUD_Standard_Layout");
	else
		DHUD_RADIO_layout2:SetChecked(1);
		DHUD:transformFrames("DHUD_PlayerLeft_Layout");
	end
end


function DHUDO_ColorPicker_ColorChanged()
	local r, g, b = ColorPickerFrame:GetColorRGB();

    DHUD_Settings["colors"][ColorPickerFrame.objname][ColorPickerFrame.objindex] = DHUD_DecToHex(r,g,b);
    --getglobal(ColorPickerFrame.tohue):SetTexture(r,g,b);
    DHUDO_changeG(ColorPickerFrame.objname);
    DHUD:init();
end

function DHUDO_ColorPicker_OnClick(boxnumber)

    local name = string.gsub( this:GetName() , "DHUD_Colorbox_", "");
    name = string.gsub( name , boxnumber, "");
    local Red, Green, Blue = unpack(DHUD_HexToDec(DHUD_Settings["colors"][name][boxnumber]));
    

    ColorPickerFrame.previousValues = {Red, Green, Blue}
    ColorPickerFrame.cancelFunc     = DHUDO_ColorPicker_Cancelled
    ColorPickerFrame.func           = DHUDO_ColorPicker_ColorChanged
    ColorPickerFrame.objname        = name
    ColorPickerFrame.objindex       = boxnumber
    ColorPickerFrame.tohue          = "DHUD_Colorbox_"..name..boxnumber.."Texture";
    ColorPickerFrame.hasOpacity     = false
    ColorPickerFrame:SetColorRGB(Red, Green, Blue)
    ColorPickerFrame:ClearAllPoints()
    local x = DHUDOptionsFrame:GetCenter()
    if (x < UIParent:GetWidth() / 2) then
        ColorPickerFrame:SetPoint("LEFT", "DHUDOptionsFrame", "RIGHT", 0, 0)
    else
        ColorPickerFrame:SetPoint("RIGHT", "DHUDOptionsFrame", "LEFT", 0, 0)
    end

    ColorPickerFrame:Show()
end

function DHUDO_ColorPicker_Cancelled(color)

    local r,g,b = unpack(color);
    DHUD_Settings["colors"][ColorPickerFrame.objname][ColorPickerFrame.objindex] = DHUD_DecToHex(r,g,b);
    --getglobal(ColorPickerFrame.tohue):SetTexture(r,g,b);
    DHUDO_changeG(ColorPickerFrame.objname);
    DHUD:init();
 
end

function DHUDO_changeG(name)
     local Hcolor1 = DHUD_Settings["colors"][name][1];
     local Hcolor2 = DHUD_Settings["colors"][name][2];
     local Hcolor3 = DHUD_Settings["colors"][name][3];
     
     local c1r,c1g,c1b = unpack(DHUD_HexToDec(Hcolor1));
     local c2r,c2g,c2b = unpack(DHUD_HexToDec(Hcolor2));
     local c3r,c3g,c3b = unpack(DHUD_HexToDec(Hcolor3));

     local basename = "DHUD_Colorbox_"..name;
     getglobal(basename.."1Texture"):SetTexture(c1r,c1g,c1b);
     getglobal(basename.."2Texture"):SetTexture(c2r,c2g,c2b);
     getglobal(basename.."3Texture"):SetTexture(c3r,c3g,c3b);

     getglobal(basename.."G1Texture"):SetGradient("HORIZONTAL",c1r,c1g,c1b, c2r,c2g,c2b);
     getglobal(basename.."G2Texture"):SetGradient("HORIZONTAL",c2r,c2g,c2b, c3r,c3g,c3b);
end
