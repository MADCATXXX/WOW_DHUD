--[[-----------------------------------------------------------------------------------
 Original Drathals HUD (c) 2006 by Markus Inger / Drathal / Silberklinge / Silbersegen
 DHUD for WotLK and later expansions (c) 2013 by MADCAT (EU-Гордунни, Мадкат)
 (http://eu.battle.net/wow/en/character/гордунни/Мадкат/advanced)
---------------------------------------------------------------------------------------
 This file contains data to reposition items along arc, data was generated with help of
 graph software (e.g. http://www.padowan.dk/download/):
 @author: MADCAT
-----------------------------------------------------------------------------------]]--

------------------
-- Ellipse Math --
------------------

--- Class to make calculation on ellipses, required to position elements around hud such as buffs, debuffs, cooldowns, combo-points
DHUDEllipseMath = {
	-- cache table to increase calculation speed of same conditions
	cache		= {
		-- table with angles
		angleStep  = { },
		-- table with numFit
		numFit		= { },
		-- table with arc heights
		arcHeight	= { },
		-- table with begin angles
		angleBegin	= { },
	},
	-- radius of circle that is used to define width of ellipse
	radiusX		= 0,
	-- radius of circle that is used to define height of ellipse
	radiusY		= 0,
	-- angle from horizontal line to the end of hud image, addon specific, since arc is cut at angle, this value will change on ellipse rescale
	angleArc	= 0,
	-- default radius in HUD texture that is used to define width of ellipse
	HUD_RADIUS_X = 336, -- can also try other values [90, 140, 200, 300, 336]
	-- default radius in HUD texture that is used to define height of ellipse
	HUD_RADIUS_Y = 336, -- can also try other values [182, 222, 262, 320, 336]
	-- amount of pixels that are part of radius, but cut from image
	HUD_RADIUS_X_OUTOFIMAGE = 280, -- can also try other values [-34, -84, 144, 244, 280]
	-- angle in degrees from horizontal line to the end of hud (-arcsin of: max y value on hud (y = 120) divided by HUD_RADIUS_Y)
	HUD_ANGLE_ARC = 20.2, -- can also try other values [41.2, 32.7, 27.3, 22.0, 20.9] * 95%
	-- width of the big bars at 0 degrees
	HUD_BAR_WIDTH = 14.5,
	-- width of the small bars at 0 degrees
	HUD_SMALLBAR_WIDTH = 12,
	--- Following comments are for drawing graph in graph software (e.g. http://www.padowan.dk/download/):
	--- Ellipse formula for graph software: x(t) = HUD_RADIUS_X * cos(t) - HUD_RADIUS_X_OUTOFIMAGE; y(t) = HUD_RADIUS_Y * sin(t);
	--- Points of HUD image (x,y) for graph software: [(35, 128-9), (50, 128-61), (56, 0), (51, 128-188), (35, 128-245)]
}

--- Sets ellipse that is represented by parameters specified
-- @param radiusX radius of circle that is used to define width of ellipse (do not set to negative or zero)
-- @param radiusY radius of circle that is used to define height of ellipse (do not set to negative or zero)
function DHUDEllipseMath:setEllipse(radiusX, radiusY)
	self.radiusX = radiusX;
	self.radiusY = radiusY;
	self:recalcAngleArc();
end

--- Recalculate angle of arc after changing ellipse radius
function DHUDEllipseMath:recalcAngleArc()
	-- formula should be readjusted manually when changing ellipse parameters
	self.angleArc = self.HUD_ANGLE_ARC + 10 * (self.radiusX - self.HUD_RADIUS_X) / self.HUD_RADIUS_X;
end

--- Scales current ellipse by the scale specified
-- @param scale scale factor to be used (do not set to negative or zero)
function DHUDEllipseMath:scaleEllipse(scale)
	self.radiusX = self.radiusX * scale;
	self.radiusY = self.radiusY * scale;
	self:recalcAngleArc();
end

--- Adjusts radius of circle that defines width of ellipse, it will also scale radiusY accordingly
-- @param offset amount to be added to current radiusX
function DHUDEllipseMath:adjustRadiusX(offset)
	local newRadiusX = self.radiusX + offset;
	if (newRadiusX <= 0) then
		newRadiusX = self.radiusX;
	end
	local scale = newRadiusX / self.radiusX;
	self:scaleEllipse(scale);
end

--- Adjusts radius of circle that defines height of ellipse, it will also scale radiusX accordingly
-- @param offset amount to be added to current radiusY
function DHUDEllipseMath:adjustRadiusY(offset)
	local newRadiusY = self.radiusY + offset;
	if (newRadiusY <= 0) then
		newRadiusY = self.radiusY;
	end
	local scale = newRadiusY / self.radiusY;
	self:scaleEllipse(scale);
end

--- Sets default ellipse that is represented by HUD texture, ellipse will be set to represent figure between two big bars on HUD texture
function DHUDEllipseMath:setDefaultEllipse()
	self:setEllipse(self.HUD_RADIUS_X, self.HUD_RADIUS_Y);
end

--- Calculate perimeter of current ellipse
-- @return perimeter of current ellipse
function DHUDEllipseMath:calculatePerimeter()
	local pi = math.pi;
	local a = self.radiusX;
	local b = self.radiusY;
	self.perimeter = 4 * (pi * a * b + (a - b) * (a - b)) / (a + b);
	return self.perimeter;
end

--- Calculate radius average of current ellipse
-- @return radius average of current ellipse
function DHUDEllipseMath:calculateRadiusAverage()
	local x, y = self:calculatePosition(self.angleArc * 0.666);
	self.radiusAverage = sqrt(x * x + y * y);
	return self.radiusAverage;
end

--- Calculate position at angle specified in current ellipse
-- @param angleDeg angle at which position is required, standard coordinate system
-- @return position at angle specified in current ellipse, 2 values are returned: x and y
function DHUDEllipseMath:calculatePosition(angleDeg)
	local x = self.radiusX * cos(angleDeg);
	local y = self.radiusY * sin(angleDeg);
	return x, y;
end

--- Calculate position at angle specified in current ellipse, correcting position to addon coordinates
-- @param angleDeg angle at which position is required, standard coordinate system
-- @return position at angle specified in current ellipse, 2 values are returned: x and y
function DHUDEllipseMath:calculatePositionInAddonCoordinates(angleDeg)
	local x, y = self:calculatePosition(angleDeg);
	x = x - self.HUD_RADIUS_X_OUTOFIMAGE + 128;
	return floor(x), floor(y);
end

--- Calculate angle step to fit elements at current ellipse radiuses
-- @param elementRadius radius of elements that are required to fit
-- @return angle step in degrees, that should be used in calculations when using calculatePosition function (e.g. angleArc + n * angleStep)
function DHUDEllipseMath:calculateAngleStep(elementRadius)
	-- code to get value from cache
	local cacheKey = elementRadius / self.radiusY;
	local angleStep = self.cache.angleStep[cacheKey];
	if (angleStep ~= nil) then
		return angleStep;
	end
	-- radius of ellipse differs on each point, but we won't consider this (use "self:calculateRadiusAverage();" instead of "self.radiusY"?)
	-- this function considers that all of it's elements are circles, we need to recalculate arc length around this circle, it will be a bit bigger than element radius
	local tanAngleDiv4 = cacheKey / 2; -- cache key contains some of the math already
	angleStep = atan(tanAngleDiv4) * 4;
	-- commented formula doesn't consider that arc length is not equal to double radius
	--angleStep = 720.0 / (self:calculatePerimeter() / elementRadius); -- 720 because we passed radius, not diameter
	self.cache.angleStep[cacheKey] = angleStep;
	--print("radiusEllipse " .. radiusEllipse .. " elementRadius " .. elementRadius .. " angle " .. angleStep);
	return angleStep;
end

--- Calculate number of elements that can fit in arc from -angleArc to angleArc using current ellipse radiuses
-- @param elementRadius radius of elements that are required to fit
-- @return number of elements that can fit in HUD arc at current ellipse radiuses
function DHUDEllipseMath:calculateNumElementsFit(elementRadius)
	-- code to get value from cache
	local cacheKey = elementRadius / self.radiusY;
	local numFit = self.cache.numFit[cacheKey];
	if (numFit ~= nil) then
		return numFit;
	end
	-- calculate
	numFit = floor((self.angleArc * 2) / self:calculateAngleStep(elementRadius)); -- -1 + 1 due to element at start and end occuping half radius
	self.cache.numFit[cacheKey] = numFit;
	return numFit;
end

--- Calculate height of current ellipse arc
-- @return arc height
function DHUDEllipseMath:calculateArcHeight()
	-- code to get value from cache
	local cacheKey = self.radiusY;
	local arcHeight = self.cache.arcHeight[cacheKey];
	if (arcHeight ~= nil) then
		return arcHeight;
	end
	-- calculate
	arcHeight = sin(self.angleArc) * self.radiusY * 2;
	self.cache.arcHeight[cacheKey] = arcHeight;
	return arcHeight;
end

--- Calculate angle at which GUI should start placing elements
-- @param elementRadius radius of elements that are required to fit
-- @param targetArcHeight arcHeight to target or nil if need to use current
-- @param distributeSpace if true then free space will be distributed at top and bottom
-- @return angle at which GUI should start placing elements
function DHUDEllipseMath:calculateAngleBegin(elementRadius, targetArcHeight, distributeSpace)
	-- default var
	targetArcHeight = targetArcHeight or self:calculateArcHeight();
	-- code to get value from cache
	local cacheKey = elementRadius / targetArcHeight * (distributeSpace and 1 or -1);
	local angleBegin = self.cache.angleBegin[cacheKey];
	if (angleBegin ~= nil) then
		return angleBegin;
	end
	-- calculate
	local angleArcToUse = self.angleArc * targetArcHeight / self:calculateArcHeight();
	angleBegin = -angleArcToUse;
	if (distributeSpace) then
		angleBegin = angleBegin + ((angleArcToUse * 2) % self:calculateAngleStep(elementRadius)) / 2;
	end
	return angleBegin;
end
