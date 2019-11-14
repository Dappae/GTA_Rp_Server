rightPosition = {x = 1450, y = 100}
leftPosition = {x = 0, y = 100}
menuPosition = {x = 0, y = 200}

if Config.MenuPosition then
  if Config.MenuPosition == "left" then
    menuPosition = leftPosition
  elseif Config.MenuPosition == "right" then
    menuPosition = rightPosition
  end
end

if Config.CustomMenuEnabled then
  local RuntimeTXD = CreateRuntimeTxd('Custom_Menu_Head')
  local Object = CreateDui(Config.MenuImage, 512, 128)
  _G.Object = Object
  local TextureThing = GetDuiHandle(Object)
  local Texture = CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'Custom_Menu_Head', TextureThing)
  Menuthing = "Custom_Menu_Head"
else
  Menuthing = "shopui_title_sm_hangar"
end

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("dp Emotes", "", menuPosition["x"], menuPosition["y"], Menuthing, Menuthing)
_menuPool:Add(mainMenu)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

local EmoteTable = {}
local FavEmoteTable = {}
local DanceTable = {}
local PropETable = {}
local WalkTable = {}
local FaceTable = {}
local FavoriteEmote = ""

Citizen.CreateThread(function()
  while true do
    if Config.FavKeybindEnabled then
      if IsControlPressed(0, Config.FavKeybind) then
        if not IsPedSittingInAnyVehicle(PlayerPedId()) then
          if FavoriteEmote ~= "" then
            EmoteCommandStart(nil,{FavoriteEmote, 0})
            Wait(3000)
          end
        end
      end
    end
    Citizen.Wait(1)
  end
end)

lang = Config.MenuLanguage

function AddEmoteMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['emotes'], "", "", Menuthing, Menuthing)
    local dancemenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['danceemotes'], "", "", Menuthing, Menuthing)
    local propmenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['propemotes'], "", "", Menuthing, Menuthing)
    local favmenu = _menuPool:AddSubMenu(submenu, Config.Languages[lang]['keybindemotes'], Config.Languages[lang]['keybindinfo'], "", Menuthing, Menuthing)
    unbind2item = NativeUI.CreateItem(Config.Languages[lang]['rkeybind'], Config.Languages[lang]['rkeybind'])
    unbinditem = NativeUI.CreateItem(Config.Languages[lang]['prop2info'], "")
    favmenu:AddItem(unbinditem)
    favmenu:AddItem(unbind2item)
    table.insert(FavEmoteTable, Config.Languages[lang]['rkeybind'])
    table.insert(FavEmoteTable, Config.Languages[lang]['rkeybind'])
    table.insert(EmoteTable, Config.Languages[lang]['danceemotes'])
    table.insert(EmoteTable, Config.Languages[lang]['keybindemotes'])
    table.insert(EmoteTable, Config.Languages[lang]['danceemotes'])

    for a,b in pairsByKeys(DP.Emotes) do
      x,y,z = table.unpack(b)
      emoteitem = NativeUI.CreateItem(z, "/e ("..a..")")
      favemoteitem = NativeUI.CreateItem(z, Config.Languages[lang]['set']..z..Config.Languages[lang]['setboundemote'])
      submenu:AddItem(emoteitem)
      favmenu:AddItem(favemoteitem)
      table.insert(EmoteTable, a)
      table.insert(FavEmoteTable, a)
    end

    for a,b in pairsByKeys(DP.Dances) do
      x,y,z = table.unpack(b)
      danceitem = NativeUI.CreateItem(z, "/e ("..a..")")
      dancemenu:AddItem(danceitem)
      table.insert(DanceTable, a)
    end

    for a,b in pairsByKeys(DP.PropEmotes) do
      x,y,z = table.unpack(b)
      propitem = NativeUI.CreateItem(z, "/e ("..a..")")
      propfavitem = NativeUI.CreateItem(z, Config.Languages[lang]['set']..z..Config.Languages[lang]['setboundemote'])
      propmenu:AddItem(propitem)
      favmenu:AddItem(propfavitem)
      table.insert(PropETable, a)
      table.insert(FavEmoteTable, a)
    end

    favmenu.OnItemSelect = function(sender, item, index)
      if FavEmoteTable[index] == Config.Languages[lang]['rkeybind'] then
        FavoriteEmote = ""
        ShowNotification(Config.Languages[lang]['rkeybind'], 2000)
      return end 

      if Config.FavKeybindEnabled then
        FavoriteEmote = FavEmoteTable[index]
        ShowNotification("~o~"..firstToUpper(FavoriteEmote)..Config.Languages[lang]['newsetemote']) 
      end
    end

    dancemenu.OnItemSelect = function(sender, item, index)
      EmoteMenuStart(DanceTable[index], "dances")
    end

    propmenu.OnItemSelect = function(sender, item, index)
      EmoteMenuStart(PropETable[index], "props")
    end

    submenu.OnItemSelect = function(sender, item, index)
     if EmoteTable[index] ~= Config.Languages[lang]['keybindemotes'] then
      EmoteMenuStart(EmoteTable[index], "emotes")
    end
  end
