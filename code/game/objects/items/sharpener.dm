/obj/item/sharpener
	name = "whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sharpener"
	desc = "A block that makes things sharp."
	force = 5
<<<<<<< HEAD
	var/used = 0
=======
	///Amount of uses the whetstone has. Set to -1 for functionally infinite uses.
	var/uses = 1
	///How much force the whetstone can add to an item.
>>>>>>> 1803077... Makes it possible to create an /obj/item/sharpener with multiple uses (#55958)
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_sharpness = 1


/obj/item/sharpener/attackby(obj/item/I, mob/user, params)
	if(uses == 0)
		to_chat(user, "<span class='warning'>The sharpening block is too worn to use again!</span>")
		return
	if(I.force >= max || I.throwforce >= max)//no esword sharpening
		to_chat(user, "<span class='warning'>[I] is much too powerful to sharpen further!</span>")
		return
	if(requires_sharpness && !I.get_sharpness())
		to_chat(user, "<span class='warning'>You can only sharpen items that are already sharp, such as knives!</span>")
		return
	if(is_type_in_list(I, list(/obj/item/melee/transforming/energy, /obj/item/dualsaber)))
		to_chat(user, "<span class='warning'>You don't think \the [I] will be the thing getting modified if you use it on \the [src]!</span>")
		return

	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max)
	if(signal_out & COMPONENT_BLOCK_SHARPEN_MAXED)
		to_chat(user, "<span class='warning'>[I] is much too powerful to sharpen further!</span>")
		return
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, "<span class='warning'>[I] is not able to be sharpened right now!</span>")
		return
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (I.force > initial(I.force) && !signal_out))
		to_chat(user, "<span class='warning'>[I] has already been refined before. It cannot be sharpened further!</span>")
		return
	if(!(signal_out & COMPONENT_BLOCK_SHARPEN_APPLIED))
		I.force = clamp(I.force + increment, 0, max)
		I.wound_bonus = I.wound_bonus + increment
	user.visible_message("<span class='notice'>[user] sharpens [I] with [src]!</span>", "<span class='notice'>You sharpen [I], making it much more deadly than before.</span>")
	playsound(src, 'sound/items/unsheath.ogg', 25, TRUE)
	I.sharpness = SHARP_EDGED
	I.throwforce = clamp(I.throwforce + increment, 0, max)
<<<<<<< HEAD
	I.name = "[prefix] [I.name]"
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = 1
	update_icon()

=======
	I.name = "[prefix] [I.name]" //This adds a prefix and a space to the item's name regardless of what the prefix is
	desc = "[desc] At least, it used to."
	uses-- //this doesn't cause issues because we check if uses == 0 earlier in this proc
	if(uses == 0)
		name = "worn out [name]" //whetstone becomes used whetstone
	update_icon()

/**
* # Super whetstone
*
* Extremely powerful admin-only whetstone
*
* Whetstone that adds 200 damage to an item, with the maximum force and throw_force reachable with it being 200. As with normal whetstones, energy weapons cannot be sharpened with it and two-handed weapons will only get the throw_force bonus.
*
*/
>>>>>>> 1803077... Makes it possible to create an /obj/item/sharpener with multiple uses (#55958)
/obj/item/sharpener/super
	name = "super whetstone"
	desc = "A block that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = 0
