return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`lovesmenot` encountered an error loading the Darktide Mod Framework.")

		new_mod("lovesmenot", {
			mod_script       = "lovesmenot/scripts/mods/lovesmenot/mod",
			mod_data         = "lovesmenot/scripts/mods/lovesmenot/mod.data",
			mod_localization = "lovesmenot/scripts/mods/lovesmenot/mod.localization",
		})
	end,
	packages = {},
}