end

function AddCancelEmote(menu)
    local newitem = NativeUI.CreateItem(Config.Languages[lang]['cancelemote'], Config.Languages[lang]['cancelemoteinfo'])
    menu:AddItem(newitem)
    menu.OnItemSelect = function(sender, item, checked_)
        if item == newitem then
          EmoteCancel()
          DestroyAllProps()
        end
    end
end

function AddWalkMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['walkingstyles'], "", "", Menuthing, Menuthing)

    walkreset = NativeUI.CreateItem(Config.Languages[lang]['normalreset'], Config.Languages[lang]['resetdef'])
    submenu:AddItem(walkreset)
    table.insert(WalkTable, Config.Languages[lang]['resetdef'])

    WalkInjured = NativeUI.CreateItem("Injured", "")
    submenu:AddItem(WalkInjured)
    table.insert(WalkTable, "move_m@injured")

    for a,b in pairsByKeys(DP.Walks) do
      x = table.unpack(b)
      walkitem = NativeUI.CreateItem(a, "")
      submenu:AddItem(walkitem)
      table.insert(WalkTable, x)
    end

    submenu.OnItemSelect = function(sender, item, index)
      if item ~= walkreset then
        WalkMenuStart(WalkTable[index])
      else
        ResetPedMovementClipset(PlayerPedId())
      end
    end
end

function AddFaceMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['moods'], "", "", Menuthing, Menuthing)

    facereset = NativeUI.CreateItem(Config.Languages[lang]['normalreset'], Config.Languages[lang]['resetdef'])
    submenu:AddItem(facereset)
    table.insert(FaceTable, "")

    for a,b in pairsByKeys(DP.Expressions) do
      x,y,z = table.unpack(b)
      faceitem = NativeUI.CreateItem(a, "")
      submenu:AddItem(faceitem)
      table.insert(FaceTable, a)
    end

    submenu.OnItemSelect = function(sender, item, index)
      if item ~= facereset then
        EmoteMenuStart(FaceTable[index], "expression")
      else
        ClearFacialIdleAnimOverride(PlayerPedId())
      end
    end
end

function AddInfoMenu(menu)
    local infomenu = _menuPool:AddSubMenu(menu, Config.Languages[lang]['infoupdate'], "(1.5.2)", "", Menuthing, Menuthing)
    contact = NativeUI.CreateItem(Config.Languages[lang]['suggestions'], Config.Languages[lang]['suggestionsinfo'])
    u152 = NativeUI.CreateItem("1.5.2", "Added language options for server owners")
    u151a = NativeUI.CreateItem("1.5.1a", "Fixed tryclothes/2, changed the guitar emotes slightly and changed facial expressions to 'moods'")
    u151 = NativeUI.CreateItem("1.5.1", "Added /walk and /walks, for walking styles without menu")
    u150 = NativeUI.CreateItem("1.5.0", "Added Facial Expressions menu (if enabled by server owner)")
    u142 = NativeUI.CreateItem("1.4.2", "Added many new prop emotes (guitar-guitar3, book, bouquet, teddy, backpack, burger and more)")
    infomenu:AddItem(contact)
    infomenu:AddItem(u152)
    infomenu:AddItem(u151a)
    infomenu:AddItem(u151)
    infomenu:AddItem(u150)
    infomenu:AddItem(u142)
end

function OpenEmoteMenu()
    mainMenu:Visible(not mainMenu:Visible())
end


function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

AddEmoteMenu(mainMenu)
AddCancelEmote(mainMenu)
if Config.WalkingStylesEnabled then
  AddWalkMenu(mainMenu)
end
if Config.ExpressionsEnabled then
  AddFaceMenu(mainMenu)
end
AddInfoMenu(mainMenu)
_menuPool:RefreshIndex()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)

