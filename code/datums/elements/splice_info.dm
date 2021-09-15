/// This element adds some examine text onto mobs with spliced cell lines.
/datum/element/splice_info
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	/// The name of the cell line
	var/cell_line_name
	/// A string with an explanation of the splice
	var/cell_line_splice_desc

/datum/element/splice_info/Attach(atom/source, cell_line_name, cell_line_splice_desc)
	. = ..()
	if (!istype(source))
		return ELEMENT_INCOMPATIBLE

	src.cell_line_name = cell_line_name
	src.cell_line_splice_desc = cell_line_splice_desc

	RegisterSignal(source, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/element/splice_info/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)

/datum/element/splice_info/proc/on_examine(atom/source, mob/user, list/examine_texts)
	examine_texts += span_notice("Partial [cell_line_name] chimaerism detected: [cell_line_splice_desc]")

