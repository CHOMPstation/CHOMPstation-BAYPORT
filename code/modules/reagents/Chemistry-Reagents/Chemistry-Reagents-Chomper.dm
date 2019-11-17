/* Chomper chemicals */

//Special digestion healing medicine
/datum/reagent/mylozine
    name = "Mylozine"
    description = "By combining effecient burn med and DNA mending chems and catalyse it with a strong enough acid, the result is Mylozine, a chemical capable of assisting the body in recovering from being broken down inside another being."
    taste_description = "acidic"
    taste_mult = 1.5
    reagent_state = LIQUID
    color = "#2398ef"
    overdose = REAGENTS_OVERDOSE * 0.5
    scannable = 1
    flags = IGNORE_MOB_SIZE

/datum/reagent/mylozine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
    if(alien != IS_DIONA)
        M.adjustDigestLoss(-5 * removed)

/datum/reagent/numbenzyme
	name = "Numbing Enzyme"
	description = "Some sort of organic painkiller."
	taste_description = "sourness"
	reagent_state = LIQUID
	color = "#800080"
	metabolism = 0.1 //Lasts up to 200 seconds if you give 20u which is OD.
	overdose = 20 //High OD. This is to make numbing bites have somewhat of a downside if you get bit too much. Have to go to medical for dialysis.
	scannable = 0 //Let's not have medical mechs able to make an extremely strong organic painkiller

/datum/reagent/numbenzyme/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	M.add_chemical_effect(CE_PAINKILLER, 200)
	if(prob(0.01)) //1 in 10000 chance per tick. Extremely rare.
		to_chat(M,"<span class='warning'>Your body feels numb as a light, tingly sensation spreads throughout it, like some odd warmth.</span>")

