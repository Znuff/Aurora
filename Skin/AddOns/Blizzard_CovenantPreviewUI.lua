local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color, Util = Aurora.Color, Aurora.Util

do --[[ AddOns\Blizzard_CovenantPreviewUI.lua ]]
    Hook.CovenantPreviewFrameMixin = {}
    function Hook.CovenantPreviewFrameMixin:TryShow(covenantInfo)
        if not covenantInfo then return end

        self.BorderFrame:Hide()
        self.Background:Hide()
        local _, _, _, a = self:GetBackdropColor()
        Base.SetBackdropColor(self, private.COVENANT_COLORS[self.uiTextureKit], a)

        self.Title.Left:Hide()
        self.Title.Right:Hide()
        self.Title.Middle:Hide()

        self.ModelSceneContainer.ModelSceneBorder:Hide()
        self.InfoPanel.Parchment:Hide()
        self.InfoPanel._bgCrest:SetAtlas("CovenantChoice-Offering-Sigil-"..self.uiTextureKit, true)
    end
    Hook.CovenantAbilityButtonMixin = {}
    function Hook.CovenantAbilityButtonMixin:SetupButton(abilityInfo)
        self.Background:Hide()
        self.IconBorder:Hide()
        self.CircleMask:Hide()
    end
end

do --[[ AddOns\Blizzard_CovenantPreviewUI.xml ]]
    function Skin.CovenantAbilityButtonTemplate(Button)
        Util.Mixin(Button, Hook.CovenantAbilityButtonMixin)
        Base.CropIcon(Button.Icon, Button)
    end
end

function private.AddOns.Blizzard_CovenantPreviewUI()
    local CovenantPreviewFrame = _G.CovenantPreviewFrame
    Util.Mixin(CovenantPreviewFrame, Hook.CovenantPreviewFrameMixin)
    Base.SetBackdrop(CovenantPreviewFrame)

    CovenantPreviewFrame.ModelSceneContainer.Background:SetTexCoord(0.00970873786408, 0.99029126213592, 0.0092807424594, 0.9907192575406)
    CovenantPreviewFrame.InfoPanel.Description:SetTextColor(Color.grayLight:GetRGB())
    CovenantPreviewFrame.InfoPanel.AbilitiesLabel:SetTextColor(Color.grayLight:GetRGB())

    local bgCrest = CovenantPreviewFrame.InfoPanel:CreateTexture(nil, "ARTWORK")
    bgCrest:SetPoint("BOTTOMRIGHT", -10, 10)
    bgCrest:SetScale(2)
    bgCrest:SetAlpha(0.1)
    CovenantPreviewFrame.InfoPanel._bgCrest = bgCrest

    Skin.UIPanelCloseButton(CovenantPreviewFrame.CloseButton)
    Skin.UIPanelButtonTemplate(CovenantPreviewFrame.SelectButton)
end
