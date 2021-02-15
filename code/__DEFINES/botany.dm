
#define TRAY_NAME_UPDATE name = myseed ? "[initial(name)] ([myseed.plantname])" : initial(name)
#define YIELD_WEED_MINIMUM 3
#define YIELD_WEED_MAXIMUM 10
#define STATIC_NUTRIENT_CAPACITY 10

<<<<<<< HEAD
//Both available scanning modes for the plant analyzer.
#define PLANT_SCANMODE_STATS		0
#define PLANT_SCANMODE_CHEMICALS 	1
=======
/// -- Flags for seeds. --
/// Allows a plant to wild mutate (mutate on haravest) at a certain instability.
#define MUTATE_EARLY (1<<0)
>>>>>>> 0f435d5... Remove hideous inline tab indentation, and bans it in contributing guidelines (#56912)

//Seed flags.
#define MUTATE_EARLY	(1<<0)
