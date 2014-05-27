local function components_to_color(r, g, b)
	-- Take the RGB components r, g, b, and return an RGB integer
	return ((math.floor(r + 0.5) * 0x10000) + (math.floor(g + 0.5) * 0x100) + math.floor(b + 0.5)) % 0xffffff -- no bit shifting operator in Lua afaik
end


local function color_to_components(color)
	-- Take the RGB components r, g, b, and return an RGB integer
	return (color / 0x10000) % 0x100, (color / 0x100) % 0x100, color % 0x100
end


-- аргументы: текущее значение, цвета нижней границы, середины и верхней границы, значения нижней границы, середины и верхней границы
local function two_colorize(arg, cold, norm, hot, min, mid, max)
	local r_hot, g_hot, b_hot = color_to_components(hot)
	local r, g, b = color_to_components(norm)
	local r_cold, g_cold, b_cold = color_to_components(cold)
	local color = 0
	if arg ~= nil then
		if arg > mid then
			if arg > max then arg = max end
			r = r + ((r_hot - r) / max) * arg
			b = b + ((b_hot - b) / max) * arg
			g = g + ((g_hot - g) / max) * arg
		else
			if arg < min then arg = min end
			r = r + ((r_cold - r) / min) * arg
			b = b + ((b_cold - b) / min) * arg
			g = g + ((g_cold - g) / min) * arg
		end
	end
	color = components_to_color(r, g, b)
	return string.format("${color #%06x}", color)
end


-- аргументы: текущее значение, цвета нижней и верхней границ, значения нижней и верхней границ
local function one_colorize(arg, norm, hot, min, max)
	local r_hot, g_hot, b_hot = color_to_components(hot)
	local r, g, b = color_to_components(norm)
	local color = 0
	if arg ~= nil and arg > min then
		if arg > max then arg = max end
		r = r + ((r_hot - r) / max) * arg
		b = b + ((b_hot - b) / max) * arg
		g = g + ((g_hot - g) / max) * arg
	end
	color = components_to_color(r, g, b)
	return string.format("${color #%06x}", color)
end


-- для вызова прописать в conkyrc
-- ${lua_parse weather_color RSXX0123 HT} # на текущий день
-- ${lua_parse weather_color RSXX0123 HT 1} # на следующий день
-- аргументы: id города, тип данных (HT или LT), на какой день (пусто - сегодня, 1 - завтра..)
function conky_weather_color(loc, dt, st) -- RSXX0123
local upd = conky_parse('${updates}')
	if st ~= nil then
		local temp = tonumber(conky_parse('${exec conkyForecast -l ' .. loc .. ' -u -x -d ' .. dt .. ' -s ' .. st .. '}'))
		return two_colorize(temp, 0x005478, 0xc8c8c8, 0xd33100, -40, 0, 40) .. temp .. '°${color0}'
	else
		local temp = tonumber(conky_parse('${exec conkyForecast -l ' .. loc .. ' -u -x -d ' .. dt .. '}'))
		return two_colorize(temp, 0x005478, 0xc8c8c8, 0xd33100, -40, 0, 40) .. temp .. '°${color0}'
	end
end


-- ${lua_parse top_cpu_color 1} # ничего не выводит - только меняет цвет дальнейшего текста
-- аргумент - номер процесса в топе
function conky_top_cpu_color(arg)
	local str = conky_parse(string.format('${top cpu %i}', tonumber(arg)))
	local cpu = tonumber(string.match(str, '(%d+%.%d+)'))
	return one_colorize(cpu, 0xc8c8c8, 0xd33100, 20, 80)
end
