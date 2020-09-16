local _, private = ...
if private.isClassic then return end

--[[ Lua Globals ]]
-- luacheck: globals next

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook = Aurora.Hook
local Color, Util = Aurora.Color, Aurora.Util

do --[[ SharedXML\NineSlice.lua ]]
    local nineSliceSetup =    {
        "TopLeftCorner",
        "TopRightCorner",
        "BottomLeftCorner",
        "BottomRightCorner",
        "TopEdge",
        "BottomEdge",
        "LeftEdge",
        "RightEdge",
        "Center",
    }

    local function BasicFrame(Frame)
        Base.SetBackdrop(Frame)
    end

    local function InsetFrame(Frame)
        Base.SetBackdrop(Frame, Color.frame)
    end

    local function HideFrame(Frame)
        Frame:SetBackdropColor(Color.frame, 0)
        Frame:SetBackdropBorderColor(Color.frame, 0)
    end

    local layouts = {
        SimplePanelTemplate = BasicFrame,
        PortraitFrameTemplate = BasicFrame,
        PortraitFrameTemplateMinimizable = BasicFrame,
        ButtonFrameTemplateNoPortrait = BasicFrame,
        ButtonFrameTemplateNoPortraitMinimizable = BasicFrame,
        InsetFrameTemplate = HideFrame,
        BFAMissionHorde = BasicFrame,
        BFAMissionAlliance = BasicFrame,
        GenericMetal = BasicFrame,
        Dialog = BasicFrame,
        WoodenNeutralFrameTemplate = BasicFrame,
        Runeforge = BasicFrame,
        AdventuresMissionComplete = InsetFrame,
        CharacterCreateDropdown = BasicFrame,
        UniqueCornersLayout = BasicFrame,
        IdenticalCornersLayout = BasicFrame,

        -- Blizzard_OrderHallTalents
        BFAOrderTalentHorde = BasicFrame,
        BFAOrderTalentAlliance = BasicFrame,

        -- Blizzard_PartyPoseUI
        PartyPoseFrameTemplate = BasicFrame,
        PartyPoseKit = BasicFrame,
    }

    if not private.isPatch then
        layouts.BFAMissionNeutral = BasicFrame
        layouts.WarboardTextureKit = BasicFrame
        layouts.WarboardTextureKit_FourCorners = BasicFrame
    end

    local layoutMap = {}
    for layoutName in next, layouts do
        local layout = _G.NineSliceUtil.GetLayout(layoutName)
        if layout then
            layoutMap[layout] = layoutName
        end
    end

    local function GetNineSlicePiece(container, pieceName)
        if container.GetNineSlicePiece then
            return container:GetNineSlicePiece(pieceName)
        end

        return container[pieceName]
    end

    Hook.NineSliceUtil = {}
    function Hook.NineSliceUtil.ApplyLayout(container, userLayout, textureKit)
        if not container._auroraNineSlice then return end

        local layoutName = layoutMap[userLayout]
        --print("ApplyLayout", container, layoutName, textureKit)
        if layouts[layoutName] then
            layouts[layoutName](container)
        else
            if not container._auroraBackdrop then return end
            container:SetBackdrop(private.backdrop)
            for i = 1, #nineSliceSetup do
                local piece = GetNineSlicePiece(container, nineSliceSetup[i])
                if piece then
                    piece:SetTexture("")
                end
            end
        end
    end
    function Hook.NineSliceUtil.ApplyLayoutByName(container, userLayoutName, textureKit)
        if not container.GetFrameLayoutType then
            if layouts[userLayoutName] then
                layouts[userLayoutName](container)
            end
        end
    end
    function Hook.NineSliceUtil.AddLayout(layoutName, layout)
        layoutMap[layout] = layoutName
    end
end

function private.SharedXML.NineSlice()
    Util.Mixin(_G.NineSliceUtil, Hook.NineSliceUtil)
end
