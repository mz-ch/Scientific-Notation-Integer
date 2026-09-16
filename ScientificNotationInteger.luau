local ScientificNotation = {}
local metatable = {}
metatable.__index = metatable

local DISPLAYED_PRECISION = 3 -- Number of decimal places displayed in the Abbreviate() method
local ABBREVIATIONS = {"", "K", "M", "B", "T", "Qa", "Qi","Sx", "Sp","O", "N", "Dc", "Udc", "Ddc", "Tdc", "Qadc", "Qidc", "Sxdc", "Spdc", "Ocdc", "Nmdc", "Vg", "Uvg", "Dvg", "Tvg", "Qavg", "Qivg", "Sxvg", "Spvg", "Ovg", "Nvg", "Tg", "Utg", "Dtg", "Ttg", "Qatg", "Qitg", "Sxtg", "Sptg", "Octg", "Notg", "Qd"}


local function numberToScientificNotation(num: number)
	if typeof(num) ~= "number" then
		error(`{num} is invalid type`)
		return
	end
	
	local result = metatable.new()
	local sign = 1
	
	if num < 0 then
		sign = -1
		num = -num
	elseif num == 0 then
		result.exponent = 0
		result.mantissa = 0
		return result
	end
	
	while num >= 10 do
		num /= 10
		result.exponent += 1
	end
	
	while num < 1 do
		num *= 10
		result.exponent -= 1
	end
	
	result.mantissa = num * sign
	return result
end


function ScientificNotation.new(exponent: number, mantissa: number)
	local self = {}
	setmetatable(self, metatable)
	
	if not mantissa or typeof(mantissa) ~= "number" then
		mantissa = 0.0
	end
	
	if not exponent or typeof(exponent) ~= "number" then
		exponent = 0
	elseif typeof(exponent) == "number" then
		exponent = math.floor(exponent)
	end
	
	self.mantissa = mantissa
	self.exponent = exponent
	self.__type = "ScientificNotation"
	
	return self
end

function metatable:GetMantissa()
	return self.mantissa
end

function metatable:GetExponent()
	return self.exponent
end

