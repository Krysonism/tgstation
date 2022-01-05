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
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_sound = 'sound/weapons/bite.ogg'

	///Our burrow action, lets us burrow down into soft turfs like a goldgrub
	var/datum/action/innate/burrow/cobraworm/burrow_action
	///cooldown of our main ranged attack
	COOLDOWN_DECLARE(enzyme_spit)
	///cooldown of our alt ranged attack
	COOLDOWN_DECLARE(wormling_ball_cooldown)

/mob/living/basic/cobraworm/Initialize(mapload)
	. = ..()
	burrow_action = new
	burrow_action.Grant(src)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/ranged_attacks, null, 'sound/creatures/cobraworm/worm_spit.ogg', /obj/projectile/worm_spit)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_COBRAWORM, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/cobraworm/ranged_secondary_attack(atom/target, modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, wormling_ball_cooldown))
		balloon_alert(src, "cooldown [round(COOLDOWN_TIMELEFT(src, wormling_ball_cooldown) * 0.1, 0.1)]s")
		return
	else
		var/obj/projectile/wormling_ball/wormy_ball = new(loc)
		playsound(src, 'sound/creatures/cobraworm/worm_spit.ogg', 100, TRUE)
		wormy_ball.starting = loc
		wormy_ball.firer = src
		wormy_ball.fired_from = src
		//wormy_ball.yo = target.y - loc.y
		//wormy_ball.xo = target.x - loc.x
		wormy_ball.original = target
		wormy_ball.preparePixelProjectile(target, src)
		wormy_ball.fire()
		COOLDOWN_START(src, wormling_ball_cooldown, 15 SECONDS)

/mob/living/basic/cobraworm/RangedAttack(atom/A, modifiers)
	if(!COOLDOWN_FINISHED(src, enzyme_spit))
		return
	COOLDOWN_START(src, enzyme_spit, 1.5 SECONDS)
	return ..()

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

/datum/action/innate/burrow/cobraworm
	background_icon_state = "bg_nature"

