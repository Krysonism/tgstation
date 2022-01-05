/obj/projectile/worm_spit
	name = "worm spit"
	icon_state = "worm"
	damage = 6
	damage_type = BURN
	flag = BIO
	speed = 0.6

/obj/projectile/worm_spit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/venomous, /datum/reagent/nightcrawler_enzymes, 3)

/obj/projectile/worm_spit/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!istype(target, /obj/machinery/hydroponics))
		return
	target?.reagents.add_reagent(/datum/reagent/nightcrawler_enzymes, 3)

/obj/projectile/wormling_ball
	name = "mud ball"
	icon_state = "mud"
	damage = 6
	speed = 0.4

/obj/projectile/wormling_ball/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/muddy_turf = get_turf(loc)
	if(!muddy_turf)
		return
	if(!isopenturf(muddy_turf))
		return
	if(locate(/obj/machinery/hydroponics/soil) in muddy_turf)
		return
	new /obj/machinery/hydroponics/soil/worm(muddy_turf)
	new /obj/effect/wormling_trap(muddy_turf)

/obj/projectile/wormling_ball/on_range()
	new /obj/machinery/hydroponics/soil/worm(loc)
	..()

/obj/effect/wormling_trap
	name = "wriggling worms"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "worm_effect"
	layer = ABOVE_MOB_LAYER

/obj/effect/wormling_trap/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 20 SECONDS)
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
