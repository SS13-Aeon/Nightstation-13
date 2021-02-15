//Thing meant for allowing datums and objects to access an NTnet network datum.
/datum/proc/ntnet_receive(datum/netdata/data)
	return

<<<<<<< HEAD
/datum/proc/ntnet_receive_broadcast(datum/netdata/data)
	return

/datum/proc/ntnet_send(datum/netdata/data, netid)
=======
/*
 * Helper function that does 90% of the work in sending a packet
 *
 * This function gets the component and builds a packet so the sending
 * person doesn't have to lift a finger.  Just create a netdata datum or even
 * just a list and it will send it on its merry way.
 *
 * Arguments:
 * * packet_data - Either a list() or a /datum/netdata.  If its netdata, the other args are ignored
 * * target_id - Target hardware id or network_id for this packet. If we are a network id, then its
					broadcasted to that network.
 * * passkey - Authentication for the packet.  If the target doesn't authenticate the packet is dropped
 */
/datum/proc/ntnet_send(packet_data, target_id = null, passkey = null)
	var/datum/netdata/data = packet_data
	if(!data) // check for easy case
		if(!islist(packet_data) || target_id == null)
			stack_trace("ntnet_send: Bad packet creation") // hard fail as its runtime fault
			return
		data = new(packet_data)
		data.receiver_id = target_id
		data.passkey = passkey
	if(data.receiver_id == null)
		return NETWORK_ERROR_BAD_TARGET_ID
>>>>>>> 0f435d5... Remove hideous inline tab indentation, and bans it in contributing guidelines (#56912)
	var/datum/component/ntnet_interface/NIC = GetComponent(/datum/component/ntnet_interface)
	if(!NIC)
		return FALSE
	return NIC.__network_send(data, netid)

/datum/component/ntnet_interface
<<<<<<< HEAD
	var/hardware_id			//text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/network_name = ""			//text
	var/list/networks_connected_by_id = list()		//id = datum/ntnet
	var/differentiate_broadcast = TRUE				//If false, broadcasts go to ntnet_receive. NOT RECOMMENDED.
=======
	var/hardware_id = null // text. this is the true ID. do not change this. stuff like ID forgery can be done manually.
	var/id_tag = null // named tag, mainly used to look up mapping objects
	var/datum/ntnet/network = null // network we are on, we MUST be on a network or there is no point in this component
	var/list/registered_sockets = list()// list of ports opened up on devices
	var/list/alias = list() // if we live in more than one network branch

/**
 * Initialize for the interface
 *
 * Assigns a hardware id and gets your object onto the network
 *
 * Arguments:
 * * network_name - Fully qualified network id of the network we are joining
 * * network_tag - The objects id_tag.  Used for finding the device at mapload time
 */
/datum/component/ntnet_interface/Initialize(network_name, network_tag = null)
	if(network_name == null || !istext(network_name))
		log_telecomms("ntnet_interface/Initialize: Bad network '[network_name]' for '[parent]', going to limbo it")
		network_name = LIMBO_NETWORK_ROOT
	// Tags cannot be numbers and must be unique over the world
	if(network_tag != null && !istext(network_tag))
		// numbers are not allowed as lookups for interfaces
		log_telecomms("Tag cannot be a number?  '[network_name]' for '[parent]', going to limbo it")
		network_tag = "BADTAG_" + network_tag

	hardware_id = SSnetworks.get_next_HID()
	id_tag = network_tag
	SSnetworks.interfaces_by_hardware_id[hardware_id] = src

	network = SSnetworks.create_network_simple(network_name)

	network.add_interface(src)
>>>>>>> 0f435d5... Remove hideous inline tab indentation, and bans it in contributing guidelines (#56912)

/datum/component/ntnet_interface/Initialize(force_name = "NTNet Device", autoconnect_station_network = TRUE)			//Don't force ID unless you know what you're doing!
	hardware_id = "[SSnetworks.get_next_HID()]"
	network_name = force_name
	if(!SSnetworks.register_interface(src))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Unable to register NTNet interface. Interface deleted.")
	if(autoconnect_station_network)
		register_connection(SSnetworks.station_network)

/datum/component/ntnet_interface/Destroy()
	unregister_all_connections()
	SSnetworks.unregister_interface(src)
	return ..()

/datum/component/ntnet_interface/proc/__network_receive(datum/netdata/data)			//Do not directly proccall!
	SEND_SIGNAL(parent, COMSIG_COMPONENT_NTNET_RECEIVE, data)
	if(differentiate_broadcast && data.broadcast)
		parent.ntnet_receive_broadcast(data)
	else
		parent.ntnet_receive(data)

/datum/component/ntnet_interface/proc/__network_send(datum/netdata/data, netid)			//Do not directly proccall!

	if(netid)
		if(networks_connected_by_id[netid])
			var/datum/ntnet/net = networks_connected_by_id[netid]
			return net.process_data_transmit(src, data)
		return FALSE
	for(var/i in networks_connected_by_id)
		var/datum/ntnet/net = networks_connected_by_id[i]
		net.process_data_transmit(src, data)
	return TRUE

/datum/component/ntnet_interface/proc/register_connection(datum/ntnet/net)
	if(net.interface_connect(src))
		networks_connected_by_id[net.network_id] = net
	return TRUE

/datum/component/ntnet_interface/proc/unregister_all_connections()
	for(var/i in networks_connected_by_id)
		unregister_connection(networks_connected_by_id[i])
	return TRUE

/datum/component/ntnet_interface/proc/unregister_connection(datum/ntnet/net)
	net.interface_disconnect(src)
	networks_connected_by_id -= net.network_id
	return TRUE
