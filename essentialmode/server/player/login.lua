-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT ANYONE BUT THE PERSON THAT SENT YOU THIS FILE! --

function LoadUser(identifier, source, new)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier=@identifier", {['@identifier'] = identifier})
		Users[source] = CreatePlayer(source, result[1])
	
		TriggerEvent('es:playerLoaded', source, Users[source])

		-- Client Stuff
		TriggerClientEvent('es:setPlayerDecorator', source, 'rank', Users[source]:getPermissions())
		TriggerClientEvent('es:setMoneyIcon', source,settings.defaultSettings.moneyIcon)

	if(new)then
		TriggerEvent('es:newPlayerLoaded', source, Users[source])
	end
end

function getPlayerFromId(id)
	return Users[id]
end

AddEventHandler('es:getPlayers', function(cb)
	cb(Users)
end)

function hasAccount(identifier)
local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @name", {['@name'] = identifier})
	if(result[1] == nil) then
		return false
	else
		return true
	end
end

-- identifier = identifier, money = 0, bank = 0, group = "user", permission_level = 0
function registerUser(identifier, source)
	if not hasAccount(identifier) then
		MySQL.Sync.execute("INSERT INTO users (`identifier`,`permission_level`,`money`,`bank`,`group`) VALUES (@identifier,@permission_level,@money,@bank,@group)", { ['@identifier'] = identifier, ['@permission_level'] = settings.defaultSettings.startingPermission, ['@money'] = settings.defaultSettings.startingCash, ['@bank'] = settings.defaultSettings.startingBank, ['@group'] = settings.defaultSettings.startingGroup})
		LoadUser(identifier, source, true)
	else
		LoadUser(identifier, source, false)
	end
end

AddEventHandler("es:setPlayerData", function(user, k, v, cb)
    if(Users[user])then
        if(Users[user].get(k))then

            if(k ~= "money" and k~= "permission_level") then
                Users[user].set(k, v)
                MySQL.Async.execute("UPDATE users SET ".. k .." = ".. v .. " WHERE identifier = @identifier",{['@identifier'] = Users[user].get('identifier')}, function(rowsUpdate)
                    print("Player Data edited")
                end)
            elseif(k == "permission_level")then
                Users[user].set(k, v)
                MySQL.Async.execute("UPDATE users SET permission_level=@value WHERE identifier = @identifier",{['@value'] = v, ['@identifier'] = Users[user].get('identifier')}, function(rowsUpdate)
                    print("Player Data edited")
                end)                
            end
            cb("Player data edited.", true)
        else
            cb("Column does not exist!", false)
        end
    else
        cb("User could not be found!", false)
    end
end)

AddEventHandler("es:setPlayerDataId", function(user, k, v, cb)
	MySQL.Async.execute("UPDATE users SET @key=@value WHERE identifier = @identifier", { ['@key'] = k, ['@value'] = v, ['@identifier'] = user}, 
		function(rowsUpdate)
			print("Player Datas edited")
		end)

	cb("Player data edited.", true)
end)

AddEventHandler("es:getPlayerFromId", function(user, cb)
	if(Users)then
		if(Users[user])then
			cb(Users[user])
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

AddEventHandler("es:getPlayerFromIdentifier", function(identifier, cb)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @name" , {['@name'] = identifier})
	if(result[1])then
		cb(result[1])
	else
		cb(nil)
	end
end)

-- Function to update player money every 60 seconds.
local function savePlayerMoney()
	SetTimeout(60000, function()
		for k,v in pairs(Users)do
			if Users[k] ~= nil then
				MySQL.Async.execute("UPDATE users SET money=@money, bank=@bank WHERE identifier=@identifier", { ['@money'] = v.getMoney(), ['@bank'] = v.getBank(), ['@identifier'] = v.get('identifier')})
			end
		end

		savePlayerMoney()
	end)
end

savePlayerMoney()