DHUD_HexTable = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["a"] = 10,
    ["b"] = 11,
    ["c"] = 12,
    ["d"] = 13,
    ["e"] = 14,
    ["f"] = 15
}

-- hexcolor to rgb 
function DHUD_HexToDec(hex)

    local r1 = tonumber(DHUD_HexTable[ string.lower(string.sub(hex,1,1)) ] * 16);
    local r2 = tonumber(DHUD_HexTable[ string.lower(string.sub(hex,2,2)) ]);
    local r  = (r1 + r2) / 255;

    local g1 = tonumber(DHUD_HexTable[ string.lower(string.sub(hex,3,3)) ] * 16);
    local g2 = tonumber(DHUD_HexTable[ string.lower(string.sub(hex,4,4)) ]);
    local g  = (g1 + g2) / 255;
    
    local b1 = tonumber(DHUD_HexTable[ string.lower(string.sub(hex,5,5)) ] * 16);
    local b2 = tonumber(DHUD_HexTable[ string.lower(string.sub(hex,6,6)) ]);
    local b  = (b1 + b2) / 255;
       
    return {r,g,b}
end

-- decimal to hex
function DHUD_DecToHex(red,green,blue)
  if ( not red or not green or not blue ) then
    return "ffffff"
  end

  red = floor(red * 255)
  green = floor(green * 255)
  blue = floor(blue * 255)

  local a,b,c,d,e,f

  a = DHUD_GiveHex(floor(red / 16))
  b = DHUD_GiveHex(math.fmod(red,16))
  c = DHUD_GiveHex(floor(green / 16))
  d = DHUD_GiveHex(math.fmod(green,16))
  e = DHUD_GiveHex(floor(blue / 16))
  f = DHUD_GiveHex(math.fmod(blue,16))

  return a..b..c..d..e..f
end

function DHUD_GiveHex(dec)
  for key, value in pairs(DHUD_HexTable) do
    if ( dec == value ) then
      return key
    end
  end
  return ""..dec
end

-- table copy
function DHUD_tablecopy(tbl)
  if type(tbl) ~= "table" then return tbl end
  local t = {}
  for i,v in pairs(tbl) do
    t[i] = DHUD_tablecopy(v)
  end
  --table.setn(t, table.getn(tbl))
  --return setmetatable(t, DHUD_tablecopy(getmetatable(tbl)))
end

function DHUD_FormatTime(secs)
	--day
	if secs >= 86400 then
		return format('%dd', floor(secs/86400 + 0.5));
	--hour
	elseif secs >= 3600 then
		return format('%dh', floor(secs/3600 + 0.5));
	--minutes
	elseif secs >= 99 then
		return format('%dm', floor(secs/60 + 0.5));
    else
        --return format('%ds', floor(secs + 0.5));
        return (floor(secs + 0.5));
    end
end