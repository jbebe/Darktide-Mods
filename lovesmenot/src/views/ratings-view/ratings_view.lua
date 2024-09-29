local ViewElementInputLegend = require 'scripts/ui/view_elements/view_element_input_legend/view_element_input_legend'
local ScriptWorld = require 'scripts/foundation/utilities/script_world'
local UIWidget = require 'scripts/managers/ui/ui_widget'
local UIWidgetGrid = require 'scripts/ui/widget_logic/ui_widget_grid'
local UIRenderer = require 'scripts/managers/ui/ui_renderer'
local localization = modRequire 'lovesmenot/src/mod.localization'
local constants = modRequire 'lovesmenot/src/constants'
local styleUtils = modRequire 'lovesmenot/src/utils/style'
local gameUtils = modRequire 'lovesmenot/src/utils/game'
local fun = modRequire 'lovesmenot/nurgle_modules/fun'

---@class RatingsViewType: BaseViewType
---@field _blueprints table
---@field _category_alignment_list table
---@field _category_content_grid table
---@field _category_content_widgets table
---@field _controller LovesMeNot
---@field _input_legend_element table
---@field _offscreen_viewport table
---@field _offscreen_viewport_name string
---@field _offscreen_world table
---@field _render_scale table
---@field _render_settings table
---@field _selected_settings_widget table
---@field _ui_offscreen_renderer table
---@field _ui_scenegraph table
---@field _using_cursor_navigation table
---@field _widgets_by_name table
---@field super table
---@field ui_manager table
local RatingsView = class('RatingsView', 'BaseView')

--
-- Init
--

---@param context RatingsViewContext
function RatingsView:init(settings, context)
    self._definitions = context.definitions
    self._blueprints = context.blueprints
    self._settings = context.settings
    self._controller = context.controller
    RatingsView.super.init(self, self._definitions, settings or self._settings, context)
    self._allow_close_hotkey = true
    self._pass_draw = false
    self.ui_manager = Managers.ui
    self:_setup_offscreen_gui()
end

function RatingsView:_setup_offscreen_gui()
    local ui_manager = Managers.ui
    local class_name = self.__class_name
    local timer_name = 'ui'
    local world_layer = 10
    local world_name = class_name .. '_ui_offscreen_world'
    local view_name = self.view_name
    self._offscreen_world = ui_manager:create_world(world_name, world_layer, timer_name, view_name)
    local shading_environment = self._settings.shading_environment
    local viewport_name = class_name .. '_ui_offscreen_world_viewport'
    local viewport_type = 'overlay_offscreen'
    local viewport_layer = 1
    self._offscreen_viewport = ui_manager:create_viewport(self._offscreen_world, viewport_name, viewport_type,
        viewport_layer, shading_environment)
    self._offscreen_viewport_name = viewport_name
    self._ui_offscreen_renderer = ui_manager:create_renderer(class_name .. '_ui_offscreen_renderer',
        self._offscreen_world)
end

function RatingsView:on_enter()
    RatingsView.super.on_enter(self)

    self._using_cursor_navigation = Managers.ui:using_cursor_navigation()
    self:_setup_category_config()
    self:_setup_input_legend()
end

local ratingsIconMap = {
    [constants.RATINGS.NEGATIVE] = constants.SYMBOLS.FLAME,
    [constants.RATINGS.POSITIVE] = constants.SYMBOLS.WREATH,
}

local ratingsColorMap = {
    [constants.RATINGS.NEGATIVE] = constants.COLORS.ORANGE,
    [constants.RATINGS.POSITIVE] = constants.COLORS.GREEN,
}

---@param a RatingAccount
---@param b RatingAccount
local function compareByCreationDate(a, b)
    return a.creationDate < b.creationDate
end

