/// The subsystem used to tick [/datum/component/slimed] instances.
PROCESSING_SUBSYSTEM_DEF(Slime)
	name = "Slime"
	priority = FIRE_PRIORITY_SLIME
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
