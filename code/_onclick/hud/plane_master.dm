/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/show_alpha = 255
	var/hide_alpha = 0

/atom/movable/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/atom/movable/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

//Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/atom/movable/screen/plane_master/proc/backdrop(mob/mymob)

///Things rendered on "openspace"; holes in multi-z
/atom/movable/screen/plane_master/openspace
	name = "open space plane master"
	plane = OPENSPACE_BACKDROP_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	alpha = 255

/atom/movable/screen/plane_master/openspace/Initialize()
	. = ..()
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -10)
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -15)
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -20)

/atom/movable/screen/plane_master/proc/outline(_size, _color)
	filters += filter(type = "outline", size = _size, color = _color)

/atom/movable/screen/plane_master/proc/shadow(_size, _border, _offset = 0, _x = 0, _y = 0, _color = "#04080FAA")
	filters += filter(type = "drop_shadow", x = _x, y = _y, color = _color, size = _size, offset = _offset)

/atom/movable/screen/plane_master/proc/clear_filters()
	filters = list()

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/floor/backdrop(mob/mymob)
	filters = list()
	if(istype(mymob) && mymob.eye_blurry)
		filters += GAUSSIAN_BLUR(clamp(mymob.eye_blurry*0.1,0.6,3))

///Contains most things in the game world
/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	filters = list()
	if(istype(mymob) && mymob.client && mymob.client.prefs && mymob.client.prefs.ambientocclusion)
		filters += AMBIENT_OCCLUSION
	if(istype(mymob) && mymob.eye_blurry)
		filters += GAUSSIAN_BLUR(clamp(mymob.eye_blurry*0.1,0.6,3))


///Contains all lighting objects
/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/lighting/backdrop(mob/mymob)
	mymob.overlay_fullscreen("lighting_backdrop_lit", /atom/movable/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /atom/movable/screen/fullscreen/lighting_backdrop/unlit)

/atom/movable/screen/plane_master/lighting/Initialize()
	. = ..()
<<<<<<< HEAD
	filters += filter(type="alpha", render_source = EMISSIVE_RENDER_TARGET, flags = MASK_INVERSE)
	filters += filter(type="alpha", render_source = EMISSIVE_UNBLOCKABLE_RENDER_TARGET, flags = MASK_INVERSE)
	filters += filter(type="alpha", render_source = O_LIGHTING_VISUAL_RENDER_TARGET, flags = MASK_INVERSE)
=======
	var/i = 1
	for(var/plane in subtypesof(/atom/movable/screen/plane_master/emissive))
		var/atom/movable/screen/plane_master/emissive/emissive_plane = plane
		add_filter("emissives-[i] ([initial(emissive_plane.name)])", i++, alpha_mask_filter(render_source = initial(emissive_plane.emissive_target), flags = MASK_INVERSE))
