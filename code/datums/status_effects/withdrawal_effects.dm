/datum/status_effect/withdrawal
	name = "drug withdrawal"
	id = "drug_withdrawal"
	duration = -1
	///the appropriate moodlet applied by this type of withdrawal.
	var/moodlet_type = /datum/mood_event/withdrawal_medium
	///this var stores how many ticks we have been in withdrawal.
	var/addiction_ticks = 0

/datum/status_effect/withdrawal/tick()
	addiction_ticks++
	if(!owner.mind)
		qdel(src)
		return
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, [id], moodlet_type)

/datum/status_effect/withdrawal/stimulant
	name = "stimulant withdrawal"
	id = "stim_withdrawl"

/datum/status_effect/withdrawal/opioid
	name = "opioid withdrawal"
	id = "opioid_withdrawl"

/datum/status_effect/withdrawal/alcohol
	name = "alcohol withdrawal"
	id = "alcohol_withdrawl"

/datum/status_effect/withdrawal/alcohol/tick()
	. = ..()
	if(addiction_ticks > 30)
		owner.Jitter(10)
		if(prob(4))
			to_chat(M, "<span class='warning'>[pick("You could really go for a drink right now.", "You wonder if the bar is still open.", "You feel anxious.")]</span>")

	if(addiction_ticks > 60)
		M.adjust_bodytemperature(6 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, M.get_body_temp_normal() + 40)
		owner.Jitter(20)
		if(prob(3))
			to_chat(M, "<span class='warning'>[pick("You feel hot.", "You feel like you're burning.", "You feel droplets of sweat pour from your body.")]</span>")

	if(addiction_ticks > 90)
		owner.Jitter(30)
		owner.hallucinate

	if(addiction_ticks > 180)
		owner.Jitter(50)
		M.adjust_bodytemperature(12 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, M.get_body_temp_normal() + 80)
		if(prob(5))
			owner.add_status_effect(STATUS_EFFECT_STROKE)

/datum/status_effect/withdrawal/hallucinogen
	name = "hallucinogen withdrawal"
	id = "hallucinogen_withdrawl"

///For maintenance drugs proper and other dirty drugs.
/datum/status_effect/withdrawal/maint
	name = "maintenance withdrawal"
	id = "maintenance_withdrawl"


