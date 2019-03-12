pico-8 cartridge // http://www.pico-8.com
version 10
__lua__
play=true

--terrain
terrain={}
tdone={}
tsize=2^5+1
tcount=4
max_delta=0.3
elevation=0.5298
thickness=2
salt=6

--explore
cur_x=0
cur_y=0

--play
mode="nav"
pos_x=55
pos_y=90
velosity=0
heading=0
ping_state=0
ping_x=0
ping_y=0
ping_term={}
chart={}
torps={}
torp_count=0

function _init()
   printh("===")
   gen_terrain()
end

function _update()
   gen_terrain()
   if play then
      update_play()
   else
      update_explore()
   end
end

function _draw()
   if play then
      draw_play()
   else
      draw_explore()
   end
end

function update_play()
   handle_buttons()
   update_pos()
   update_torps()
end

function handle_buttons()
   if (btnp(4) and mode=="nav") or ping_state!=0 then
      ping()
   elseif btnp(4) and mode=="torp" then
      fire()
   end
   if btn(0) then
      heading+=.002
   end
   if btn(1) then
      heading-=.002
   end
   if heading<0 then
      heading+=1
   end
   if heading>=1 then
      heading-=1
   end
   if btn(2) then
      velosity+=0.002
   end
   if btn(3) then
      velosity-=0.002
   end
   if velosity<0 then
      velosity=0
   end
   if velosity>0.1 then
      velosity=0.1
   end
   if btnp(5) then
      if mode=="nav" then
         mode="torp"
      else
         mode="nav"
      end
   end
end

function update_pos()
   local dx=velosity*cos(heading)
   local dy=velosity*sin(heading)
   local x=flr(pos_x+dx)
   local y=flr(pos_y+dy)
   if maybe(p,x,y,tcount) then
      velosity=0
      return
   end
   pos_x+=dx
   pos_y+=dy
   cursor(pos_x-64,pos_y-64)
end

function fire()
   local t={}
   t.x=pos_x
   t.y=pos_y
   t.h=heading
   torp_count+=1
   torps[torp_count]=t
end

function update_torps()
   for k,v in pairs(torps) do
      x=v.x+cos(v.h)*0.1
      y=v.y+sin(v.h)*0.1
      if maybe(p,flr(x),flr(y),tcount) then
         torps[k]=nil
      else
         v.x=x
         v.y=y
      end
   end
end

function draw_torps()
   for k,v in pairs(torps) do
      circfill(v.x,v.y,1,8)
   end
end

function draw_play()
   draw_chart()
   draw_hud()
   draw_torps()
   circfill(pos_x,pos_y,1,10)
end

function draw_hud()
   print("velosity: "..velosity.." heading: "..heading,3,120,8)
   if ping_state!=0 then
      circ(ping_x,ping_y,ping_state-0.5,8)
   end
   if mode=="nav" then
      draw_nav_hud()
   elseif mode=="torp" then
      draw_torp_hud()
   end
end

function draw_nav_hud()
   local dx=cos(heading)
   local dy=sin(heading)
   local vx=dx*velosity*500
   local vy=dy*velosity*500
   local hx=vx+dx*200
   local hy=vy+dy*200
   circ(pos_x,pos_y,30,6)
   line(pos_x,pos_y,pos_x+vx,pos_y+vy,13)
   line(pos_x+vx,pos_y+vy,pos_x+hx,pos_y+hy,6)
end

function draw_torp_hud()
   x1=cos(heading+0.05)*200
   y1=sin(heading+0.05)*200
   x2=cos(heading-0.05)*200
   y2=sin(heading-0.05)*200
   line(pos_x,pos_y,pos_x+x1,pos_y+y1,6)
   line(pos_x,pos_y,pos_x+x2,pos_y+y2,6)   
end

function draw_chart()
   rectfill(0,0,127,127,5)
   for x=0,(tsize-1)*tcount do
      for y=0,(tsize-1)*tcount do
         if maybe(chart,x,y,tcount)=="water" then
            pset(x,y,12)
         elseif maybe(chart,x,y,tcount)=="land" then
            pset(x,y,0)
         end
      end
   end
end

function update_explore()
   local lower=0
   local upper=(tsize-1)*tcount
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
      p=plane(terrain,tcount,elevation)
   end
   if btnp(5) and elevation<1 then
      elevation+=0.001
      p=plane(terrain,tcount,elevation)
   end
end

function draw_explore()
   rectfill(0,0,127,127,0)
   for x=0,(tsize-1)*tcount do
      for y=0,(tsize-1)*tcount do
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

function ping()
   if ping_state==0 then
      ping_state=1
      ping_x=pos_x
      ping_y=pos_y
      ping_term={}
   else
      for i=0,1,0.01 do
         if not ping_term[i] then
            local x=flr(ping_x+ping_state*cos(i))
            local y=flr(ping_y+ping_state*sin(i))
            if maybe(p,x,y,tcount) then
               set_chart(x,y,"land")
               ping_term[i]=true
            else
               set_chart(x,y,"water")
            end
         end
      end
      ping_state+=1
   end
   if ping_state==30 then
      ping_state=0
   end
end

function set_chart(x,y,what)
   if chart[x]==nil then
      chart[x]={}
   end
   chart[x][y]=what
end

