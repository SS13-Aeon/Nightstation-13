/*
<<<<<<< HEAD
	Holodeck Update

	The on-station holodeck area is of type [holodeck_type].
	All subtypes of [program_type] are loaded into the program cache or emag programs list.
	If init_program is null, a random program will be loaded on startup.
	If you don't wish this, set it to the offline program or another of your choosing.
=======
Map Template Holodeck

Holodeck finds the location of mapped_start_area and loads offline_program in it on LateInitialize. It then passes its program templates to Holodeck.js in the form of program_cache and emag_programs. when a user selects a program the
ui calls load_program() with the id of the selected program.
load_program() -> map_template/load() on map_template/holodeck.

holodeck map templates:
1. have an update_blacklist that doesnt allow placing on non holofloors (except for engine floors so you can repair it)
2. has should_place_on_top = FALSE, so that the baseturfs list doesnt pull a kilostation oom crash
3. has returns_created = TRUE, so that SSatoms gives the map template a list of spawned atoms
all the fancy flags and shit are added to holodeck objects in finish_spawn()

Easiest way to add new holodeck programs:
1. Define new map template datums in code/modules/holodeck/holodeck_map_templates, make sure they have the access flags
of the holodeck you want them to be able to load, for the onstation holodeck the flag is STATION_HOLODECK.
2. Create the new map templates in _maps/templates (remember theyre 9x10, and make sure they have area/noop or else it will fuck with linked)
all turfs in holodeck programs MUST be of type /turf/open/floor/holofloor, OR /turf/open/floor/engine, or they will block future programs!

Note: if youre looking at holodeck code because you want to see how returns_created is handled so that templates return a list of atoms
created from them: make sure you handle that list correctly! Either copy them by value and delete them or reference it and handle qdel'ing
and clear when youre done! if you dont i will use :newspaper2: on you
*/
>>>>>>> 052130a... see title (#56536)

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

<<<<<<< HEAD
=======
	//new vars
	///what area type this holodeck loads into. linked turns into the nearest instance of this area
	var/area/mapped_start_area = /area/holodeck/rec_center

	///the currently used map template
	var/datum/map_template/holodeck/template

	///bottom left corner of the loading room, used for placing
	var/turf/bottom_left

	//old vars

	///the area that this holodeck loads templates into, used for power and deleting holo objects that leave it
>>>>>>> 052130a... see title (#56536)
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

<<<<<<< HEAD
/obj/machinery/computer/holodeck/Destroy()
	emergency_shutdown()
	if(linked)
		linked.linked = null
		linked.power_usage = new /list(AREA_USAGE_LEN)
	return ..()

/obj/machinery/computer/holodeck/power_change()
	. = ..()
	toggle_power(!machine_stat)
=======
///adds all programs that this holodeck has access to, and separates the restricted and unrestricted ones
/obj/machinery/computer/holodeck/proc/generate_program_list()
	for(var/typekey in subtypesof(program_type))
		var/datum/map_template/holodeck/program = typekey
		var/list/info_this = list("id" = initial(program.template_id), "name" = initial(program.name))
		if(initial(program.restricted))
			LAZYADD(emag_programs, list(info_this))
		else
			LAZYADD(program_cache, list(info_this))
>>>>>>> 052130a... see title (#56536)

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
			say("Safeties restored. Restarting...")

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

<<<<<<< HEAD
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

=======
>>>>>>> 052130a... see title (#56536)
#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
