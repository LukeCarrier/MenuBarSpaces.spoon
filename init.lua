local MenuBarSpaces = {}
MenuBarSpaces.__index = MenuBarSpaces

MenuBarSpaces.name = "MenuBarSpaces"
MenuBarSpaces.version = "0.1"
MenuBarSpaces.author = "Luke Carrier"
MenuBarSpaces.homepage = "https://github.com/LukeCarrier/MenuBarSpaces.spoon"
MenuBarSpaces.license = "MIT - https://opensource.org/licenses/MIT"

MenuBarSpaces.log = hs.logger.new(MenuBarSpaces.name, "info")

function MenuBarSpaces:getSortedScreens()
  local screens = hs.screen.allScreens()
  -- Order screens by Y position (top to bottom), like PaperWM.spoon
  table.sort(screens, function(a, b)
    aYPos = select(2, a:position())
    bYPos = select(2, b:position())
    return aYPos < bYPos
  end)
  return screens
end

function MenuBarSpaces:updateMenuBar()
  local activeSpaces = hs.spaces.activeSpaces()
  local nrSeenSpaces = 0
  local menuBarScreens = {}

  local screens = self:getSortedScreens()
  self.log.i("Displays ordered " .. hs.inspect(screens))

  for _, screen in ipairs(screens) do
    local screenUUID = screen:getUUID()
    local screenPos = screen:position()
    local allScreenSpaces = hs.spaces.spacesForScreen(screenUUID)
    local activeSpaceID = activeSpaces[screenUUID]
    local screenSpaces = {}
    local nrSeenSpacesThisScreen

    self.log.d("Screen " .. hs.inspect(screen) .. " contains spaces " .. hs.inspect(allScreenSpaces))
    for i, spaceID in ipairs(allScreenSpaces) do
      nrSeenSpacesThisScreen = i
      local spaceNumber = nrSeenSpaces + i
      
      local spacePresentation
      if spaceID == activeSpaceID then
        spacePresentation = "[" .. spaceNumber .. "]"
      else
        spacePresentation = spaceNumber
      end
      table.insert(screenSpaces, spacePresentation)
    end

    table.insert(menuBarScreens, table.concat(screenSpaces, " "))
    nrSeenSpaces = nrSeenSpaces + nrSeenSpacesThisScreen
  end

  title = table.concat(menuBarScreens, " | ")
  self.menubar_item:setTitle(title)
end

function MenuBarSpaces:start()
  self.menubar_item = hs.menubar.new(true, MenuBarSpaces.name)
  self:updateMenuBar()
  self.screen_watcher = hs.screen.watcher.new(function()
    self:updateMenuBar()
  end):start()
  self.space_watcher = hs.spaces.watcher.new(function(_)
    self:updateMenuBar()
  end):start()
end

function MenuBarSpaces:stop()
  self.screen_watcher:stop()
  self.space_watcher:stop()
  self.menubar_item:destroy()
end

return MenuBarSpaces
