/datum/component/sentience_touch
	var/being_offered = FALSE

/datum/component/sentience_touch/Initialize(creator)
	. = ..()
	if(!isanimal(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/neuron_activate)

/datum/component/sentience_touch/Destroy(force, silent)
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

/datum/component/sentience_touch/proc/neuron_activate(mob/living/simple_animal/clever_animal, mob/living/toucher)
	if(being_offered)
		return

	being_offered = TRUE
	clever_animal.balloon_alert_to_viewers("rapid neurogenesis triggered")
	clever_animal.Unconscious(20)

	var/list/candidates = pollCandidatesForMob("Do you want to play as [clever_animal.name]?", ROLE_SENTIENCE, ROLE_SENTIENCE, 50, clever_animal, POLL_IGNORE_SENTIENCE_POTION) // see poll_ignore.dm

	if(!candidates.len)
		clever_animal.balloon_alert_to_viewers("neurogenic factors decayed")
		being_offered = FALSE
		return

	var/mob/dead/observer/lucky_ghost = pick(candidates)
	clever_animal.key = lucky_ghost.key
	clever_animal.mind.enslave_mind_to_creator(toucher)
	clever_animal.balloon_alert_to_viewers("sentience developed")
	clever_animal.sentience_act()
	clever_animal.copy_languages(toucher)
	var/parent_role
	switch(toucher.gender)
		if(FEMALE)
			parent_role = "mother"
		if(MALE)
			parent_role = "father"
		else
			parent_role = "parent"

	to_chat(clever_animal, span_nicegreen("All at once it makes sense: you know what you are and who you are! Self awareness is yours!"))
	to_chat(clever_animal, span_userdanger("You are grateful to have been brought into this world by your [parent_role] [toucher.real_name]. Honor your [parent_role] and follow their instructions."))
	qdel(src)
