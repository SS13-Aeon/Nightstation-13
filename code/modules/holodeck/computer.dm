/*
	Holodeck Update

	The on-station holodeck area is of type [holodeck_type].
	All subtypes of [program_type] are loaded into the program cache or emag programs list.
	If init_program is null, a random program will be loaded on startup.
	If you don't wish this, set it to the offline program or another of your choosing.

	You can use this to add holodecks with minimal code:
	1) Define new areas for the holodeck programs
	2) Map them
	3) Create a new control console that uses those areas

	Non-mapped areas should be skipped but you should probably comment them out anyway.
	The base of program_type will always be ignored; only subtypes will be loaded.
*/

#define HOLODECK_CD 25
#define HOLODECK_DMG_CD 500

/obj/machinery/computer/holodeck
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	icon_screen = "holocontrol"
	idle_power_usage = 10
	active_power_usage = 50

	var/area/holodeck/linked
	var/area/holodeck/program
	var/area/holodeck/last_program
	var/area/offline_program = /area/holodeck/rec_center/offline

	var/list/program_cache
	var/list/emag_programs

	// Splitting this up allows two holodecks of the same size
	// to use the same source patterns.  Y'know, if you want to.
	var/holodeck_type = /area/holodeck/rec_center	// locate(this) to get the target holodeck
	var/program_type = /area/holodeck/rec_center	// subtypes of this (but not this itself) are loadable programs

	var/active = FALSE
	var/damaged = FALSE
	var/list/spawned = list()
	var/list/effects = list()
	var/current_cd = 0

/obj/machinery/computer/holodeck/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/holodeck/LateInitialize()
	if(ispath(holodeck_type, /area))
		linked = pop(get_areas(holodeck_type, FALSE))
	if(ispath(offline_program, /area))
		offline_program = pop(get_areas(offline_program), FALSE)
	// the following is necessary for power reasons
	if(!linked || !offline_program)
		log_world("No matching holodeck area found")
		qdel(src)
		return
	var/area/AS = get_area(src)
	if(istype(AS, /area/holodeck))
		log_mapping("Holodeck computer cannot be in a holodeck, This would cause circular power dependency.")
		qdel(src)
		return
	else
		linked.linked = src
		var/area/my_area = get_area(src)
		if(my_area)
			linked.power_usage = my_area.power_usage
		else
			linked.power_usage = new /list(AREA_USAGE_LEN)

	generate_program_list()
	load_program(offline_program, FALSE, FALSE)

/obj/machinery/computer/holodeck/Destroy()
	emergency_shutdown()
	if(linked)
		linked.linked = null
		linked.power_usage = new /list(AREA_USAGE_LEN)
	return ..()

/obj/machinery/computer/holodeck/power_change()
	. = ..()
	toggle_power(!machine_stat)

/obj/machinery/computer/holodeck/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holodeck", name)
		ui.open()

/obj/machinery/computer/holodeck/ui_data(mob/user)
	var/list/data = list()

	data["default_programs"] = program_cache
	if(obj_flags & EMAGGED)
		data["emagged"] = TRUE
		data["emag_programs"] = emag_programs
	data["program"] = program
	data["can_toggle_safety"] = issilicon(user) || isAdminGhostAI(user)

	return data

/obj/machinery/computer/holodeck/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("load_program")
			var/program_to_load = text2path(params["type"])
			if(!ispath(program_to_load))
				return FALSE
			var/valid = FALSE
			var/list/checked = program_cache.Copy()
			if(obj_flags & EMAGGED)
				checked |= emag_programs
			for(var/prog in checked)
				var/list/P = prog
				if(P["type"] == program_to_load)
					valid = TRUE
					break
			if(!valid)
				return FALSE

			var/area/A = locate(program_to_load) in GLOB.sortedAreas
			if(A)
				load_program(A)
		if("safety")
			if((obj_flags & EMAGGED) && program)
				emergency_shutdown()
			nerf(obj_flags & EMAGGED)
			obj_flags ^= EMAGGED
<<<<<<< HEAD
			say("Safeties restored. Restarting...")
=======
			say("Safeties reset. Restarting...")

///this is what makes the holodeck not spawn anything on broken tiles (space and non engine plating / non holofloors)
/datum/map_template/holodeck/update_blacklist(turf/placement, list/input_blacklist)
	for (var/_turf in get_affected_turfs(placement))
		var/turf/possible_blacklist = _turf
		if (possible_blacklist.holodeck_compatible)
			continue
		input_blacklist += possible_blacklist

