return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`lovesmenot` encountered an error loading the Darktide Mod Framework.")

		new_mod("lovesmenot", {
			mod_script       = "lovesmenot/scripts/mods/lovesmenot/lovesmenot",
			mod_data         = "lovesmenot/scripts/mods/lovesmenot/lovesmenot_data",
			mod_localization = "lovesmenot/scripts/mods/lovesmenot/lovesmenot_localization",
		})
	end,
	packages = {},
}
