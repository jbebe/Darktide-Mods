return {
	-- Meta
	lovesmenot_mod_title = {
		en = 'Loves me, loves me not'
	},
	lovesmenot_mod_description = {
		en = 'Mark toxic or good players for your convenience.\n' ..
			'Hotkeys only work during missions.\n' ..
			'Players are indexed by the team hud panel {#under(true)}from bottom-up{#under(false)}.\n' ..
			'(Teammate #1 will be on the bottom, closest to your avatar)'
	},

	-- Settings
	lovesmenot_settings_open_ratings = {
		en = 'Open accounts dashboard'
	},
	lovesmenot_settings_hotkey_group_title = {
		en = 'Manual rating'
	},
	lovesmenot_settings_hotkey_1_title = {
		en = 'Change rating of teammate #1'
	},
	lovesmenot_settings_hotkey_2_title = {
		en = 'Change rating of teammate #2'
	},
	lovesmenot_settings_hotkey_3_title = {
		en = 'Change rating of teammate #3'
	},
	lovesmenot_settings_community = {
		en = 'Community rating'
	},
	lovesmenot_settings_community_description = {
		en = 'Synchronizes ratings between all mod users'
	},
	lovesmenot_settings_community_hide_own_rating = {
		en = 'Hide my community rating'
	},
	lovesmenot_settings_community_hide_own_rating_description = {
		en = 'Hides all visual signs of your own community ranking (for sensitive souls)'
	},

	-- Dashboard delete modal
	lovesmenot_ratingsview_delete_title = {
		en = 'Rehabilitate Account',
	},
	lovesmenot_ratingsview_delete_description = {
		en = 'Do you want to remove the account from this list?',
	},
	lovesmenot_ratingsview_delete_yes = {
		en = 'Yes',
	},
	lovesmenot_ratingsview_delete_no = {
		en = 'Cancel',
	},

	-- Turn on community modal
	lovesmenot_community_create_token_title = {
		en = 'Generate Access Token',
	},
	lovesmenot_community_create_token_description = {
		en = 'In order to access the community version of this mod, you need to ' ..
			'generate an access token.\n' ..
			'Press Cancel to exit the dialog.',
	},
	lovesmenot_community_create_token_step_1 = {
		en = '1. The button below takes you to the authentication site:'
	},
	lovesmenot_community_create_token_url = {
		en = '\u{e06f} Get Access',
	},
	lovesmenot_community_create_token_step_2 = {
		en = '2. Paste the generated token here:'
	},
	lovesmenot_community_create_token_step_3 = {
		en = '3. Save the token to your settings file:'
	},
	lovesmenot_community_create_token_save = {
		en = 'Save',
	},

	-- Accounts dashboard
	lovesmenot_ratingsview_title = {
		en = 'Account ratings'
	},
	lovesmenot_ratingsview_local_description = {
		en = 'These are the accounts you rated so far. Click on any account to revoke your rating.'
	},
	lovesmenot_ratingsview_community_description = {
		en =
		'These are the accounts you rated so far. Click on any account to revoke your rating.\n(Community accounts cannot be revoked)'
	},
	lovesmenot_ratingsview_griditem_title = {
		en = '%s %s | %s %s'
	},
	lovesmenot_ratingsview_griditem_subtitle = {
		en = 'Operative: %s (%s) | %s | %s'
	},
	lovesmenot_ratingsview_download_ratings = {
		en = 'Sync now'
	},
	lovesmenot_ratingsview_download_ratings_notif = {
		en = 'Database successfully updated'
	},

	-- Ingame text
	lovesmenot_ingame_rating_negative = {
		en = 'Negative'
	},
	lovesmenot_ingame_rating_positive = {
		en = 'Positive'
	},
	lovesmenot_ingame_notification_set = {
		en = '%s is now marked as: %s'
	},
	lovesmenot_ingame_notification_unset = {
		en = '%s is now unmarked'
	},
	lovesmenot_ingame_self_status = {
		en = 'Congratulations! You are rated as \'%s\' by the community.'
	},
	lovesmenot_ingame_community_rating = {
		en = 'Community'
	},
}
