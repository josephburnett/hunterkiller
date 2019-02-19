pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
scale=7
elevation=0.5341
salt=4
worldsize=2

function delta(size)
   --return (rnd(0.5)-0.25)*(size/tsize)
   return flr((rnd(0.1)-0.05)*100)/100
   --return rnd(0.1)-0.05
end

cur_x=64
cur_y=64

function _init()
   tsize=2^scale+1
   terrain={}
   for x=0,tsize*worldsize do
      terrain[x]={}
   end
   for x=0,worldsize-1 do
      for y=0, worldsize-1 do
         tile(x*tsize,y*tsize)
      end
   end
   printh("terrain complete")
end

function _update()
   local lower=tsize/2+1
   local upper=tsize*worldsize-tsize
   if btnp(0) and cur_x>lower then
      cur_x-=1
   end
   if btnp(1) and cur_x<upper then
      cur_x+=1
   end
   if btnp(2) and cur_y>lower then
      cur_y-=1
   end
   if btnp(3) and cur_y<upper then
      cur_y+=1
   end
   if btnp(4) and elevation>0 then
      elevation-=0.001
   end
   if btnp(5) and elevation<1 then
      elevation+=0.001
   end
end

function _draw()
   rectfill(0,0,127,127,0)
   local s=tsize/2
   for x=0,127 do
      for y=0,127 do
         local tx=cur_x+x
         local ty=cur_y+y
         if terrain[tx][ty]>elevation then
            pset(x,y,5)
         else
            pset(x,y,12)
         end
      end
   end
   pset(tsize/2+1,tsize/2+1,8)
   print(elevation.." "..cur_x.." "..cur_y,3,120,8)
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
   local d=delta(size)
   terrain[dx][dy]=avg+d
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
   local avg1=(w1+w2+w3+w4)/4

   local count=0
   local total=0
   s1=maybe(sx+s,sy)
   if s1 then
      count+=1
      total+=s1
   end
   s2=maybe(sx-s,sy)
   if s2 then
      count+=1
      total+=s2
   end
   s3=maybe(sx,sy+s)
   if s3 then
      count+=1
      total+=s3
   end
   s4=maybe(sx,sy-s)
   if s4 then
      count+=1
      total+=s4
   end
   local avg2=total/count

   local d=delta(size)
   terrain[sx][sy]=avg1+d
end

function maybe(x,y)
   if x<0 or x>tsize-1 then
      return nil
   end
   if y<0 or y>tsize-1 then
      return nil
   end
   return terrain[x][y]
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
   srand(x*10000+y+salt)
   --terrain[x][y]=rnd(0.5)+0.25
   terrain[x][y]=0.5
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
