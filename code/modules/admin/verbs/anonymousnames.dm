/client/proc/anon_names()
	set category = "Admin.Events"
	set name = "Setup Anonymous Names"


	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame.")
		return

	if(SSticker.anonymousnames)
		SSticker.anonymousnames = ANON_DISABLED
		to_chat(usr, "Disabled anonymous names.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] has disabled anonymous names.</span>")
		return
	var/list/names = list("Cancel", ANON_RANDOMNAMES, ANON_EMPLOYEENAMES)
	var/result = input(usr, "Choose an anonymous theme","going dark") as null|anything in names
	if(!usr || !result || result == "Cancel")
		return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "You took too long! The game has started.")
		return

	SSticker.anonymousnames = result
	to_chat(usr, "Enabled anonymous names. THEME: [SSticker.anonymousnames].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has enabled anonymous names. THEME: [SSticker.anonymousnames].</span>")

/**
 * anonymous_name: generates a corporate random name. used in admin event tool anonymous names
 *
<<<<<<< HEAD
 * first letter is always a letter
 * Example name = "Employee Q5460Z"
=======
 * why is this a proc instead of just part of above? events use this as well.
 */
/proc/anonymous_all_players()
	var/datum/anonymous_theme/theme = SSticker.anonymousnames
	for(var/mob/living/player in GLOB.player_list)
		if(!player.mind || (!ishuman(player) && !issilicon(player)) || !SSjob.GetJob(player.mind.assigned_role))
			continue
		if(issilicon(player))
			player.fully_replace_character_name(player.real_name, theme.anonymous_ai_name(isAI(player)))
		else
			var/original_name = player.real_name //id will not be changed if you do not do this
			randomize_human(player) //do this first so the special name can be given
			player.fully_replace_character_name(original_name, theme.anonymous_name(player))

/* Datum singleton initialized by the client proc to hold the naming generation */
/datum/anonymous_theme
	var/name = "Randomized Names"
	var/announcement_alert = "A recent bureaucratic error in the Organic Resources Department has resulted in a necessary full recall of all identities and names until further notice."

/**
 * anonymous_name: generates a random name, based off of whatever the round's anonymousnames is set to.
 *
 * examples:
 * Employee = "Employee Q5460Z"
 * Wizards = "Gulstaff of Void"
>>>>>>> cceb2f2... woop (#56400)
 * Arguments:
 * * M - mob for preferences and gender
 */
/proc/anonymous_name(mob/M)
	switch(SSticker.anonymousnames)
		if(ANON_RANDOMNAMES)
			return M.client.prefs.pref_species.random_name(M.gender,1)
		if(ANON_EMPLOYEENAMES)
			var/name = "Employee "

			for(var/i in 1 to 6)
				if(prob(30) || i == 1)
					name += ascii2text(rand(65, 90)) //A - Z
				else
					name += ascii2text(rand(48, 57)) //0 - 9
			return name

/**
 * anonymous_ai_name: generates a corporate random name (but for sillycones). used in admin event tool anonymous names
 *
 * first letter is always a letter
 * Example name = "Employee Assistant Assuming Delta"
 * Arguments:
 * * is_ai - boolean to decide whether the name has "Core" (AI) or "Assistant" (Cyborg)
 */
/proc/anonymous_ai_name(is_ai = FALSE)
	switch(SSticker.anonymousnames)
		if(ANON_RANDOMNAMES)
			return pick(GLOB.ai_names)
		if(ANON_EMPLOYEENAMES)
			var/verbs = capitalize(pick(GLOB.ing_verbs))
			var/phonetic = pick(GLOB.phonetic_alphabet)

			return "Employee [is_ai ? "Core" : "Assistant"] [verbs] [phonetic]"
