//Exploration
/obj/item/clothing/head/helmet/space/void/exploration
	name = "exploration voidsuit helmet"
	desc = "A radiation-resistant helmet made especially for exploring unknown planetary environments."
	icon_state = "helm_explorer"
	item_state = "helm_explorer"
	armor = list(melee = 40, bullet = 15, laser = 25,energy = 35, bomb = 30, bio = 100, rad = 70)
	light_overlay = "helmet_light_dual" //explorer_light

/obj/item/clothing/suit/space/void/exploration
	name = "exploration voidsuit"
	desc = "A lightweight, radiation-resistant voidsuit, featuring the Explorer emblem on its chest plate. Designed for exploring unknown planetary environments."
	icon_state = "void_explorer"
	armor = list(melee = 40, bullet = 15, laser = 25,energy = 35, bomb = 30, bio = 100, rad = 70)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/stack/flag,/obj/item/device/healthanalyzer,/obj/item/device/gps,/obj/item/device/radio/beacon,/obj/item/weapon/shovel)

/obj/item/clothing/suit/space/void/exploration/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/exploration
	boots = /obj/item/clothing/shoes/magboots

//Pilot
/obj/item/clothing/head/helmet/space/void/pilot
	desc = "An atmos resistant helmet for space and planet exploration."
	name = "pilot voidsuit helmet"
	icon_state = "rig0_pilot"
	item_state = "pilot_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 15, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	light_overlay = "helmet_light_dual"

/obj/item/clothing/suit/space/void/pilot
	desc = "An atmos resistant voidsuit for space and planet exploration."
	icon_state = "rig-pilot"
	item_state = "rig-pilot"
	name = "pilot voidsuit"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 15, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/storage/toolbox,/obj/item/weapon/storage/briefcase/inflatable,/obj/item/device/t_scanner,/obj/item/weapon/rcd)

/obj/item/clothing/suit/space/void/pilot/prepared
	helmet = /obj/item/clothing/head/helmet/space/void/pilot
	boots = /obj/item/clothing/shoes/magboots
	
/obj/item/clothing/head/helmet/space/void/engineering/hazmat
	name = "HAZMAT voidsuit helmet"
	desc = "A engineering helmet designed for work in a low-pressure environment. Extra radiation shielding appears to have been installed at the price of comfort."
	icon_state = "rig0-engineering_rad"
	item_state_slots = list(slot_r_hand_str = "eng_helm_rad", slot_l_hand_str = "eng_helm_rad")
	armor = list(melee = 30, bullet = 5, laser = 20, energy = 5, bomb = 50, bio = 100, rad = 100)

/obj/item/clothing/suit/space/void/engineering/hazmat
	name = "HAZMAT voidsuit"
	desc = "A engineering voidsuit that protects against hazardous, low pressure environments. Has enhanced radiation shielding compared to regular engineering voidsuits."
	icon_state = "rig-engineering_rad"
	item_state_slots = list(slot_r_hand_str = "eng_voidsuit_rad", slot_l_hand_str = "eng_voidsuit_rad")

/obj/item/clothing/head/helmet/space/void/engineering/construction
	name = "construction voidsuit helmet"
	icon_state = "rig0-engineering_con"
	item_state_slots = list(slot_r_hand_str = "eng_helm_con", slot_l_hand_str = "eng_helm_con")

/obj/item/clothing/suit/space/void/engineering/construction
	name = "contstruction voidsuit"
	icon_state = "rig-engineering_con"
	item_state_slots = list(slot_r_hand_str = "eng_voidsuit_con", slot_l_hand_str = "eng_voidsuit_con")
							
/obj/item/clothing/head/helmet/space/void/medical/emt
	name = "emergency medical response voidsuit helmet"
	icon_state = "rig0-medical_emt"
	item_state_slots = list(slot_r_hand_str = "medical_helm_emt", slot_l_hand_str = "medical_helm_emt")

/obj/item/clothing/suit/space/void/medical/emt
	name = "emergency medical response voidsuit"
	icon_state = "rig-medical_emt"
	item_state_slots = list(slot_r_hand_str = "medical_voidsuit_emt", slot_l_hand_str = "medical_voidsuit_emt")

/obj/item/clothing/head/helmet/space/void/medical/bio
	name = "biohazard voidsuit helmet"
	desc = "A special helmet that protects against hazardous environments. Has minor radiation shielding."
	icon_state = "rig0-medical_bio"
	item_state_slots = list(slot_r_hand_str = "medical_helm_bio", slot_l_hand_str = "medical_helm_bio")
	armor = list(melee = 45, bullet = 5, laser = 20, energy = 5, bomb = 15, bio = 100, rad = 75)

/obj/item/clothing/suit/space/void/medical/bio
	name = "biohazard voidsuit"
	desc = "A special suit that protects against hazardous, environments. It feels heavier than the standard suit with extra protection around the joints."
	icon_state = "rig-medical_bio"
	item_state_slots = list(slot_r_hand_str = "medical_voidsuit_bio", slot_l_hand_str = "medical_voidsuit_bio")
	armor = list(melee = 45, bullet = 5, laser = 20, energy = 5, bomb = 15, bio = 100, rad = 75)

/obj/item/clothing/head/helmet/space/void/security/riot
	name = "crowd control voidsuit helmet"
	icon_state = "rig0-sec_riot"
	item_state_slots = list(slot_r_hand_str = "sec_helm_riot", slot_l_hand_str = "sec_helm_riot")

/obj/item/clothing/suit/space/void/security/riot
	name = "crowd control voidsuit"
	icon_state = "rig-sec_riot"
	item_state_slots = list(slot_r_hand_str = "sec_voidsuit_riot", slot_l_hand_str = "sec_voidsuit_riot")