function RatingsView:_get_widget_configs()
    local widgetConfig = {}
    local rawRatings = table.clone(self._controller.localRating and
        self._controller.localRating.accounts or {})

    ---@alias ExtendedRatingAccount (RatingAccount | { accountId: string })

    ---@type ExtendedRatingAccount[]
    local sortedRatings = fun.reduce(function(acc, accountId, accountInfo)
        accountInfo.accountId = accountId
        table.insert(acc, accountInfo)
        return acc
    end, {}, rawRatings)
    table.sort(sortedRatings, compareByCreationDate)

    local negativeRatings, positiveRatings = fun.partition(function(x)
        ---@cast x ExtendedRatingAccount
        return x.rating == constants.RATINGS.NEGATIVE
    end, sortedRatings)

    ---@type ExtendedRatingAccount[]
    local groupedRatings = fun.chain(positiveRatings, negativeRatings)

    self._controller.dmf:add_global_localize_strings({
        lovesmenot_ratingsview_delete_title = localization.lovesmenot_ratingsview_delete_title,
        lovesmenot_ratingsview_delete_description = localization.lovesmenot_ratingsview_delete_description,
        lovesmenot_ratingsview_delete_yes = localization.lovesmenot_ratingsview_delete_yes,
        lovesmenot_ratingsview_delete_no = localization.lovesmenot_ratingsview_delete_no,
    })

    if self._controller:isCommunity() then
        for hash, rating in pairs(self._controller.communityRating) do
            local title = 'lovesmenot_ratingsview_griditem_title_' .. hash
            local subtitle = 'lovesmenot_ratingsview_griditem_subtitle_' .. hash
            local ratingText = self._controller.dmf:localize('lovesmenot_ingame_rating_' .. rating)
            local ratingIcon = styleUtils.colorize(ratingsColorMap[rating], ratingsIconMap[rating])
            local ratingIconWithPadding = ratingIcon
            if rating == constants.RATINGS.NEGATIVE then
                ratingIconWithPadding = '\u{2009}' .. ratingIconWithPadding .. '\u{2009}'
            else
                ratingText = ratingText .. '    '
            end
            self._controller.dmf:add_global_localize_strings({
                [title] = {
                    en = self._controller.dmf:localize('lovesmenot_ratingsview_griditem_title',
                        ratingIconWithPadding, ratingText, '', hash),
                },
                [subtitle] = {
                    en = constants.SYMBOLS.WEB ..
                        ' ' .. self._controller.dmf:localize('lovesmenot_ingame_community_rating'),
                }
            })
            local entry = {
                widget_type = 'settings_button',
                display_name = title,
                display_name2 = subtitle,
            }
            widgetConfig[#widgetConfig + 1] = entry
        end
    end

    for _, info in fun.iter(groupedRatings) do
        local title = 'lovesmenot_ratingsview_griditem_title_' .. info.accountId
        local subtitle = 'lovesmenot_ratingsview_griditem_subtitle_' .. info.accountId
        local playerInfo = Managers.data_service.social:get_player_info_by_account_id(info.accountId)
        local playerAvailability = playerInfo._presence._immaterium_entry.status
        local platformIcon = constants.PLATFORMS[info.platform]
        local ratingIcon = styleUtils.colorize(ratingsColorMap[info.rating], ratingsIconMap[info.rating])
        local ratingText = self._controller.dmf:localize('lovesmenot_ingame_rating_' .. info.rating)
        local ratingIconWithPadding = ratingIcon
        if info.rating == constants.RATINGS.NEGATIVE then
            ratingIconWithPadding = '\u{2009}' .. ratingIconWithPadding .. '\u{2009}'
        else
            ratingText = ratingText .. '  '
        end
        self._controller.dmf:add_global_localize_strings({
            [title] = {
                en = self._controller.dmf:localize('lovesmenot_ratingsview_griditem_title',
                    ratingIconWithPadding, ratingText, platformIcon, info.name),
            },
            [subtitle] = {
                en = self._controller.dmf:localize('lovesmenot_ratingsview_griditem_subtitle',
                    info.characterName, info.characterType, playerAvailability, info.creationDate),
            }
        })
        local entry = {
            widget_type = 'settings_button',
            display_name = title,
            display_name2 = subtitle,
            pressed_function = function(parent, widget, entry)
                local context = {
                    title_text = 'lovesmenot_ratingsview_delete_title',
                    description_text = 'lovesmenot_ratingsview_delete_description',
                    options = {
                        {
                            close_on_pressed = true,
                            text = 'lovesmenot_ratingsview_delete_yes',
                            callback = callback(function()
                                self._controller.localRating.accounts[info.accountId] = nil
                                self._controller:persistLocalRating()
                                self:_reload()
                            end),
                        },
                        {
                            close_on_pressed = true,
                            hotkey = 'back',
                            template_type = 'terminal_button_small',
                            text = 'lovesmenot_ratingsview_delete_no',
                        },
                    },
                }
                Managers.event:trigger('event_show_ui_popup', context)
            end
        }
        widgetConfig[#widgetConfig + 1] = entry
    end

    -- widget list will be reversed by the grid
    return widgetConfig
end

function RatingsView:_setup_category_config()
    local scenegraph_id = 'grid_content_pivot'
    local callback_name = 'cb_on_category_pressed'
    local widgetConfig = self:_get_widget_configs()
    self._category_content_widgets, self._category_alignment_list =
        self:_setup_content_widgets(widgetConfig, scenegraph_id, callback_name)
    local scrollbar_widget_id = 'scrollbar'
    local grid_scenegraph_id = 'background'
    local grid_pivot_scenegraph_id = 'grid_content_pivot'
    local grid_spacing = self._settings.grid_spacing
    self._category_content_grid = self:_setup_grid(self._category_content_widgets, self._category_alignment_list,
        grid_scenegraph_id, grid_spacing, true)
    self:_setup_content_grid_scrollbar(self._category_content_grid, scrollbar_widget_id, grid_scenegraph_id,
        grid_pivot_scenegraph_id)
end

function RatingsView:_setup_content_grid_scrollbar(grid, widget_id, grid_scenegraph_id, grid_pivot_scenegraph_id)
    local widgets_by_name = self._widgets_by_name
    local scrollbar_widget = widgets_by_name[widget_id]

    if self._controller.dmf:get('dmf_options_scrolling_speed') and widgets_by_name and widgets_by_name['scrollbar'] then
        widgets_by_name['scrollbar'].content.scroll_speed = self._controller.dmf:get('dmf_options_scrolling_speed')
    end

    grid:assign_scrollbar(scrollbar_widget, grid_pivot_scenegraph_id, grid_scenegraph_id)
    grid:set_scrollbar_progress(0)
end

function RatingsView:_setup_grid(widgets, alignment_list, grid_scenegraph_id, spacing, use_is_focused)
    local ui_scenegraph = self._ui_scenegraph
    local direction = 'down'
    local grid = UIWidgetGrid:new(widgets, alignment_list, ui_scenegraph, grid_scenegraph_id, direction, spacing, nil,
        use_is_focused)
    local render_scale = self._render_scale

    grid:set_render_scale(render_scale)

    return grid
end

function RatingsView:_setup_content_widgets(content, scenegraph_id, callback_name)
    local widget_definitions = {}
    local widgets = {}
    local alignment_list = {}
    local amount = #content

    for i = amount, 1, -1 do
        local entry = content[i]
        local widget_type = entry.widget_type
        local widget = nil
        local template = self._blueprints[widget_type]
        local size = template.size
        local pass_template = template.pass_template

        if pass_template and not widget_definitions[widget_type] then
            widget_definitions[widget_type] = UIWidget.create_definition(pass_template, scenegraph_id, nil, size)
        end

        local widget_definition = widget_definitions[widget_type]

        if widget_definition then
            local name = scenegraph_id .. '_widget_' .. i
            widget = self:_create_widget(name, widget_definition)

            if template.init then
                template.init(self, widget, entry, callback_name)
            end

            local focus_group = entry.focus_group

            if focus_group then
                widget.content.focus_group = focus_group
            end

            widgets[#widgets + 1] = widget
        end

        alignment_list[#alignment_list + 1] = widget or {
            size = size
        }
    end

    return widgets, alignment_list
end

function RatingsView:_setup_input_legend()
    self._input_legend_element = self:_add_element(ViewElementInputLegend, 'input_legend', 10)
    local legend_inputs = self._definitions.legend_inputs
    for i = 1, #legend_inputs do
        local legend_input = legend_inputs[i]
        local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)
        local visibility_function = legend_input.visibility_function
        self._input_legend_element:add_entry(legend_input.display_name, legend_input.input_action, visibility_function,
            on_pressed_callback, legend_input.alignment)
    end
end

--
-- Present
--

function RatingsView:draw(dt, t, input_service, layer)
    self:_draw_elements(dt, t, self._ui_renderer, self._render_settings, input_service)

    self._category_content_grid:update(dt, t, input_service)

    local widgets_by_name = self._widgets_by_name
    local grid_interaction_widget = widgets_by_name.grid_interaction
    self:_draw_grid(self._category_content_grid, self._category_content_widgets, grid_interaction_widget, dt, t,
        input_service)
    RatingsView.super.draw(self, dt, t, input_service, layer)
end

function RatingsView:_draw_elements(dt, t, ui_renderer, render_settings, input_service)
    RatingsView.super._draw_elements(self, dt, t, ui_renderer, render_settings, input_service)
end

function RatingsView:_draw_grid(grid, widgets, interaction_widget, dt, t, input_service)
    local is_grid_hovered = not self._using_cursor_navigation or interaction_widget.content.hotspot.is_hover or false
    local null_input_service = input_service:null_service()
    local render_settings = self._render_settings
    local ui_renderer = self._ui_offscreen_renderer
    local ui_scenegraph = self._ui_scenegraph

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, render_settings)

    for j = 1, #widgets do
        local widget = widgets[j]
        local draw = widget ~= self._selected_settings_widget

        if draw then
            if self._selected_settings_widget then
                ui_renderer.input_service = null_input_service
            end

            if grid:is_widget_visible(widget) then
                local hotspot = widget.content.hotspot

                if hotspot then
                    hotspot.force_disabled = not is_grid_hovered
                    local is_active = hotspot.is_focused or hotspot.is_hover
                end

                UIWidget.draw(widget, ui_renderer)
            end
        end
    end

    UIRenderer.end_pass(ui_renderer)
end

--
-- Callbacks
--

function RatingsView:cb_on_category_pressed(widget, entry)
    local pressed_function = entry.pressed_function

    if pressed_function then
        pressed_function(self, widget, entry)
    end
end

function RatingsView:cb_on_back_pressed()
    self.ui_manager:close_view('ratings_view')
end

function RatingsView:cb_on_download_ratings_pressed()
    if self._controller:isCommunity() then
        self._controller:uploadCommunityRating()
        self._controller:downloadCommunityRating()
    end
    self._controller:persistLocalRating()
    gameUtils.directNotification(
        self._controller.dmf:localize('lovesmenot_ratingsview_download_ratings_notif'))
    self:_setup_category_config()
end

--
-- Close
--

RatingsView.on_exit = function(self)
    if self._input_legend_element then
        self._input_legend_element = nil
        self:_remove_element('input_legend')
    end

    if self._ui_offscreen_renderer then
        self._ui_offscreen_renderer = nil

        Managers.ui:destroy_renderer(self.__class_name .. '_ui_offscreen_renderer')

        local offscreen_world = self._offscreen_world
        local offscreen_viewport_name = self._offscreen_viewport_name

        ScriptWorld.destroy_viewport(offscreen_world, offscreen_viewport_name)
        Managers.ui:destroy_world(offscreen_world)

        self._offscreen_viewport = nil
        self._offscreen_viewport_name = nil
        self._offscreen_world = nil
    end

    if self.ui_manager:view_active('ratings_view') and not self.ui_manager:is_view_closing('ratings_view') then
        self.ui_manager:close_view('ratings_view', true)
    end

    RatingsView.super.on_exit(self)
end

RatingsView._reload = function(self)
    if self.ui_manager:view_active('ratings_view') and not self.ui_manager:is_view_closing('ratings_view') then
        self.ui_manager:close_view('ratings_view', true)
    end
    self:_setup_category_config()
end

return RatingsView
