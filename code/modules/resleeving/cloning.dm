
#define CLONE_BIOMASS 150

/obj/machinery/computer/cloning
	name = "cloning control console"
	icon_keyboard = "med_key"
	icon_screen = "dna"
	light_color = "#315ab4"
	circuit = /obj/item/weapon/circuitboard/cloning
	req_access = list(access_heads) //Only used for record deletion right now.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/list/pods = list() //Linked cloning pods.
	var/temp = ""
	var/scantemp = "Scanner unoccupied"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text


/obj/machinery/computer/cloning/Initialize()
	. = ..()
	updatemodules()

/obj/machinery/computer/cloning/Destroy()
	releasecloner()
	..()

/obj/machinery/computer/cloning/proc/updatemodules()
	scanner = findscanner()
	releasecloner()
	findcloner()

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	//Try to find scanner on adjacent tiles first
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
		if (scannerf)
			return scannerf

	//Then look for a free one in the area
	if(!scannerf)
		var/area/A = get_area(src)
		for(var/obj/machinery/dna_scannernew/S in A.get_contents())
			return S

	return

/obj/machinery/computer/cloning/proc/releasecloner()
	for(var/obj/machinery/clonepod/P in pods)
		P.connected = null
		P.name = initial(P.name)
	pods.Cut()

/obj/machinery/computer/cloning/proc/findcloner()
	var/num = 1
	var/area/A = get_area(src)
	for(var/obj/machinery/clonepod/P in A.get_contents())
		if(!P.connected)
			pods += P
			P.connected = src
			P.name = "[initial(P.name)] #[num++]"

/obj/machinery/computer/cloning/attackby(obj/item/W as obj, mob/user as mob)
/*
	if (istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!diskette)
			user.drop_item()
			W.loc = src
			diskette = W
			user << "You insert [W]."
			updateUsrDialog()
			return*/
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		var/obj/machinery/clonepod/P = M.get_buffer()
		if(P && !(P in pods))
			pods += P
			P.connected = src
			P.name = "[initial(P.name)] #[pods.len]"
			user << "<span class='notice'>You connect [P] to [src].</span>"

	else if (menu == 4 && (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda)))
		if(check_access(W))
			records.Remove(active_record)
			qdel(active_record)
			temp = "Record deleted."
			menu = 2
		else
			temp = "Access Denied."
	else
		..()
	return

/obj/machinery/computer/cloning/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()

	ui_interact(user)

/obj/machinery/computer/cloning/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]

	var/records_list_ui[0]
	for(var/datum/dna2/record/R in records)
		records_list_ui[++records_list_ui.len] = list("ckey" = R.ckey, "name" = R.dna.real_name)

	var/pods_list_ui[0]
	for(var/obj/machinery/clonepod/pod in pods)
		pods_list_ui[++pods_list_ui.len] = list("pod" = pod, "biomass" = pod.biomass)

	if(pods)
		data["pods"] = pods_list_ui
	else
		data["pods"] = null

	if(records)
		data["records"] = records_list_ui
	else
		data["records"] = null

	if(active_record)
		data["activeRecord"] = list("ckey" = active_record.ckey, "real_name" = active_record.dna.real_name, \
									"ui" = active_record.dna.uni_identity, "se" = active_record.dna.struc_enzymes)
	else
		data["activeRecord"] = null

	data["menu"] = menu
	data["connected"] = scanner
	data["podsLen"] = pods.len
	data["loading"] = loading
	if(!scanner.occupant)
		scantemp = ""
	data["scantemp"] = scantemp
	data["occupant"] = scanner.occupant
	data["locked"] = scanner.locked
