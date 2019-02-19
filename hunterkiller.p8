pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
scale=7
elevation=0.3

cur_x=63
cur_y=63

function _init()
   tsize=2^scale+1
   terrain={}
   for x=0,tsize-1 do
      terrain[x]={}
   end
   tile(0,0)
   printh("terrain complete")
end

function _update()
   if btnp(0) and cur_x>0 then
      cur_x-=1
   end
   if btnp(1) and cur_x<127 then
      cur_x+=1
   end
   if btnp(2) and cur_y>0 then
      cur_y-=1
   end
   if btnp(3) and cur_y<127 then
      cur_y+=1
   end
end

function _draw()
   rectfill(0,0,127,127,0)
   for x=0,tsize-1 do
      for y=0,tsize-1 do
         if terrain[x][y]>elevation then
            pset(x,y,5)
         else
            pset(x,y,12)
         end
      end
   end
   pset(cur_x,cur_y,8)
   print(terrain[cur_x][cur_y],0,0,8)
end

function tile(x,y)
   local t=tsize-1
   corner(x,y)
   corner(x,y+t)
   corner(x+t,y)
   corner(x+t,y+t)
   local s=flr(tsize/2)
   diamond(x,y,x+s,y+s,tsize)
   fill(x,y,tsize)
end

function fill(x,y,size)
   --printh("fill: "..x.." "..y.." "..size)
   local s=flr(size/2)
   --printh("   s="..s)
   square(x,y,x+s,y,size)
   square(x,y,x,y+s,size)
   square(x,y,x+s,y+s+s,size)
   square(x,y,x+s+s,y+s,size)
   if size>3 then
      local t=flr(s/2)
      diamond(x,y,x+t,y+t,s+1)
      diamond(x,y,x+t+s,y+t,s+1)
      diamond(x,y,x+t,y+t+s,s+1)
      diamond(x,y,x+t+s,y+t+s,s+1)
      fill(x,y,s+1)
      fill(x+s,y,s+1)
      fill(x,y+s,s+1)
      fill(x+s,y+s,s+1)
   end
end

function diamond(x,y,dx,dy,size)
   --printh("diamond: "..x.." "..y.." "..dx.." "..dy.." "..size)
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
   --printh("square: "..x.." "..y.." "..sx.." "..sy.." "..size)
   local s=flr(size/2)
   --printh("   s="..s)
   --printh_terrain()

   local w1=wrap(x,y,sx+s,sy,size)
   local w2=wrap(x,y,sx-s,sy,size)
   local w3=wrap(x,y,sx,sy+s,size)
   local w4=wrap(x,y,sx,sy-s,size)
   local avg=(w1+w2+w3+w4)/4
   local delta=(rnd(0.5)-0.25)*(size/tsize)
   terrain[sx][sy]=avg+delta
end

function wrap(x,y,wx,wy,size)
   --printh("wrap: "..x.." "..y.." "..wx.." "..wy.." "..size)
   local t=size-1
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
   --printh("   wx="..wx.." wy="..wy)
   --printh("   =>"..terrain[wx][wy])
   return terrain[wx][wy]
end

function corner(x,y)
   --printh("corner: "..x.." "..y)
   srand(x*10000+y)
   terrain[x][y]=rnd(0.5)+0.25
end

function printh_terrain()
   --printh("terrain:\n")
   for x=0,tsize-1 do
      for y=0,tsize-1 do
         local t=terrain[x][y]
         if not t then
            t="nil"
         end
         --printh("x="..x.." y="..y.." "..t)
      end
      --printh("")
   end
end
