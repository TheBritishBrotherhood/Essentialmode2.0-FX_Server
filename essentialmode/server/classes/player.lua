-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --

-- restart essentialmode

function CreatePlayer(source, result)
	local self = {}

	self.source = source
	self.permission_level =result.permission_level
	self.money = result.money
	self.bank = result.bank
	self.identifier = result.identifier
	self.group = result.group
	self.coords = {x = 0.0, y = 0.0, z = 0.0}
	self.session = {}
	self.bankDisplayed = false

	local rTable = {}

	rTable.setMoney = function(m)
		local prevMoney = self.money
		local newMoney = m

		self.money = m

		if((prevMoney - newMoney) < 0)then
			TriggerClientEvent("es:addedMoney", self.source, math.abs(prevMoney - newMoney), settings.defaultSettings.nativeMoneySystem)
		else
			TriggerClientEvent("es:removedMoney", self.source, math.abs(prevMoney - newMoney), settings.defaultSettings.nativeMoneySystem)
		end

		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateMoney', self.source , self.money)
		end
	end

	rTable.getMoney = function()
		return self.money
	end

	rTable.setBankBalance = function(m)
		local prevBank = self.bank
		local newBank = m

		self.bank = m

		if((prevBank - newBank) < 0)then
		TriggerClientEvent("es:addedBank", self.source, math.abs(prevBank - newBank), settings.defaultSettings.nativeMoneySystem)
		else
			TriggerClientEvent("es:removedBank", self.source, math.abs(prevBank - newBank), settings.defaultSettings.nativeMoneySystem)
		end

		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateBank', self.source , self.bank)
		end
		--[[TriggerEvent("es:setPlayerData", self.source, "bank", m, function(response, success)
			self.bank = m
		end)--]]
	end

	rTable.getBank = function()
		return self.bank
	end

	rTable.getCoords = function()
		return self.coords
	end

	rTable.setCoords = function(x, y, z)
		self.coords = {x = x, y = y, z = z}
	end

	rTable.kick = function(r)
		DropPlayer(self.source, r)
	end

	rTable.addMoney = function(m)
		local newMoney = self.money + m

		self.money = newMoney

		TriggerClientEvent("es:addedMoney", self.source, m, settings.defaultSettings.nativeMoneySystem)
		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateMoney', self.source , self.money)
		end
	end

	rTable.removeMoney = function(m)
		local newMoney = self.money - m

		self.money = newMoney

		TriggerClientEvent("es:removedMoney", self.source, m, settings.defaultSettings.nativeMoneySystem)
		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateMoney', self.source , self.money)
		end
	end

	rTable.addBank = function(m)
		local newBank = self.bank + m
		self.bank = newBank
		TriggerClientEvent("es:addedBank", self.source, m, settings.defaultSettings.nativeMoneySystem)
		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateBank', self.source , self.bank)
		end
	end

	rTable.removeBank = function(m)
		local newBank = self.bank - m
		self.bank = newBank
		TriggerClientEvent("es:removedBank", self.source, m, settings.defaultSettings.nativeMoneySystem)
		if not settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent('es:activateBank', self.source , self.bank)
		end
	end

	rTable.displayMoney = function(m)
		if settings.defaultSettings.nativeMoneySystem then
			TriggerClientEvent("es:displayMoney", self.source, math.floor(m))
		else
			TriggerClientEvent('es:activateMoney', self.source , self.money)
		end
	end

	rTable.displayBank = function(m)
		if not self.bankDisplayed then
			if settings.defaultSettings.nativeMoneySystem then
				TriggerClientEvent("es:displayBank", self.source, math.floor(m))
			else
				TriggerClientEvent("es:activateBank", self.source, self.bank)
			end
			self.bankDisplayed = true
		end
	end

	rTable.setSessionVar = function(key, value)
		self.session[key] = value
	end

	rTable.getSessionVar = function(k)
		return self.session[k]
	end

	rTable.getPermissions = function()
		return self.permission_level
	end

	rTable.setPermissions = function(p)
		self.permission_level = p
	end

	rTable.getIdentifier = function(i)
		return self.identifier
	end

	rTable.getGroup = function()
		return self.group
	end

	rTable.set = function(k, v)
		self[k] = v
	end

	rTable.get = function(k)
		return self[k]
	end

	rTable.setGlobal = function(g, default)
		self[g] = default or ""

		rTable["get" .. g:gsub("^%l", string.upper)] = function()
			return self[g]
		end

		rTable["set" .. g:gsub("^%l", string.upper)] = function(e)
			self[g] = e
		end

		Users[self.source] = rTable
	end

	return rTable
end