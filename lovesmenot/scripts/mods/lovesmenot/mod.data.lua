local mod = get_mod("lovesmenot")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "rate_teammate",
				type = "group",
				sub_widgets = (function()
					local widgets = {}

					for i = 1, 3 do
						table.insert(widgets, {
							setting_id = string.format("rate_teammate_%d", i),
							type = "keybind",
							default_value = {},
							keybind_global = false,
							keybind_trigger = "pressed",
							keybind_type = "function_call",
							function_name = string.format("rate_teammate_%d", i),
						})
					end

					return widgets
				end)()
			},
			{
				setting_id = "open_ratings",
				type = "keybind",
				default_value = {},
				keybind_trigger = "pressed",
				keybind_type = "view_toggle",
				view_name = "ratings_view"
			}
		}
	}
}
