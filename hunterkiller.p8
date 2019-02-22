pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
scale=7
elevation=0.5000
salt=4

cur_x=64
cur_y=64

function _init()
   tsize=2^scale+1
   terrain=tile(0,0)
   printh("terrain complete")
end

function _update()
   local lower=0
   local upper=tsize-1
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
   print(elevation.." "..cur_x.." "..cur_y.." "..terrain[cur_x][cur_y],3,120,8)
end

function tile(x,y)
   local t={}
   for tx=0,tsize-1 do
      t[tx]={}
   end
   corner(t,x,y)
   corner(t,x,y+tsize-1)
   corner(t,x+tsize-1,y)
   corner(t,x+tsize-1,y+tsize-1)
   local size=tsize
   while size>=3 do
      local half=flr(size/2)
      for dx=half,tsize-1,size-1 do
         for dy=half,tsize-1,size-1 do
            diamond(t,x,y,x+dx,y+dy,size)
         end
      end
      for sx=half,tsize-1,size-1 do
         for sy=half,tsize-1,size-1 do
            square(t,x,y,sx+half,sy,size)
            square(t,x,y,sx,sy+half,size)
            square(t,x,y,sx-half,sy,size)
            square(t,x,y,sx,sy-half,size)
          end
      end
      size=half+1
   end
   return t
end

function diamond(t,x,y,dx,dy,size)
   local avg=(
            t[x][y]+
            t[x][y+size-1]+
            t[x+size-1][y]+
            t[x+size-1][y+size-1]
         )/4
   local d=delta(size)
   t[dx][dy]=avg+d
end

function square(t,x,y,sx,sy,size)
   local half=flr(size/2)
   local count=0
   local total=0
   s1=maybe(t,sx+half,sy)
   if s1 then
      count+=1
      total+=s1
   end
   s2=maybe(t,sx-half,sy)
   if s2 then
      count+=1
      total+=s2
   end
   s3=maybe(t,sx,sy+half)
   if s3 then
      count+=1
      total+=s3
   end
   s4=maybe(t,sx,sy-half)
   if s4 then
      count+=1
      total+=s4
   end
   local avg=total/count
   local d=delta(size)
   t[sx][sy]=avg+d
end

function maybe(t,x,y)
   if x<0 or x>tsize-1 then
      return nil
   end
   if y<0 or y>tsize-1 then
      return nil
   end
   return t[x][y]
end

function corner(t,x,y)
   srand(x*10000+y+salt)
   --t[x][y]=rnd(0.5)+0.25
   t[x][y]=0.5
end

function delta(size)
   return flr((rnd(0.1)-0.05)*100)/100
end
