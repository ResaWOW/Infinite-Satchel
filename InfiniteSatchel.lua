-- Infinite Satchel v0.2 — search + item grid (bags/bank/warband)
-- Author: Resa (Theresa Baker)

local ADDON = ...
InfiniteSatchelDB = InfiniteSatchelDB or { hideDefault = false }

------------------------------------------------------------
-- UI shell (movable, resizable, persistent)
------------------------------------------------------------
local ui = CreateFrame("Frame", "InfiniteSatchelFrame", UIParent, "BasicFrameTemplateWithInset")
ui:SetSize(720, 520)
ui:SetPoint("CENTER")
ui:SetUserPlaced(true)            -- let the game remember we position this
ui:SetClampedToScreen(true)
ui:Hide()
ui.TitleText:SetText("Infinite Satchel")

-- Make it draggable
ui:SetMovable(true)
ui:EnableMouse(true)
ui:RegisterForDrag("LeftButton")
ui:SetScript("OnDragStart", function(self) self:StartMoving() end)
ui:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  SavePosition()
end)

-- Resizing + grabber
ui:SetResizable(true)
ui:SetMinResize(560, 420)

local sizer = CreateFrame("Frame", nil, ui)
sizer:SetSize(16, 16)
sizer:SetPoint("BOTTOMRIGHT", -4, 4)
local tex = sizer:CreateTexture(nil, "OVERLAY")
tex:SetAllPoints()
tex:SetTexture(130838) -- Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up
sizer:EnableMouse(true)
sizer:SetScript("OnMouseDown", function() ui:StartSizing("BOTTOMRIGHT") end)
sizer:SetScript("OnMouseUp", function()
  ui:StopMovingOrSizing()
  SavePosition() -- save after resize, too
end)

-- Persist size/position (single, final versions)
local function SavePosition()
  InfiniteSatchelDB.pos = { ui:GetPoint() }    -- { point, relativeTo, relativePoint, xOfs, yOfs }
  InfiniteSatchelDB.size = { ui:GetSize() }    -- { width, height }
end

local function RestorePosition()
  if InfiniteSatchelDB and InfiniteSatchelDB.size then
    ui:SetSize(InfiniteSatchelDB.size[1], InfiniteSatchelDB.size[2])
  end
  if InfiniteSatchelDB and InfiniteSatchelDB.pos and #InfiniteSatchelDB.pos >= 5 then
    ui:ClearAllPoints()
    -- ignore stored relativeTo object; anchor to UIParent with stored offsets
    ui:SetPoint(InfiniteSatchelDB.pos[1], UIParent, InfiniteSatchelDB.pos[3], InfiniteSatchelDB.pos[4], InfiniteSatchelDB.pos[5])
  else
    ui:ClearAllPoints()
    ui:SetPoint("CENTER")
  end
end

-- Close with ESC
table.insert(UISpecialFrames, ui:GetName())

-- (keep your hint/srclabel creation after this)



------------------------------------------------------------
-- Search box
------------------------------------------------------------
local SEARCH_W, SEARCH_H = 280, 28
local searchBox = CreateFrame("EditBox", "InfiniteSatchelSearchBox", ui, "InputBoxTemplate")
searchBox:SetSize(SEARCH_W, SEARCH_H)
searchBox:SetAutoFocus(false)
searchBox:SetMaxLetters(120)
searchBox:SetPoint("TOPRIGHT", -48, -28)
searchBox:HookScript("OnEscapePressed", function(self) self:ClearFocus() end)

local placeholder = ui:CreateFontString(nil, "ARTWORK", "GameFontDisable")
placeholder:SetPoint("LEFT", searchBox, "LEFT", 8, 0)
placeholder:SetText("Search…")

local function UpdatePlaceholder()
  if searchBox:HasFocus() or (searchBox:GetText() or "") ~= "" then
    placeholder:Hide()
  else
    placeholder:Show()
  end
end

searchBox:HookScript("OnEditFocusGained", UpdatePlaceholder)
searchBox:HookScript("OnEditFocusLost", UpdatePlaceholder)

local clearBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
clearBtn:SetSize(28, 22)
clearBtn:SetPoint("LEFT", searchBox, "RIGHT", 6, 0)
clearBtn:SetText("✕")

------------------------------------------------------------
-- Scroll + grid
------------------------------------------------------------
local scroll = CreateFrame("ScrollFrame", "InfiniteSatchelScroll", ui, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 12, -84)
scroll:SetPoint("BOTTOMRIGHT", -28, 12)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(1,1)
scroll:SetScrollChild(content)

