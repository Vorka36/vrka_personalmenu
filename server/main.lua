ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function getMaximumGrade(jobname)
	local result = MySQL.Sync.fetchAll("SELECT * FROM job_grades WHERE job_name = @jobname ORDER BY `grade` DESC ;", {
		['@jobname'] = jobname
	})

	if result[1] ~= nil then
		return result[1].grade
	end

	return nil
end

ESX.RegisterServerCallback('VorkA-PersonalMenu:Bill_getBills', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local bills = {}

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		for i = 1, #result, 1 do
			table.insert(bills, {
				id         = result[i].id,
				label      = result[i].label,
				amount     = result[i].amount
			})
		end

		cb(bills)
	end)
end)

ESX.RegisterServerCallback('VorkA-PersonalMenu:Admin_getUsergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer ~= nil then
		local playerGroup = xPlayer.getGroup()
     	local ident = xPlayer.getIdentifier()

        if playerGroup ~= nil then 
            cb(playerGroup)
        else
            cb(nil)
        end
	else
		cb(nil)
	end
end)

-- Weapon Menu --

RegisterServerEvent("VorkA-PersonalMenu:Weapon_addAmmoToPedS")
AddEventHandler("VorkA-PersonalMenu:Weapon_addAmmoToPedS", function(plyId, value, quantity)
	TriggerClientEvent('VorkA-PersonalMenu:Weapon_addAmmoToPedC', plyId, value, quantity)
end)

-- Admin Menu --

RegisterServerEvent("VorkA-PersonalMenu:Admin_BringS")
AddEventHandler("VorkA-PersonalMenu:Admin_BringS", function(plyId, plyPedCoords)
	TriggerClientEvent('VorkA-PersonalMenu:Admin_BringC', plyId, plyPedCoords)
end)

RegisterServerEvent("VorkA-PersonalMenu:Admin_giveCash")
AddEventHandler("VorkA-PersonalMenu:Admin_giveCash", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addMoney((total))

	local item = '$'
	local message = 'GIVE de '
	TriggerClientEvent('esx:showNotification', _source, message .. total .. item)
end)

RegisterServerEvent("VorkA-PersonalMenu:Admin_giveBank")
AddEventHandler("VorkA-PersonalMenu:Admin_giveBank", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addAccountMoney('bank', total)

	local item = '$ en banque'
	local message = 'GIVE de '
	TriggerClientEvent('esx:showNotification', _source, message .. total .. item)
end)

RegisterServerEvent("VorkA-PersonalMenu:Admin_giveDirtyMoney")
AddEventHandler("VorkA-PersonalMenu:Admin_giveDirtyMoney", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addAccountMoney('black_money', total)

	local item = '$ sale.'
	local message = 'GIVE de '
	TriggerClientEvent('esx:showNotification', _source, message..total..item)
end)

-- Grade Menu --