///loads the template whose id string it was given ("offline_program" loads datum/map_template/holodeck/offline)
/obj/machinery/computer/holodeck/proc/load_program(map_id, force = FALSE, add_delay = TRUE)
	if (program == map_id)
		return

	if (!is_operational)//load_program is called once with a timer (in toggle_power) we dont want this to load anything if its off
		map_id = offline_program
		force = TRUE

	if (!force && (!COOLDOWN_FINISHED(src, holodeck_cooldown) || spawning_simulation))
		say("ERROR. Recalibrating projection apparatus.")
		return

	if(spawning_simulation)
		return

	if (add_delay)
		COOLDOWN_START(src, holodeck_cooldown, (damaged ? HOLODECK_CD + HOLODECK_DMG_CD : HOLODECK_CD))
		if (damaged && floorcheck())
			damaged = FALSE

	spawning_simulation = TRUE
	active = (map_id != offline_program)
	use_power = active + IDLE_POWER_USE
	program = map_id

	//clear the items from the previous program
	for (var/_item in spawned)
		var/obj/holo_item = _item
		derez(holo_item)

	for (var/_effect in effects)
		var/obj/effect/holodeck_effect/holo_effect = _effect
		effects -= holo_effect
		holo_effect.deactivate(src)

	//makes sure that any time a holoturf is inside a baseturf list (e.g. if someone put a wall over it) its set to the OFFLINE turf
	//so that you cant bring turfs from previous programs into other ones (like putting the plasma burn turf into lounge for example)
	for (var/turf/closed/holo_turf in linked)
		for (var/_baseturf in holo_turf.baseturfs)
			if (ispath(_baseturf, /turf/open/floor/holofloor))
				holo_turf.baseturfs -= _baseturf
				holo_turf.baseturfs += /turf/open/floor/holofloor/plating

	template = SSmapping.holodeck_templates[map_id]
	template.load(bottom_left) //this is what actually loads the holodeck simulation into the map

	spawned = template.created_atoms //populate the spawned list with the atoms belonging to the holodeck

	if(istype(template, /datum/map_template/holodeck/thunderdome1218) && !SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_MEDISIM])
		say("Special note from \"1218 AD\" developer: I see you too are interested in the REAL dark ages of humanity! I've made this program also unlock some interesting shuttle designs on any communication console around. Have fun!")
		SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_MEDISIM] = TRUE

	nerf(!(obj_flags & EMAGGED))
	finish_spawn()

///finalizes objects in the spawned list
/obj/machinery/computer/holodeck/proc/finish_spawn()
	//this is used for holodeck effects (like spawners). otherwise they dont do shit
	//holo effects are taken out of the spawned list and added to the effects list
	//turfs and overlay objects are taken out of the spawned list
	//objects get resistance flags added to them
	for (var/atom/atoms in spawned)
		if (isturf(atoms) || istype(atoms, /obj/effect/overlay/vis))
			spawned -= atoms
			continue

		RegisterSignal(atoms, COMSIG_PARENT_PREQDELETED, .proc/remove_from_holo_lists)
		atoms.flags_1 |= HOLOGRAM_1

		if (isholoeffect(atoms))//activates holo effects and transfers them from the spawned list into the effects list
			var/obj/effect/holodeck_effect/holo_effect = atoms
			effects += holo_effect
			spawned -= holo_effect
			var/atom/active_effect = holo_effect.activate(src)
			if(istype(active_effect) || islist(active_effect))
				spawned += active_effect // we want mobs or objects spawned via holoeffects to be tracked as objects
			continue

		if (isobj(atoms))
			var/obj/holo_object = atoms
			holo_object.resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

			if (isstructure(holo_object))
				holo_object.flags_1 |= NODECONSTRUCT_1
				continue

			if (ismachinery(holo_object))
				var/obj/machinery/machines = holo_object
				machines.flags_1 |= NODECONSTRUCT_1
				machines.power_change()

				if(istype(machines, /obj/machinery/button))
					var/obj/machinery/button/buttons = machines
					buttons.setup_device()
	spawning_simulation = FALSE

///this qdels holoitems that should no longer exist for whatever reason
/obj/machinery/computer/holodeck/proc/derez(obj/object, silent = TRUE, forced = FALSE)
	spawned -= object
	if(!object)
		return
	UnregisterSignal(object, COMSIG_PARENT_PREQDELETED)
	var/turf/target_turf = get_turf(object)
	for(var/c in object) //make sure that things inside of a holoitem are moved outside before destroying it
		var/atom/movable/object_contents = c
		object_contents.forceMove(target_turf)

	if(!silent)
		visible_message("<span class='notice'>[object] fades away!</span>")

	qdel(object)

/obj/machinery/computer/holodeck/proc/remove_from_holo_lists(datum/to_remove, _forced)
	spawned -= to_remove
	UnregisterSignal(to_remove, COMSIG_PARENT_PREQDELETED)
