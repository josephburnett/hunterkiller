pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
tile_size=5
tile_count=4
elevation=0.380
thickness=2
salt=0

cur_x=0
cur_y=0

function _init()
   for i=0,100 do
      printh("")
   end
   tsize=2^tile_size+1
   --printh("tsize="..tsize)
   terrain=tile(0,0,tile_count)
   p=plane(terrain,tile_count,elevation)
   printh("terrain complete")
   --printh_terrain(terrain)
end

function _update()
   local lower=0
   local upper=(tsize-1)*tile_count
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
      p=plane(terrain,tile_count,elevation)
   end
   if btnp(5) and elevation<1 then
      elevation+=0.001
      p=plane(terrain,tile_count,elevation)
   end
end

function _draw()
   rectfill(0,0,127,127,0)
   for x=0,(tsize-1)*tile_count do
      for y=0,(tsize-1)*tile_count do
         if p[x][y] then
            pset(x,y,5)
         else
            pset(x,y,12)
         end
      end
   end
   pset(cur_x,cur_y,8)
   print(elevation.." "..cur_x.." "..cur_y.." "..terrain[cur_x][cur_y],3,120,8)
end

function tile(x,y,cnt)
   --printh("tile "..x.." "..y.." "..cnt)
   local step=tsize-1
   local t={}
   for tx=0,step*cnt do
      t[tx]={}
   end
   for cx=0,step*cnt,step do
      for cy=0,step*cnt,step do
         corner(t,x+cx,y+cy)
      end
   end
   local size=tsize
   local i=0
   while size>=3 do
      local half=flr(size/2)
      for dx=half,step*cnt-1,size-1 do
         for dy=half,step*cnt-1,size-1 do
            diamond(t,x,y,x+dx,y+dy,size,i)
         end
      end
      for sx=half,step*cnt-1,size-1 do
         for sy=half,step*cnt-1,size-1 do
            square(t,x,y,x+sx+half,y+sy,size,cnt,i)
            square(t,x,y,x+sx,y+sy+half,size,cnt,i)
            square(t,x,y,x+sx-half,y+sy,size,cnt,i)
            square(t,x,y,x+sx,y+sy-half,size,cnt,i)
         end
      end
      size=half+1
      i+=1
   end
   return t
end

function diamond(t,x,y,dx,dy,size,i)
   --printh("diamond "..x.." "..y.." "..dx.." "..dy.." "..size)
   local avg=(
            t[x][y]+
            t[x][y+size-1]+
            t[x+size-1][y]+
            t[x+size-1][y+size-1]
         )/4
   local d=delta(size,i)
   t[dx][dy]=avg+d
end

function square(t,x,y,sx,sy,size,cnt,i)
   local half=flr(size/2)
   local count=0
   local total=0
   s1=maybe(t,sx+half,sy,cnt)
   if s1 then
      count+=1
      total+=s1
   end
   s2=maybe(t,sx-half,sy,cnt)
   if s2 then
      count+=1
      total+=s2
   end
   s3=maybe(t,sx,sy+half,cnt)
   if s3 then
      count+=1
      total+=s3
   end
   s4=maybe(t,sx,sy-half,cnt)
   if s4 then
      count+=1
      total+=s4
   end
   local avg=total/count
   local d=delta(size,i)
   t[sx][sy]=avg+d
end

function maybe(t,x,y,cnt)
   if x<0 or x>(tsize-1)*cnt then
      return nil
   end
   if y<0 or y>(tsize-1)*cnt then
      return nil
   end
   return t[x][y]
end

function corner(t,x,y)
   --printh("corner "..x.." "..y)
   srand(x*10000+y+salt)
   t[x][y]=rnd(0.5)+0.25
   --t[x][y]=0.5
end

function delta(size,i)
   --return flr((rnd(0.1)-0.05)*100)/100
   --return rnd(0.5)-0.25
   --local max_delta=0.75
   --if size<tsize/8 then
   --   max_delta=0.25
   --end
   --return rnd(max_delta*2)-max_delta
   local max_delta=0.5/(i+1)
   return rnd(max_delta*2)-max_delta
end

function plane(t,cnt,elev)
   local step=tsize-1
   local p={}
   for x=0,step*cnt do
      p[x]={}
      for y=0,step*cnt do
         if t[x][y]>elev then
            p[x][y]=true
         else
            p[x][y]=false
         end
      end
   end
   despeckle(p)
   for i=1,thickness do
      thicken(p,cnt)
   end
   return p
end

function despeckle(p)
   local step=tsize-1
   for x=0,step*tile_count do
      for y=0,step*tile_count do
         if p[x][y] then
            local p1=maybe(p,x+1,y,tile_count)
            local p2=maybe(p,x,y+1,tile_count)
            local p3=maybe(p,x-1,y,tile_count)
            local p4=maybe(p,x,y-1,tile_count)
            if not p1 and not p2 and
               not p3 and not p4 then
               p[x][y]=false
            end
         end
      end
   end
end

function thicken(p,cnt)
   local step=tsize-1
   for x=0,step*cnt do
      for y=0,step*cnt do
         if p[x][y] then
            if maybe(p,x-1,y,tile_count)!=nil then
               p[x-1][y]=true
            end
            if maybe(p,x,y-1,tile_count)!=nil then
               p[x][y-1]=true
            end
         end
      end
   end
   for x=step*cnt,0,-1 do
      for y=step*cnt,0,-1 do
         if p[x][y] then
            if maybe(p,x+1,y,tile_count)!=nil then
               p[x+1][y]=true
            end
            if maybe(p,x,y+1,tile_count)!=nil then
               p[x][y+1]=true
            end
         end
      end
   end
end

function printh_terrain()
   --printh("terrain:\n")
   local step=tsize-1
   for x=0,step*tile_count do
      for y=0,step*tile_count do
         local t=terrain[x][y]
         if not t then
            t="nil"
         end
         printh("x="..x.." y="..y.." "..t)
      end
      printh("")
   end
end
