pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
tsize=3

function _init()
   terrain={}
   for x=0,tsize-1 do
      terrain[x]={}
   end
   corner(0,0)
   corner(0,tsize-1)
   corner(tsize-1,0)
   corner(tsize-1,tsize-1)
   fill(0,0,tsize)
end

function fill(x,y,size)
   printh("fill: "..x.." "..y.." "..size)
   local s=flr(size/2)
   printh("   s="..s)
   diamond(x,y,x+s,y+s,size)
   square(x,y,x+s,y,size)
   square(x,y,x,y+s,size)
   square(x,y,x+s,y+s+s,size)
   square(x,y,x+s+s,y+s,size)
   if size>3 then
      fill(x,y,s)
      fill(x+s,y,s)
      fill(x,y+s,s)
      fill(x+s,y+s,s)
   end
end

function diamond(x,y,dx,dy,size)
   printh("diamond: "..x.." "..y.." "..dx.." "..dy.." "..size)
   local avg=(
            terrain[x][y]+
            terrain[x][y+size-1]+
            terrain[x+size-1][y]+
            terrain[x+size-1][y+size-1]
         )/4
   local delta=(rnd(0.5)-0.25)*(size/tsize)
   terrain[dx][dy]=avg+delta
end

function square(x,y,sx,sy,size)
   printh("square: "..x.." "..y.." "..sx.." "..sy.." "..size)
   local s=flr(size/2)
   printh("   s="..s)
   printh_terrain()

   local w1=wrap(x,y,sx+s,sy,size)
   local w2=wrap(x,y,sx-s,sy,size)
   local w3=wrap(x,y,sx,sy+s,size)
   local w4=wrap(x,y,sx,sy-s,size)
   local avg=(w1+w2+w3+w4)/4
   local delta=(rnd(0.5)-0.25)*(size/tsize)
   terrain[sx][sy]=avg+delta
end

function wrap(x,y,wx,wy,size)
   printh("wrap: "..x.." "..y.." "..wx.." "..wy.." "..size)
   local t=tsize-1
   if wx>x and wx-t>x then
      wx=wx-t
   end
   if wx<x then
      wx=wx+t
   end
   if wy>y and wy-t>y then
      wy=wy-t
   end
   if wy<y then
      wy=wy+t
   end
   printh("   wx="..wx.." wy="..wy)
   printh("   =>"..terrain[wx][wy])
   return terrain[wx][wy]
end

function corner(x,y)
   printh("corner: "..x.." "..y)
   srand(x*10000+y)
   terrain[x][y]=rnd(0.5)+0.25
end

function printh_terrain()
   printh("terrain:\n")
   for x=0,tsize-1 do
      for y=0,tsize-1 do
         local t=terrain[x][y]
         if not t then
            t="nil"
         end
         printh("x="..x.." y="..y.." "..t)
      end
      printh("")
   end
end
