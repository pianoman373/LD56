pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[main]--
-->8
--[utils]--


--collision with list of entities
function col_list(hb, list)
	local r = {}
	for e in all(list) do
		if col(hb, e) then
			add(r, e)
		end
	end
	return r
end

--collision with dict of entities
function col_dict(hb, dict)
	local r = {}
	for k,e in pairs(dict) do
		if col(hb, e) then
			add(r, {k, e})
		end
	end
	return r
end

--draw hitbox
function draw_hb(o, col)
	rect(o.x, o.y, o.x+o.w-1, 
		o.y+o.h-1, col or 15)
end

--move entity with collision
function move(e)
	local col_x = false
	local col_y = false
	
	e.x += e.dx
	if map_col(e) then
		e.x -= e.dx
		e.dx = 0
		col_x = true
	end
	
	e.y += e.dy
	if map_col(e) then
		e.y -= e.dy
		e.dy = 0
		col_y = true
	end
	
	return col_x, col_y
end

--entity collision
function col(a, b)
	return a.x < b.x+(b.w or 8)-1
		and a.x+(a.w or 8)-1 > b.x
		and a.y < b.y+(b.h or 8)-1
		and a.y+a.h-1 > (b.y or 8)
end

function tile_col(o, x, y)
	local t = mget(x, y)

	local ret = false
	if fget(t, 0) then
		ret = ret or col(o, {x=x*8 + 6, y=y*8, w=2, h=8})
	end
	if fget(t, 1) then
		ret = ret or col(o, {x=x*8, y=y*8 + 6, w=8, h=2})
	end
	if fget(t, 2) then
		ret = ret or col(o, {x=x*8, y=y*8, w=2, h=8})
	end
	if fget(t, 3) then
		ret = ret or col(o, {x=x*8, y=y*8, w=8, h=2})
	end

	return ret
end

--map collision
function map_col(o)
	local x1 = flr(o.x/8)
	local x2 = flr((o.x+o.w-1)/8)
	local y1 = flr(o.y/8)
	local y2 = flr((o.y+o.h-1)/8)
	x1=mid(0,x1,128)
	x2=mid(0,x2,128)
	y1=mid(0,y1,128)
	y2=mid(0,y2,128)

	return tile_col(o, x1, y1) or tile_col(o, x1, y2) or tile_col(o, x2, y1) or tile_col(o, x2, y2)

	-- local a = mget(x1, y1)
	-- local b = mget(x1, y2)
	-- local c = mget(x2, y1)
	-- local d = mget(x2, y2)
	
	-- return fget(a, f) or fget(b, f)
	-- 	or fget(c, f) or fget(d, f)
	-- 	or x1 < 0 or y1 < 0
end

--distance
function dist(dx,dy)
  local ang=atan2(dx,dy)
  return dx*cos(ang)+dy*sin(ang)
end

--normalize
function nrm(x, y)
	local a = atan2(x, y)
	return cos(a), sin(a)
end

