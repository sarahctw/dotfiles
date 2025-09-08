-- A global variable for the Hyper Mode
k = hs.hotkey.modal.new({ "ctrl" }, "f")

launch = function(appname)
  hs.application.launchOrFocus(appname)
  k.triggered = true
  k:exit()
end

-- Sequential keybindings, e.g. Hyper-a,f for Finder
a = hs.hotkey.modal.new({}, "F16")
apps = {
  { 'p', 'System Preferences' },
  { 'v', 'Preview' },
  { 'c', 'Google Chrome' },
}
for i, app in ipairs(apps) do
  a:bind({}, app[1], function()
    launch(app[2]); a:exit();
  end)
end

-- Bind a to hyper
pressedA = function() a:enter() end
releasedA = function() end
k:bind({}, 'a', nil, pressedA, releasedA)

-- Allow escape to exit the modal
k:bind('', 'escape', function() k:exit() end)

-- Launch Alfred with HYPER+A
k:bind({ "shift" }, 'a', nil, function() launch('Alfred 5'); end)

-- Launch Drafts with HYPER+d
k:bind({}, 'd', nil, function() launch('Drafts'); end)

-- Launch Finder with HYPER+f
k:bind({}, 'f', nil, function() launch('Finder'); end)

-- Launch email with HYPER+E
k:bind({}, 'e', nil, function() launch('Superhuman'); end)

-- Launch browser (Safari) with HYPER+b
k:bind({}, 'b', nil, function() launch('Safari'); end)

-- launch calendar (fantastical) with hyper+c
k:bind({}, 'c', nil, function() launch('Fantastical'); end)

-- launch ChatGPT with hyper+C
k:bind({ "shift" }, 'c', nil, function() launch('ChatGPT'); end)

-- Launch terminal (iTerm) with HYPER+t
k:bind({}, 't', nil, function() launch('iTerm'); end)

-- Launch Slack with HYPER+s
k:bind({}, 's', nil, function() launch('Slack'); end)

-- Launch Reminders with HYPER+r
k:bind({}, 'r', nil, function() launch('Reminders'); end)

-- Launch Ulysses with HYPER+u
k:bind({}, 'u', nil, function() launch('UlyssesMac'); end)

-- HYPER+up: Act like hyper up
ufun = function()
  hs.eventtap.keyStroke({ "shift", "cmd", "alt", "ctrl" }, "Up")
  k.triggered = true
  k:exit()
end
k:bind({}, 'Up', nil, ufun)

-- HYPER+left: Act like hyper left
lfun = function()
  hs.eventtap.keyStroke({ "shift", "cmd", "alt", "ctrl" }, "Left")
  k.triggered = true
  k:exit()
end
k:bind({}, 'Left', nil, lfun)

-- HYPER+right Act like hyper right
rfun = function()
  hs.eventtap.keyStroke({ "shift", "cmd", "alt", "ctrl" }, "Right")
  k.triggered = true
  k:exit()
end
k:bind({}, 'Right', nil, rfun)

-- HYPER+down: Act like hyper down
dfun = function()
  hs.eventtap.keyStroke({ "shift", "cmd", "alt", "ctrl" }, "Down")
  k.triggered = true
  k:exit()
end
k:bind({}, 'Down', nil, dfun)

-- UI Settings
-- Keep animations snappy/off
hs.window.animationDuration = 0

-- Small helpers (simple & safe)
local function appWindow(bundleID, name)
  local app = hs.application.get(bundleID)
  if not app and name then app = hs.appfinder.appFromName(name) end
  if not app then return nil end

  local win = app:mainWindow()
  if win and win:isStandard() and win:isVisible() then return win end

  local wins = app:allWindows()
  for _, w in ipairs(wins) do
    if w:isStandard() and w:isVisible() then return w end
  end
  return nil
end

local function setRectFull(win, rect) -- rect: normalized {x,y,w,h}
  if not win then return false end
  if win:isFullScreen() then
    win:setFullScreen(false)
    hs.timer.usleep(250000)
  end
  local scr = win:screen() or hs.mouse.getCurrentScreen()
  local f = scr:fullFrame() -- immune to hidden menu bar/dock
  win:moveToScreen(scr, false, true)
  win:setFrame({
    x = f.x + rect.x * f.w,
    y = f.y + rect.y * f.h,
    w = rect.w * f.w,
    h = rect.h * f.h
  }, 0)
  return true
end

-- === HYPER + 1: Superhuman left 50%, Drafts right 50% ===
k:bind({}, '1', nil, function()
  -- Launch apps first (explicit fallbacks, no inline `or`)
  if not hs.application.launchOrFocusByBundleID('com.superhuman.Superhuman') then
    hs.application.launchOrFocus('Superhuman')
  end
  if not hs.application.launchOrFocusByBundleID('com.agiletortoise.Drafts-OSX') then
    hs.application.launchOrFocus('Drafts')
  end

  hs.timer.doAfter(0.15, function()
    local shWin   = appWindow('com.superhuman.Superhuman', 'Superhuman')
    local draftsW = appWindow('com.agiletortoise.Drafts-OSX', 'Drafts')

    if shWin then setRectFull(shWin, { x = 0.00, y = 0.00, w = 0.50, h = 1.00 }) end
    if draftsW then setRectFull(draftsW, { x = 0.50, y = 0.00, w = 0.50, h = 1.00 }) end

    k.triggered = true; k:exit()
  end)
end)

-- === HYPER + 0: Chrome centered 2/3 width, TOP 1/3 height ===
k:bind({}, '0', nil, function()
  if not hs.application.launchOrFocusByBundleID('com.google.Chrome') then
    hs.application.launchOrFocus('Google Chrome')
  end

  hs.timer.doAfter(0.15, function()
    local chromeW = appWindow('com.google.Chrome', 'Google Chrome')
    if chromeW then
      -- Center 2/3 (x=1/6, w=2/3) and top third (y=0, h=1/3)
      setRectFull(chromeW, { x = 1 / 6, y = 0, w = 2 / 3, h = 1 / 3 })
    end
    k.triggered = true; k:exit()
  end)
end)

-- Enter Hyper Mode when F18 (Hyper/Capslock) is pressed
-- pressedF18 = function()
--   k.triggered = false
--   k:enter()
-- end

-- Leave Hyper Mode when F18 (Hyper/Capslock) is pressed,
--   send ESCAPE if no other keys are pressed.
-- releasedF18 = function()
--   k:exit()
--   if not k.triggered then
--     hs.eventtap.keyStroke({}, 'ESCAPE')
--   end
-- end

-- Bind the Hyper key
-- f18 = hs.hotkey.bind({}, 'F18', pressedF18, releasedF18)