//	data["diskette"] = diskette
	data["temp"] = temp

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "cloning.tmpl", src.name, 400, 450)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(5)

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return 1

	if(loading)
		return

	if ((href_list["scan"]) && (!isnull(scanner)))
		scantemp = ""

		loading = 1

		spawn(20)
			scan_mob(scanner.occupant)

			loading = 0

		//No locking an open scanner.
	else if ((href_list["lock"]) && (!isnull(scanner)))
		if ((!scanner.locked) && (scanner.occupant))
			scanner.locked = 1
		else
			scanner.locked = 0

	else if ((href_list["eject"]) && (!isnull(scanner)))
		if ((!scanner.locked) && (scanner.occupant))
			scanner.eject_occupant()

	else if (href_list["view_rec"])
		active_record = find_record(href_list["view_rec"])
		if(istype(active_record,/datum/dna2/record))
			if ((isnull(active_record.ckey)))
				qdel(active_record)
				temp = "ERROR: Record Corrupt"
			else
				menu = 3
		else
			active_record = null
			temp = "Record missing."

	else if (href_list["del_rec"])
		if ((!active_record) || (menu < 3))
			return
		if (menu == 3) //If we are viewing a record, confirm deletion
			temp = "Delete record?"
			menu = 4
/*
	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if ((isnull(diskette)) || isnull(diskette.buf))
					temp = "Load error."
					return
				if (isnull(active_record))
					temp = "Record error."
					menu = 1
					return

				active_record = diskette.buf

				temp = "Load successful."
			if("eject")
				if (!isnull(diskette))
					diskette.loc = loc
					diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if ((isnull(diskette)) || (diskette.read_only) || (isnull(active_record)))
			temp = "Save error."

		// DNA2 makes things a little simpler.
		diskette.buf = active_record
		diskette.buf.types = 0
		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				diskette.buf.types = DNA2_BUF_UI
			if("ue")
				diskette.buf.types = DNA2_BUF_UI | DNA2_BUF_UE
			if("se")
				diskette.buf.types = DNA2_BUF_SE
		diskette.name = "data disk - '[active_record.dna.real_name]'"
		temp = "Save \[[href_list["save_disk"]]\] successful."
*/
	else if (href_list["refresh"])
		updateUsrDialog()

	else if (href_list["clone"])
		var/datum/dna2/record/C = find_record(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if(!pods.len)
				temp = "Error: No clone pods detected."
			else
				var/obj/machinery/clonepod/pod = pods[1]
				if (pods.len > 1)
					pod = input(usr,"Select a cloning pod to use", "Pod selection") as anything in pods
				if(pod.occupant)
					temp = "Error: Clonepod is currently occupied."
				else if(pod.biomass < CLONE_BIOMASS)
					temp = "Error: Not enough biomass."
				else if(pod.mess)
					temp = "Error: Clonepod malfunction."
				else if(!config.revival_cloning)
					temp = "Error: Unable to initiate cloning cycle."

				else if(pod.growclone(C))
					temp = "Initiating cloning cycle..."
					records.Remove(C)
					qdel(C)
					menu = 1
				else

					var/mob/selected = find_dead_player("[C.ckey]")
					selected << 'sound/machines/chime.ogg'	//probably not the best sound but I think it's reasonable
					var/answer = alert(selected,"Do you want to return to life?","Cloning","Yes","No")
					if(answer != "No" && pod.growclone(C))
						temp = "Initiating cloning cycle..."
						records.Remove(C)
						qdel(C)
						menu = 1
					else
						temp = "Initiating cloning cycle...<br>Error: Post-initialisation failed. Cloning cycle aborted."

		else
			temp = "Error: Data corruption."

	else if (href_list["menu"])
		menu = href_list["menu"]
		temp = ""
		scantemp = ""

	SSnano.update_uis(src)
	add_fingerprint(usr)

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob)
	var/brain_skip = 0
	if (istype(subject, /mob/living/carbon/brain)) //Brain scans.
		brain_skip = 1
	if ((isnull(subject)) || (!(ishuman(subject)) && !brain_skip) || (!subject.dna))
		scantemp = "Error: Unable to locate valid genetic data."
		return
	if (!subject.has_brain() && !brain_skip)
		if(istype(subject, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = subject
			if(H.should_have_organ("brain"))
				scantemp = "Error: No signs of intelligence detected."
		else
			scantemp = "Error: No signs of intelligence detected."
		return

	if(subject.isSynthetic())
		scantemp = "Error: Majority of subject is non-organic."
		return
		/* Suicide no exist - Jon
	if (subject.suiciding)
		scantemp = "Error: Subject's brain is not responding to scanning stimuli."
		return */
	if ((!subject.ckey) || (!subject.client))
		scantemp = "Error: Mental interface failure."
		return
/*	if (NOCLONE in subject.mutations) // Temporarily removing this - Jon
		scantemp = "Error: Mental interface failure."
		return*/
	if (subject.species && subject.species.species_flags & SPECIES_FLAG_NO_SCAN && !brain_skip)
		scantemp = "Error: Mental interface failure."
		return
	/* Errr we dont have any modifiers - Jon
	for(var/modifier_type in subject.modifiers)	//Can't be cloned, even if they had a previous scan
		if(istype(modifier_type, /datum/modifier/no_clone))
			scantemp = "Error: Mental interface failure."
			return */
	if (!isnull(find_record(subject.ckey)))
		scantemp = "Subject already in database."
		return

	subject.dna.check_integrity()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.dna = subject.dna
	R.ckey = subject.ckey
	R.id = copytext(md5(subject.real_name), 2, 6)
	R.name = R.dna.real_name
	R.types = DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages = subject.languages
	if(!brain_skip) //Brains don't have flavor text.
		R.flavor = subject.flavor_texts.Copy()
	else
		R.flavor = list()
		/* Errr we dont have any modifiers - Jon
	for(var/datum/modifier/mod in subject.modifiers)
		if(mod.flags & MODIFIER_GENETIC)
			R.genetic_modifiers.Add(mod.type)
	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp = locate(/obj/item/weapon/implant/health, subject)
	if (isnull(imp))
		imp = new /obj/item/weapon/implant/health(subject)
		imp.implanted = subject
		R.implant = "\ref[imp]"
	//Update it if needed
	else
		R.implant = "\ref[imp]"*/

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	records += R
	scantemp = "Subject successfully scanned."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in records)
		if (R.ckey == find_key)
			selected_record = R
			break
	return selected_record



/obj/machinery/clonepod
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	anchored = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_medical) //For premature unlocking.
	var/mob/living/occupant
	var/heal_level = 20 //The clone is released once its health reaches this level.
	var/heal_rate = 1
	var/notoxin = 0
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk
	var/biomass = CLONE_BIOMASS * 3

	//keeping here for now to remember
	/*
	var/cloninginitialdamage = (H.getMaxHealth() - config.health_threshold_dead)*0.5
	var/clonningcurrentdamage = 100-(H.getCloneLoss()/H.cloninginitialdamage*100)
	*/

