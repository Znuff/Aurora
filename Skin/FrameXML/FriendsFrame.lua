local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals next select

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color, Util = Aurora.Color, Aurora.Util

do --[[ FrameXML\FriendsFrame.lua ]]
    Hook.FriendsBroadcastFrameMixin = {}
    function Hook.FriendsBroadcastFrameMixin:ShowFrame()
        self.BroadcastButton:LockHighlight()
    end
    function Hook.FriendsBroadcastFrameMixin:HideFrame()
        self.BroadcastButton:UnlockHighlight()
    end

    function Hook.FriendsFrame_UpdateFriendButton(button)
        local gameIcon = button.gameIcon
        gameIcon._bg:SetShown(gameIcon:IsShown())
    end
    function Hook.WhoList_Update()
        local buttons = _G.WhoListScrollFrame.buttons
        local numButtons = #buttons

        for i = 1, numButtons do
            local button = buttons[i]
            if button.index then
                local info = _G.C_FriendList.GetWhoInfo(button.index)
                if info.filename then
                    button.Class:SetTextColor(_G.CUSTOM_CLASS_COLORS[info.filename]:GetRGB())
                end
            end
        end
    end
end

do --[[ FrameXML\FriendsFrame.xml ]]
    function Skin.FriendsTabTemplate(Button)
        Skin.TabButtonTemplate(Button)
    end
    function Skin.FriendsFrameSlider(Slider)
        Skin.HybridScrollBarTrimTemplate(Slider)
    end
    function Skin.FriendsFrameScrollFrame(ScrollFrame)
        Skin.FriendsFrameSlider(ScrollFrame.scrollBar)
    end
    function Skin.FriendsFrameHeaderTemplate(Frame)
    end
    function Skin.FriendsFrameButtonTemplate(Button)
        Skin.UIPanelButtonTemplate(Button)
    end
    function Skin.FriendsListButtonTemplate(Button)
        local gameIcon = Button.gameIcon
        gameIcon._bg = Base.CropIcon(Button.gameIcon, Button)
        gameIcon:SetSize(22, 22)
        gameIcon:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
        gameIcon:SetPoint("TOPRIGHT", -21, -6)

        local travelPassButton = Button.travelPassButton
        Skin.FrameTypeButton(travelPassButton)
        travelPassButton:SetSize(20, 32)

        local texture = travelPassButton:CreateTexture(nil, "OVERLAY", nil, 7)
        texture:SetTexture([[Interface\FriendsFrame\PlusManz-PlusManz]])
        texture:SetPoint("TOPRIGHT", 1, -4)
        texture:SetSize(22, 22)
        texture:SetAlpha(0.75)
        travelPassButton._auroraTextures = {texture}
    end
    function Skin.WhoFrameColumnHeaderTemplate(Button)
        Button.Left:Hide()
        Button.Right:Hide()
        Button.Middle:Hide()
        Button.HighlightTexture:SetAlpha(0)
    end
    function Skin.FriendsFrameTabTemplate(Button)
        Skin.CharacterFrameTabButtonTemplate(Button)
        Button._auroraTabResize = true
    end
end

