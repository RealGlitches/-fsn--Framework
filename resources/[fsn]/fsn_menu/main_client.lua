local menuEnabled = false
local initialised = true

function fsn_SplitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(centre)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x , y)
end

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end
function fsn_lookingAt()
	local targetVehicle = false

	local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
	local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, -1.0)
	targetVehicle = getVehicleInDirection(coordA, coordB)

	return targetVehicle
end

function ToggleActionMenu()
	menuEnabled = not menuEnabled
	if ( menuEnabled ) then
		if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
			if not IsPedGettingIntoAVehicle(GetPlayerPed(-1)) then
				FreezeEntityPosition(GetPlayerPed(-1), 0)
				SetEntityCollision(GetPlayerPed(-1), 1, 1)
				ClearPedTasks(GetPlayerPed(-1))
			end
		end

		SetNuiFocus( true, true )
		if exports.fsn_police:fsn_PDDuty() then
			if exports.fsn_police:fsn_getPDLevel() > 6 then
				pdcommand = true
			else
				pdcommand = false
			end
			police = true
		else
			police = false
			pdcommand = false
		end
		if exports.fsn_ems:fsn_EMSDuty() then
			if exports.fsn_ems:fsn_getEMSLevel() > 6 then
				emscommand = true
			else
				emscommand = false
			end
			ems = true
		else
			ems = false
			emscommand = false
		end
		if IsPedInAnyVehicle(GetPlayerPed(-1)) then
			vehicle = true
			lookingatvehicle = false
		else
			vehicle = false
			local veh = fsn_lookingAt()
			if DoesEntityExist(veh) then
				lookingatvehicle = true
				vehicleinv = json.encode(exports.fsn_vehiclecontrol:GetVehicleInventory(GetVehicleNumberPlateText(veh)))
			else
				lookingatvehicle = false
			end
		end
		SendNUIMessage({
			showmenu = true,
			dead = exports.fsn_ems:fsn_IsDead(),
			vehicle = vehicle,
			lookingatvehicle = lookingatvehicle,
			police = police,
			pdcommand = pdcommand,
			ems = ems,
			emscommand = emscommand,
			atstorage = exports["fsn_apartments"]:isNearStorage(),
		})
	else
		SetNuiFocus( false )
		SendNUIMessage({
			hidemenu = true
		})
	end
