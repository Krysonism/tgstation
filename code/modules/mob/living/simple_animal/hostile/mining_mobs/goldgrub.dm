//An ore-devouring but easily scared creature
/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	vision_range = 2
	aggro_vision_range = 9
	move_to_delay = 5
	friendly_verb_continuous = "harmlessly rolls into"
	friendly_verb_simple = "harmlessly roll into"
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attack_verb_continuous = "barrels into"
	attack_verb_simple = "barrel into"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = FALSE
	speak_emote = list("screeches")
	throw_message = "sinks in slowly, before being pushed out of "
	deathmessage = "stops moving as green liquid oozes from the carcass!"
	status_flags = CANPUSH
	gold_core_spawnable = HOSTILE_SPAWN
	search_objects = 1
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/uranium)

	var/chase_time = 100
	var/will_burrow = TRUE
	var/datum/action/innate/goldgrub/spitore/spit
	var/datum/action/innate/burrow/burrow

/mob/living/simple_animal/hostile/asteroid/goldgrub/Initialize(mapload)
	. = ..()
	var/i = rand(1,3)
	while(i)
		loot += pick(/obj/item/stack/ore/silver, /obj/item/stack/ore/gold, /obj/item/stack/ore/uranium, /obj/item/stack/ore/diamond)
		i--
	spit = new
	burrow = new
	spit.Grant(src)
	burrow.Grant(src)

/datum/action/innate/goldgrub
	background_icon_state = "bg_default"

/datum/action/innate/goldgrub/spitore
	name = "Spit Ore"
	desc = "Vomit out all of your consumed ores."

/datum/action/innate/goldgrub/spitore/Activate()
	var/mob/living/simple_animal/hostile/asteroid/goldgrub/grubby = owner
	if(grubby.stat == DEAD || !isturf(grubby.loc))
		return
	grubby.barf_contents()

/datum/action/innate/burrow
	name = "Burrow"
	desc = "Burrow under soft ground, evading predators and increasing your speed."
	icon_icon =  'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "burrow"
	background_icon_state = "bg_default"
	var/is_burrowed = FALSE
	/// list of types we can dig into
	var/static/list/diggable_turfs

/datum/action/innate/burrow/Activate()
	if(!diggable_turfs)
		diggable_turfs = list(
			/turf/open/floor/plating/asteroid,
			/turf/open/floor/plating/grass,
			/turf/open/floor/grass,
			/turf/open/floor/plating/ironsand,
			/turf/open/floor/plating/dirt,
			/turf/open/floor/plating/sandy_dirt
		)

	var/mob/living/wormy_owner = owner
	var/obj/effect/dummy/phased_mob/holder = null
	if(wormy_owner.stat == DEAD)
		return
	var/turf/dig_turf = get_turf(wormy_owner)
	if (!is_type_in_list(dig_turf, diggable_turfs) || !do_after(wormy_owner, 30, target = dig_turf))
		to_chat(wormy_owner, span_warning("You can only burrow in and out soft ground and must stay still!"))
		return
	if (get_dist(wormy_owner, dig_turf) != 0)
		to_chat(wormy_owner, span_warning("Action cancelled, as you moved while reappearing."))
		return
	if(is_burrowed)
		holder = wormy_owner.loc
		wormy_owner.forceMove(dig_turf)
		QDEL_NULL(holder)
		is_burrowed = FALSE
		wormy_owner.visible_message(span_danger("[wormy_owner] emerges from the ground!"))
		playsound(get_turf(wormy_owner), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
		button_icon_state = "burrow"
	else
		wormy_owner.visible_message(span_danger("[wormy_owner] buries into the ground, vanishing from sight!"))
		playsound(get_turf(wormy_owner), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
		holder = new /obj/effect/dummy/phased_mob(dig_turf)
		wormy_owner.forceMove(holder)
		is_burrowed = TRUE
		button_icon_state = "emerge"
	UpdateButtonIcon()

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(new_target)
	add_target(new_target)
	if(target != null)
		if(istype(target, /obj/item/stack/ore))
			visible_message(span_notice("The [name] looks at [target.name] with hungry eyes."))
		else if(isliving(target))
			Aggro()
			visible_message(span_danger("The [name] tries to flee from [target.name]!"))
			retreat_distance = 10
			minimum_distance = 10
			if(will_burrow)
				addtimer(CALLBACK(src, .proc/Burrow), chase_time)

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/stack/ore))
		EatOre(target)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(atom/movable/targeted_ore)
	if(targeted_ore && targeted_ore.loc != src)
		targeted_ore.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/asteroid/goldgrub/death(gibbed)
	barf_contents()
	return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/barf_contents()
	visible_message(span_danger("[src] spits out its consumed ores!"))
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!stat)
		visible_message(span_danger("The [name] buries into the ground, vanishing from sight!"))
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/projectile/P)
	visible_message(span_danger("The [P.name] is repelled by [name]'s girth!"))
	return BULLET_ACT_BLOCK

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	vision_range = 9
	. = ..()
