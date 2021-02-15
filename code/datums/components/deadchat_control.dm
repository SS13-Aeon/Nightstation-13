#define DEMOCRACY_MODE "democracy"
#define ANARCHY_MODE "anarchy"

/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/timerid

	var/list/datum/callback/inputs = list()
	var/list/ckey_to_cooldown = list()
	var/orbiters = list()
	var/deadchat_mode
	var/input_cooldown

/datum/component/deadchat_control/Initialize(_deadchat_mode, _inputs, _input_cooldown = 12 SECONDS)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, .proc/orbit_begin)
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, .proc/orbit_stop)
	deadchat_mode = _deadchat_mode
	inputs = _inputs
	input_cooldown = _input_cooldown
	if(deadchat_mode == DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, .proc/democracy_loop), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	notify_ghosts("[parent] is now deadchat controllable!", source = parent, action = NOTIFY_ORBIT, header="Something Interesting!")


/datum/component/deadchat_control/Destroy(force, silent)
	inputs = null
	orbiters = null
	ckey_to_cooldown = null
	return ..()

/datum/component/deadchat_control/proc/deadchat_react(mob/source, message)
	SIGNAL_HANDLER

	message = lowertext(message)
	if(!inputs[message])
		return 
	if(deadchat_mode == ANARCHY_MODE)
		var/cooldown = ckey_to_cooldown[source.ckey]
		if(cooldown)
			return MOB_DEADSAY_SIGNAL_INTERCEPT
		inputs[message].Invoke()
		ckey_to_cooldown[source.ckey] = TRUE
		addtimer(CALLBACK(src, .proc/remove_cooldown, source.ckey), input_cooldown)
	else if(deadchat_mode == DEMOCRACY_MODE)
		ckey_to_cooldown[source.ckey] = message
	return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/deadchat_control/proc/remove_cooldown(ckey)
	ckey_to_cooldown.Remove(ckey)
	
/datum/component/deadchat_control/proc/democracy_loop()
	if(QDELETED(parent) || deadchat_mode != DEMOCRACY_MODE)
		deltimer(timerid)
		return
	var/result = count_democracy_votes()
	if(!isnull(result))
		inputs[result].Invoke()
		var/message = "<span class='deadsay italics bold'>[parent] has done action [result]!<br>New vote started. It will end in [input_cooldown/10] seconds.</span>"
		for(var/M in orbiters)
			to_chat(M, message)
	else
		var/message = "<span class='deadsay italics bold'>No votes were cast this cycle.</span>"
		for(var/M in orbiters)
			to_chat(M, message)
			
/datum/component/deadchat_control/proc/count_democracy_votes()
	if(!length(ckey_to_cooldown))
		return
	var/list/votes = list()
	for(var/command in inputs)
		votes["[command]"] = 0
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		ckey_to_cooldown.Remove(vote)
	
	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote
	
	if(result in inputs)
		return result

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, .proc/democracy_loop), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	else
		deltimer(timerid)

/datum/component/deadchat_control/proc/orbit_begin(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	RegisterSignal(orbiter, COMSIG_MOB_DEADSAY, .proc/deadchat_react)
	orbiters |= orbiter

/datum/component/deadchat_control/proc/orbit_stop(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	if(orbiter in orbiters)
		UnregisterSignal(orbiter, COMSIG_MOB_DEADSAY)
		orbiters -= orbiter
<<<<<<< HEAD
=======

/// Allows for this component to be removed via a dedicated VV dropdown entry.
/datum/component/deadchat_control/proc/handle_vv_topic(datum/source, mob/user, list/href_list)
	SIGNAL_HANDLER
	if(!href_list[VV_HK_DEADCHAT_PLAYS] || !check_rights(R_FUN))
		return
	. = COMPONENT_VV_HANDLED
	INVOKE_ASYNC(src, .proc/async_handle_vv_topic, user, href_list)

/// Async proc handling the alert input and associated logic for an admin removing this component via the VV dropdown.
/datum/component/deadchat_control/proc/async_handle_vv_topic(mob/user, list/href_list)
	if(alert(user, "Remove deadchat control from [parent]?", "Deadchat Plays [parent]", "Remove", "Cancel") == "Remove")
		// Quick sanity check as this is an async call.
		if(QDELETED(src))
			return

		to_chat(user, "<span class='notice'>Deadchat can no longer control [parent].</span>")
		log_admin("[key_name(user)] has removed deadchat control from [parent]")
		message_admins("<span class='notice'>[key_name(user)] has removed deadchat control from [parent]</span>")

		qdel(src)

/// Informs any examiners to the inputs available as part of deadchat control, as well as the current operating mode and cooldowns.
/datum/component/deadchat_control/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += "<span class='notice'>[A.p_theyre(TRUE)] currently under deadchat control using the [deadchat_mode] ruleset!</span>"

	if(deadchat_mode == DEMOCRACY_MODE)
		examine_list += "<span class='notice'>Type a command into chat to vote on an action. This happens once every [input_cooldown * 0.1] seconds.</span>"
	else if(deadchat_mode == ANARCHY_MODE)
		examine_list += "<span class='notice'>Type a command into chat to perform. You may do this once every [input_cooldown * 0.1] seconds.</span>"

	var/extended_examine = "<span class='notice'>Command list:"

	for(var/possible_input in inputs)
		extended_examine += " [possible_input]"

	extended_examine += ".</span>"

	examine_list += extended_examine

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for a spicy
 * singularity or vomit goose.
 */
/datum/component/deadchat_control/cardinal_movement/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(GLOBAL_PROC, .proc/_step, parent, NORTH)
	inputs["down"] = CALLBACK(GLOBAL_PROC, .proc/_step, parent, SOUTH)
	inputs["left"] = CALLBACK(GLOBAL_PROC, .proc/_step, parent, WEST)
	inputs["right"] = CALLBACK(GLOBAL_PROC, .proc/_step, parent, EAST)

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for spicy
 * immovable rod.
 */
/datum/component/deadchat_control/immovable_rod/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!istype(parent, /obj/effect/immovablerod))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(parent, /obj/effect/immovablerod.proc/walk_in_direction, NORTH)
	inputs["down"] = CALLBACK(parent, /obj/effect/immovablerod.proc/walk_in_direction, SOUTH)
	inputs["left"] = CALLBACK(parent, /obj/effect/immovablerod.proc/walk_in_direction, WEST)
	inputs["right"] = CALLBACK(parent, /obj/effect/immovablerod.proc/walk_in_direction, EAST)
>>>>>>> 7c94f81... Adds more admin memery and deadchat_control options to immovable rods. (#56888)
