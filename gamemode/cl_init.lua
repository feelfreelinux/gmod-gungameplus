include( "shared.lua" )

net.Receive( "ShowGunsTable", function()
  serverWeapons = net.ReadTable()
  local DermaPanel = vgui.Create( "DFrame" )
  DermaPanel:SetPos( 50,50 )
  DermaPanel:SetSize( 675, 700 )
  DermaPanel:SetTitle( "Choose weapons" )
  DermaPanel:SetVisible( true )
  DermaPanel:SetDraggable( true )
  DermaPanel:ShowCloseButton( true )
  DermaPanel:MakePopup()
 
  local AvailableWeapons = vgui.Create("DListView")
  AvailableWeapons:SetParent(DermaPanel)
  AvailableWeapons:SetPos(25, 50)
  AvailableWeapons:SetSize(300, 550)
  AvailableWeapons:SetMultiSelect(false)
  AvailableWeapons:AddColumn("Weapon Name")
  AvailableWeapons:AddColumn("Weapon Codename")

 
  local ChoosedWeapons = vgui.Create("DListView")
  ChoosedWeapons:SetParent(DermaPanel)
  ChoosedWeapons:SetPos(350, 50)
  ChoosedWeapons:SetSize(300, 550)
  ChoosedWeapons:SetMultiSelect(false)
  ChoosedWeapons:AddColumn("Weapon Name")
  ChoosedWeapons:AddColumn("Weapon Codename")

  AvailableWeapons.DoDoubleClick = function (parent, index, list)
    ChoosedWeapons:AddLine(list:GetValue(1), list:GetValue(2))
  end

  ChoosedWeapons.DoDoubleClick = function (parent, index, list)
    ChoosedWeapons:RemoveLine(index)
  end

  local StartGame = vgui.Create("DButton")
  StartGame:SetParent(DermaPanel)
  StartGame:SetSize(625, 50)
  StartGame:SetPos(25, 625)
  StartGame:SetText( "Start game" )

  StartGame.DoClick = function( button )
    DermaPanel:Close()

    newWeaponList = {}
    for k, v in ipairs(ChoosedWeapons:GetLines()) do
      newWeaponList[k] = {}
      newWeaponList[k]["printname"] = v:GetValue(1)
      newWeaponList[k]["classname"] = v:GetValue(2)
    end
    net.Start("StartGunGame")
    net.WriteTable(newWeaponList)
    net.SendToServer()
  end

  for k,v in ipairs(serverWeapons) do
    AvailableWeapons:AddLine(v["printname"],v["classname"])
  end
end )