/obj/machinery/clonepod/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonepod(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)

	RefreshParts()
	update_icon()

/obj/machinery/clonepod/attack_ai(mob/user as mob)

	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/clonepod/attack_hand(mob/user as mob)
	if((isnull(occupant)) || (stat & NOPOWER))
		return
	if((!isnull(occupant)) && (occupant.stat != 2))
		var/completion = (100 * ((100-(occupant.getCloneLoss()/((occupant.getMaxHealth() - config.health_threshold_dead)*0.5)*100)) / (heal_level + 100))) // Clones start at -150 health
		user << "Current clone cycle is [round(completion)]% complete."
	return

//Clonepod

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(var/datum/dna2/record/R)
	if(mess || attempting)
		return 0
	var/datum/mind/clonemind = locate(R.mind)

	if(!istype(clonemind, /datum/mind))	//not a mind
		return 0
	if(clonemind.current && clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
		return 0
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != R.ckey)
			return 0
	else
		for(var/mob/observer/ghost/G in GLOB.player_list)
			if(G.ckey == R.ckey)
				if(G.can_reenter_corpse)
					break
				else
					return 0
/* No modifiers on this codebase @ ~@ - Jon
	for(var/modifier_type in R.genetic_modifiers)	//Can't be cloned, even if they had a previous scan
		if(istype(modifier_type, /datum/modifier/no_clone))
			return 0
*/
	attempting = 1 //One at a time!!
	locked = 1

	eject_wait = 1
	spawn(30)
		eject_wait = 0

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name

	//Get the clone body ready
	H.adjustCloneLoss(150) // New damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	H.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	clonemind.transfer_to(H)
	H.ckey = R.ckey
	to_chat(H, "<span class='warning'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><b><font size='3'>Your recent memories are fuzzy, and it's hard to remember anything from today...</font></b></span><br><span class='notice'><i>So this is what cloning feels like?</i></span>")

	// -- Mode/mind specific stuff goes here
	callHook("clone", list(H))
	update_antag_icons(H.mind)
	// -- End mode specific stuff

	if(!R.dna)
		H.dna = new /datum/dna()
		H.dna.real_name = H.real_name
	else
		H.dna = R.dna
	H.UpdateAppearance()
	H.sync_organ_dna()
	if(heal_level < 60)
		randmutb(H) //Sometimes the clones come out wrong.
		H.dna.UpdateSE()
		H.dna.UpdateUI()

	H.set_cloned_appearance()
	update_icon()

	// A modifier is added which makes the new clone be unrobust.
	var/modifier_lower_bound = 25 MINUTES
	var/modifier_upper_bound = 40 MINUTES

	// Upgraded cloners can reduce the time of the modifier, up to 80%
	var/clone_sickness_length = abs(((heal_level - 20) / 100 ) - 1)
	clone_sickness_length = between(0.2, clone_sickness_length, 1.0) // Caps it off just incase.
	modifier_lower_bound = round(modifier_lower_bound * clone_sickness_length, 1)
	modifier_upper_bound = round(modifier_upper_bound * clone_sickness_length, 1)

	H.apply_damage(rand(modifier_lower_bound, modifier_upper_bound), CLONE)

	// Modifier that doesn't do anything.
