-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsSessionStarted() then
			TriggerServerEvent('es:firstJoinProper')
			TriggerEvent('es:allowedToSpawn')
			return
		end
	end
end)

local loaded = false
local cashy = 0
local oldPos

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local pos = GetEntityCoords(GetPlayerPed(-1))

		if(oldPos ~= pos)then
			TriggerServerEvent('es:updatePositions', pos.x, pos.y, pos.z)

			if(loaded)then
				SendNUIMessage({
					setmoney = true,
					money = cashy,
					setbank = true,
					bank = cashy
				})

				loaded = false
			end
			oldPos = pos
		end
	end
end)

local myDecorators = {}

RegisterNetEvent("es:setPlayerDecorator")
AddEventHandler("es:setPlayerDecorator", function(key, value, doNow)
	myDecorators[key] = value
	DecorRegister(key, 3)

	if(doNow)then
		DecorSetInt(GetPlayerPed(-1), key, value)
	end
end)

local enableNative = {false, false}

local firstSpawn = true
AddEventHandler("playerSpawned", function()
	for k,v in pairs(myDecorators)do
		DecorSetInt(GetPlayerPed(-1), k, v)
	end

	if enableNative[1] then
		N_0xc2d15bef167e27bc()
		SetPlayerCashChange(1, 0)
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		SetPlayerCashChange(-1, 0)
	end

	if enableNative[2] then
		SetMultiplayerBankCash()
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		SetPlayerCashChange(0, 1)
		SetPlayerCashChange(0, -1)
	end
end)

RegisterNetEvent('es:setMoneyIcon')
AddEventHandler('es:setMoneyIcon', function(i)
	SendNUIMessage({
		seticon = true,
		icon = i
	})
end)

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(e)
	SendNUIMessage({
		setmoney = true,
		money = e
	})
end)

RegisterNetEvent('es:activateBank')
AddEventHandler('es:activateBank', function(e)
	SendNUIMessage({
		setbank = true,
		bank = e
	})
end)

RegisterNetEvent('es:displayMoney')
AddEventHandler('es:displayMoney', function(a)
	-- Found by FiveM forum user @Lobix300
	N_0xc2d15bef167e27bc()
	SetPlayerCashChange(1, 0)
	Citizen.InvokeNative(0x170F541E1CADD1DE, true)
	SetPlayerCashChange(a - 1, 0)

	enableNative[1] = true
end)

RegisterNetEvent('es:displayBank')
AddEventHandler('es:displayBank', function(a)
	-- Found by FiveM forum user @Lobix300
	SetMultiplayerBankCash()
	SetPlayerCashChange(0, 1)
	Citizen.InvokeNative(0x170F541E1CADD1DE, true)
	SetPlayerCashChange(0, a)

	enableNative[2] = true
end)

RegisterNetEvent("es:addedMoney")
AddEventHandler("es:addedMoney", function(m, native)
	if not native then
		SendNUIMessage({
			addcash = true,
			money = m
		})
	else
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		Citizen.InvokeNative(0x0772DF77852C2E30, math.floor(m), 0)
	end
end)

RegisterNetEvent("es:removedMoney")
AddEventHandler("es:removedMoney", function(m, native, current)
	if not native then
		SendNUIMessage({
			removecash = true,
			money = m
		})
	else
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		Citizen.InvokeNative(0x0772DF77852C2E30, -math.floor(m), 0)
	end
end)

RegisterNetEvent('es:addedBank')
AddEventHandler('es:addedBank', function(m, native)
	if not native then
		SendNUIMessage({
			addbank = true,
			bank = m
		})
	else
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		Citizen.InvokeNative(0x0772DF77852C2E30, 0, math.floor(m))
	end
end)

RegisterNetEvent('es:removedBank')
AddEventHandler('es:removedBank', function(m, native)
	if not native then
		SendNUIMessage({
			removebank = true,
			bank = m
		})
	else
		Citizen.InvokeNative(0x170F541E1CADD1DE, true)
		Citizen.InvokeNative(0x0772DF77852C2E30, 0, -math.floor(m))
	end
end)

RegisterNetEvent("es:setMoneyDisplay")
AddEventHandler("es:setMoneyDisplay", function(val)
	SendNUIMessage({
		setDisplay = true,
		display = val
	})
end)

RegisterNetEvent("es:enablePvp")
AddEventHandler("es:enablePvp", function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			for i = 0,32 do
				if NetworkIsPlayerConnected(i) then
					if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
						SetCanAttackFriendly(GetPlayerPed(i), true, true)
						NetworkSetFriendlyFireOption(true)
					end
				end
			end
		end
	end)
end)