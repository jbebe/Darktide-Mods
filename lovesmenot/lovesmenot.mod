return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`lovesmenot` encountered an error loading the Darktide Mod Framework.")

		new_mod("lovesmenot", {
			mod_script       = "lovesmenot/src/mod",
			mod_data         = "lovesmenot/src/mod.data",
			mod_localization = "lovesmenot/src/mod.localization",
		})
	end,
	packages = {},
}
