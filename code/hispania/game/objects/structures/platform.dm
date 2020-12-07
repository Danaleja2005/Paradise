//Platform Code by Danaleja2005

/obj/structure/platform
	name = "Metal Platform"
	icon = 'icons/hispania/obj/platform.dmi'
	icon_state = "metal"
	desc = "A metal platform"
	flags = ON_BORDER
	anchored = FALSE
	climbable = TRUE
	layer = ABOVE_OBJ_LAYER
	max_integrity = 200
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 50, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	var/corner = FALSE
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amount = 10
	var/decon_speed

/obj/structure/platform/proc/CheckLayer() // Para saber si el icono debe ir encima del mob o no
	if(dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else if(corner && dir == SOUTH)
		layer = ABOVE_MOB_LAYER

/obj/structure/platform/setDir(newdir)
	. = ..()
	CheckLayer()

/obj/structure/platform/New()
		..()
		if(corner)
			decon_speed = 30
			density = FALSE
		else
			decon_speed = 40
	CheckLayer()

/obj/structure/platform/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The [src] is [anchored == TRUE ? "screwed" : "unscrewed"] to the floor.</span>"

/obj/structure/platform/verb/rotate()
	set name = "Rotate Platform Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>[src] cannot be rotated while it is screwed to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, 90)

	setDir(target_dir)
	air_update_turf(1)
	add_fingerprint(usr)
	return TRUE

// Construcción

/obj/structure/platform/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	to_chat(user, "<span class='notice'>You begin [anchored == TRUE ? "unscrewing" : "screwing"] [src] to the floor.</span>")
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You [anchored == TRUE ? "unscrew" : "screw"] [src] to the floor.</span>")
	anchored = !anchored

/obj/structure/platform/wrench_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(anchored)
		to_chat(user, "<span class='notice'>You cannot disassemble [src] unscrew it firts!.</span>")
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume))
		return
	var/obj/item/stack/sheet/G = new material_type(user.loc, material_amount)
	G.add_fingerprint(user)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1) 
	TOOL_DISMANTLE_SUCCESS_MESSAGE 
	qdel(src)


/obj/structure/platform/CheckExit(atom/movable/O, turf/target)
	if(corner)
		return !density
	if(O && O.throwing)
		return TRUE
	if(((flags & ON_BORDER) && get_dir(loc, target) == dir))
		return FALSE
	else
		return TRUE

/obj/structure/platform/CanPass(atom/movable/mover, turf/target)
	if(corner)
		return !density
	if(mover && mover.throwing)
		return TRUE
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags & ON_BORDER) && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return TRUE
	if(!(flags & ON_BORDER) || get_dir(loc, target) == dir)
		return FALSE
	else
		return TRUE

/obj/structure/platform/CanAtmosPass()
	return TRUE

// Plataformas de otros tipos

/obj/structure/platform/reinforced
	name = "Reinforced Plasteel Platform"
	desc = "A robust platform made of plasteel, more resistance for hazard sites"
	icon_state = "metal2"
	material_type = /obj/item/stack/sheet/plasteel
	max_integrity = 300
	armor = list("melee" = 20, "bullet" = 30, "laser" = 30, "energy" = 100, "bomb" = 50, "bio" = 0, "rad" = 75, "fire" = 100, "acid" = 100)

///Corners

/obj/structure/platform/corner
	name = "Metal Platform Corner"
	icon_state = "metalcorner"
	desc = "A metal platform corner"
	corner = TRUE
	material_amount = 5

/obj/structure/platform/reinforced/corner 
	name = "Reinforced Platform Corner"
	desc = "A robust platform corner made of plasteel, more resistance for hazard sites"
	icon_state = "metalcorner2"
	corner = TRUE
	material_amount = 5

/*Plataformas para el Map
Tan simple como que no hubo forma de hacer 
que las plataformas del mapa iniciaron anchored y 
las de construccion iniciaran unanchored*/

/obj/structure/platform/map
	anchored = TRUE

/obj/structure/platform/corner/map
	anchored = TRUE

/obj/structure/platform/metal2/map
	anchored = TRUE

/obj/structure/platform/metal2/corner/map
	anchored = TRUE