-- Grid constants
local COLS = 10
local BUTTON = 40
local PAD = 6

-- Reusable buttons pool
local buttons = {}
local function AcquireButton(i)
  if not buttons[i] then
    local btn = CreateFrame("Button", "InfiniteSatchelItem"..i, content, "ItemButtonTemplate")
    btn:SetSize(BUTTON, BUTTON)
    btn.Count:SetDrawLayer("OVERLAY")
    btn.icon = _G[btn:GetName().."IconTexture"] or btn.Icon
    btn.icon:SetTexCoord(0.06,0.94,0.06,0.94)

    btn:SetScript("OnEnter", function(self)
      if self.link then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.link)
        GameTooltip:Show()
      end
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    buttons[i] = btn
  end
  return buttons[i]
end

local function HideUnused(fromIndex)
  for i = fromIndex, #buttons do
    buttons[i]:Hide()
  end
end

------------------------------------------------------------
-- Item collection
------------------------------------------------------------
local function safeNameFromLink(link)
  if not link then return nil end
  local n = link:match("%[(.-)%]")
  return n
end

local function collect_bags()
  local items = {}
  for bag = 0, 4 do
    local n = C_Container.GetContainerNumSlots(bag) or 0
    for slot = 1, n do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info and info.hyperlink and info.iconFileID then
        table.insert(items, {link=info.hyperlink, icon=info.iconFileID, count=info.stackCount or 1})
      end
    end
  end
  return items
end

local function collect_char_bank()
  local items = {}
  -- -1 is the main bank container
  do
    local bag = Enum.BagIndex.Bank
    local n = C_Container.GetContainerNumSlots(bag) or 0
    for slot = 1, n do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info and info.hyperlink and info.iconFileID then
        table.insert(items, {link=info.hyperlink, icon=info.iconFileID, count=info.stackCount or 1})
      end
    end
  end
  -- bank bags 5..11 (available only at bank)
  for bag = 5, 11 do
    local n = C_Container.GetContainerNumSlots(bag) or 0
    for slot = 1, n do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info and info.hyperlink and info.iconFileID then
        table.insert(items, {link=info.hyperlink, icon=info.iconFileID, count=info.stackCount or 1})
      end
    end
  end
  return items
end

local function collect_account_bank()
  local items = {}
  -- Active account bank TAB is -5
  local bag = Enum.BagIndex.Accountbanktab
  local n = C_Container.GetContainerNumSlots(bag) or 0
  for slot = 1, n do
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info and info.hyperlink and info.iconFileID then
      table.insert(items, {link=info.hyperlink, icon=info.iconFileID, count=info.stackCount or 1})
    end
  end
  return items
end

------------------------------------------------------------
-- Determine source based on bank state
------------------------------------------------------------
local function activeBankType()
  if BankFrame and BankFrame.GetActiveBankType and BankFrame:IsShown() then
    return BankFrame:GetActiveBankType() -- may be nil/Enum.BankType.Account/Character
  end
  return nil
end

local function currentSource()
  local bt = activeBankType()
  if bt == Enum.BankType and Enum.BankType.Account then
    return "account"
  elseif BankFrame and BankFrame:IsShown() then
    return "bank"
  else
    return "bags"
  end
end

------------------------------------------------------------
-- Filtering + populate
------------------------------------------------------------
local allItems = {}
local filteredItems = {}
local function passesFilter(item, query)
  if not query or query == "" then return true end
  local name = safeNameFromLink(item.link)
  if not name then return false end
  name = name:lower()
  return name:find(query, 1, true) ~= nil
end

local function relayoutGrid()
  local cols = COLS
  local x, y = 0, 0
  for i, btn in ipairs(buttons) do
    if btn:IsShown() then
      local col = (i-1) % cols
      local row = math.floor((i-1) / cols)
      btn:ClearAllPoints()
      btn:SetPoint("TOPLEFT", content, "TOPLEFT", col*(BUTTON+PAD), -row*(BUTTON+PAD))
      x = math.max(x, (col+1)*(BUTTON+PAD))
      y = math.max(y, (row+1)*(BUTTON+PAD))
    end
  end
  content:SetSize(x, y)
end

local function populateGrid()
  local i = 1
  for _, item in ipairs(filteredItems) do
    local btn = AcquireButton(i)
    btn:Show()
    btn.link = item.link
    SetItemButtonTexture(btn, item.icon)
    SetItemButtonCount(btn, item.count or 1)
    i = i + 1
  end
  HideUnused(i)
  relayoutGrid()
