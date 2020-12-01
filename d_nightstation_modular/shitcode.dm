//This is the best solution I could think of for getting miners in modularly without map specific fuckery, gray please move this somewhere where it belongs

//Oxygen
/obj/machinery/air_sensor/atmos/oxygen_tank/Initialize(mapload)
. = ..()
if(mapload)
  new /obj/machinery/atmospherics/miner/oxygen(get_turf(src));
  
//Nitrogen
/obj/machinery/air_sensor/atmos/nitrogen_tank/Initialize(mapload)
. = ..()
if(mapload)
  new /obj/machinery/atmospherics/miner/nitrogen(get_turf(src));
  
//Nitrous Oxide
/obj/machinery/air_sensor/atmos/toxin_tank/Initialize(mapload)
. = ..()
if(mapload)
  new /obj/machinery/atmospherics/miner/n2o(get_turf(src));
  
//Carbon Dioxide
/obj/machinery/air_sensor/atmos/carbon_tank/Initialize(mapload)
. = ..()
if(mapload)
  new /obj/machinery/atmospherics/miner/carbon_dioxide(get_turf(src));
  
//Blasma
/obj/machinery/air_sensor/atmos/toxin_tank/Initialize(mapload)
. = ..()
if(mapload)
  new /obj/machinery/atmospherics/miner/toxins(get_turf(src));
  
