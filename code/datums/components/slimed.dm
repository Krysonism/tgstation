///How many units of reagents  we transfer / expose per slimed limb each second, reduced by bio armour if it is on a worn item instead.
#define BODYSLIME_REAGENT_RATE 2

/**
 * Component representing slime applied to an object.
 * Must be attached to an atom.
 * Processes, repeatedly transfering reagents to the target.
 */
/datum/component/slimed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///reagent holder to store slimne reagents
	var/datum/reagents/slime_reagents

	/// Default slime  overlay, do not touch
	//var/static/mutable_appearance/default_slime_overlay = mutable_appearance('icons/effects/effects.dmi', "object_slimed")

	/// The proc used to handle the parent [/atom] when processing.
	var/datum/callback/process_effect


/datum/component/slimed/Initialize(datum/reagents/slime_source_reagents, slime_amount = 10)
	. = ..()
	//create reagent holder, hopefully the large volume won't cause problems.
	slime_reagents = new(1000)
	//seed with reagents
	slime_source_reagents.copy_to(slime_reagents, slime_amount)

/datum/component/slimed/RegisterWithParent()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	//determine which type of processing to use
	if(isbasicmob(parent))
		process_effect = CALLBACK(src, PROC_REF(process_basicmob))
	else
		if(!isitem(parent))
			return COMPONENT_INCOMPATIBLE

		if(isbodypart(parent))
			var/obj/item/bodypart/bodypart_parent = parent
			if(bodypart_parent.owner)
				process_effect = CALLBACK(src, PROC_REF(process_bodypart))
				RegisterSignal(parent, COMSIG_BODYPART_REMOVED, PROC_REF(on_detach))
			else
				process_effect = CALLBACK(src, PROC_REF(process_item))
				RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(on_attach))
		else
			process_effect = CALLBACK(src, PROC_REF(process_item))

	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(on_expose_reagent))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	var/atom/atom_parent = parent
	atom_parent.update_appearance()
	START_PROCESSING(SSslime, src)

/datum/component/slimed/UnregisterFromParent()
	STOP_PROCESSING(SSslime, src)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXPOSE_REAGENT,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_BODYPART_ATTACHED,
		COMSIG_BODYPART_REMOVED,
	))
	process_effect = null
	var/atom/atom_parent = parent
	if(!QDELETED(atom_parent))
		atom_parent.update_appearance()

/datum/component/slimed/InheritComponent(datum/component/C, i_am_original, datum/reagents/slime_source_reagents, slime_amount)
	if(!slime_source_reagents || !slime_reagents || !i_am_original)
		return
	slime_source_reagents.copy_to(slime_reagents, slime_amount)

/datum/component/slimed/Destroy(force)
	QDEL_NULL(slime_reagents)
	return ..()

/datum/component/slimed/process(seconds_per_tick)
	process_effect?.InvokeAsync(seconds_per_tick)

///Handle processing for bodypart items attached to a carbon
/datum/component/slimed/proc/process_bodypart(seconds_per_tick)
	var/obj/item/bodypart/bodypart_parent = parent
	var/mob/living/carbon/slimed_grandpa = parent.owner

	if(!slimed_grandpa) //this shouldn't happen, but just to be sure
		return on_detach(bodypart_parent)

	//only organic limbs siphon reagents into the bloodstream
	if(bodypart_parent.bodytype & BODYTYPE_ORGANIC)
		slime_reagents.trans_to(slimed_grandpa, amount = BODYSLIME_REAGENT_RATE * seconds_per_tick, methods = PATCH) //active ingredient + polymer + solvent + transdermal application = PATCH
	else
		slime_reagents.expose(animal_parent, BODYSLIME_REAGENT_RATE * seconds_per_tick)
		slime_reagents.remove_all(BODYSLIME_REAGENT_RATE * seconds_per_tick)

	if(slime_reagents.total_volume <= 0)
		slimed_grandpa.visible_message(span_notice("The slime covering [slimed_grandpa.name]'s [bodypart_parent.name] dissolves."), span_nicegreen("The slime covering your [bodypart_parent.name] dissolves."))
		qdel(src)

///Handle processing for other items like clothing and unattached bodyparts
/datum/component/slimed/proc/process_item(seconds_per_tick)

///Handle processing for basic animals.
/datum/component/slimed/proc/process_basicmob(seconds_per_tick)
	if(!isbasicmob(parent))
		qdel(src) //:mistake:
		return

	var/living/basic/animal_parent = parent
	//Larger mobs have greater surface area to make contact with the slime.
	var/mob_reagent_amount = 1 + animal_parent.mob_size * 4

	//if they have reagents we transfer, if not we expose.
	if(!slime_reagents.trans_to(animal_parent, amount = mob_reagent_amount, methods = PATCH))
		slime_reagents.expose(animal_parent, mob_reagent_amount)
		slime_reagents.remove_all(mob_reagent_amount)

	if(slime_reagents.total_volume <= 0)
		animal_parent.to_chat(span_nicegreen("The slime covering your body dissolves."))
		qdel(src)

/datum/component/slimed/proc/on_clean(atom/source, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & CLEAN_TYPE_ACID))
		return NONE
	qdel(src)
	return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/datum/component/slimed/proc/on_update_overlays()

/datum/component/slimed/proc/on_expose_reagent()

/datum/component/slimed/proc/on_detach()
	SIGNAL_HANDLER
	process_effect = CALLBACK(src, PROC_REF(process_item))
	UnregisterSignal(parent, COMSIG_BODYPART_REMOVED)
	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(on_attach))

/datum/component/slimed/proc/on_attach()

#undef BODYSLIME_REAGENT_RATE
