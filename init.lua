
wconfig = {}
wconfig.modname = core.get_current_modname()
wconfig.modpath = core.get_modpath(wconfig.modname)

function wconfig.log(lvl, msg)
	if not msg then
		msg = lvl
		lvl = nil
	end

	msg = "[" .. wconfig.modname .. "] " .. msg
	if not lvl then
		core.log(msg)
	else
		core.log(lvl, msg)
	end
end
