/datum/export/bounty_box
	cost = 1
	k_elasticity = 0 //Bounties are non-elastic funds.
	unit_name = "completed bounty cube"
	export_types = list(/obj/item/bounty_cube)

<<<<<<< HEAD
/datum/export/bounty_box/get_cost(obj/item/bounty_cube/cube, allowed_categories, apply_elastic)
	return cube.bounty_value
=======
/datum/export/bounty_box/get_cost(obj/item/bounty_cube/cube, apply_elastic)
	return cube.bounty_value + (cube.bounty_value * (cube.speed_bonus / 100))
>>>>>>> 29bc917... Cargo bounty cube incentives (#56375)
