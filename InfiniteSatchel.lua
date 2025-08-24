-- Infinite Satchel v0.1 (bank-aware placeholder)
-- Author: Resa (Theresa Baker)

local ADDON = ...
InfiniteSatchelDB = InfiniteSatchelDB or { hideDefault = false }

local ui = CreateFrame("Frame", "InfiniteSatchelFrame", UIParent, "BasicFrameTemplateWithInset")
ui:SetSize(520, 360)
ui:SetPoint("CENTER")
ui:Hide()
ui.TitleText:SetText("Infinite Satchel")
ui.label = ui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
ui.label:SetPoint("TOPLEFT", 16, -48)
ui.hint = ui:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
ui.hint:SetPoint("TOPLEFT", ui.label, "BOTTOMLEFT", 0, -12)
ui.hint:SetText("|cffaaaaaaTip: /is, /is dump, /is dumpaccount|r")

local function activeBankLabel()
  local bankType = BankFrame and BankFrame.GetActiveBankType and BankFrame:GetActiveBankType()
  if bankType == Enum.BankType and Enum.BankType.Account then
    return "Warband Bank (Account)"
  end
  return "Character Bank"
end

local function showUI()
  ui:Show()
  ui.label:SetText("Infinite Satchel — "..activeBankLabel())
end

local function hideUI() ui:Hide() end

-- Character bank dump (-1)
local function DumpCharacterBank()
  if not C_Container then return end
  local bag = Enum.BagIndex.Bank -- -1
  local n = C_Container.GetContainerNumSlots(bag) or 0
  print("|cffffcc00[Infinite Satchel]|r Character bank slots:", n)
  for slot = 1, n do
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info and info.hyperlink then
      print("  slot", slot, info.hyperlink)
    end
  end
end

-- Warband account bank tab dump (-5) when that tab is visible
local function DumpAccountBankTab()
  if not (BankFrame and BankFrame.GetActiveBankType and BankFrame:GetActiveBankType() == Enum.BankType.Account) then
    print("|cffff3333[Infinite Satchel]|r Open the Warband bank tab first.")
    return
  end
  local bag = Enum.BagIndex.Accountbanktab -- -5
  local n = C_Container.GetContainerNumSlots(bag) or 0
  print("|cffffcc00[Infinite Satchel]|r Account bank tab slots:", n)
  for slot = 1, n do
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info and info.hyperlink then
      print("  slot", slot, info.hyperlink)
    end
  end
end

SLASH_INFINITESATCHEL1 = "/is"
SlashCmdList.INFINITESATCHEL = function(msg)
  msg = (msg or ""):lower()
  if msg == "dump" then
    DumpCharacterBank()
  elseif msg == "dumpaccount" then
    DumpAccountBankTab()
  elseif msg == "hidedefault" then
    InfiniteSatchelDB.hideDefault = true
    print("|cff99ff99[Infinite Satchel]|r Will hide Blizzard bank next time.")
  elseif msg == "showdefault" then
    InfiniteSatchelDB.hideDefault = false
    print("|cff99ff99[Infinite Satchel]|r Will show Blizzard bank UI.")
  else
    if ui:IsShown() then hideUI() else showUI() end
  end
end

local function EnsureBankHooks()
  if BankFrame and not BankFrame.__IS_Hooked then
    BankFrame:HookScript("OnShow", function()
      if InfiniteSatchelDB.hideDefault then
        C_Timer.After(0, function()
          if BankFrame:IsShown() then BankFrame:Hide() end
        end)
      end
      showUI()
    end)
    BankFrame:HookScript("OnHide", hideUI)
    BankFrame.__IS_Hooked = true
  end

  if AccountBankPanel and not AccountBankPanel.__IS_Button then
    local btn = CreateFrame("Button", nil, AccountBankPanel, "UIPanelButtonTemplate")
    btn:SetSize(130, 22)
    btn:SetPoint("BOTTOMLEFT", 6, 8)
    btn:SetText("Open Satchel")
    btn:SetScript("OnClick", function()
      if ui:IsShown() then hideUI() else showUI() end
    end)
    AccountBankPanel.__IS_Button = btn
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_LOGIN" then
    EnsureBankHooks()
  elseif event == "ADDON_LOADED" then
    if arg1 == "Blizzard_BankUI" or arg1 == "Blizzard_AccountBankUI" or arg1 == "Blizzard_UIPanels_Game" then
      EnsureBankHooks()
    end
  end
end)

print("|cffffcc00[Infinite Satchel]|r Loaded (v0.1 placeholder).")
