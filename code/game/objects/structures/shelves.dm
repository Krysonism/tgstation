/obj/structure/shelves
	name = "shelves"
	desc = "A set of shelves, seems to be constructed just sturdily enough to not collapse in on itself..."
	icon = 'icons/obj/shelves.dmi'
	icon_state = "shelves_map3"
	base_icon_state = "shelves"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE | LETPASSTHROW
	layer = TABLE_LAYER
	obj_flags = CAN_BE_HIT
	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 3)
	max_integrity = 100
	integrity_failure = 0.33
	///How many shelves do we have, we should logically have at least one. But if we have too  many, the sprite might get too tall...
	var/shelf_count = 3
	///How many pixels do we offset the shelf overlays beyond the first.
	var/shelf_offset_height = 7
	///how many pixels from the bottom is the exclusive domain of the base shelf. clicks above this will try to place the item on a higher shelf if there is one.
	var/base_shelf_capture_height = 14

/obj/structure/shelves/Initialize(mapload)
	. = ..()
	icon_state = base_icon_state
	update_appearance()

/obj/structure/shelves/update_overlays()
	. = ..()

	. += mutable_appearance(icon, "[base_icon_state]_shadow")

	if(shelf_count <= 1)
		return

	for(var/i in 1 to shelf_count - 1)

		var/mutable_appearance/shelf_overlay = mutable_appearance(icon, "[base_icon_state]_shelf")
		shelf_overlay.pixel_z = 7 * (i - 1)
		shelf_overlay.layer = TABLE_LAYER + 0.01 * i
		. += shelf_overlay

		var/mutable_appearance/shelf_shadow = mutable_appearance(icon, "[base_icon_state]_shelf_shadow")
		shelf_shadow.pixel_z = 7 * (i - 1)
		shelf_shadow.layer = TABLE_LAYER + 0.01 * i
		shelf_shadow.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		. += shelf_shadow

/obj/structure/shelves/proc/shelves_place_act(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.item_flags & ABSTRACT)
		return NONE
	if(!user.transferItemToLoc(tool, drop_location(), silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	// Items are centered by default, but we move them if click ICON_X and ICON_Y are available
	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		// Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		tool.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X*0.5), ICON_SIZE_X*0.5)
		tool.pixel_z = text2num(LAZYACCESS(modifiers, ICON_Y)) - 16
		world.log << "click height:[text2num(LAZYACCESS(modifiers, ICON_Y))]"
		tool.layer = TABLE_LAYER + 0.001
		for(var/i in 1 to shelf_count - 1)
			var/click_height = text2num(LAZYACCESS(modifiers, ICON_Y))
			if(click_height >= base_shelf_capture_height + shelf_offset_height * (i - 1))
				tool.layer +=  0.01
				world.log << "click height:[tool.layer] i: [i]"
	return ITEM_INTERACT_SUCCESS


/obj/structure/shelves/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .

	if(!user.combat_mode || (tool.item_flags & NOBLUDGEON))
		return shelves_place_act(user, tool, modifiers)

	return NONE

/obj/structure/shelves/short
	icon_state = "shelves_map2"
	shelf_count = 2

/obj/structure/shelves/tall_experimental
	shelf_count = 5

/obj/structure/shelves/supertall_experimental
	shelf_count = 7
