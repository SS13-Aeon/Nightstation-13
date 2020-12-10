/datum/preferences

	max_save_slots = 10

/datum/preferences/New(client/C)
	..()
	if(unlock_content)
		max_save_slots = 20
