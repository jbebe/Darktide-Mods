return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`example` encountered an error loading the Darktide Mod Framework.")

		new_mod("example", {
			mod_script       = "example/scripts/mods/example/example",
			mod_data         = "example/scripts/mods/example/example_data",
			mod_localization = "example/scripts/mods/example/example_localization",
		})
	end,
	packages = {},
}