end
function fsn_NearestPlayersS(x, y, z, radius)
	local players = {}
	for id = 0, 128 do
		local ppos = GetEntityCoords(GetPlayerPed(id))
    if GetPlayerPed(id) ~= GetPlayerPed(-1) then
  		if GetDistanceBetweenCoords(ppos.x, ppos.y, ppos.z, x, y, z) < radius then
  			table.insert(players, #players+1, GetPlayerServerId(id))
  		end
    end
	end
	return players
end
local windows = {
  [1] = false,
  [2] = false,
  [3] = false,
  [4] = false
}
local last_click = 0
RegisterNetEvent('fsn_commands:getHDC')
AddEventHandler('fsn_commands:getHDC', function(hdc)
	hdccommand = hdc
end)

RegisterNUICallback( "ButtonClick", function( data, cb )
  if last_click + 1000 > GetNetworkTime() then print('toosoon') return end
  last_click = GetNetworkTime()
	local split = fsn_SplitString(data, "-")
  if ( data == "phone" ) then
		ToggleActionMenu()
		ExecuteCommand('p')
  elseif split[1] == 'hdc' then
    if split[2] == 'escort' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand(hdccommand..' escort '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'cuff' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand(hdccommand..' toggle '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'search' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand(hdccommand..' search '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'rob' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand(hdccommand..' rob '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'takephone' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand(hdccommand..' takephone '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
  elseif split[1] == 'service' then
    if split[2] == 'ems' then
        ExecuteCommand('service request ems')
        ToggleActionMenu()
    end
    if split[2] == 'taxi' then
        ExecuteCommand('service request taxi')
        ToggleActionMenu()
    end
    if split[2] == 'tow' then
        ExecuteCommand('service request tow')
        ToggleActionMenu()
    end
  elseif split[1] == 'ems' then
    if split[2] == 'command' then
      if split[3] == 'level' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          Citizen.CreateThread(function()
            DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP8", "", "", "", "", "", 2)
            local editOpen = true
            while UpdateOnscreenKeyboard() == 0 or editOpen do
              drawTxt('What ~r~EMS~w~ level do you wish to give to ~y~'..ply..'~w~?',4,1,0.5,0.35,0.6,255,255,255,255)
              if UpdateOnscreenKeyboard() ~= 0 then
                editOpen = false
                if UpdateOnscreenKeyboard() == 1 then
                  input = tonumber(GetOnscreenKeyboardResult())
                  if input then
                    ExecuteCommand('ems command level '..ply..' '..input)
                  else
                    TriggerEvent('chatMessage', '', {255,255,255}, '^4FSN | ^0Something was wrong with what you entered!')
                  end
                end
                break
              end
            Wait(1)
            end
          end)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
    end
    if split[2] == 'escort' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('ems escort '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'vehicle' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('ems vehicle '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'revive' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('ems revive '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
  elseif split[1] == 'police' then
    if split[2] == 'search' then
      --/police search all 1
      if split[3] == 'cpic' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd cpic '..ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'all' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd search all '..ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'weapons' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd search weapons '..ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'inventory' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd search inventory '..ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'money' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd search money '..ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'strip' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd search strip '..ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
    end
    if split[2] == 'k9' then
      if split[3] == 'toggle' then
        TriggerEvent("fsn_police:ToggleK9", 'a_c_husky')
      end
	    if split[3] == 'follow' then
        TriggerEvent("fsn_police:ToggleFollow")
      end
      if split[3] == 'searchperson' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd k9 search person ' .. ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'action' then
        if split[4] == 'sit' then
          TriggerEvent('fsn_police:Sit')
        end
      end
      if split[3] == 'vehicle' then
        TriggerEvent('fsn_police:GetInVehicle')
      end
    end
    if split[2] == 'command' then
      if split[3] == 'license' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('pd command givelicense '..ply..' '..split[4])
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'duty' then
        ExecuteCommand('police command duty '..GetPlayerServerId(PlayerId()))
        ToggleActionMenu()
      end
      if split[3] == 'duty1' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          ExecuteCommand('police command duty '..ply)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
      if split[3] == 'level' then
        ToggleActionMenu()
        local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
        if ply and ply ~= GetPlayerServerId(PlayerId()) then
          Citizen.CreateThread(function()
            DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP8", "", "", "", "", "", 2)
            local editOpen = true
            while UpdateOnscreenKeyboard() == 0 or editOpen do
              drawTxt('What ~b~POLICE~w~ level do you wish to give to ~y~'..ply..'~w~?',4,1,0.5,0.35,0.6,255,255,255,255)
              if UpdateOnscreenKeyboard() ~= 0 then
                editOpen = false
                if UpdateOnscreenKeyboard() == 1 then
                  input = tonumber(GetOnscreenKeyboardResult())
                  if input then
                    ExecuteCommand('police command level '..ply..' '..input)
                  else
                    TriggerEvent('chatMessage', '', {255,255,255}, '^4FSN | ^0Something was wrong with what you entered!')
                  end
                end
                break
              end
            Wait(1)
            end
          end)
        else
          TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
        end
      end
    end
    if split[2] == 'escort' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('police escort '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'impound' then
      ExecuteCommand('police impound')
    end
    if split[2] == 'impound2' then
      ExecuteCommand('police impound2')
    end
    if split[2] == 'putinveh' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('police putinveh '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'runplate' then
      ExecuteCommand('police runplate')
    end
    if split[2] == 'licenses' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('police license take '..split[3]..' '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'revive' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('police revive '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'handcuffs' then
      local ply = fsn_NearestPlayersS(GetEntityCoords(GetPlayerPed(-1)).x, GetEntityCoords(GetPlayerPed(-1)).y, GetEntityCoords(GetPlayerPed(-1)).z, 2)[1]
      if ply and ply ~= GetPlayerServerId(PlayerId()) then
        ExecuteCommand('police cuff '..ply)
      else
        TriggerEvent('fsn_notify:displayNotification', ':FSN: Nobody detected!', 'centerLeft', 3000, 'error')
      end
    end
    if split[2] == 'boot' then
      ExecuteCommand('police boot')
    end
    if split[2] == 'unboot' then
      ExecuteCommand('police unboot')
    end
  elseif split[1] == 'license' then
    if split[2] == 'id' then
      TriggerEvent('fsn_licenses:showid')
    end
    if split[2] == 'driver' then
      TriggerEvent('fsn_licenses:display', 'driver')
    end
    if split[2] == 'pilot' then
      TriggerEvent('fsn_licenses:display', 'pilot')
    end
    if split[2] == 'weapon' then
      TriggerEvent('fsn_licenses:display', 'weapon')
    end
	elseif ( split[1] == "vehicle" ) then
		if split[2] == 'race' then
			ToggleActionMenu()
			TriggerEvent('fsn_criminalmisc:racing:createRace')
			CancelEvent()
		end
		if split[2] == 'keys' then
		  TriggerEvent('fsn_vehiclecontrol:giveKeys')
		  CancelEvent()
		end
		if split[2] == 'window' then
		  if split[3] == '*' then
			if not windows[1] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
			  windows[1] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
			  windows[1] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
			if not windows[2] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
			  windows[2] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
			  windows[2] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
			if not windows[3] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2)
			  windows[3] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2)
			  windows[3] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
			if not windows[4] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3)
			  windows[4] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3)
			  windows[4] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
		  end
		  if split[3] == '1' then
			if not windows[1] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
			  windows[1] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
			  windows[1] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
		  end
		  if split[3] == '2' then
			if not windows[2] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
			  windows[2] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
			  windows[2] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
		  end
		  if split[3] == '3' then
			if not windows[3] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2)
			  windows[3] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2)
			  windows[3] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
		  end
		  if split[3] == '4' then
			if not windows[4] then
			  RollDownWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3)
			  windows[4] = true
			  TriggerEvent('fsn_notify:displayNotification', 'Window open', 'centerLeft', 3000, 'info')
			else
			  RollUpWindow(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3)
			  windows[4] = false
			  TriggerEvent('fsn_notify:displayNotification', 'Window closed', 'centerLeft', 3000, 'info')
			end
		  end
		end
		if split[2] == 'door' then
		  if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1) then
			if split[3] == '*' then
			  SetVehicleDoorsShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
			end
			if split[3] == '1' then
			  if not IsVehicleDoorFullyOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) then
				print('opened')
				SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, false, false)
			  else
				print('closed')
				SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, false)
			  end
			end
			if split[3] == '2' then
			  if not IsVehicleDoorFullyOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) then
				SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, false, false)
			  else
				SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, false)
			  end
			end
			if split[3] == '3' then
			  if not IsVehicleDoorFullyOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) then
				SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, false, false)
			  else
				SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, false)
			  end
			end
			if split[3] == '4' then
			  if not IsVehicleDoorFullyOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) then
				SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, false, false)
			  else
				SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, false)
			  end
			end
			if split[3] == '5' then
			  if not IsVehicleDoorFullyOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) then
				SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, false, false)
			  else
				SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, false)
			  end
			end
			if split[3] == '6' then
			  if not IsVehicleDoorFullyOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) then
				SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, false, false)
			  else
				SetVehicleDoorShut(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, false)
			  end
			end
		  else
			TriggerEvent('fsn_notify:displayNotification', 'You need to be in the driver seat!', 'centerLeft', 3000, 'error')
		  end
		end
		if split[2] == 'engine' then
			TriggerEvent('EngineToggle:Engine')
			CancelEvent()
		end
		if split[2] == 'seat' then
			if split[3] == '1' then
				if IsVehicleSeatFree(GetVehiclePedIsIn(GetPlayerPed(-1)), -1) then
					SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), -1)
					TriggerEvent('fsn_commands:me', 'shuffles to the driver seat.')
				elseif GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) ~= GetPlayerPed(-1) then
					TriggerEvent('fsn_notify:displayNotification', 'Somebody is already there!', 'centerLeft', 3000, 'error')
				end
			elseif split[3] == '2' then
				if IsVehicleSeatFree(GetVehiclePedIsIn(GetPlayerPed(-1)), 0) then
					SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
					TriggerEvent('fsn_commands:me', 'shuffles to the passenger seat.')
				elseif GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) ~= GetPlayerPed(-1) then
					TriggerEvent('fsn_notify:displayNotification', 'Somebody is already there!', 'centerLeft', 3000, 'error')
				end
			elseif split[3] == '3' then
				if IsVehicleSeatFree(GetVehiclePedIsIn(GetPlayerPed(-1)), 1) then
					SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
					TriggerEvent('fsn_commands:me', 'shuffles to the rear left seat.')
				elseif GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) ~= GetPlayerPed(-1) then
					TriggerEvent('fsn_notify:displayNotification', 'Somebody is already there!', 'centerLeft', 3000, 'error')
				end
			elseif split[3] == '4' then
				if IsVehicleSeatFree(GetVehiclePedIsIn(GetPlayerPed(-1)), 2) then
					SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 2)
					TriggerEvent('fsn_commands:me', 'shuffles to the rear right seat.')
				elseif GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) ~= GetPlayerPed(-1) then
			 	 	TriggerEvent('fsn_notify:displayNotification', 'Somebody is already there!', 'centerLeft', 3000, 'error')
				end
			end
		end
	elseif ( data == "exit" ) then
		ToggleActionMenu()
		return
	end

