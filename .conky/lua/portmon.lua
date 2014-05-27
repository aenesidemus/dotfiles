--[[

Conky Lua scripting example

Copyright (c) 2009 Brenden Matthews, Toni Spets, all rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This is a helper script to graph the output of tcp_portmon count

Note: The <graph options> portions below can be omitted (see the Conky
documentation for $lua_graph for details).

in your conkyrc, use something like so:

lua_load ~/portmon_graph.lua
...
TEXT
...
${lua_graph portmon_bittorrent_count <graph options>}
]]

do
	local function portmon_count(pstart, pend)
		return tonumber(conky_parse('${tcp_portmon ' .. pstart .. ' ' .. pend .. ' count}'))
	end

	-- returns the port count for bittorrent (assuming a typical port range of 6881-6999)
	function conky_portmon_bittorrent_count()
		local port_start, port_end = '6881', '6999' -- starting and ending ports
		return portmon_count(port_start, port_end)
	end

	-- returns the port count for p2o
	function conky_portmon_p2p_count()
		local port_start, port_end = '3030', '3030' -- starting and ending ports
		return portmon_count(port_start, port_end)
	end

	-- returns the port count for http
	function conky_portmon_http_count()
		local port_start, port_end = '80', '80' -- starting and ending ports
		return portmon_count(port_start, port_end)
	end
end