function metatable:Abbreviate()
	self:Normalize()
	local num = self.mantissa * (10 ^ (self.exponent % 3))
	num = math.floor(num * (10 ^ DISPLAYED_PRECISION)) / (10 ^ DISPLAYED_PRECISION)
	if self.exponent >= 0 then
		local abbreviation = ABBREVIATIONS[(self.exponent // 3) + 1]
		return num.. abbreviation
	else
		return `{math.round(self.mantissa * DISPLAYED_PRECISION) / DISPLAYED_PRECISION} * 10^{self.exponent}`
	end
end

function metatable:Normalize()
	local sign = 1

	if self.mantissa == 0 then
		self.exponent = 0
	elseif self.mantissa < 0 then
		self.mantissa *= -1
		sign = -1
	end

	while self.mantissa >= 10 do
		self.mantissa /= 10
		self.exponent += 1
	end

	while self.mantissa < 1 do
		self.mantissa *= 10
		self.exponent -= 1
	end

	self.mantissa *= sign
end

metatable.__tostring = function(self)
	if self.exponent == 0 then
		return "0.0"
	end

	local mantissaString = tostring(self.mantissa)
	local decimalPointIndex = string.find(mantissaString, ".")
	local newString = string.sub(mantissaString, 0, decimalPointIndex) .. string.sub(mantissaString, decimalPointIndex + 2, -1)

	if self.exponent >= 0 then
		if self.exponent >= #mantissaString then

			for i = 1, self.exponent - #mantissaString, 1 do
				newString ..= "0"
			end

		else
			newString = string.sub(newString, self.exponent, -1) .. "." .. string.sub(mantissaString, self.exponent + 1, -1)
		end

	else
		local decimalPlaces = ""

		for i = 1, -self.exponent, 1 do
			decimalPlaces..= "0"
		end

		newString = decimalPlaces .. "." .. newString
	end	

	return `{newString} * 10^{self.exponent}`
end

metatable.__gt = function(num1, num2)
	local SN1 = num1
	local SN2 = num2
	
	if type(num1) == "number" then
		SN1 = numberToScientificNotation(num1)
	elseif typeof(num1) ~= "table" or num1.__type ~= "ScientificNotation" then
		error(`{num1} is invalid type`)
		return false
	end
	
	if type(num2) == "number" then
		SN1 = numberToScientificNotation(num2)
	elseif typeof(num2) ~= "table" or num2.__type ~= "ScientificNotation" then
		error(`{num2} is invalid type`)
		return false
	end
	
	SN1:Normalize()
	SN2:Normalize()
	
	if SN1.exponent > SN2.exponent then
		return true
	elseif SN1.exponent < SN2.exponent then
		return false
	end

	return SN1.mantissa > SN2.mantissa
end

metatable.__lt = function(num1, num2)
	local SN1 = num1
	local SN2 = num2

	if type(num1) == "number" then
		SN1 = numberToScientificNotation(num1)
	elseif typeof(num1) ~= "table" or num1.__type ~= "ScientificNotation" then
		error(`{num1} is invalid type`)
		return false
	end

	if type(num2) == "number" then
		SN1 = numberToScientificNotation(num2)
	elseif typeof(num2) ~= "table" or num2.__type ~= "ScientificNotation" then
		error(`{num2} is invalid type`)
		return false
	end

	SN1:Normalize()
	SN2:Normalize()

	if SN1.exponent > SN2.exponent then
		return false
	elseif SN1.exponent < SN2.exponent then
		return true
	end

	return SN1.mantissa < SN2.mantissa
end

metatable.__eq = function(num1, num2)
	local SN1 = num1
	local SN2 = num2

	if type(num1) == "number" then
		SN1 = numberToScientificNotation(num1)
	elseif typeof(num1) ~= "table" or num1.__type ~= "ScientificNotation" then
		error(`{num1} is invalid type`)
		return false
	end

	if type(num2) == "number" then
		SN1 = numberToScientificNotation(num2)
	elseif typeof(num2) ~= "table" or num2.__type ~= "ScientificNotation" then
		error(`{num2} is invalid type`)
		return false
	end

	SN1:Normalize()
	SN2:Normalize()

	return SN1.mantissa == SN2.mantissa and SN1.exponent == SN2.exponent
end

metatable.__add = function(num1, num2)
	local SN1 = num1
	local SN2 = num2

	if type(num1) == "number" then
		SN1 = numberToScientificNotation(num1)
	elseif typeof(num1) ~= "table" or num1.__type ~= "ScientificNotation" then
		error(`{num1} is invalid type`)
		return false
	end

	if type(num2) == "number" then
		SN1 = numberToScientificNotation(num2)
	elseif typeof(num2) ~= "table" or num2.__type ~= "ScientificNotation" then
		error(`{num2} is invalid type`)
		return false
	end

	SN1:Normalize()
	SN2:Normalize()
	local sumSN = ScientificNotation.new()
	
	if SN1.exponent > SN2.exponent then
		local adjustedMantissa = SN2.mantissa / (10 ^ (SN1.exponent - SN2.exponent))
		sumSN.mantissa = SN1.mantissa + adjustedMantissa
	elseif SN1.exponent < SN2.exponent then
		local adjustedMantissa = SN1.mantissa / (10 ^ (SN2.exponent - SN1.exponent))
		sumSN.mantissa = SN2.mantissa + adjustedMantissa
	else
		sumSN.mantissa = SN1.mantissa + SN2.mantissa
	end
	
	sumSN.exponent = math.max(SN1.exponent, SN2.exponent)
	sumSN:Normalize()
	return sumSN
end

metatable.__sub = function(num1, num2)
	local SN1 = num1
	local SN2 = num2

	if type(num1) == "number" then
		SN1 = numberToScientificNotation(num1)
	elseif typeof(num1) ~= "table" or num1.__type ~= "ScientificNotation" then
		error(`{num1} is invalid type`)
		return false
	end

	if type(num2) == "number" then
		SN1 = numberToScientificNotation(num2)
	elseif typeof(num2) ~= "table" or num2.__type ~= "ScientificNotation" then
		error(`{num2} is invalid type`)
		return false
	end

	SN1:Normalize()
	SN2:Normalize()
	local differenceSN = ScientificNotation.new()
	
	local sign = 1
	
	if SN1.exponent > SN2.exponent then
		local adjustedMantissa = SN2.mantissa / (10 ^ (SN1.exponent - SN2.exponent))
		differenceSN.mantissa = SN1.mantissa - adjustedMantissa
	elseif SN1.exponent < SN2.exponent then
		local adjustedMantissa = SN1.mantissa / (10 ^ (SN2.exponent - SN1.exponent))
		differenceSN.mantissa = SN2.mantissa - adjustedMantissa
		sign = -1	
	elseif SN1 > SN2 then
		differenceSN.mantissa = SN1.mantissa - SN2.mantissa
	elseif SN1 < SN2 then
		differenceSN.mantissa = SN2.mantissa - SN1.mantissa
		sign = -1
	else
		differenceSN.mantissa = 0.0
	end
	
	differenceSN.exponent = math.max(SN1.exponent, SN2.exponent)
	differenceSN:Normalize()
	differenceSN.mantissa *= sign
	return differenceSN
end

metatable.__mul = function(num1, num2)
	local SN1 = num1
	local SN2 = num2

	if type(num1) == "number" then
		SN1 = numberToScientificNotation(num1)
	elseif typeof(num1) ~= "table" or num1.__type ~= "ScientificNotation" then
		error(`{num1} is invalid type`)
		return false
	end

	if type(num2) == "number" then
		SN1 = numberToScientificNotation(num2)
	elseif typeof(num2) ~= "table" or num2.__type ~= "ScientificNotation" then
		error(`{num2} is invalid type`)
		return false
	end

	SN1:Normalize()
	SN2:Normalize()
	local productSN = ScientificNotation.new()
	
	productSN.mantissa = SN1.mantissa * SN2.mantissa
	productSN.exponent = SN1.exponent + SN2.exponent
	
	productSN:Normalize()
	return productSN
end

metatable.__div = function(num1, num2)
	local SN1 = num1
	local SN2 = num2

	if type(num1) == "number" then
		SN1 = numberToScientificNotation(num1)
	elseif typeof(num1) ~= "table" or num1.__type ~= "ScientificNotation" then
		error(`{num1} is invalid type`)
		return false
	end

	if type(num2) == "number" then
		SN1 = numberToScientificNotation(num2)
	elseif typeof(num2) ~= "table" or num2.__type ~= "ScientificNotation" then
		error(`{num2} is invalid type`)
		return false
	end

	SN1:Normalize()
	SN2:Normalize()
	local quotientSN = ScientificNotation.new()
	
	sumSN.mantissa = SN1.mantissa / SN2.mantissa
	quotientSN.exponent = SN1.exponent - SN2.exponent
	
	quotientSN:Normalize()
	return quotientSN
end

return ScientificNotation
