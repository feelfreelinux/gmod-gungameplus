AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
util.AddNetworkString( "ShowGunsTable" )
util.AddNetworkString( "StartGunGame" )

currentWeaponsTable = {}
roundRunning = false

function GM:PlayerLoadout( ply )
  if (roundRunning) then
    ply:Give(currentWeaponsTable[ply:GetNWInt('points')]["classname"])
  end

  ply:SetModel( "models/player/kleiner.mdl" )
end

function GM:PlayerInitialSpawn( ply )
  ply:SetNWInt( 'points', 1 )
  if (ply:IsAdmin()) then
    print("Showing gun table to admin")
    openWeaponsMenu(ply)
  end
end

function GM:PlayerDeath(victim, inflictor, attacker)
  if roundRunning then
    if victim == attacker then
      if (victim:GetNWInt('points') > 1) then
        PrintMessage( HUD_PRINTTALK, victim:Name() .. " git commit suicide" )
        victim:SetNWInt( 'points', victim:GetNWInt('points') - 1 )
      end
    else
      PrintMessage( HUD_PRINTTALK, victim:Name() .. " zostau umarniety przez " .. attacker:Name() )
      PrintMessage( HUD_PRINTTALK, attacker:Name() .. " ma " .. attacker:GetNWInt('points') .. " punktów" )
      attacker:SetNWInt('points', attacker:GetNWInt('points') + 1)
      attacker:StripWeapons()
      attacker:Give(currentWeaponsTable[attacker:GetNWInt('points')]["classname"])

      if (attacker:GetNWInt('points') == table.Count(currentWeaponsTable)) then 
        won(attacker)
      end
    end
  end
end

function won(ply)
  roundRunning = false
  PrintMessage( HUD_PRINTTALK, ply:Name() .. " wygrał totalnie" )
  openWeaponsMenu(table.Random(player.GetAll()))
end

function openWeaponsMenu( ply )
  net.Start( "ShowGunsTable" )
    
  mappedWeapons = {} 
  for k,v in ipairs(weapons.GetList()) do
    mappedWeapons[k] = {}
    mappedWeapons[k]["printname"] = v.PrintName
    mappedWeapons[k]["classname"] = v.ClassName
  end

  net.WriteTable(mappedWeapons)
  net.Send(ply)
end

function startRound()
  roundRunning = true
  currentWeaponsTable = net.ReadTable()
  for k, v in ipairs( player.GetAll() ) do
    v:SetNWInt( 'points', 1 )
  end 

  setupPlayers()
end

function setupPlayers() 
  for k, v in ipairs(player.GetAll()) do
    v:StripWeapons()
    v:Give(currentWeaponsTable[v:GetNWInt('points')]["classname"])
    v:SetHealth(100)
  end
end

net.Receive( "StartGunGame", function()
  startRound()
end )

