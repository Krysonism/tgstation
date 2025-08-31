/obj/item/seed/coconut
	name = "coconut seed pack"
	desc = "Cocos Nucifera: this elegant palm is an essential feature of any tropical paradise."
	icon_state = "seed-coconut"
	growing_icon = 'icons/obj/service/hydroponics/growing_tall.dmi'
	icon_dead = "coconut-dead"
	lifespan = 120
	endurance = 60
	maturation_speed = 15
	species = "coconut"
	plantname = "Coconut Tree"
	product = /obj/item/food/grown/coconut
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/water = 0.1, /datum/reagent/consumable/nutriment/fat = 0.1)

/obj/item/food/grown/coconut
	name = "coconut"
	icon_state = "coconut"
	desc = "A large thick-shelled nut.\n\nWhile examining the face it almost seems like if it is mocking you, confident its thick shell will protect it from harm."
	throwforce = 10
	seed = /obj/item/seed/coconut
	foodtype = FRUIT
	w_class = WEIGHT_CLASS_NORMAL
	food_flags = FOOD_IN_CONTAINER
	w_class = WEIGHT_CLASS_NORMAL
	preserved_food = TRUE
	juice_typepath = /datum/reagent/consumable/coconut_milk
	distill_reagent = /datum/reagent/consumable/ethanol/coconut_rum
	tastes = list("coconut")

/obj/item/food/grown/coconut/attack(mob/living/target, mob/user, def_zone)
	if (!is_drainable())
		to_chat(user, span_warning("You need to open [src] first!"))
		return FALSE
	return ..()

/obj/item/food/grown/coconut/make_processable()
	AddElement(/datum/element/processable, TOOL_AXE, /obj/item/food/grown/coconut/split, 2, 20, screentip_verb = "Split")

/obj/item/food/grown/split_coconut
	name = "split coconut"
	icon_state = "coconut_split"
	desc = "A coconut that has been split in half, a testament to mans mastery over nature."
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/grown/coconut/split/Initialize(mapload)
	. = ..()
	reagents.flags |= OPENCONTAINER

/obj/item/reagent_containers/beaker/coconut
	name = "coconut shell"
	icon_state = "coconut_shell"
	desc = "A coconut shell, perfect for holding liquids."
	volume = 50
	max_volume = 50
	base_reagents = list(/datum/reagent/consumable/coconut_milk = 50)