--lerp between array values
function tlerp(t, x)
	local x = mid(0.0001, x, 0.9999)
	return t[flr(x*#t)+1]	
end

--set whole palette to color
function filt(c)
	pal({[0]=c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c}, 0)
end

--outlined print
function oprint(str, x, y, col, otl_col)
		print(str, x-1, y, otl_col or 0)
		print(str, x+1, y, otl_col or 0)
		print(str, x, y-1, otl_col or 0)
		print(str, x, y+1, otl_col or 0)
		
		print(str, x-1, y-1, otl_col or 0)
		print(str, x+1, y+1, otl_col or 0)
		print(str, x+1, y-1, otl_col or 0)
		print(str, x-1, y+1, otl_col or 0)
		
		
		print(str, x, y, col or 7)
end

--outlined sprite
function ospr(c, n, x, y, w, h, flip_x, flip_y)
	w = w or 1
	h = h or 1
	flip_x = flip_x or false
	flip_y = flip_y or false
	
	pal({[0]=c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c}, 0)
	
	spr(n, x-1, y, w, h, flip_x, flip_y)
	spr(n, x+1, y, w, h, flip_x, flip_y)
	spr(n, x, y-1, w, h, flip_x, flip_y)
	spr(n, x, y+1, w, h, flip_x, flip_y)

	pal(0)
	
	spr(n, x, y, w, h, flip_x, flip_y)
end

-- from https://www.lexaloffle.com/bbs/?tid=38548
function pd_rotate(x,y,rot,mx,my,w,flip,scale)
	scale=scale or 1
	w*=scale*4

	local cs, ss = cos(rot)*.125/scale,sin(rot)*.125/scale
	local sx, sy = mx+cs*-w, my+ss*-w
	local hx = flip and -w or w

	local halfw = -w
	for py=y-w, y+w do
		tline(x-hx, py, x+hx, py, sx-ss*halfw, sy+cs*halfw, cs, ss)
		halfw+=1
	end
end

function onscreen(e, pad)
	local hb = {
		x=camx-pad,
		y=camy-pad,
		w=128+pad,
		h=128+pad
	}
	
	return col(e, hb)
end

debug_log = ""

dbg = {}
function dbg.tstr(t, indent)
 indent = indent or 0
 local indentstr = ''
 for i=0,indent do
  indentstr = indentstr .. ' '
 end
 local str = ''
 for k, v in pairs(t) do
  if type(v) == 'table' then
   str = str .. indentstr .. k .. '\n' .. debug.tstr(v, indent + 1) .. '\n'
  else
   str = str .. indentstr .. tostr(k) .. ': ' .. tostr(v) .. '\n'
  end
 end
  str = sub(str, 1, -2)
 return str
end

function dbg.draw(col)
	print(debug_log, 1, 1, 0)
	print(debug_log, 0, 0, col)
end

function dbg.log(msg)
	debug_log = debug_log..tostr(msg).."\n"
end

function dbg.clear()
	debug_log = ""
end

--toggles between 0,1 with
--period and offset
function isin2(p,o)
	return flr(sin(t*p+(o or 0))*0.5+1)
end

--toggles between 0,1,2 with
--period and offset
function isin3(p,o)
	return flr(sin(t*p+(o or 0))+0.5)
end

dither_pat={
  0b1111111111111111,
  0b0111111111111111,
  0b0111111111011111,
  0b0101111111011111,
  0b0101111101011111,
  0b0101101101011111,
  0b0101101101011110,
  0b0101101001011110,
  0b0101101001011010,
  0b0001101001011010,
  0b0001101001001010,
  0b0000101001001010,
  0b0000101000001010,
  0b0000001000001010,
  0b0000001000001000
}
--gradient rect
function gradrect(x0,y0,x1,y1,col1, col2)
 local col = col1 + (col2<<4)
 local y=y0
 while y <= y1 do
 	local t=(y-y0)/(y1-y0)
 	fillp(tlerp(dither_pat,t))
 
  rectfill(x0, y, x1, y, col)
  y += 1
 end
 
 fillp(█)
end

function mono(c, idx)
	if (not c) then
		palt()
		pal(0)
		return
	end
	local p = {
		{[0]=0, c, 0, c, 0, c, 0, c, 0, c, 0, c, 0, c, 0, c},
		{[0]=0, 0, c, c, 0, 0, c, c, 0, 0, c, c, 0, 0, c, c},
		{[0]=0, 0, 0, 0, c, c, c, c, 0, 0, 0, 0, c, c, c, c},
		{[0]=0, 0, 0, 0, 0, 0, 0, 0, c, c, c, c, c, c, c, c},
	}
	local t = {
		0b1010101010101010,
		0b1100110011001100,
		0b1111000011110000,
		0b1111111100000000,
	} 
	pal(p[idx+1], 0)
	palt(t[idx+1])
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