function gen_terrain()
   local tactual=(tsize-1)*(tcount-2)
   local tx=flr(pos_x/tactual)*tactual
   local ty=flr(pos_y/tactual)*tactual
   local r=flr(128/tactual)*tactual
   --printh("r: "..r)
   --printh("tsize: "..tsize)
   --printh("tcount: "..tcount)
   --printh("tactual: "..tactual)
   for x=-r,r,tactual do
      for y=-r,r,tactual do
         gen_tile(x,y)
      end
   end
end

function gen_tile(x,y)
   printh("gen_tile("..x..","..y..")")
   local dx=tdone[x]
   if dx==nil then
      dx={}
      tdone[x]=dx
   end
   if dx[y] then
      printh(" cache hit")
      return
   end
   printh(" cache miss")
   local step=tsize-1
   local t=elevations(x-step,y-step)
   local p=plane(t,x-step,y-step,elevation)
   local tactual=step*(tcount-2)
   for px=x,x+tactual do
      for py=y,y+tactual do
         local tx=terrain[px]
         if tx==nil then
            tx={}
            terrain[px]=tx
         end
         tx[py]=p[px][py]
      end
   end
   local dx=tdone[x]
   dx[y]=true
end

function elevations(x,y)
   --printh("elevations("..x..","..y..")")
   local step=tsize-1
   local t={}
   for tx=0,step*tcount do
      t[tx+x]={}
   end
   for cx=0,step*tcount,step do
      for cy=0,step*tcount,step do
         corner(t,x+cx,y+cy)
      end
   end
   local size=tsize
   local i=0
   while size>=3 do
      local half=flr(size/2)
      for dx=half,step*tcount-1,size-1 do
         for dy=half,step*tcount-1,size-1 do
            diamond(t,x,y,x+dx,y+dy,size,i)
         end
      end
      for sx=half,step*tcount-1,size-1 do
         for sy=half,step*tcount-1,size-1 do
            square(t,x,y,x+sx+half,y+sy,size,i)
            square(t,x,y,x+sx,y+sy+half,size,i)
            square(t,x,y,x+sx-half,y+sy,size,i)
            square(t,x,y,x+sx,y+sy-half,size,i)
         end
      end
      size=half+1
      i+=1
   end
   return t
end

function diamond(t,x,y,dx,dy,size,i)
   --printh("diamond("..x..","..y..","..dx..","..dy..","..size..","..i..")")
   local avg=(
            t[x][y]+
            t[x][y+size-1]+
            t[x+size-1][y]+
            t[x+size-1][y+size-1]
         )/4
   local d=delta(size,i)
   t[dx][dy]=avg+d
end

function square(t,x,y,sx,sy,size,i)
   --printh("diamond("..x..","..y..","..sx..","..sy..","..size..","..i..")")
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
   local d=delta(size,i)
   t[sx][sy]=avg+d
end

function maybe(t,x,y)
   if x<0 or x>(tsize-1)*tcount then
      return nil
   end
   if y<0 or y>(tsize-1)*tcount then
      return nil
   end
   if t[x]==nil then
      return nil
   end
   return t[x][y]
end

function corner(t,x,y)
   --printh("corner("..x..","..y..")")
   srand(x*y*salt)
   tx=t[x]
   if tx==nil then
      tx={}
      t[x]=tx
   end
   tx[y]=rnd(1)
end

function delta(size,i)
   local md=max_delta/(i+1)
   return rnd(md*2)-md
end

function plane(t,x,y,elev)
   local step=tsize-1
   local p={}
   for px=0,step*tcount do
      p[px+x]={}
      for py=0,step*tcount do
         if t[px+x][py+y]>elev then
            p[px+x][py+y]=true
         else
            p[px+x][py+y]=false
         end
      end
   end
   despeckle(p,x,y)
   for i=1,thickness do
      thicken(p,x,y)
   end
   return p
end

function despeckle(p,x,y)
   local step=tsize-1
   for px=0,step*tcount do
      for py=0,step*tcount do
         if p[px+x][py+y] then
            local p1=maybe(p,px+x+1,py+y,tcount)
            local p2=maybe(p,px+x,py+y+1,tcount)
            local p3=maybe(p,px+x-1,py+y,tcount)
            local p4=maybe(p,px+x,py+y-1,tcount)
            if not p1 and not p2 and
               not p3 and not p4 then
               p[px+x][py+y]=false
            end
         end
      end
   end
end

function thicken(p,x,y)
   local temp={}
   local step=tsize-1
   for px=0,step*tcount do
      temp[px+x]={}
      for py=0,step*tcount do
         temp[px+x][py+y]=p[px+x][py+y]
      end
   end
   for px=step*tcount,0,-1 do
      for py=step*tcount,0,-1 do
         if temp[px+x][py+y] then
            if maybe(temp,px+x+1,py+y,tcount)!=nil then
               p[px+x+1][py+y]=true
            end
            if maybe(temp,px+x,py+y+1,tcount)!=nil then
               p[px+x][py+y+1]=true
            end
            if maybe(temp,px+x-1,py+y,tcount)!=nil then
               p[px+x-1][py+y]=true
            end
            if maybe(temp,px+x,py+y-1,tcount)!=nil then
               p[px+x][py+y-1]=true
            end
         end
      end
   end
end

function printh_terrain()
   local step=tsize-1
   for x=0,step*tcount do
      for y=0,step*tcount do
         local t=terrain[x][y]
         if not t then
            t="nil"
         end
         printh("x="..x.." y="..y.." "..t)
      end
      printh("")
   end
end
