PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS
	var/datum/ntnet/station/station_network
	var/assignment_hardware_id = HID_RESTRICTED_END
	var/list/networks_by_id = list()				//id = network
	var/list/interfaces_by_id = list()				//hardware id = component interface
	var/resolve_collisions = TRUE

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	station_network.register_map_supremecy()
	. = ..()

/datum/controller/subsystem/processing/networks/proc/register_network(datum/ntnet/network)
	if(!networks_by_id[network.network_id])
		networks_by_id[network.network_id] = network
		return TRUE
	return FALSE

<<<<<<< HEAD
/datum/controller/subsystem/processing/networks/proc/unregister_network(datum/ntnet/network)
	networks_by_id -= network.network_id
	return TRUE
=======
/datum/controller/subsystem/networks/proc/log_data_transfer( datum/netdata/data)
	logs += "[station_time_timestamp()] - [data.generate_netlog()]"
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len - setting_maxlogcount, 0)

/**
 * Records a message into the station logging system for the network
 *
 * This CAN be read in station by personal so do not use it for game debugging
 * during fire.  At this point data.receiver_id has already been converted if it was a broadcast but
 * is undefined in this function.  It is also dumped to normal logs but remember players can read/intercept
 * these messages
 * Arguments:
 * * log_string - message to log
 * * network - optional, It can be a ntnet or just the text equivalent
 * * hardware_id = optional, text, will look it up and return with the parent.name as well
 */
/datum/controller/subsystem/networks/proc/add_log(log_string, network = null , hardware_id = null)
	set waitfor = FALSE // so process keeps running
	var/list/log_text = list()
	log_text += "\[[station_time_timestamp()]\]"
	if(network)
		var/datum/ntnet/net = network
		if(!istype(net))
			net = networks[network]
		if(net) // bad network?
			log_text += "{[net.network_id]}"
		else // bad network?
			log_text += "{[network] *BAD*}"

	if(hardware_id)
		var/datum/component/ntnet_interface/conn = interfaces_by_hardware_id[hardware_id]
		if(conn)
			log_text += " ([hardware_id])[conn.parent]"
		else
			log_text += " ([hardware_id])*BAD ID*"
	else
		log_text += "*SYSTEM*"
	log_text += " - "
	log_text += log_string
	log_string = log_text.Join()

	logs.Add(log_string)
	//log_telecomms("NetLog: [log_string]") // causes runtime on startup humm

	// We have too many logs, remove the oldest entries until we get into the limit
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len-setting_maxlogcount,0)
>>>>>>> c7ab3a8... Fixes NTNet logging runtime (#55892)

/datum/controller/subsystem/processing/networks/proc/register_interface(datum/component/ntnet_interface/D)
	if(!interfaces_by_id[D.hardware_id])
		interfaces_by_id[D.hardware_id] = D
		return TRUE
	return FALSE

/datum/controller/subsystem/processing/networks/proc/unregister_interface(datum/component/ntnet_interface/D)
	interfaces_by_id -= D.hardware_id
	return TRUE

/datum/controller/subsystem/processing/networks/proc/get_next_HID()
	var/string = "[num2text(assignment_hardware_id++, 12)]"
	return make_address(string)

/datum/controller/subsystem/processing/networks/proc/make_address(string)
	if(!string)
		return resolve_collisions? make_address("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]"):null
	var/hex = md5(string)
	if(!hex)
		return		//errored
	. = "[copytext_char(hex, 1, 9)]"		//16 ^ 8 possibilities I think.
	if(interfaces_by_id[.])
		return resolve_collisions? make_address("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]"):null