end )

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(centre)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x , y)
end

RegisterNUICallback( "inventoryAction", function(data, cb)
	if data.action == 'item_use' then
		TriggerEvent('fsn_inventory:item:use', data.item)
	elseif data.action == 'item_store' then
		ToggleActionMenu()
		Citizen.CreateThread(function()
			DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP8", "#ID NUMBER", "", "", "", "", 10)
			local editOpen = true
			while UpdateOnscreenKeyboard() == 0 or editOpen do
				Wait(0)
				drawTxt('How many '..data.item..' would you like to store?',4,1,0.5,0.35,0.6,255,255,255,255)
				drawTxt('~r~Enter a number value or "all"',4,1,0.5,0.49,0.4,255,255,255,255)
				if UpdateOnscreenKeyboard() ~= 0 then
					editOpen = false
					if UpdateOnscreenKeyboard() == 1 then
						res = GetOnscreenKeyboardResult()
						if not exports["fsn_inventory"]:fsn_HasItem(data.item) then
							TriggerEvent('fsn_notify:displayNotification', 'How do you not have any '..data.item..'????', 'centerLeft', 3000, 'error')
							break
						end
						local myAMT = exports["fsn_inventory"]:fsn_GetItemAmount(data.item)
						if res == 'all' then
							print('(all) you are trying to store '..myAMT..' '..data.item)
							TriggerEvent('fsn_apartments:store:item', data.item, myAMT)
							TriggerEvent('fsn_inventory:item:take', data.item, myAMT)
							TriggerEvent('fsn_notify:displayNotification', 'You stored '..myAMT..' '..data.item, 'centerLeft', 5000, 'success')
						else
							if tonumber(res) then
								local myNUM = tonumber(res)
								if myNUM > 0 and myNUM < 500 then
									if myAMT >= myNUM then
										print('(amt) you are trying to store '..myNUM..' '..data.item)
										TriggerEvent('fsn_apartments:store:item', data.item, myNUM)
										TriggerEvent('fsn_inventory:item:take', data.item, myNUM)
										TriggerEvent('fsn_notify:displayNotification', 'You stored '..myNUM..' '..data.item, 'centerLeft', 5000, 'success')
									else
										TriggerEvent('fsn_notify:displayNotification', 'You do not have '..myNUM..' '..data.item..', you have '..myAMT, 'centerLeft', 3000, 'error')
									end
								else
									TriggerEvent('fsn_notify:displayNotification', 'Enter a number between 1-500.', 'centerLeft', 3000, 'error')
								end
							else
								TriggerEvent('fsn_notify:displayNotification', 'You need to enter \'all\' or a number between 1-500.', 'centerLeft', 3000, 'error')
							end 
						end
						break
						--[[
						if res == 'all' then
							TriggerEvent('fsn_apartments:store:item', data.item, exports["fsn_inventory"]:fsn_GetItemAmount(data.item))
							TriggerEvent('fsn_inventory:item:take', data.item, exports["fsn_inventory"]:fsn_GetItemAmount(data.item))
							TriggerEvent('fsn_notify:displayNotification', 'You stored '..exports["fsn_inventory"]:fsn_GetItemAmount(data.item)..' '..data.item, 'centerLeft', 5000, 'success')
						else
							if tonumber(res) then
								res = tonumber(res)
								if res > 0 and res < 500 then
									if res >= exports["fsn_inventory"]:fsn_GetItemAmount(data.item) then
										TriggerEvent('fsn_apartments:store:item', data.item, res)
										TriggerEvent('fsn_inventory:item:take', data.item, res)
										print('trying to store '..res..' x '..data.item)
										TriggerEvent('fsn_notify:displayNotification', 'You stored '..res..' '..data.item, 'centerLeft', 5000, 'success')
									else
										TriggerEvent('fsn_notify:displayNotification', 'You do not have enough', 'centerLeft', 3000, 'error')
									end
								else
									TriggerEvent('fsn_notify:displayNotification', 'Looks to be an issue with the number you entered', 'centerLeft', 3000, 'error')
								end
							else
								TriggerEvent('fsn_notify:displayNotification', 'You didn\'t enter \'all\' or a number.', 'centerLeft', 3000, 'error')
							end
						end
						break
						]]
					end
				end
			end
		end)
	elseif data.action == 'item_give' then
		print('you are attempting to GIVE '..data.item)
	elseif data.action == 'item_drop' then
  	TriggerEvent('fsn_inventory:item:drop', data.item)
    ToggleActionMenu()
	else
		print(':fsn_menu: something has gone wrong!')
	end
end)

Citizen.CreateThread( function()
	SetNuiFocus( false )
	while true do
		if IsControlJustPressed( 1,  288 ) and initialised then
			TriggerEvent('fsn_menu:requestInventory')
			ToggleActionMenu()
		end
	    if ( menuEnabled ) then
            local ped = GetPlayerPed( -1 )
            DisableControlAction( 0, 1, true )
            DisableControlAction( 0, 2, true )
            DisableControlAction( 0, 24, true )
            DisablePlayerFiring( ped, true )
            DisableControlAction( 0, 142, true )
            DisableControlAction( 0, 106, true )
        end
		Citizen.Wait( 0 )
	end
end )

AddEventHandler('fsn_inventory:update', function(tbl)
	SendNUIMessage({
    type = 'inventory',
    inventory = json.encode(tbl)
  })
end)

AddEventHandler('fsn_inventory:init', function(sendtojs)
  initialised = true
  SendNUIMessage({
    type = 'init',
    items = sendtojs
  })
end)

RegisterNUICallback('escape', function(data, cb) -- NUI to close menu on ESCAPE key pressed.
  ToggleActionMenu()
end)
