local mod = get_mod('lovesmenot')

return {
	name = mod:localize('lovesmenot_mod_title'),
	description = mod:localize('lovesmenot_mod_description'),
	is_togglable = true,
	options = {
		widgets = {
			-- extra settings that are not shown here:
			-- lovesmenot_settings_community_access_token
			{
				setting_id = 'lovesmenot_settings_hotkey_group_title',
				type = 'group',
				sub_widgets = (function()
					local widgets = {}

					for i = 1, 3 do
						table.insert(widgets, {
							setting_id = ('lovesmenot_settings_hotkey_%d_title'):format(i),
							type = 'keybind',
							default_value = {},
							keybind_global = false,
							keybind_trigger = 'pressed',
							keybind_type = 'function_call',
							function_name = ('lovesmenot_settings_hotkey_%d_title'):format(i),
						})
					end

					table.insert(widgets, {
						setting_id = 'lovesmenot_settings_open_ratings',
						type = 'keybind',
						default_value = {},
						keybind_trigger = 'pressed',
						keybind_type = 'function_call',
						function_name = 'openRatings'
					})

					return widgets
				end)()
			},
			-- {
			-- 	setting_id = 'lovesmenot_settings_community',
			-- 	type = 'checkbox',
			-- 	default_value = false,
			-- 	sub_widgets = {
			-- 		{
			-- 			setting_id = 'lovesmenot_settings_community_hide_own_rating',
			-- 			type = 'checkbox',
			-- 			default_value = false,
			-- 		}
			-- 	}
			-- },
			{
				setting_id = 'lovesmenot_settings_loglevel',
				type = 'dropdown',
				default_value = 'error',
				options = {
					{ text = 'lovesmenot_settings_loglevel_error',   value = 'error' },
					{ text = 'lovesmenot_settings_loglevel_warning', value = 'warning' },
					{ text = 'lovesmenot_settings_loglevel_info',    value = 'info' },
					{ text = 'lovesmenot_settings_loglevel_debug',   value = 'debug' },
				},
			}
		}
	}
}
