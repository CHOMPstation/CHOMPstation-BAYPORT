
// CHOMPER AUDIO


GLOBAL_LIST_INIT(digestion_sound,list('sound/vore/digest1.ogg','sound/vore/digest2.ogg','sound/vore/digest3.ogg','sound/vore/digest4.ogg','sound/vore/digest5.ogg','sound/vore/digest6.ogg','sound/vore/digest7.ogg','sound/vore/digest8.ogg','sound/vore/digest9.ogg','sound/vore/digest10.ogg','sound/vore/digest11.ogg','sound/vore/digest12.ogg'))

GLOBAL_LIST_INIT(death_sound,list('sound/vore/death1.ogg','sound/vore/death2.ogg','sound/vore/death3.ogg','sound/vore/death4.ogg','sound/vore/death5.ogg','sound/vore/death6.ogg','sound/vore/death7.ogg','sound/vore/death8.ogg','sound/vore/death9.ogg','sound/vore/death10.ogg'))

GLOBAL_LIST_INIT(hunger_sound,list('sound/vore/growl1.ogg','sound/vore/growl2.ogg','sound/vore/growl3.ogg','sound/vore/growl4.ogg','sound/vore/growl5.ogg'))

GLOBAL_LIST_INIT(struggle_sound,list("Squish1" = 'sound/vore/squish1.ogg',"Squish2" = 'sound/vore/squish2.ogg',"Squish3" = 'sound/vore/squish3.ogg',"Squish4" = 'sound/vore/squish4.ogg'))

GLOBAL_LIST_INIT(vore_sounds,list("Gulp" = 'sound/vore/gulp.ogg',"Insert" = 'sound/vore/insert.ogg',"Insertion1" = 'sound/vore/insertion1.ogg',"Insertion2" = 'sound/vore/insertion2.ogg',"Insertion3" = 'sound/vore/insertion3.ogg',"Schlorp" = 'sound/vore/schlorp.ogg',"Squish1" = 'sound/vore/squish1.ogg',"Squish2" = 'sound/vore/squish2.ogg',"Squish3" = 'sound/vore/squish3.ogg',"Squish4" = 'sound/vore/squish4.ogg',"Rustle (cloth)" = 'sound/effects/rustle5.ogg',"None" = null))



/proc/vr_playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff, is_global, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, preference = null)
	if(isarea(source))
		throw EXCEPTION("playsound(): source is an area")
		return

	var/turf/turf_source = get_turf(source)

	//allocate a channel if necessary now so its the same for everyone
	channel = 0

 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/sound/S = sound(get_sfx(soundin))
	var/maxdistance = (world.view + extrarange) * 3
	var/list/listeners = GLOB.player_list
	if(!ignore_walls) //these sounds don't carry through walls
		listeners = listeners & hearers(maxdistance,turf_source)
	for(var/P in listeners)
		var/mob/M = P
		if(!M || !M.client)
			continue
		var/turf/T = get_turf(M)
		var/distance = get_dist(T, turf_source)

		if(distance <= maxdistance)
			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global, channel, pressure_affected, S)

/mob/proc/vr_playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff, is_global, channel = 0, pressure_affected = TRUE, sound/S, preference)
	if(!client || ear_deaf > 0)
		return
	if(preference && !client.get_preference_value(/datum/client_preference/play_ambiance) == GLOB.PREF_YES)
		return

	if(!S)
		S = sound(get_sfx(soundin))

	S.wait = 0 //No queue
	S.channel = 0
	S.volume = vol

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		//Atmosphere affects sound
		var/pressure_factor = 1
		if(pressure_affected)
			var/datum/gas_mixture/hearer_env = T.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			S.volume *= pressure_factor
			//End Atmosphere affecting sound

		//Don't bother with doing anything below.
		if(S.volume <= 0)
			return //No sound

		//Apply a sound environment.
		if(!is_global)
			if(istype(src,/mob/living/))
				var/mob/living/carbon/M = src
				if (istype(M) && M.hallucination_power > 50 && M.chem_effects[CE_MIND] < 1)
					S.environment = PSYCHOTIC
				else if (M.druggy)
					S.environment = DRUGGED
				else if (M.drowsyness)
					S.environment = DIZZY
				else if (M.confused)
					S.environment = DIZZY
				else if (M.stat == UNCONSCIOUS)
					S.environment = UNDERWATER
				else if (pressure_factor < 0.5)
					S.environment = SPACE
				else
					var/area/A = get_area(src)
					S.environment = A.sound_env

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	src << S