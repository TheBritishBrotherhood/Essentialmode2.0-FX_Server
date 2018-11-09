-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --

_VERSION = '4.1.6 [Async]'

-- Server
Users = {}
commands = {}
settings = {}
settings.defaultSettings = {
	['pvpEnabled'] = true,
	['permissionDenied'] = false,
	['debugInformation'] = false,
	['startingCash'] = 500,
	['startingBank'] = 500,
	['startingGroup'] = "user",
	['startingPermission'] = 0,
	['enableRankDecorators'] = false,
	['moneyIcon'] = "$",
	['nativeMoneySystem'] = false,
	['commandDelimeter'] = '/'
}
settings.sessionSettings = {}

AddEventHandler('playerDropped', function()
	local src = tonumber(source)
	if(Users[src]) or Users[src] ~= nil then
		MySQL.Sync.execute("UPDATE users SET `money`=@value, `bank`=@v2 WHERE identifier = @identifier", {
			['@value'] = Users[src].getMoney(),
			['@v2'] = Users[src].getBank(),
			['@identifier'] = Users[src].get('identifier')
		})
		print('\nThe player: ' .. Users[src].get('identifier') .. ' has disconnected!\n')
		Users[src] = nil
	end
end)

local justJoined = {}

RegisterServerEvent('es:firstJoinProper')
AddEventHandler('es:firstJoinProper', function()
	local Source = source
	Citizen.CreateThread(function()
		local id
		for k,v in ipairs(GetPlayerIdentifiers(Source))do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				id = v
				break
			end
		end

		if not id then
			DropPlayer(Source, "SteamID not found, please try reconnecting with Steam open.")
		else
			registerUser(id, Source)
			justJoined[Source] = true

			if(settings.defaultSettings.pvpEnabled)then
				TriggerClientEvent("es:enablePvp", Source)
			end
		end

		return
	end)
end)

AddEventHandler('es:setSessionSetting', function(k, v)
	settings.sessionSettings[k] = v
end)

AddEventHandler('es:getSessionSetting', function(k, cb)
	cb(settings.sessionSettings[k])
end)

RegisterServerEvent('playerSpawn')
AddEventHandler('playerSpawn', function()
	if(justJoined[source])then
		TriggerEvent("es:firstSpawn", source, Users[source])
		justJoined[source] = nil
	end
end)

AddEventHandler("es:setDefaultSettings", function(tbl)
	for k,v in pairs(tbl) do
		if(settings.defaultSettings[k] ~= nil)then
			settings.defaultSettings[k] = v
		end
	end

	debugMsg("Default settings edited.")
end)

AddEventHandler('chatMessage', function(source, n, message)
	if(startswith(message, settings.defaultSettings.commandDelimeter))then
		local command_args = stringsplit(message, " ")

		command_args[1] = string.gsub(command_args[1], settings.defaultSettings.commandDelimeter, "")

		local command = commands[command_args[1]]

		if(command)then
			CancelEvent()
			if(command.perm > 0)then
				if(Users[source].getPermissions() >= command.perm or groups[Users[source].getGroup()]:canTarget(command.group))then
					command.cmd(source, command_args, Users[source])
					TriggerEvent("es:adminCommandRan", source, command_args, Users[source])
				else
					command.callbackfailed(source, command_args, Users[source])
					TriggerEvent("es:adminCommandFailed", source, command_args, Users[source])

					if(type(settings.defaultSettings.permissionDenied) == "string" and not WasEventCanceled())then
						TriggerClientEvent('chatMessage', source, "", {0,0,0}, defaultSettings.permissionDenied)
					end

					debugMsg("Non admin (" .. GetPlayerName(source) .. ") attempted to run admin command: " .. command_args[1])
				end
			else
				command.cmd(source, command_args, Users[source])
				TriggerEvent("es:userCommandRan", source, command_args)
			end
			
			TriggerEvent("es:commandRan", source, command_args, Users[source])
		else
			TriggerEvent('es:invalidCommandHandler', source, command_args, Users[source])

			if WasEventCanceled() then
				CancelEvent()
			end
		end
	else
		TriggerEvent('es:chatMessage', source, message, Users[source])
	end
end)

function addCommand(command, callback)
	commands[command] = {}
	commands[command].perm = 0
	commands[command].group = "user"
	commands[command].cmd = callback

	debugMsg("Command added: " .. command)
end

AddEventHandler('es:addCommand', function(command, callback)
	addCommand(command, callback)
end)

function addAdminCommand(command, perm, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = perm
	commands[command].group = "superadmin"
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Admin command added: " .. command .. ", requires permission level: " .. perm)
end

AddEventHandler('es:addAdminCommand', function(command, perm, callback, callbackfailed)
	addAdminCommand(command, perm, callback, callbackfailed)
end)

function addGroupCommand(command, group, callback, callbackfailed)
	commands[command] = {}
	commands[command].perm = math.maxinteger
	commands[command].group = group
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	debugMsg("Group command added: " .. command .. ", requires group: " .. group)
end

AddEventHandler('es:addGroupCommand', function(command, group, callback, callbackfailed)
	addGroupCommand(command, group, callback, callbackfailed)
end)

RegisterServerEvent('es:updatePositions')
AddEventHandler('es:updatePositions', function(x, y, z)
	if(Users[source])then
		Users[source].setCoords(x, y, z)
	end
end)

-- Info command
commands['info'] = {}
commands['info'].perm = 0
commands['info'].cmd = function(source, args, user)
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Version: ^2 " .. _VERSION)
	TriggerClientEvent('chatMessage', source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Commands loaded: ^2 " .. (returnIndexesInTable(commands) - 1))
end

AddEventHandler('es:playerLoaded', function(source, user)
    -- Get the players money amount
        local m = user.getMoney()
        local b = user.getBank()
        print("Money: "..m)
        print("Bank: "..b)
        user.displayMoney(m)
        user.displayBank(b)
end)--]]