>>>>>>> 00cf04b... All Holobugs Must Die the Same Day Theyre Born or You Are Money Back Part Two (#56878)

/obj/machinery/computer/holodeck/process(delta_time)
	if(damaged && DT_PROB(5, delta_time))
		for(var/turf/T in linked)
			if(DT_PROB(2.5, delta_time))
				do_sparks(2, 1, T)
				return

	if(!..() || !active)
		return

	if(!floorcheck())
		emergency_shutdown()
		damaged = TRUE
		for(var/mob/M in urange(10,src))
			M.show_message("The holodeck overloads!")

		for(var/turf/T in linked)
			if(prob(30))
				do_sparks(2, 1, T)
			SSexplosions.lowturf += T
			T.hotspot_expose(1000,500,1)

	if(!(obj_flags & EMAGGED))
		for(var/item in spawned)
			if(!(get_turf(item) in linked))
				derez(item, 0)
	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.tick()

	active_power_usage = 50 + spawned.len * 3 + effects.len * 5

/obj/machinery/computer/holodeck/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	if(!LAZYLEN(emag_programs))
		to_chat(user, "[src] does not seem to have a card swipe port. It must be an inferior model.")
		return
	playsound(src, "sparks", 75, TRUE)
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>You vastly increase projector power and override the safety and security protocols.</span>")
	say("Warning. Automatic shutoff and derezzing protocols have been corrupted. Please call Nanotrasen maintenance and do not use the simulator.")
	log_game("[key_name(user)] emagged the Holodeck Control Console")
	nerf(!(obj_flags & EMAGGED))

/obj/machinery/computer/holodeck/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	emergency_shutdown()

/obj/machinery/computer/holodeck/ex_act(severity, target)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/proc/generate_program_list()
	for(var/typekey in subtypesof(program_type))
		var/area/holodeck/A = GLOB.areas_by_type[typekey]
		if(!A || !A.contents.len)
			continue
		var/list/info_this = list()
		info_this["name"] = A.name
		info_this["type"] = A.type
		if(A.restricted)
			LAZYADD(emag_programs, list(info_this))
		else
			LAZYADD(program_cache, list(info_this))

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = FALSE)
	if(active == toggleOn)
		return

	if(toggleOn)
		if(last_program && last_program != offline_program)
			addtimer(CALLBACK(src, .proc/load_program, last_program, TRUE), 25)
		active = TRUE
	else
		last_program = program
		load_program(offline_program, TRUE)
		active = FALSE

/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	last_program = program
	load_program(offline_program, TRUE)
	active = FALSE

/obj/machinery/computer/holodeck/proc/floorcheck()
	for(var/turf/T in linked)
		if(!T.intact || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/computer/holodeck/proc/nerf(active)
	for(var/obj/item/I in spawned)
		I.damtype = active ? STAMINA : initial(I.damtype)
	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.safety(active)

/obj/machinery/computer/holodeck/proc/load_program(area/A, force = FALSE, add_delay = TRUE)
	if(!is_operational)
		A = offline_program
		force = TRUE

	if(program == A)
		return
	if(current_cd > world.time && !force)
		say("ERROR. Recalibrating projection apparatus.")
		return
	if(add_delay)
		current_cd = world.time + HOLODECK_CD
		if(damaged)
			current_cd += HOLODECK_DMG_CD
	active = (A != offline_program)
	use_power = active + IDLE_POWER_USE

	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.deactivate(src)

	for(var/item in spawned)
		derez(item, !force)

	program = A
	// note nerfing does not yet work on guns, should
	// should also remove/limit/filter reagents?
	// this is an exercise left to others I'm afraid.  -Sayu
	spawned = A.copy_contents_to(linked, 1, nerf_weapons = !(obj_flags & EMAGGED))
	for(var/obj/machinery/M in spawned)
		M.flags_1 |= NODECONSTRUCT_1
	for(var/obj/structure/S in spawned)
		S.flags_1 |= NODECONSTRUCT_1
	effects = list()

	addtimer(CALLBACK(src, .proc/finish_spawn), 30)

/obj/machinery/computer/holodeck/proc/finish_spawn()
	var/list/added = list()
	for(var/obj/effect/holodeck_effect/HE in spawned)
		effects += HE
		spawned -= HE
		var/atom/x = HE.activate(src)
		if(istype(x) || islist(x))
			spawned += x // holocarp are not forever
			added += x
	for(var/obj/machinery/M in added)
		M.flags_1 |= NODECONSTRUCT_1
	for(var/obj/structure/S in added)
		S.flags_1 |= NODECONSTRUCT_1

/obj/machinery/computer/holodeck/proc/derez(obj/O, silent = TRUE, forced = FALSE)
	// Emagging a machine creates an anomaly in the derez systems.
	if(O && (obj_flags & EMAGGED) && !machine_stat && !forced)
		if((ismob(O) || ismob(O.loc)) && prob(50))
			addtimer(CALLBACK(src, .proc/derez, O, silent), 50) // may last a disturbingly long time
			return

	spawned -= O
	if(!O)
		return
	var/turf/T = get_turf(O)
	for(var/atom/movable/AM in O) // these should be derezed if they were generated
		AM.forceMove(T)
		if(ismob(AM))
			silent = FALSE					// otherwise make sure they are dropped

	if(!silent)
		visible_message("<span class='notice'>[O] fades away!</span>")
	qdel(O)

#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