RegisterServerEvent('VorkA-PersonalMenu:Boss_promouvoirplayer')
AddEventHandler('VorkA-PersonalMenu:Boss_promouvoirplayer', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local maximumgrade = tonumber(getMaximumGrade(sourceXPlayer.job.name)) - 1

	if (targetXPlayer.job.grade == maximumgrade) then
		TriggerClientEvent('esx:showNotification', _source, "Vous devez demander une autorisation du ~r~Gouvernement~w~.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) + 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~promu " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~promu par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('VorkA-PersonalMenu:Boss_destituerplayer')
AddEventHandler('VorkA-PersonalMenu:Boss_destituerplayer', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~r~rétrograder~w~ davantage.")
	else
		if (sourceXPlayer.job.name == targetXPlayer.job.name) then
			local grade = tonumber(targetXPlayer.job.grade) - 1
			local job = targetXPlayer.job.name

			targetXPlayer.setJob(job, grade)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~rétrogradé " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~r~rétrogradé par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('VorkA-PersonalMenu:Boss_recruterplayer')
AddEventHandler('VorkA-PersonalMenu:Boss_recruterplayer', function(target, job, grade)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	
	targetXPlayer.setJob(job, grade)

	TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~recruté " .. targetXPlayer.name .. "~w~.")
	TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~embauché par " .. sourceXPlayer.name .. "~w~.")
end)

RegisterServerEvent('VorkA-PersonalMenu:Boss_virerplayer')
AddEventHandler('VorkA-PersonalMenu:Boss_virerplayer', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local job = "unemployed"
	local grade = "0"

	if (sourceXPlayer.job.name == targetXPlayer.job.name) then

		targetXPlayer.setJob(job, grade)

		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~viré " .. targetXPlayer.name .. "~w~.")
		TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~viré par " .. sourceXPlayer.name .. "~w~.")
	else
		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
	end
end)

RegisterServerEvent('VorkA-PersonalMenu:Boss_promouvoirplayer2')
AddEventHandler('VorkA-PersonalMenu:Boss_promouvoirplayer2', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local maximumgrade = tonumber(getMaximumGrade(sourceXPlayer.job2.name)) -1

	if (targetXPlayer.job2.grade == maximumgrade) then
		TriggerClientEvent('esx:showNotification', _source, "Vous devez demander une autorisation du ~r~Gouvernement~w~.")
	else
		if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
			local grade2 = tonumber(targetXPlayer.job2.grade) + 1
			local job2 = targetXPlayer.job2.name

			targetXPlayer.setJob2(job2, grade2)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~promu " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~promu par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('VorkA-PersonalMenu:Boss_destituerplayer2')
AddEventHandler('VorkA-PersonalMenu:Boss_destituerplayer2', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if (targetXPlayer.job2.grade == 0) then
		TriggerClientEvent('esx:showNotification', _source, "Vous ne pouvez pas plus ~r~rétrograder~w~ davantage.")
	else
		if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
			local grade2 = tonumber(targetXPlayer.job2.grade) - 1
			local job2 = targetXPlayer.job2.name

			targetXPlayer.setJob2(job2, grade2)

			TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~rétrogradé " .. targetXPlayer.name .. "~w~.")
			TriggerClientEvent('esx:showNotification', target, "Vous avez été ~r~rétrogradé par " .. sourceXPlayer.name .. "~w~.")
		else
			TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
		end
	end
end)

RegisterServerEvent('VorkA-PersonalMenu:Boss_recruterplayer2')
AddEventHandler('VorkA-PersonalMenu:Boss_recruterplayer2', function(target, job2, grade2)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	
	targetXPlayer.setJob2(job2, grade2)

	TriggerClientEvent('esx:showNotification', _source, "Vous avez ~g~recruté " .. targetXPlayer.name .. "~w~.")
	TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~embauché par " .. sourceXPlayer.name .. "~w~.")
end)

RegisterServerEvent('VorkA-PersonalMenu:Boss_virerplayer2')
AddEventHandler('VorkA-PersonalMenu:Boss_virerplayer2', function(target)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	local job2 = "unemployed"
	local grade2 = "0"

	if (sourceXPlayer.job2.name == targetXPlayer.job2.name) then
		targetXPlayer.setJob2(job2, grade2)

		TriggerClientEvent('esx:showNotification', _source, "Vous avez ~r~viré " .. targetXPlayer.name .. "~w~.")
		TriggerClientEvent('esx:showNotification', target, "Vous avez été ~g~viré par " .. sourceXPlayer.name .. "~w~.")
	else
		TriggerClientEvent('esx:showNotification', _source, "Vous n'avez pas ~r~l'autorisation~w~.")
	end
end)

-- HANDSUP --

RegisterServerEvent('VorkA-PersonalMenu:getSurrenderStatus')
AddEventHandler('VorkA-PersonalMenu:getSurrenderStatus', function(event, targetID)
	TriggerClientEvent(event, targetID, event, source)
end)

RegisterServerEvent('VorkA-PersonalMenu:sendSurrenderStatus')
AddEventHandler('VorkA-PersonalMenu:sendSurrenderStatus', function(event, targetID, handsup)
	TriggerClientEvent(event, targetID, handsup)
end)

RegisterServerEvent('VorkA-PersonalMenu:reSendSurrenderStatus')
AddEventHandler('VorkA-PersonalMenu:reSendSurrenderStatus', function(event, targetID, handsup)
	TriggerClientEvent(event, targetID, handsup)
end)