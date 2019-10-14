local _, private = ...

--[[ Lua Globals ]]
-- luacheck: globals select ipairs min

--[[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color, Util = Aurora.Color, Aurora.Util

do --[[ AddOns\Blizzard_AuctionHouseUI.lua ]]
    do --[[ Blizzard_AuctionHouseTableBuilder ]]
        Hook.AuctionHouseTableHeaderStringMixin = {}
        function Hook.AuctionHouseTableHeaderStringMixin:SetArrowState(sortOrderState)
            self.Arrow:SetTexCoord(0, 1, 0, 1)
            if sortOrderState == _G.AuctionHouseSortOrderState.PrimarySorted then
                Base.SetTexture(self.Arrow, "arrowUp")
            elseif sortOrderState == _G.AuctionHouseSortOrderState.PrimaryReversed then
                Base.SetTexture(self.Arrow, "arrowDown")
            end
        end
    end
    do --[[ Blizzard_AuctionHouseItemList ]]
        Hook.AuctionHouseItemListMixin = {}
        function Hook.AuctionHouseItemListMixin:Init()
            for i, button in ipairs(self.ScrollFrame.buttons) do
                if not self.hideStripes then
                    local oddRow = (i % 2) == 1
                    button.NormalTexture:SetColorTexture(Color.white:GetRGB())
                    button.NormalTexture:SetAlpha(oddRow and 0.05 or 0.0)
                end
            end
        end
        function Hook.AuctionHouseItemListMixin:RefreshScrollFrame()
            local numResults = self.getNumEntries()
            if numResults == 0 then return end

            local buttons = _G.HybridScrollFrame_GetButtons(self.ScrollFrame)
            local buttonCount = #buttons

            local offset = self:GetScrollOffset()
            for i = 1, buttonCount do
                local visible = i + offset <= numResults
                local button = buttons[i]

                if visible then
                    --button.NormalTexture:SetAlpha(0.3)

                    if self.highlightCallback then
                        local currentRowData = button.rowData
                        local quantity = min(currentRowData.maximumToHighlight or 0, currentRowData.quantity)
                        local highlightAlpha = _G.Lerp(0.2, 0.8, quantity / currentRowData.quantity)

                        button.SelectedHighlight:SetAlpha(highlightAlpha)
                    end
                end
            end
        end
    end
    do --[[ Blizzard_AuctionHouseCategoriesList ]]
        function Hook.AuctionFrameFilters_UpdateCategories(categoriesList, forceSelectionIntoView)
            for i = 1, _G.NUM_FILTERS_TO_DISPLAY do
                local button = categoriesList.FilterButtons[i]
                if button.SelectedTexture:IsShown() then
                    button:LockHighlight()
                else
                    button:UnlockHighlight()
                end
            end
        end
        function Hook.FilterButton_SetUp(button, info)
            local bd = button:GetBackdrop()

            if info.type == "subSubCategory" then
                button:SetBackdrop(nil)

                button.SelectedTexture:SetColorTexture(Color.highlight:GetRGB())
                button.SelectedTexture:SetAlpha(0.5)

                button.HighlightTexture:SetColorTexture(Color.highlight:GetRGB())
                button.HighlightTexture:SetAlpha(0.5)
            else
                button:SetBackdrop(bd)
                button.HighlightTexture:SetAlpha(0)
                button.SelectedTexture:SetAlpha(0)

                if info.selected then
                    button:LockHighlight()
                else
                    button:UnlockHighlight()
                end

                if info.type == "category" then
                    button:SetBackdropOption("offsets", {
                        left = 1,
                        right = 1,
                        top = 1,
                        bottom = 1,
                    })
                elseif info.type == "subCategory" then
                    button:SetBackdropOption("offsets", {
                        left = 11,
                        right = 1,
                        top = 1,
                        bottom = 1,
                    })
                end
            end
        end
    end
end

do --[[ AddOns\Blizzard_AuctionHouseUI.xml ]]
    do --[[ Blizzard_AuctionHouseTableBuilder ]]
        function Skin.AuctionHouseTableCellItemDisplayTemplate(Frame)
            Frame.Icon._auroraBG = Base.CropIcon(Frame.Icon, Frame)
            Frame.IconBorder:SetAlpha(0)
        end
        function Skin.AuctionHouseTableHeaderStringTemplate(Button)
            Skin.ColumnDisplayButtonShortTemplate(Button)
            Button.Arrow:SetSize(10, 5)
        end
    end
    do --[[ Blizzard_AuctionHouseSharedTemplates ]]
        function Skin.AuctionHouseBackgroundTemplate(Frame)
            Frame.NineSlice.Center = Frame.Background
            Skin.NineSlicePanelTemplate(Frame.NineSlice)
        end
        function Skin.AuctionHouseItemDisplayBaseTemplate(Button)
            Skin.AuctionHouseBackgroundTemplate(Button)
        end
        function Skin.AuctionHouseItemDisplayTemplate(Button)
            Skin.AuctionHouseItemDisplayBaseTemplate(Button)
            Skin.CircularGiantItemButtonTemplate(Button.ItemButton)
        end
        function Skin.AuctionHouseQuantityInputEditBoxTemplate(Frame)
            Skin.LargeInputBoxTemplate(Frame)
        end
        function Skin.AuctionHouseRefreshFrameTemplate(Frame)
            Skin.RefreshButtonTemplate(Frame.RefreshButton)
        end
        function Skin.AuctionHouseBidFrameTemplate(Frame)
            Skin.MoneyInputFrameTemplate(Frame.BidAmount)
            Skin.UIPanelButtonTemplate(Frame.BidButton)
        end
        function Skin.AuctionHouseBuyoutFrameTemplate(Frame)
            Skin.UIPanelButtonTemplate(Frame.BuyoutButton)
        end
    end
    do --[[ Blizzard_AuctionHouseTab ]]
        function Skin.AuctionHouseFrameTabTemplate(Button)
            Skin.CharacterFrameTabButtonTemplate(Button)
            Button._auroraTabResize = true
        end
        function Skin.AuctionHouseFrameTopTabTemplate(Button)
            Skin.TabButtonTemplate(Button)
        end
        function Skin.AuctionHouseFrameDisplayModeTabTemplate(Button)
            Skin.AuctionHouseFrameTabTemplate(Button)
        end
    end
    do --[[ Blizzard_AuctionHouseItemList ]]
        function Skin.AuctionHouseItemListLineTemplate(Button)
            Button.SelectedHighlight:SetColorTexture(Color.highlight:GetRGB())
            Button.SelectedHighlight:SetAlpha(0.5)

            Button.HighlightTexture:SetColorTexture(Color.highlight:GetRGB())
            Button.HighlightTexture:SetAlpha(0.5)
        end
        function Skin.AuctionHouseFavoritableLineTemplate(Button)
            Skin.AuctionHouseItemListLineTemplate(Button)
        end
        function Skin.AuctionHouseItemListTemplate(Frame)
            Util.Mixin(Frame, Hook.AuctionHouseItemListMixin)

            Skin.AuctionHouseBackgroundTemplate(Frame)

            Skin.AuctionHouseRefreshFrameTemplate(Frame.RefreshFrame)
            --Skin.AuctionHouseItemListHeadersTemplate(Frame.HeaderContainer)
            Skin.HybridScrollBarTemplate(Frame.ScrollFrame.scrollBar)
            Frame.ScrollFrame.scrollBar.Background:Hide()
        end
    end
    do --[[ Blizzard_AuctionHouseCategoriesList ]]
        function Skin.AuctionCategoryButtonTemplate(Button)
            Skin.FrameTypeButton(Button)

            Button.NormalTexture:Hide()
            Button.HighlightTexture:SetColorTexture(Color.highlight:GetRGB())
            Button.SelectedTexture:SetColorTexture(Color.highlight:GetRGB())
        end
        function Skin.AuctionHouseCategoriesListTemplate(Frame)
            Skin.NineSlicePanelTemplate(Frame.NineSlice)

            for i = 1, _G.NUM_FILTERS_TO_DISPLAY do
                Skin.AuctionCategoryButtonTemplate(Frame.FilterButtons[i])
            end

            Skin.FauxScrollFrameTemplate(Frame.ScrollFrame)
            Frame.ScrollFrame.scrollBorderTop:Hide()
            Frame.ScrollFrame.scrollBorderBottom:Hide()
            Frame.ScrollFrame.scrollBorderMiddle:Hide()
            Frame.ScrollFrame.scrollFrameScrollBarBackground:Hide()

            Frame.Background:Hide()
        end
    end
    do --[[ Blizzard_AuctionHouseSearchBar ]]
        function Skin.AuctionHouseSearchBoxTemplate(EditBox)
            Skin.SearchBoxTemplate(EditBox)
        end
        function Skin.AuctionHouseFavoritesSearchButtonTemplate(Button)
            Skin.SquareIconButtonTemplate(Button)
        end
        function Skin.AuctionHouseLevelRangeFrameTemplate(Frame)
            Skin.InputBoxTemplate(Frame.MinLevel)
            Skin.InputBoxTemplate(Frame.MaxLevel)
        end
        function Skin.AuctionHouseFilterButtonTemplate(Button)
            Button.Icon:SetSize(5, 10)
            Base.SetTexture(Button.Icon, "arrowRight")
            Skin.UIMenuButtonStretchTemplate(Button)
            Skin.AuctionHouseLevelRangeFrameTemplate(Button.LevelRangeFrame)
        end
        function Skin.AuctionHouseFilterDropDownMenuTemplate(Frame)
            Skin.UIDropDownMenuTemplate(Frame)
        end
        function Skin.AuctionHouseSearchButtonTemplate(Button)
            Skin.UIPanelButtonTemplate(Button)
        end
        function Skin.AuctionHouseSearchBarTemplate(Frame)
            Skin.AuctionHouseFavoritesSearchButtonTemplate(Frame.FavoritesSearchButton)
            Skin.AuctionHouseSearchBoxTemplate(Frame.SearchBox)
            Skin.AuctionHouseSearchButtonTemplate(Frame.SearchButton)
            Skin.AuctionHouseFilterButtonTemplate(Frame.FilterButton)
        end
    end
    do --[[ Blizzard_AuctionHouseBrowseResultsFrame ]]
        function Skin.AuctionHouseBrowseResultsFrameTemplate(Frame)
            Skin.AuctionHouseItemListTemplate(Frame.ItemList)
        end
    end
    do --[[ Blizzard_AuctionHouseCommoditiesList ]]
        function Skin.AuctionHouseCommoditiesListTemplate(Frame)
            Skin.AuctionHouseItemListTemplate(Frame)
        end
        function Skin.AuctionHouseCommoditiesBuyListTemplate(Frame)
            Skin.AuctionHouseCommoditiesListTemplate(Frame)
        end
        function Skin.AuctionHouseCommoditiesSellListTemplate(Frame)
            Skin.AuctionHouseCommoditiesListTemplate(Frame)
        end
    end
    do --[[ Blizzard_AuctionHouseItemBuyFrame ]]
        function Skin.AuctionHouseItemBuyFrameTemplate(Frame)
            Skin.UIPanelButtonTemplate(Frame.BackButton)
            Skin.AuctionHouseItemDisplayTemplate(Frame.ItemDisplay)
            Skin.AuctionHouseBuyoutFrameTemplate(Frame.BuyoutFrame)
            Skin.AuctionHouseBidFrameTemplate(Frame.BidFrame)
            Skin.AuctionHouseItemListTemplate(Frame.ItemList)
        end
    end
    do --[[ Blizzard_AuctionHouseSellFrame ]]
        function Skin.AuctionHouseSellFrameAlignedControlTemplate(Frame)
        end
        function Skin.AuctionHouseAlignedQuantityInputFrameTemplate(Frame)
            Skin.AuctionHouseSellFrameAlignedControlTemplate(Frame)
            Skin.AuctionHouseQuantityInputEditBoxTemplate(Frame.InputBox)
            Skin.UIPanelButtonTemplate(Frame.MaxButton)
        end
    end
    do --[[ Blizzard_AuctionHouseCommoditiesBuyFrame ]]
        function Skin.AuctionHouseCommoditiesBuyDisplayTemplate(Frame)
            Skin.AuctionHouseBackgroundTemplate(Frame)

            Skin.AuctionHouseItemDisplayTemplate(Frame.ItemDisplay)
            local _, _, itemheaderframe = Frame.ItemDisplay:GetRegions()
            itemheaderframe:Hide()

            Skin.AuctionHouseAlignedQuantityInputFrameTemplate(Frame.QuantityInput)
            --Skin.AuctionHouseAlignedPriceDisplayTemplate(Frame.UnitPrice)
            --Skin.AuctionHouseAlignedPriceDisplayTemplate(Frame.TotalPrice)
            Skin.UIPanelButtonTemplate(_G.BuyButton)
        end
        function Skin.AuctionHouseCommoditiesBuyFrameTemplate(Frame)
            Skin.UIPanelButtonTemplate(Frame.BackButton)
            Skin.AuctionHouseCommoditiesBuyDisplayTemplate(Frame.BuyDisplay)
            Skin.AuctionHouseCommoditiesBuyListTemplate(Frame.ItemList)
        end
    end
    do --[[ Blizzard_AuctionHouseWoWTokenFrame ]]
        function Skin.DummyScrollBarTemplate(Slider)
            Skin.HybridScrollBarTemplate(Slider)
            Slider.Background:Hide()
        end
        function Skin.BrowseWowTokenResultsTemplate(Frame)
            Skin.AuctionHouseBackgroundTemplate(Frame)

            local GameTimeTutorial = Frame.GameTimeTutorial
            Skin.ButtonFrameTemplate(GameTimeTutorial)
            GameTimeTutorial.Tutorial:ClearAllPoints()
            GameTimeTutorial.Tutorial:SetPoint("TOPLEFT", 0, -private.FRAME_TITLE_HEIGHT)
            GameTimeTutorial.Tutorial:SetPoint("BOTTOMRIGHT", 0, 0)
            Skin.UIPanelGoldButtonTemplate(GameTimeTutorial.RightDisplay.StoreButton)

            Skin.MainHelpPlateButton(Frame.HelpButton)
            do -- Token
                local Token = Frame.Token
                Token.ItemBorder:Hide()

                local border = Base.CropIcon(Token.Icon, Token)
                border:SetColorTexture(_G.HEIRLOOM_BLUE_COLOR:GetRGB())

                Token.IconBorder:Hide()
                local nameBG = _G.CreateFrame("Frame", nil, Token)
                nameBG:SetPoint("TOPLEFT", border, "TOPRIGHT", 1, 0)
                nameBG:SetPoint("BOTTOMRIGHT", -3, 1)
                Base.SetBackdrop(nameBG, Color.frame)
            end
            Skin.UIPanelButtonTemplate(Frame.Buyout)
            Skin.DummyScrollBarTemplate(Frame.DummyScrollBar)
        end
    end
end

function private.AddOns.Blizzard_AuctionHouseUI()
    if not private.isPatch then return end
    ----====####$$$$%%%%$$$$####====----
    --      Blizzard_AuctionData      --
    ----====####$$$$%%%%$$$$####====----


    ----====####$$$$%%%%%$$$$####====----
    --    Blizzard_AuctionHouseUtil    --
    ----====####$$$$%%%%%$$$$####====----


    ----====####$$$$%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseTableBuilder --
    ----====####$$$$%%%%%%%$$$$####====----
    Util.Mixin(_G.AuctionHouseTableHeaderStringMixin, Hook.AuctionHouseTableHeaderStringMixin)


    ----====####$$$$%%%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseSharedTemplates --
    ----====####$$$$%%%%%%%%%%$$$$####====----


    ----====####$$$$%%%%$$$$####====----
    --    Blizzard_AuctionHouseTab    --
    ----====####$$$$%%%%$$$$####====----


    ----====####$$$$%%%%%$$$$####====----
    --  Blizzard_AuctionHouseItemList  --
    ----====####$$$$%%%%%$$$$####====----
    --Util.Mixin(_G.AuctionHouseItemListMixin, Hook.AuctionHouseItemListMixin)


    ----====####$$$$%%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseCategoriesList --
    ----====####$$$$%%%%%%%%%$$$$####====----
    _G.hooksecurefunc("AuctionFrameFilters_UpdateCategories", Hook.AuctionFrameFilters_UpdateCategories)
    _G.hooksecurefunc("FilterButton_SetUp", Hook.FilterButton_SetUp)


    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_AuctionHouseSearchBar --
    ----====####$$$$%%%%$$$$####====----


    ----====####$$$$%%%%%%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseBrowseResultsFrame --
    ----====####$$$$%%%%%%%%%%%%%$$$$####====----


    ----====####$$$$%%%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseCommoditiesList --
    ----====####$$$$%%%%%%%%%%$$$$####====----


    ----====####$$$$%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseItemBuyFrame --
    ----====####$$$$%%%%%%%$$$$####====----


    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_AuctionHouseSellFrame --
    ----====####$$$$%%%%$$$$####====----


    ----====####$$$$%%%%%%%%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseCommoditiesSellFrame --
    ----====####$$$$%%%%%%%%%%%%%%%$$$$####====----


    ----====####$$$$%%%%%%%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseCommoditiesBuyFrame --
    ----====####$$$$%%%%%%%%%%%%%%$$$$####====----


    ----====####$$$$%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseItemSellFrame --
    ----====####$$$$%%%%%%%%$$$$####====----


    ----====####$$$$%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseAuctionsFrame --
    ----====####$$$$%%%%%%%%$$$$####====----


    ----====####$$$$%%%%%%%%$$$$####====----
    -- Blizzard_AuctionHouseWoWTokenFrame --
    ----====####$$$$%%%%%%%%$$$$####====----


    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_AuctionHouseBuyDialog --
    ----====####$$$$%%%%$$$$####====----


    ----====####$$$$%%%%$$$$####====----
    -- Blizzard_AuctionHouseMultisell --
    ----====####$$$$%%%%$$$$####====----


    ----====####$$$$%%%%$$$$####====----
    --   Blizzard_AuctionHouseFrame   --
    ----====####$$$$%%%%$$$$####====----
    local AuctionHouseFrame = _G.AuctionHouseFrame
    Skin.PortraitFrameTemplate(AuctionHouseFrame)

    local _, _, MoneyInsetFrame = AuctionHouseFrame:GetChildren()
    Skin.InsetFrameTemplate(MoneyInsetFrame)
    Skin.ThinGoldEdgeTemplate(AuctionHouseFrame.MoneyFrameBorder)
    local _, _, _, border = AuctionHouseFrame.MoneyFrameBorder:GetRegions()
    border:Hide()

    Skin.AuctionHouseFrameDisplayModeTabTemplate(AuctionHouseFrame.BuyTab)
    Skin.AuctionHouseFrameDisplayModeTabTemplate(AuctionHouseFrame.SellTab)
    Skin.AuctionHouseFrameDisplayModeTabTemplate(AuctionHouseFrame.AuctionsTab)
    Util.PositionRelative("TOPLEFT", AuctionHouseFrame, "BOTTOMLEFT", 20, -1, 1, "Right", AuctionHouseFrame.Tabs)

    Skin.AuctionHouseSearchBarTemplate(AuctionHouseFrame.SearchBar)
    Skin.AuctionHouseCategoriesListTemplate(AuctionHouseFrame.CategoriesList)
    Skin.AuctionHouseBrowseResultsFrameTemplate(AuctionHouseFrame.BrowseResultsFrame)
    Skin.BrowseWowTokenResultsTemplate(AuctionHouseFrame.WoWTokenResults)

    Skin.AuctionHouseCommoditiesBuyFrameTemplate(AuctionHouseFrame.CommoditiesBuyFrame)
    Skin.AuctionHouseItemBuyFrameTemplate(AuctionHouseFrame.ItemBuyFrame)
end


function private.AddOns.Blizzard_AuctionUI()
    if private.isPatch then return end
    local F, C = _G.unpack(Aurora)

    F.SetBD(_G.AuctionFrame, 11, -12, -1, 10)
    _G.AuctionPortraitTexture:Hide()
    _G.AuctionFrame:DisableDrawLayer("ARTWORK")

    for i = 1, 3 do
        F.ReskinTab(_G["AuctionFrameTab"..i])
    end

    local moneyBG = _G.CreateFrame("Frame", nil, _G.AuctionFrame)
    Base.SetBackdrop(moneyBG, Color.frame)
    moneyBG:SetBackdropBorderColor(1, 0.95, 0.15)
    moneyBG:SetPoint("BOTTOMLEFT", 20, 18)
    moneyBG:SetPoint("TOPRIGHT", _G.AuctionFrame, "BOTTOMLEFT", 175, 35)

    F.ReskinClose(_G.AuctionFrameCloseButton)

    local function SkinSort(sortButtons)
        for i = 1, #sortButtons do
            _G[sortButtons[i]]:DisableDrawLayer("BACKGROUND")
        end
    end
    local function SkinScroll(scroll)
        scroll:GetRegions():Hide()
        select(2, scroll:GetRegions()):Hide()
        F.ReskinScroll(scroll.ScrollBar)
    end
    local function SkinList(prefix, middleIdx, numToDisplay)
        for i = 1, numToDisplay do
            local name = prefix..i
            local button = _G[name]
            local item = _G[name.."Item"]
            local icon = _G[name.."ItemIconTexture"]

            if button and item then
                item._auroraIconBorder = F.ReskinIcon(icon)
                item:SetNormalTexture("")
                item:SetPushedTexture("")

                _G[name.."Left"]:Hide()
                _G[name.."Right"]:Hide()
                select(middleIdx, button:GetRegions()):Hide() -- middle

                local bd = _G.CreateFrame("Frame", nil, button)
                bd:SetPoint("TOPLEFT", item, "TOPRIGHT", 2, 1)
                bd:SetPoint("BOTTOMRIGHT", 0, 4)
                bd:SetFrameLevel(button:GetFrameLevel()-1)
                F.CreateBD(bd, .25)
                button._auroraBD = bd

                local highlight = button:GetHighlightTexture()
                highlight:SetTexture([[Interface\ClassTrainerFrame\TrainerTextures]])
                highlight:SetTexCoord(0.005859375, 0.5703125, 0.85546875, 0.939453125)
                highlight:SetPoint("TOPLEFT", bd, 1, -1)
                highlight:SetPoint("BOTTOMRIGHT", bd, -1, 1)
            end
        end
    end
    local function SkinButtons(buttons, hasBorder)
        for i = 1, #buttons do
            local button = buttons[i]
            F.Reskin(button)
            if hasBorder then
                select(6, button:GetRegions()):Hide()
            end
            if i == 1 then
                button:SetPoint("BOTTOMRIGHT", 66, 15)
            else
                button:SetPoint("RIGHT", buttons[i - 1], "LEFT", -1, 0)
            end
        end
    end

    --[[ Browse ]]--
    local filterButtonColor = {r = 0.2, g = 0.2, b = 0.2}
    local wowTokenColor = _G.BAG_ITEM_QUALITY_COLORS[_G.LE_ITEM_QUALITY_WOW_TOKEN]
    _G.hooksecurefunc("FilterButton_SetUp", function(button, info)
        if not button._auroraSkinned then
            F.CreateBD(button, 0)
            button._auroraSkinned = true
        end
        local color
        if info.isToken then
            color = wowTokenColor
        else
            color = filterButtonColor
        end
        button:SetBackdropColor(color.r, color.g, color.b, 0.6)
        button:SetBackdropBorderColor(color.r, color.g, color.b)
        button:SetNormalTexture("")
    end)
    SkinScroll(_G.BrowseFilterScrollFrame)
    SkinScroll(_G.BrowseScrollFrame)

    -- WoW token
    local BrowseWowTokenResults = _G.BrowseWowTokenResults
    F.Reskin(BrowseWowTokenResults.Buyout)

    local token = BrowseWowTokenResults.Token
    token.ItemBorder:Hide()
    local itemBG = F.CreateBDFrame(token.ItemBorder, .2)
    itemBG:SetPoint("TOPLEFT", token.Icon, "TOPRIGHT", 3, 1)
    itemBG:SetPoint("BOTTOMRIGHT", -2, 2)
    local iconBG = F.ReskinIcon(token.Icon)
    iconBG:SetBackdropBorderColor(wowTokenColor.r, wowTokenColor.g, wowTokenColor.b)
    token.IconBorder:Hide()

    local WowTokenGameTimeTutorial = _G.WowTokenGameTimeTutorial
    F.ReskinPortraitFrame(WowTokenGameTimeTutorial, true)
    WowTokenGameTimeTutorial.Tutorial:SetDrawLayer("BACKGROUND", 7)

    F.Reskin(_G.StoreButton)
    _G.StoreButton:SetSize(149, 26)
    _G.StoreButton:SetPoint("TOPLEFT", _G.WowTokenGameTimeTutorial.RightDisplay.Tutorial2, "BOTTOMLEFT", 56, -12)

    SkinSort({"BrowseQualitySort", "BrowseLevelSort", "BrowseDurationSort", "BrowseHighBidderSort", "BrowseCurrentBidSort"})
    SkinList("BrowseButton", 5, _G.NUM_BROWSE_TO_DISPLAY)

    F.ReskinInput(_G.BrowseName)
    F.ReskinInput(_G.BrowseMinLevel)
    F.ReskinInput(_G.BrowseMaxLevel)
    F.ReskinDropDown(_G.BrowseDropDown)
    F.ReskinCheck(_G.IsUsableCheckButton)
    F.ReskinCheck(_G.ShowOnPlayerCheckButton)
    F.Reskin(_G.BrowseResetButton)
    F.Reskin(_G.BrowseSearchButton)

    F.ReskinArrow(_G.BrowsePrevPageButton, "Left")
    _G.BrowsePrevPageButton:SetPoint("TOPLEFT", 660, -60)
    F.ReskinArrow(_G.BrowseNextPageButton, "Right")
    _G.BrowseNextPageButton:SetPoint("TOPRIGHT", 67, -60)

    SkinButtons({_G.BrowseCloseButton, _G.BrowseBuyoutButton, _G.BrowseBidButton}, true)
    F.ReskinMoneyInput(_G.BrowseBidPrice)
    F.ReskinCheck(_G.ExactMatchCheckButton)

    --[[ Bid ]]--
    SkinSort({"BidQualitySort", "BidLevelSort", "BidDurationSort", "BidBuyoutSort", "BidStatusSort", "BidBidSort"})
    SkinScroll(_G.BidScrollFrame)
    SkinList("BidButton", 6, _G.NUM_BIDS_TO_DISPLAY)
    F.ReskinMoneyInput(_G.BidBidPrice)
    SkinButtons({_G.BidCloseButton, _G.BidBuyoutButton, _G.BidBidButton}, true)

    --[[ Auctions ]]--
    SkinSort({"AuctionsQualitySort", "AuctionsDurationSort", "AuctionsHighBidderSort", "AuctionsBidSort"})
    SkinScroll(_G.AuctionsScrollFrame)
    SkinList("AuctionsButton", 4, _G.NUM_AUCTIONS_TO_DISPLAY)

    _G.AuctionsItemButton._auroraIconBorder = F.CreateBDFrame(_G.AuctionsItemButton, .2)
    local nameFrame = select(2, _G.AuctionsItemButton:GetRegions())
    nameFrame:Hide()
    local nameBG = F.CreateBDFrame(_G.AuctionsItemButton, .2)
    nameBG:SetPoint("TOPLEFT", _G.AuctionsItemButton, "TOPRIGHT", 3, 1)
    nameBG:SetPoint("BOTTOMRIGHT", nameFrame)
    _G.AuctionsItemButton:HookScript("OnEvent", function(self, event, ...)
        local icon = _G.AuctionsItemButton:GetNormalTexture()
        if icon then
            icon:SetTexCoord(.08, .92, .08, .92)
        end
    end)

    F.ReskinInput(_G.AuctionsStackSizeEntry)
    F.Reskin(_G.AuctionsStackSizeMaxButton)
    F.ReskinInput(_G.AuctionsNumStacksEntry)
    F.Reskin(_G.AuctionsNumStacksMaxButton)
    F.ReskinDropDown(_G.PriceDropDown)
    F.ReskinMoneyInput(_G.StartPrice)
    F.ReskinMoneyInput(_G.BuyoutPrice)
    F.ReskinDropDown(_G.DurationDropDown)
    SkinButtons({_G.AuctionsCloseButton, _G.AuctionsCancelAuctionButton})
    F.Reskin(_G.AuctionsCreateAuctionButton)

    -- AuctionProgressFrame
    for i = 1, 4 do
        select(i, _G.AuctionProgressFrame:GetRegions()):Hide()
    end
    F.CreateBD(_G.AuctionProgressFrame)
    _G.AuctionProgressFrame:SetSize(280, 53)
    _G.AuctionProgressFrame:SetPoint("BOTTOM", 0, 179)

    local AuctionProgressBar = _G.AuctionProgressBar
    F.CreateBD(AuctionProgressBar, 0)
    AuctionProgressBar:SetPoint("CENTER", 3, -1)
    AuctionProgressBar:SetStatusBarTexture(C.media.backdrop)
    AuctionProgressBar.Border:Hide()
    AuctionProgressBar.Text:ClearAllPoints()
    AuctionProgressBar.Text:SetPoint("CENTER", 0, 1)
    F.ReskinIcon(AuctionProgressBar.Icon)
    AuctionProgressBar.Icon:ClearAllPoints()
    AuctionProgressBar.Icon:SetPoint("TOPRIGHT", AuctionProgressBar, "TOPLEFT", -10, 5)
    F.ReskinClose(_G.AuctionProgressFrameCancelButton, "TOPLEFT", AuctionProgressBar, "TOPRIGHT", 11, 2)
end