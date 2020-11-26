// All nightstation ear organs are stored here.

/obj/item/organ/ears/nightstation
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "kitty"
	damage_multiplier = 1
	var/ear_type = "None"

/obj/item/organ/ears/nightstation/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		color = H.hair_color
		H.dna.features["ears"] = H.dna.species.mutant_bodyparts["ears"] = ear_type
		H.update_body()

/obj/item/organ/ears/nightstation/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		color = H.hair_color
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()

/obj/item/organ/ears/nightstation/bunny
	name = "bunny ears"
	ear_type = "Bunny"

/obj/item/organ/ears/nightstation/cow
	name = "cow ears"
	ear_type = "Cow"

/obj/item/organ/ears/nightstation/dog
	name = "dog ears"
	damage_multiplier = 2
	ear_type = "Dog"

/obj/item/organ/ears/nightstation/elf
	name = "elf ears"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "ears"
	damage_multiplier = 3
	ear_type = "Elf"

/obj/item/organ/ears/nightstation/fox
	name = "fox ears"
	damage_multiplier = 2
	ear_type = "Fox"

/obj/item/organ/ears/nightstation/rabbit
	name = "rabbit ears"
	ear_type = "Rabbit"

/obj/item/organ/ears/nightstation/squirrel
	name = "squirrel ears"
	ear_type = "Rabbit"

/obj/item/organ/ears/nightstation/wolf
	name = "wolf ears"
	damage_multiplier = 2
	ear_type = "Wolf"

/obj/item/organ/ears/nightstation/wolfbig
	name = "big wolf ears"
	damage_multiplier = 2
	ear_type = "Wolf, Big"