function private.FrameXML.FriendsFrame()
    _G.hooksecurefunc("FriendsFrame_UpdateFriendButton", Hook.FriendsFrame_UpdateFriendButton)
    _G.hooksecurefunc("WhoList_Update", Hook.WhoList_Update)

    local FriendsFrame = _G.FriendsFrame
    Skin.ButtonFrameTemplate(FriendsFrame)
    _G.FriendsFrameIcon:Hide()

    ----------------------
    -- FriendsTabHeader --
    ----------------------
    local FriendsTabHeader = FriendsFrame.FriendsTabHeader
    local BNetFrame = _G.FriendsFrameBattlenetFrame
    BNetFrame:GetRegions():Hide() -- BattleTag background
    BNetFrame:SetWidth(245)
    BNetFrame:SetPoint("TOPLEFT", 54, -26)
    Base.SetBackdrop(BNetFrame, _G.FRIENDS_BNET_BACKGROUND_COLOR, Color.frame.a)

    do -- BNetFrame.BroadcastButton
        local Button = BNetFrame.BroadcastButton
        Button:GetNormalTexture():SetAlpha(0)
        Button:GetPushedTexture():SetAlpha(0)
        Button:SetHighlightTexture("")
        local icon = Button:CreateTexture(nil, "ARTWORK")
        icon:SetTexture([[Interface\FriendsFrame\BroadcastIcon]])
        icon:SetSize(16, 16)
        icon:SetPoint("CENTER")

        Base.SetBackdrop(Button, Color.button)
        local bg = Button:GetBackdropTexture("bg")
        bg:SetPoint("TOPLEFT", 5, -5)
        bg:SetPoint("BOTTOMRIGHT", -5, 5)
        Base.SetHighlight(Button, "backdrop")
    end

    Skin.UIPanelInfoButton(BNetFrame.UnavailableInfoButton)

    local BroadcastFrame = BNetFrame.BroadcastFrame
    Skin.DialogBorderOpaqueTemplate(BroadcastFrame.Border)
    BroadcastFrame:SetPoint("TOPLEFT", -55, -24)

    do -- BroadcastFrame.EditBox
        local EditBox = BroadcastFrame.EditBox
        Base.CreateBackdrop(EditBox, private.backdrop, {
            tl = EditBox.TopLeftBorder,
            tr = EditBox.TopRightBorder,
            t = EditBox.TopBorder,

            bl = EditBox.BottomLeftBorder,
            br = EditBox.BottomRightBorder,
            b = EditBox.BottomBorder,

            l = EditBox.LeftBorder,
            r = EditBox.RightBorder,

            bg = EditBox.MiddleBorder
        })
        Skin.FrameTypeEditBox(EditBox)
        EditBox:SetBackdropOption("offsets", {
            left = -7,
            right = -5,
            top = 0,
            bottom = 0,
        })
    end


    Skin.FriendsFrameButtonTemplate(BroadcastFrame.UpdateButton)
    Skin.FriendsFrameButtonTemplate(BroadcastFrame.CancelButton)

    Skin.DialogBorderTemplate(BNetFrame.UnavailableInfoFrame)
    local _, blizzIcon = select(11, BNetFrame.UnavailableInfoFrame:GetRegions())
    blizzIcon:SetTexture([[Interface\Glues\MainMenu\Glues-BlizzardLogo]])

    Skin.UIDropDownMenuTemplate(_G.FriendsFrameStatusDropDown)
    _G.FriendsFrameStatusDropDown:SetPoint("TOPLEFT", -12, -27)
    Skin.FriendsTabTemplate(FriendsTabHeader.Tab1)
    Skin.FriendsTabTemplate(FriendsTabHeader.Tab2)
    Skin.FriendsTabTemplate(FriendsTabHeader.Tab3)


    ----------------------
    -- FriendsListFrame --
    ----------------------
    local FriendsListFrame = _G.FriendsListFrame
    Skin.FriendsFrameButtonTemplate(_G.FriendsFrameAddFriendButton)
    Skin.FriendsFrameButtonTemplate(_G.FriendsFrameSendMessageButton)
    Skin.UIDropDownMenuTemplate(FriendsListFrame.FilterDropDown)
    Skin.UIPanelButtonTemplate(FriendsListFrame.RIDWarning:GetChildren()) -- ContinueButton
    Skin.FriendsFrameScrollFrame(_G.FriendsListFrameScrollFrame)
    Hook.HybridScrollFrame_CreateButtons(_G.FriendsListFrameScrollFrame, "FriendsListButtonTemplate") -- Called here since the original is called OnLoad


    ----------------------
    -- IgnoreListFrame --
    ----------------------
    Skin.FriendsFrameButtonTemplate(_G.FriendsFrameIgnorePlayerButton)
    Skin.FriendsFrameButtonTemplate(_G.FriendsFrameUnsquelchButton)
    Skin.FriendsFrameHeaderTemplate(_G.FriendsFrameIgnoredHeader)
    Skin.FriendsFrameHeaderTemplate(_G.FriendsFrameBlockedInviteHeader)
    Skin.FriendsFrameScrollFrame(_G.IgnoreListFrameScrollFrame)


    --------------
    -- WhoFrame --
    --------------
    Skin.InsetFrameTemplate(_G.WhoFrameListInset)
    Skin.WhoFrameColumnHeaderTemplate(_G.WhoFrameColumnHeader1)
    Skin.WhoFrameColumnHeaderTemplate(_G.WhoFrameColumnHeader2)
    Skin.UIDropDownMenuTemplate(_G.WhoFrameDropDown)
    _G.WhoFrameDropDownHighlightTexture:SetAlpha(0)
    Skin.WhoFrameColumnHeaderTemplate(_G.WhoFrameColumnHeader3)
    Skin.WhoFrameColumnHeaderTemplate(_G.WhoFrameColumnHeader4)
    Skin.FriendsFrameButtonTemplate(_G.WhoFrameGroupInviteButton)
    Skin.UIPanelButtonTemplate(_G.WhoFrameAddFriendButton)
    Skin.UIPanelButtonTemplate(_G.WhoFrameWhoButton)
    Skin.InsetFrameTemplate(_G.WhoFrameEditBoxInset)
    Skin.FriendsFrameScrollFrame(_G.WhoListScrollFrame)


    ----------------------
    -- FriendsFrameMisc --
    ----------------------
    Skin.FriendsFrameTabTemplate(_G.FriendsFrameTab1)
    Skin.FriendsFrameTabTemplate(_G.FriendsFrameTab2)
    Skin.FriendsFrameTabTemplate(_G.FriendsFrameTab3)
    Skin.FriendsFrameTabTemplate(_G.FriendsFrameTab4)
    Util.PositionRelative("TOPLEFT", FriendsFrame, "BOTTOMLEFT", 20, -1, 1, "Right", {
        _G.FriendsFrameTab1,
        _G.FriendsFrameTab2,
        _G.FriendsFrameTab3,
        _G.FriendsFrameTab4,
    })

    Skin.GlowBoxTemplate(FriendsFrame.FriendsFrameQuickJoinHelpTip)







    --------------------
    -- AddFriendFrame --
    --------------------
    Skin.DialogBorderTemplate(_G.AddFriendFrame.Border)
    Skin.UIPanelButtonTemplate(_G.AddFriendInfoFrameContinueButton)

    Skin.UIPanelInfoButton(_G.AddFriendEntryFrameInfoButton)
    do -- AddFriendNameEditBox
        Skin.FrameTypeEditBox(_G.AddFriendNameEditBox)
        _G.AddFriendNameEditBoxLeft:Hide()
        _G.AddFriendNameEditBoxRight:Hide()
        _G.AddFriendNameEditBoxMiddle:Hide()
    end
    Skin.UIPanelButtonTemplate(_G.AddFriendEntryFrameAcceptButton)
    Skin.UIPanelButtonTemplate(_G.AddFriendEntryFrameCancelButton)







    -------------------------
    -- FriendsFriendsFrame --
    -------------------------
    Skin.DialogBorderTemplate(_G.FriendsFriendsFrame.Border)
    Skin.UIDropDownMenuTemplate(_G.FriendsFriendsFrameDropDown)
    _G.FriendsFriendsFrame.ScrollFrameBorder:SetBackdrop(nil)
    Skin.FriendsFrameScrollFrame(_G.FriendsFriendsScrollFrame)
    Skin.UIPanelButtonTemplate(_G.FriendsFriendsFrame.SendRequestButton)
    Skin.UIPanelButtonTemplate(_G.FriendsFriendsFrame.CloseButton)







    --------------------------
    -- BattleTagInviteFrame --
    --------------------------
    Skin.DialogBorderTemplate(_G.BattleTagInviteFrame.Border)
    local _, send, cancel = _G.BattleTagInviteFrame:GetChildren()
    Skin.UIPanelButtonTemplate(send)
    Skin.UIPanelButtonTemplate(cancel)
end
