/mob/living/proc/getDigestLoss()
	return 0

/mob/living/proc/adjustDigestLoss(var/amount)
	adjustBruteLoss(amount * 0.5)

/mob/living/proc/setDigestLoss(var/amount)
	adjustBruteLoss((amount * 0.5)-getBruteLoss())

/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()
	//CHOMPER Edit Start - Making it so SSD people have prefs with fallback to original style.
	if(config.allow_Metadata)
		if(ooc_notes)
			to_chat(usr, "[src]'s Metainfo:<br>[ooc_notes]")
		else if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		usr << "OOC Metadata is not supported by this server!"
	//CHOMPER Edit End - Making it so SSD people have prefs with fallback to original style.
	return