//	H.add_modifier(/datum/modifier/cloned)

	// This is really stupid.
//	for(var/modifier_type in R.genetic_modifiers)
//		H.add_modifier(modifier_type) // If it's really stupid then explain what this does, I don't know what the fuck this does - Jon

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
	H.flavor_texts = R.flavor.Copy()
//	H.suiciding = 0 // Suicide is deprecated - Jon
	attempting = 0
	return 1

//From humans.dm moved here cause dependency - Jon
//Used for new human mobs created by cloning/goleming/etc.
/mob/living/carbon/human/proc/set_cloned_appearance()
	f_style = "Shaved"
	if(dna.species == "Human") //no more xenos losing ears/tentacles
		h_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")
//	all_underwear.Cut() // Can't be bothered looking for an alternative - Jon
	regenerate_icons()

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/Process()

	var/visible_message = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/meat/meat in range(1, src))
		qdel(meat)
		biomass += 50
		visible_message = 1 // Prevent chatspam when multiple meat are near

	if(visible_message)
		visible_message("<span class = 'notice'>[src] sucks in and processes the nearby biomass.</span>")

	if(stat & NOPOWER) //Autoeject if power is lost
		if(occupant)
			locked = 0
			go_out()
		return

	if((occupant) && (occupant.loc == src))
