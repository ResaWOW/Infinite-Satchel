-- Infinite Satchel v0.1 — search box scaffold
-- Author: Resa (Theresa Baker)

local ADDON = ...
InfiniteSatchelDB = InfiniteSatchelDB or { hideDefault = false }

----------------------------------------------------------------------
-- Frame
----------------------------------------------------------------------
local ui = CreateFrame("Frame", "InfiniteSatchelFrame", UIParent, "BasicFrameTemplateWithInset")
ui:SetSize(560, 420)
ui:SetPoint("CENTER")
ui:Hide()
ui.TitleText:SetText("Infinite Satchel")

-- Header hint
ui.hint = ui:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
ui.hint:SetPoint("TOPLEFT", 12, -32)
ui.hint:SetText("|cffaaaaaaTip: /is (toggle), /is clear, /is search <text>|r")

----------------------------------------------------------------------
-- Search Box + Clear Button
----------------------------------------------------------------------
local SEARCH_W, SEARCH_H = 260, 28

-- EditBox
local searchBox = CreateFrame("EditBox", "InfiniteSatchelSearchBox", ui, "InputBoxTemplate")
searchBox:SetSize(SEARCH_W, SEARCH_H)
searchBox:SetAutoFocus(false)
searchBox:SetMaxLetters(120)
searchBox:SetPoint("TOPRIGHT", -42, -28) -- leave room for the clear button
searchBox:HookScript("OnEscapePressed", function(self) self:ClearFocus() end)

-- Placeholder (grey text overlay)
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

-- Clear (✕) button
local clearBtn = CreateFrame("Button", nil, ui, "UIPanelButtonTemplate")
clearBtn:SetSize(28, 22)
clearBtn:SetPoint("LEFT", searchBox, "RIGHT", 6, 0)
clearBtn:SetText("✕")
clearBtn:SetMotionScriptsWhileDisabled(true)

local function ClearSearch()
  searchBox:SetText("")
  searchBox:ClearFocus()
  UpdatePlaceholder()
  -- Re-apply empty filter
  C_Timer.After(0, function() ApplyFilter("") end)
end
clearBtn:SetScript("OnClick", ClearSearch)

----------------------------------------------------------------------
-- Debounced filter apply
----------------------------------------------------------------------
local debounceHandle

function ApplyFilter(text)
  -- 🔧 Wire this to your item grid later. For now: print to chat.
  local shown = text and text:gsub("^%s+", ""):gsub("%s+$", "") or ""
  print("|cffffcc00[Infinite Satchel]|r Filter:", shown ~= "" and shown or "(blank)")
end

local function DebouncedApply()
  if debounceHandle then
    debounceHandle:Cancel()
  end
  debounceHandle = C_Timer.NewTimer(0.15, function()
    debounceHandle = nil
    ApplyFilter(searchBox:GetText() or "")
  end)
end

searchBox:HookScript("OnTextChanged", function(_, user)
  if user then DebouncedApply() end
  UpdatePlaceholder()
end)

UpdatePlaceholder()

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
SLASH_INFINITESATCHEL1 = "/is"
SlashCmdList.INFINITESATCHEL = function(msg)
  msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
  local cmd, rest = msg:match("^(%S+)%s*(.*)$")
  cmd = cmd and cmd:lower() or ""

  if cmd == "clear" then
    ClearSearch()
  elseif cmd == "search" then
    searchBox:SetText(rest or "")
    searchBox:SetFocus()
    DebouncedApply()
  else
    -- Toggle the UI
    if ui:IsShown() then ui:Hide() else ui:Show() end
  end
end

----------------------------------------------------------------------
-- Optional: open our UI when the bank opens (nice for testing)
----------------------------------------------------------------------
local function EnsureBankHooks()
  if BankFrame and not BankFrame.__IS_Hooked then
    BankFrame:HookScript("OnShow", function()
      if InfiniteSatchelDB.hideDefault then
        C_Timer.After(0, function()
          if BankFrame:IsShown() then BankFrame:Hide() end
        end)
      end
      ui:Show()
    end)
    BankFrame:HookScript("OnHide", function() ui:Hide() end)
    BankFrame.__IS_Hooked = true
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_LOGIN" then
    EnsureBankHooks()
    print("|cffffcc00[Infinite Satchel]|r Loaded — search enabled. Try /is")
  elseif event == "ADDON_LOADED" then
    if arg1 == "Blizzard_BankUI" or arg1 == "Blizzard_AccountBankUI" or arg1 == "Blizzard_UIPanels_Game" then
      EnsureBankHooks()
    end
  end
end)