end

local function ApplyFilter(text)
  local q = (text or ""):lower():gsub("^%s+",""):gsub("%s+$","")
  wipe(filteredItems)
  for _, item in ipairs(allItems) do
    if passesFilter(item, q) then
      table.insert(filteredItems, item)
    end
  end
  populateGrid()
end

-- expose for search box clear
_G.ApplyFilter = ApplyFilter

local debounceHandle
local function DebouncedApply()
  if debounceHandle then debounceHandle:Cancel() end
  debounceHandle = C_Timer.NewTimer(0.12, function()
    debounceHandle = nil
    ApplyFilter(searchBox:GetText() or "")
  end)
end

searchBox:HookScript("OnTextChanged", function(_, user)
  if user then DebouncedApply() end
  UpdatePlaceholder()
end)
clearBtn:SetScript("OnClick", function()
  searchBox:SetText("")
  searchBox:ClearFocus()
  UpdatePlaceholder()
  C_Timer.After(0, function() ApplyFilter("") end)
end)
UpdatePlaceholder()

------------------------------------------------------------
-- Refresh items whenever source changes or UI opens
------------------------------------------------------------
local function refreshSourceAndItems()
  local src = currentSource()
  wipe(allItems)
  if src == "account" then
    ui.srclabel:SetText("Source: Warband Bank (current tab)")
    allItems = collect_account_bank()
  elseif src == "bank" then
    ui.srclabel:SetText("Source: Character Bank")
    allItems = collect_char_bank()
  else
    ui.srclabel:SetText("Source: Bags")
    allItems = collect_bags()
  end
  ApplyFilter(searchBox:GetText() or "")
end

------------------------------------------------------------
-- Slash: /is
------------------------------------------------------------
SLASH_INFINITESATCHEL1 = "/is"
SlashCmdList.INFINITESATCHEL = function(msg)
  msg = (msg or ""):gsub("^%s+",""):gsub("%s+$","")
  local cmd, rest = msg:match("^(%S+)%s*(.*)$")
  cmd = cmd and cmd:lower() or ""

  if cmd == "search" then
    searchBox:SetText(rest or "")
    searchBox:SetFocus()
    DebouncedApply()
  elseif cmd == "clear" then
    searchBox:SetText("")
    searchBox:ClearFocus()
    UpdatePlaceholder()
    ApplyFilter("")
  else
    if ui:IsShown() then ui:Hide() else ui:Show(); refreshSourceAndItems() end
  end
end

------------------------------------------------------------
-- Bank hooks
------------------------------------------------------------
local function EnsureBankHooks()
  if BankFrame and not BankFrame.__IS_Hooked then
    BankFrame:HookScript("OnShow", function()
      if InfiniteSatchelDB.hideDefault then
        C_Timer.After(0, function()
          if BankFrame:IsShown() then BankFrame:Hide() end
        end)
      end
      ui:Show()
      refreshSourceAndItems()
    end)
    BankFrame:HookScript("OnHide", function()
      ui:Hide()
    end)
    -- Update when switching Character <-> Warband tab
    hooksecurefunc(BankFrame, "SetActiveBankType", function()
      if ui:IsShown() then refreshSourceAndItems() end
    end)
    BankFrame.__IS_Hooked = true
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("BAG_UPDATE_DELAYED")        -- bags change
f:RegisterEvent("PLAYERBANKSLOTS_CHANGED")   -- character bank changes
f:RegisterEvent("ACCOUNT_MONEY")             -- (harmless) account/warband events
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_LOGIN" then
    -- SavedVariables are now loaded; safe to restore
    RestorePosition()

    EnsureBankHooks()
    -- Optional: populate once on login if the UI is shown
    if ui:IsShown() then
      refreshSourceAndItems()
    end

    print("|cffffcc00[Infinite Satchel]|r Loaded — search + grid. Try /is")

  elseif event == "ADDON_LOADED" then
    if arg1 == "Blizzard_BankUI" or arg1 == "Blizzard_AccountBankUI" or arg1 == "Blizzard_UIPanels_Game" then
      EnsureBankHooks()
    end

  else
    -- BAG_UPDATE_DELAYED / PLAYERBANKSLOTS_CHANGED / ACCOUNT_MONEY, etc.
    if ui:IsShown() then
      refreshSourceAndItems()
    end
  end
end)