//		if((occupant.stat == DEAD) || (occupant.suiciding) || !occupant.key)  //Autoeject corpses and suiciding dudes.
//			locked = 0
//			go_out()
//			connected_message("Clone Rejected: Deceased.")
//			return

		if((100-(occupant.getCloneLoss()/((occupant.getMaxHealth() - config.health_threshold_dead)*0.5)*100)) < heal_level && occupant.getCloneLoss() > 0)
			occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			occupant.adjustCloneLoss(-2 * heal_rate)

			//Premature clones may have brain damage.
			occupant.adjustBrainLoss(-(ceil(0.5*heal_rate)))

			//So clones don't die of oxyloss in a running pod.
			if(occupant.reagents.get_reagent_amount("inaprovaline") < 15)
				occupant.reagents.add_reagent("inaprovaline", 30)
			occupant.Sleeping(30)
			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			occupant.adjustOxyLoss(-4)

			use_power_oneoff(7500) //This might need tweaking.
			return

		else if(((100-(occupant.getCloneLoss()/((occupant.getMaxHealth() - config.health_threshold_dead)*0.5)*100)) >= heal_level || (100-(occupant.getCloneLoss()/((occupant.getMaxHealth() - config.health_threshold_dead)*0.5)*100)) == occupant.getMaxHealth()) && (!eject_wait))
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			audible_message("\The [src] signals that the cloning process is complete.")
			connected_message("Cloning Process Complete.")
			locked = 0
			go_out()
			return

	else if((!occupant) || (occupant.loc != src))
		occupant = null
		if(locked)
			locked = 0
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isnull(occupant))
		if(default_deconstruction_screwdriver(user, W))
			return
		if(default_deconstruction_crowbar(user, W))
			return
		if(default_part_replacement(user, W))
			return
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(!check_access(W))
			user << "<span class='warning'>Access Denied.</span>"
			return
		if((!locked) || (isnull(occupant)))
			return
		if((occupant.health < -20) && (occupant.stat != 2))
			user << "<span class='warning'>Access Refused.</span>"
			return
		else
			locked = 0
			user << "System unlocked."
	else if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		user << "<span class='notice'>\The [src] processes \the [W].</span>"
		biomass += 50
		user.drop_item()
		qdel(W)
		return
	else if(istype(W, /obj/item/weapon/wrench))
		if(locked && (anchored || occupant))
			user << "<span class='warning'>Can not do that while [src] is in use.</span>"
		else
			if(anchored)
				anchored = 0
				connected.pods -= src
				connected = null
			else
				anchored = 1
			//playsound(src, W.usesound, 100, 1) Usesound deprecated - Jon
			if(anchored)
				user.visible_message("[user] secures [src] to the floor.", "You secure [src] to the floor.")
			else
				user.visible_message("[user] unsecures [src] from the floor.", "You unsecure [src] from the floor.")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		M.set_buffer(src)
		user << "<span class='notice'>You load connection data from [src] to [M].</span>"
		M.update_icon()
		return
	else
		..()

/obj/machinery/clonepod/emag_act(var/remaining_charges, var/mob/user)
	if(isnull(occupant))
		return
	user << "You force an emergency ejection."
	locked = 0
	go_out()
	return 1

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(var/message)
	if((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return 0
	if(!message)
		return 0

	connected.temp = "[name] : [message]"
	connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/RefreshParts()
	..()
	var/rating = 0
	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/scanning_module) || istype(P, /obj/item/weapon/stock_parts/manipulator))
			rating += P.rating

	heal_level = rating * 10 - 20
	heal_rate = round(rating / 4)
	if(rating >= 8)
		notoxin = 1
	else
		notoxin = 0

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return
	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if(locked)
		return

	if(mess) //Clean that mess and dump those gibs!
		mess = 0
		gibs(src.loc)
		update_icon()
		return

	if(!(occupant))
		return

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.loc = src.loc
	eject_wait = 0 //If it's still set somehow.
	if(ishuman(occupant)) //Need to be safe.
		var/mob/living/carbon/human/patient = occupant
		if(!(patient.species.species_flags & SPECIES_FLAG_NO_SCAN)) //If, for some reason, someone makes a genetically-unalterable clone, let's not make them permanently disabled.
			domutcheck(occupant) //Waiting until they're out before possible transforming.
	occupant = null

	biomass -= CLONE_BIOMASS
	update_icon()
	return

/obj/machinery/clonepod/proc/malfunction()
	if(occupant)
		connected_message("Critical Error!")
		mess = 1
		update_icon()
		occupant.ghostize()
		spawn(5)
			qdel(occupant)
	return

/obj/machinery/clonepod/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/severity))
		malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		else
	return

/obj/machinery/clonepod/update_icon()
	..()
	icon_state = "pod_0"
	if(occupant && !(stat & NOPOWER))
		icon_state = "pod_1"
	else if(mess)
		icon_state = "pod_g"

//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if(!implanted)
		return "ERROR"
	else
		if(isliving(implanted))
			var/mob/living/L = implanted
			healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if(!healthstring)
			healthstring = "ERROR"
		return healthstring