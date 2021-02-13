
#define TRAY_NAME_UPDATE name = myseed ? "[initial(name)] ([myseed.plantname])" : initial(name)
#define YIELD_WEED_MINIMUM 3
#define YIELD_WEED_MAXIMUM 10
#define STATIC_NUTRIENT_CAPACITY 10

<<<<<<< HEAD
//Both available scanning modes for the plant analyzer.
#define PLANT_SCANMODE_STATS		0
#define PLANT_SCANMODE_CHEMICALS 	1

//Seed flags.
=======
/// -- Flags for seeds. --
/// Allows a plant to wild mutate (mutate on haravest) at a certain instability.
>>>>>>> 4f7a73c... Moves the plant analyzer chem mode to right click + lets you read out a tray's chemical contents (#56836)
#define MUTATE_EARLY	(1<<0)
