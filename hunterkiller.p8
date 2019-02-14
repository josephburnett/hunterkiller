pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
tsize=128

function _init()
   terrain={}
   for x=0,127 do
      terrain[x]={}
   end
   corner(0,0)
   corner(0,tsize)
   corner(tsize,0)
   corner(tsize,tsize)
   fill(0,0,tsize)
end

function fill(x,y,size)
   local s=size/2
   diamond(x,y,x+s,y+s,size)
   square(x,y,x+s,y,size)
   square(x,y,x,y+s,size)
   square(x,y,x+size,y+s)
   square(x,y,x+s,y+size)
   if size>3 then
      fill(x,y,s)
      fill(x+s,y,s)
      fill(x,y+s,s)
      fill(x+s,y+s,s)
   end
end

function diamond(x,y,dx,dy,size)
   local avg=(
            terrain[x][y]+
            terrain[x][y+size]+
            terrain[x+size][y]+
            terrain[x+size][y+size]
         )/4
   local delta=(rnd(0.5)-0.25)*(size/tsize)
   terrain[dx][dy]=avg+delta
end

function square(x,y,sx,sy,size)
   local s=size/2
   local avg=(
            wrap(x,y,sx+s,sy,size)+
            wrap(x,y,sx-s,sy,size)+
            wrap(x,y,sx,sy+s,size)+
            wrap(x,y,sy,sy-s,size)
         )/4
   local delta=(rnd(0.5)-0.25)*(size/tsize)
   terrain[sx][sy]=avg+delta
end

function wrap(x,y,wx,wy,size)
   if wx>x and (wx-size)>x then
      wx=wx-size
   end
   if wx<x and (wx+size)<x then
      wx=wx+size
   end
   if wy>y and (wy-size)>y then
      wy=wy-size
   end
   if wy<y and (wy+size)<y then
      wy=wy+size
   end
   return terrain[wx][wy]
end

function corner(x,y)
   srand(x*10000+y)
   terrain[x][y]=rnd(0.5)+0.25
end