>>>>>>> 1f1b58b... Adds Neon Carpet (#55782)

/**
 * Things placed on this mask the lighting plane. Doesn't render directly.
 *
 * Gets masked by blocking planes. Use for things that you want blocked by
 * mobs, items, etc.
 */
/atom/movable/screen/plane_master/emissive
	name = "emissive plane master"
	plane = EMISSIVE_PLANE
	layer = EMISSIVE_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET
	/// Basically a second copy of the `render_target` because `initial(plane_master_typepath.render_target)` always returns `null` because _BYOND_
	var/emissive_target = EMISSIVE_RENDER_TARGET

/atom/movable/screen/plane_master/emissive/Initialize()
	. = ..()
<<<<<<< HEAD
	filters += filter(type="alpha", render_source=EMISSIVE_BLOCKER_RENDER_TARGET, flags=MASK_INVERSE)

/**
 * Things placed on this always mask the lighting plane. Doesn't render directly.
 *
 * Always masks the light plane, isn't blocked by anything. Use for on mob glows,
 * magic stuff, etc.
 */
/atom/movable/screen/plane_master/emissive_unblockable
=======
	var/i = 1
	for(var/plane in subtypesof(/atom/movable/screen/plane_master/emissive_blocker))
		var/atom/movable/screen/plane_master/emissive_blocker/blocker_plane = plane
		if(initial(blocker_plane.layer) <= layer)
			continue
		add_filter("emissive_block-[i] (initial(blocker_plane.name))", i++, alpha_mask_filter(render_source = initial(blocker_plane.blocker_target), flags = MASK_INVERSE))

/// The plane master used for emissive turfs and turf overlays
/atom/movable/screen/plane_master/emissive/emissive_turf
	name = "emissive turf plane master"
	plane = EMISSIVE_TURF_PLANE
	layer = EMISSIVE_TURF_LAYER
	render_target = EMISSIVE_TURF_RENDER_TARGET
	emissive_target = EMISSIVE_TURF_RENDER_TARGET

/// The plane master used for emissive structures and structure overlays
/atom/movable/screen/plane_master/emissive/emissive_structure
	name = "emissive structure plane master"
	plane = EMISSIVE_STRUCTURE_PLANE
	layer = EMISSIVE_STRUCTURE_LAYER
	render_target = EMISSIVE_STRUCTURE_RENDER_TARGET
	emissive_target = EMISSIVE_STRUCTURE_RENDER_TARGET

/// The plane master used for emissive items and item overlays
/atom/movable/screen/plane_master/emissive/emissive_item
	name = "emissive item plane master"
	plane = EMISSIVE_ITEM_PLANE
	layer = EMISSIVE_ITEM_LAYER
	render_target = EMISSIVE_ITEM_RENDER_TARGET
	emissive_target = EMISSIVE_ITEM_RENDER_TARGET

/// The plane master used for emissive mobs and mob overlays
/atom/movable/screen/plane_master/emissive/emissive_mob
	name = "emissive mob plane master"
	plane = EMISSIVE_MOB_PLANE
	layer = EMISSIVE_MOB_LAYER
	render_target = EMISSIVE_MOB_RENDER_TARGET
	emissive_target = EMISSIVE_MOB_RENDER_TARGET

/// The plane master used for unblockable emissive effects
/atom/movable/screen/plane_master/emissive/unblockable
>>>>>>> 1f1b58b... Adds Neon Carpet (#55782)
	name = "unblockable emissive plane master"
	plane = EMISSIVE_UNBLOCKABLE_PLANE
	layer = EMISSIVE_UNBLOCKABLE_LAYER
	render_target = EMISSIVE_UNBLOCKABLE_RENDER_TARGET
	emissive_target = EMISSIVE_UNBLOCKABLE_RENDER_TARGET

/// The plane master used for overlay lighting masking
/atom/movable/screen/plane_master/emissive/o_light_visual
	name = "overlight light visual plane master"
	layer = O_LIGHTING_VISUAL_LAYER
	plane = O_LIGHTING_VISUAL_PLANE
	render_target = O_LIGHTING_VISUAL_RENDER_TARGET
	emissive_target = O_LIGHTING_VISUAL_RENDER_TARGET
	blend_mode = BLEND_MULTIPLY

/**
 * Things placed on this layer mask the emissive layer. Doesn't render directly
 *
 * You really shouldn't be directly using this, use atom helpers instead
 */
/atom/movable/screen/plane_master/emissive_blocker
	name = "emissive blocker plane master"
	plane = EMISSIVE_BLOCKER_PLANE
	layer = EMISSIVE_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_BLOCKER_RENDER_TARGET
	/// Basically a second copy of the `render_target` because `initial(plane_master_typepath.render_target)` always returns `null` because _BYOND_
	var/blocker_target = EMISSIVE_BLOCKER_RENDER_TARGET

/// The emissive blocker plane master used by structures to block... something. Presumably whatever's under turfs. (NOTE: Not actually implemented because adding this to every turf would be expensive and there's no reason to use this yet)
/atom/movable/screen/plane_master/emissive_blocker/turf_emissive
	name = "turf emissive blocker plane master"
	plane = TURF_EMISSIVE_BLOCKER_PLANE
	layer = EMISSIVE_TURF_LAYER
	render_target = TURF_EMISSIVE_BLOCKER_RENDER_TARGET
	blocker_target = TURF_EMISSIVE_BLOCKER_RENDER_TARGET

/// The emissive blocker plane master used by structures to block emissive turfs and turf overlays
/atom/movable/screen/plane_master/emissive_blocker/structure_emissive
	name = "structure emissive blocker plane master"
	plane = STRUCTURE_EMISSIVE_BLOCKER_PLANE
	layer = EMISSIVE_STRUCTURE_LAYER
	render_target = STRUCTURE_EMISSIVE_BLOCKER_RENDER_TARGET
	blocker_target = STRUCTURE_EMISSIVE_BLOCKER_RENDER_TARGET

/// The emissive blocker plane master used by items to block emissive turfs, structures and overlays thereof
/atom/movable/screen/plane_master/emissive_blocker/item_emissive
	name = "item emissive blocker plane master"
	plane = ITEM_EMISSIVE_BLOCKER_PLANE
	layer = EMISSIVE_ITEM_LAYER
	render_target = ITEM_EMISSIVE_BLOCKER_RENDER_TARGET
	blocker_target = ITEM_EMISSIVE_BLOCKER_RENDER_TARGET

/// The emissive blocker plane master used by items to block emissive turfs, structures, items and overlays thereof
/atom/movable/screen/plane_master/emissive_blocker/mob_emissive
	name = "mob emissive blocker plane master"
	plane = MOB_EMISSIVE_BLOCKER_PLANE
	layer = EMISSIVE_MOB_LAYER
	render_target = MOB_EMISSIVE_BLOCKER_RENDER_TARGET
	blocker_target = MOB_EMISSIVE_BLOCKER_RENDER_TARGET

///Contains space parallax
/atom/movable/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE

/atom/movable/screen/plane_master/camera_static
	name = "camera static plane master"
	plane = CAMERA_STATIC_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/excited_turfs
	name = "atmos excited turfs"
	plane = ATMOS_GROUP_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	alpha = 0

/atom/movable/screen/plane_master/runechat
	name = "runechat plane master"
	plane = RUNECHAT_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/runechat/backdrop(mob/mymob)
	filters = list()
	if(istype(mymob) && mymob.client?.prefs?.ambientocclusion)
		filters += AMBIENT_OCCLUSION
