/mob/living/basic/cobraworm
	name = "tiziran cobraworm"
	desc = "A wormlike creature from the Tiziran crudlands. It is commonly encounted near bone heaps, plastomiddens and compost basins. Its noxious spit is feared amongst Tirizan scourjocks."
	icon = 'icons/mob/cobraworm.dmi'
	icon_state = "cobraworm"
	base_icon_state = "cobraworm"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	maxHealth = 80
	health = 80
	speed = 0
	melee_damage_lower = 3
	melee_damage_upper = 6
	obj_damage = 10
	///Our burrow action, lets us burrow down into soft turfs like a goldgrub
	var/datum/action/innate/burrow/cobraworm/burrow_action
	COOLDOWN_DECLARE(wormling_ball_cooldown)

/mob/living/basic/cobraworm/Initialize(mapload)
	. = ..()
	burrow_action = new
	burrow_action.Grant(src)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/ranged_attacks, null, 'sound/creatures/cobraworm/worm_spit.ogg', /obj/projectile/worm_spit)

/mob/living/basic/cobraworm/ranged_secondary_attack(atom/target, modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, wormling_ball_cooldown))
		balloon_alert(src, "cooldown [round(COOLDOWN_TIMELEFT(src, wormling_ball_cooldown) * 0.001, 0.1)]s")
		return
	else
		var/obj/projectile/wormling_ball/wormy_ball = new(loc)
		playsound(src, 'sound/creatures/cobraworm/worm_spit.ogg', 100, TRUE)
		wormy_ball.starting = loc
		wormy_ball.firer = src
		wormy_ball.fired_from = src
		wormy_ball.yo = target.y - loc.y
		wormy_ball.xo = target.x - loc.x
		wormy_ball.original = target
		wormy_ball.preparePixelProjectile(target, src)
		wormy_ball.fire()
		COOLDOWN_START(src, wormling_ball_cooldown, 15 SECONDS)

/particles/worm_enzymes
	icon = 'icons/effects/particles/worm_enzymes.dmi'
	icon_state = list("enzymes_1" = 4, "enzymes_2" = 4, "enzymes_3" = 2, "enzymes_4" = 1)
	width = 64
	height = 64
	count = 1000
	spawning = 8
	lifespan = 2 SECONDS
	fade = 1.5 SECONDS
	velocity = list(0, 2, 0)
	position = list(-16, 16, 0)
	drift = generator("sphere", 0, 2, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, -1)
	grow = 0

/obj/projectile/worm_spit
	name = "worm spit"
	icon_state = "worm"
	damage = 4
	damage_type = BURN
	flag = BIO

/obj/projectile/worm_spit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/venomous, /datum/reagent/nightcrawler_enzymes, 3)

/obj/projectile/wormling_ball
	name = "mud ball"
	icon_state = "mud"
	damage = 6

/obj/projectile/wormling_ball/Impact(atom/A)
	. = ..()
	var/muddy_turf = get_turf(A)
	if(!muddy_turf)
		return
	if(!isopenturf(muddy_turf))
		return
	if(locate(/obj/machinery/hydroponics/soil) in muddy_turf)
		return
	new /obj/machinery/hydroponics/soil/worm(muddy_turf)
	new /obj/effect/wormling_trap(muddy_turf)

/obj/effect/wormling_trap
	name = "wriggling worms"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "worm_effect"
	layer = ABOVE_MOB_LAYER

/obj/effect/wormling_trap/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10 SECONDS)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/wormling_trap/proc/on_entered(datum/source, atom/movable/movable_atom)
	SIGNAL_HANDLER
	trigger(movable_atom)

/obj/effect/wormling_trap/Bump(atom/bumped_atom)
	trigger(bumped_atom)

/obj/effect/wormling_trap/Bumped(atom/movable/movable_atom)
	trigger(movable_atom)

/obj/effect/wormling_trap/proc/trigger(mob/living/target)
	if(!istype(target) || target.stat == DEAD || istype(target, /mob/living/basic/cobraworm))
		return

	target.balloon_alert_to_viewers("ensnared")
	playsound(get_turf(target), 'sound/creatures/cobraworm/worm_ensnare.ogg', 50, TRUE, -1)
	target.apply_status_effect(STATUS_EFFECT_ROOTED, 5 SECONDS, src)

/datum/action/innate/burrow/cobraworm
	background_icon_state = "bg_nature"

