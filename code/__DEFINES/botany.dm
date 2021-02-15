
#define TRAY_NAME_UPDATE name = myseed ? "[initial(name)] ([myseed.plantname])" : initial(name)
#define YIELD_WEED_MINIMUM 3
#define YIELD_WEED_MAXIMUM 10
#define STATIC_NUTRIENT_CAPACITY 10

//Both available scanning modes for the plant analyzer.
#define PLANT_SCANMODE_STATS		0
#define PLANT_SCANMODE_CHEMICALS 	1

<<<<<<< HEAD
//Seed flags.
#define MUTATE_EARLY	(1<<0)
=======
/// -- Flags for traits. --
/// Caps the plant's yield at 5 instead of 10.
#define TRAIT_HALVES_YIELD (1<<0)

/// Define for how much endurance a glowcap loses per spread
#define GLOWCAP_ENDURANCE_SPREAD_COST 20
>>>>>>> da0b4f7d... Glowcap spread endurance loss is 10 times bigger (#56885)
