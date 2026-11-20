-- Colony: Last Haven
-- Mobile-first top-down colony simulation prototype for LÖVE2D.
-- No external assets required. Designed for touch screens and desktop testing.
-- Run with: love colony-last-haven/

local TILE, MAP_W, MAP_H = 32, 72, 72
local SAVE_FILE = "colony_last_haven_save.lua"

local game = {}
local camera = { x = 0, y = 0, zoom = 1 }
local ui = { mode = "select", panel = "main", message = "Build a shelter and gather supplies.", messageTime = 5 }
local world, settlers, buildings, resources, raiders, particles
local selected = nil
local day, hour, speed = 1, 8, 1
local research = 0
local researchDone = {}
local raidCooldown = 3
local dragging = false
local dragLastX, dragLastY = 0, 0
local mapSeed = 9137
local screenW, screenH = 960, 640

local BUILDINGS = {
    wall = { name = "Wall", cost = { wood = 3 }, hp = 90, color = {0.48,0.34,0.22}, solid = true },
    bed = { name = "Bed", cost = { wood = 8 }, hp = 55, color = {0.72,0.48,0.34} },
    stockpile = { name = "Stockpile", cost = { wood = 10 }, hp = 75, color = {0.65,0.58,0.38} },
    farm = { name = "Farm plot", cost = { wood = 2 }, hp = 35, color = {0.35,0.58,0.27} },
    workshop = { name = "Workshop", cost = { wood = 14, stone = 5 }, hp = 100, color = {0.48,0.52,0.58} },
    medbay = { name = "Medical room", cost = { wood = 12, cloth = 4 }, hp = 80, color = {0.72,0.72,0.76} },
    beacon = { name = "Research beacon", cost = { wood = 16, stone = 8 }, hp = 85, color = {0.35,0.62,0.76} }
}

local TECH = {
    { id="masonry", name="Masonry", cost=18, desc="Unlock stronger stone walls.", unlock="stonewall" },
    { id="agriculture", name="Agriculture", cost=24, desc="Crops grow 35% faster.", unlock="farming" },
    { id="power", name="Basic power", cost=38, desc="Unlock efficient workshops.", unlock="power" },
    { id="medicine", name="Medicine", cost=42, desc="Settlers recover faster.", unlock="medicine" },
    { id="engineering", name="Engineering", cost=60, desc="Improve construction speed.", unlock="engineering" }
}

local function notify(msg)
    ui.message, ui.messageTime = msg, 4
end

local function key(x,y) return x .. ":" .. y end
local function inside(x,y) return x >= 1 and y >= 1 and x <= MAP_W and y <= MAP_H end
local function dist(ax,ay,bx,by) return math.abs(ax-bx) + math.abs(ay-by) end
local function hasCost(cost)
    for k,v in pairs(cost or {}) do if (world.stock[k] or 0) < v then return false end end
    return true
end
local function pay(cost)
    for k,v in pairs(cost or {}) do world.stock[k] = (world.stock[k] or 0) - v end
end

local function tileAt(x,y)
    if not inside(x,y) then return "water" end
    return world.tiles[y][x]
end

local function isOccupied(x,y)
    for _,b in ipairs(buildings) do if b.x==x and b.y==y then return true end end
    for _,s in ipairs(settlers) do if math.floor(s.x+0.5)==x and math.floor(s.y+0.5)==y then return true end end
    return false
end

local function newWorld()
    world = { tiles={}, stock={wood=35, stone=18, food=45, cloth=8}, explored={}, weather="Clear" }
    settlers, buildings, resources, raiders, particles = {}, {}, {}, {}, {}
    local seed = mapSeed
    local function rnd()
        seed = (seed * 1103515245 + 12345) % 2147483648
        return seed / 2147483648
    end
    for y=1,MAP_H do
        world.tiles[y]={}
        for x=1,MAP_W do
            local n = rnd()
            local edge = math.min(x,y,MAP_W-x+1,MAP_H-y+1)
            if edge < 2 then world.tiles[y][x]="water"
            elseif n < 0.10 then world.tiles[y][x]="rock"
            elseif n < 0.22 then world.tiles[y][x]="rough"
            else world.tiles[y][x]="grass" end
        end
    end
    local cx,cy = math.floor(MAP_W/2), math.floor(MAP_H/2)
    for y=cy-5,cy+5 do for x=cx-7,cx+7 do
        if inside(x,y) then world.tiles[y][x]="grass" end
    end end
    for i=1,95 do
        local x,y = math.floor(rnd()*MAP_W)+1, math.floor(rnd()*MAP_H)+1
        if tileAt(x,y)=="grass" and dist(x,y,cx,cy)>7 then
            local kind = rnd()<0.66 and "tree" or "stone"
            resources[#resources+1]={x=x,y=y,kind=kind,amount=kind=="tree" and 8 or 7}
        end
    end
    settlers = {
        {id=1,name="Mira",role="Builder",x=cx-2,y=cy,health=100,hunger=15,rest=90,mood=82,skill=3,job="idle",task=nil},
        {id=2,name="Tomas",role="Gatherer",x=cx,y=cy+2,health=100,hunger=12,rest=95,mood=76,skill=2,job="idle",task=nil},
        {id=3,name="Ivo",role="Farmer",x=cx+2,y=cy,health=100,hunger=18,rest=88,mood=90,skill=2,job="idle",task=nil}
    }
    buildings = {
        {kind="stockpile",x=cx,y=cy-3,hp=75},
        {kind="bed",x=cx-2,y=cy+2,hp=55},
        {kind="bed",x=cx+2,y=cy+2,hp=55}
    }
    world.stock.wood=world.stock.wood-18
    camera.x, camera.y = cx*TILE, cy*TILE
    day,hour,speed,research=1,8,1,0
    researchDone={}
    raidCooldown=3
    selected=nil
    ui.mode,ui.panel="select","main"
    notify("Welcome to Last Haven. Your colony begins here.")
end

local function worldToScreen(x,y)
    return (x*TILE-camera.x)*camera.zoom+screenW/2, (y*TILE-camera.y)*camera.zoom+screenH/2
end
local function screenToWorld(sx,sy)
    return math.floor((sx-screenW/2)/camera.zoom/TILE+camera.x/TILE)+1,
           math.floor((sy-screenH/2)/camera.zoom/TILE+camera.y/TILE)+1
end

local function buildingAt(x,y)
    for _,b in ipairs(buildings) do if b.x==x and b.y==y then return b end end
end
local function resourceAt(x,y)
    for _,r in ipairs(resources) do if r.x==x and r.y==y and r.amount>0 then return r end end
end

local function nearestResource(s, kind)
    local best,bd=nil,9999
    for _,r in ipairs(resources) do
        if r.amount>0 and (not kind or r.kind==kind) then
            local d=dist(math.floor(s.x),math.floor(s.y),r.x,r.y)
            if d<bd then best,bd=r,d end
        end
    end
    return best
end

local function assignJobs()
    for _,s in ipairs(settlers) do
        if not s.task or s.task.done then
            local r=nearestResource(s)
            if r then s.task={type="gather",target=r}; s.job="Gathering"
            elseif world.stock.food<20 then s.task={type="restock"}; s.job="Looking for food"
            else s.task=nil; s.job="Idle" end
        end
    end
end

local function moveToward(s,tx,ty,dt)
    local dx,dy=tx-s.x,ty-s.y
    local d=math.sqrt(dx*dx+dy*dy)
    if d<0.08 then return true end
    local step=math.min(d,1.65*dt)
    s.x=s.x+dx/d*step
    s.y=s.y+dy/d*step
    return d<0.12
end

local function updateSettlers(dt)
    assignJobs()
    for _,s in ipairs(settlers) do
        s.hunger=math.min(100,s.hunger+dt*0.22)
        s.rest=math.max(0,s.rest-dt*0.12)
        if s.hunger>80 then s.health=math.max(1,s.health-dt*0.5) end
        if s.task and s.task.type=="gather" then
            local r=s.task.target
            if r and r.amount>0 then
                if moveToward(s,r.x,r.y,dt) then
                    s.work=(s.work or 0)+dt
                    if s.work>2.5 then
                        s.work=0; r.amount=r.amount-1
                        local item=r.kind=="tree" and "wood" or "stone"
                        world.stock[item]=world.stock[item]+1
                        if r.amount<=0 then s.task=nil; s.job="Idle" end
                    end
                end
            else s.task=nil end
        elseif s.task and s.task.type=="restock" then
            s.task=nil
        end
        if s.rest<12 then
            local bed
            for _,b in ipairs(buildings) do if b.kind=="bed" then bed=b break end end
            if bed then
                if moveToward(s,bed.x,bed.y,dt) then s.rest=math.min(100,s.rest+dt*2.2); s.job="Resting" end
            end
        end
        if s.hunger>55 and world.stock.food>0 then
            world.stock.food=world.stock.food-0.015*dt
            s.hunger=math.max(0,s.hunger-dt*0.9)
        end
        s.mood=math.max(0,math.min(100,70+(s.rest-50)*0.25+(55-s.hunger)*0.3))
    end
end

local function placeBuilding(kind,x,y)
    local def=BUILDINGS[kind]
    if not def or not inside(x,y) then return end
    if tileAt(x,y)=="water" or tileAt(x,y)=="rock" or buildingAt(x,y) or isOccupied(x,y) then
        notify("This tile cannot be used.")
        return
    end
    if not hasCost(def.cost) then notify("Not enough resources."); return end
    pay(def.cost)
    buildings[#buildings+1]={kind=kind,x=x,y=y,hp=def.hp}
    if kind=="farm" then buildings[#buildings].growth=0 end
    notify(def.name.." constructed.")
    ui.mode="select"
end

local function startRaid()
    if #raiders>0 then return end
    for i=1,4+math.floor(day/3) do
        local side=i%4
        local x=side==0 and 2 or (side==1 and MAP_W-1 or math.random(4,MAP_W-3))
        local y=side==2 and 2 or (side==3 and MAP_H-1 or math.random(4,MAP_H-3))
        raiders[#raiders+1]={x=x,y=y,hp=24+day*2}
    end
    notify("A raid has been spotted! Keep your colony safe.")
end

local function updateRaid(dt)
    if #raiders==0 then return end
    for i=#raiders,1,-1 do
        local r=raiders[i]
        local target=buildings[1]
        local best=9999
        for _,b in ipairs(buildings) do
            local d=dist(r.x,r.y,b.x,b.y)
            if d<best then best,target=d,b end
        end
        if target then
            local dx,dy=target.x-r.x,target.y-r.y
            local d=math.max(1,math.abs(dx)+math.abs(dy))
            r.x=r.x+(dx/d)*dt*0.7
            r.y=r.y+(dy/d)*dt*0.7
            if d<1.4 then
                target.hp=target.hp-dt*5
                if target.hp<=0 then
                    for j,b in ipairs(buildings) do if b==target then table.remove(buildings,j) break end end
                    notify("A structure was damaged beyond repair.")
                end
            end
        end
        for _,s in ipairs(settlers) do
            if dist(math.floor(s.x),math.floor(s.y),math.floor(r.x),math.floor(r.y))<2 then r.hp=r.hp-dt*8 end
        end
        if r.hp<=0 then table.remove(raiders,i) end
    end
    if #raiders==0 then
        world.stock.food=world.stock.food+12
        world.stock.wood=world.stock.wood+6
        notify("The raid is over. The colony recovered some supplies.")
    end
end

local function updateWorld(dt)
    local oldDay=day
    hour=hour+dt*0.32
    if hour>=24 then hour=hour-24; day=day+1 end
    if day~=oldDay then
        world.stock.food=math.max(0,world.stock.food-#settlers*2)
        raidCooldown=raidCooldown-1
        if raidCooldown<=0 then startRaid(); raidCooldown=math.random(3,5) end
        notify("Day "..day.." begins.")
    end
    for _,b in ipairs(buildings) do
        if b.kind=="farm" then
            b.growth=(b.growth or 0)+dt*(researchDone.agriculture and 0.0011 or 0.0008)
            if b.growth>=1 then b.growth=0; world.stock.food=world.stock.food+5 end
        elseif b.kind=="beacon" then research=research+dt*0.08 end
    end
    updateSettlers(dt)
    updateRaid(dt)
    if ui.messageTime>0 then ui.messageTime=ui.messageTime-dt end
end

local function drawTile(x,y,t)
    local sx,sy=worldToScreen(x-1,y-1)
    local z=TILE*camera.zoom
    if sx+z<0 or sy+z<0 or sx>screenW or sy>screenH then return end
    local c={0.30,0.48,0.28}
    if t=="water" then c={0.18,0.35,0.52}
    elseif t=="rock" then c={0.42,0.42,0.40}
    elseif t=="rough" then c={0.38,0.43,0.29} end
    love.graphics.setColor(c)
    love.graphics.rectangle("fill",sx,sy,z+1,z+1)
    if t=="grass" and (x*7+y*11)%9==0 then
        love.graphics.setColor(0.38,0.56,0.32,0.55)
        love.graphics.circle("fill",sx+z*.45,sy+z*.5,math.max(1,z*.035))
    end
end

local function drawWorld()
    local minX,minY=screenToWorld(0,0)
    local maxX,maxY=screenToWorld(screenW,screenH)
    for y=math.max(1,minY-1),math.min(MAP_H,maxY+1) do
        for x=math.max(1,minX-1),math.min(MAP_W,maxX+1) do drawTile(x,y,tileAt(x,y)) end
    end
    for _,r in ipairs(resources) do
        if r.amount>0 then
            local sx,sy=worldToScreen(r.x-1,r.y-1); local z=TILE*camera.zoom
            if r.kind=="tree" then
                love.graphics.setColor(0.20,0.32,0.17); love.graphics.circle("fill",sx+z/2,sy+z/2,z*.36)
                love.graphics.setColor(0.32,0.52,0.25); love.graphics.circle("fill",sx+z*.43,sy+z*.4,z*.27)
            else
                love.graphics.setColor(0.58,0.59,0.57); love.graphics.polygon("fill",sx+z*.2,sy+z*.7,sx+z*.35,sy+z*.25,sx+z*.72,sy+z*.3,sx+z*.82,sy+z*.72)
            end
        end
    end
    for _,b in ipairs(buildings) do
        local sx,sy=worldToScreen(b.x-1,b.y-1); local z=TILE*camera.zoom
        local def=BUILDINGS[b.kind]
        love.graphics.setColor(def.color)
        love.graphics.rectangle("fill",sx+z*.08,sy+z*.08,z*.84,z*.84,3,3)
        love.graphics.setColor(0.12,0.12,0.12,0.45)
        love.graphics.rectangle("line",sx+z*.08,sy+z*.08,z*.84,z*.84,3,3)
        if b.kind=="farm" then
            love.graphics.setColor(0.20,0.42,0.14)
            for n=1,3 do love.graphics.line(sx+z*.2,sy+z*(.25+n*.15),sx+z*.8,sy+z*(.25+n*.15)) end
        end
        if b.hp<def.hp then
            love.graphics.setColor(0.12,0.12,0.12); love.graphics.rectangle("fill",sx,sy-4,z,3)
            love.graphics.setColor(0.85,0.3,0.2); love.graphics.rectangle("fill",sx,sy-4,z*math.max(0,b.hp/def.hp),3)
        end
    end
    for _,s in ipairs(settlers) do
        local sx,sy=worldToScreen(s.x-.5,s.y-.5); local z=TILE*camera.zoom
        love.graphics.setColor(0.86,0.76,0.57); love.graphics.circle("fill",sx+z/2,sy+z/2,z*.28)
        love.graphics.setColor(0.20,0.35,0.65); love.graphics.rectangle("fill",sx+z*.3,sy+z*.48,z*.4,z*.32,3,3)
        if selected==s then love.graphics.setColor(1,0.9,0.25); love.graphics.circle("line",sx+z/2,sy+z/2,z*.42) end
    end
    for _,r in ipairs(raiders) do
        local sx,sy=worldToScreen(r.x-.5,r.y-.5); local z=TILE*camera.zoom
        love.graphics.setColor(0.72,0.25,0.22); love.graphics.circle("fill",sx+z/2,sy+z/2,z*.28)
    end
end

local function buttonRect(i,total)
    local margin=10
    local w=math.min(112,(screenW-margin*2)/total-5)
    local x=margin+(i-1)*(w+5)
    return x,screenH-58,w,48
end

local function drawButton(i,total,label,active)
    local x,y,w,h=buttonRect(i,total)
    love.graphics.setColor(active and {0.25,0.48,0.67} or {0.12,0.15,0.18,0.94})
    love.graphics.rectangle("fill",x,y,w,h,8,8)
    love.graphics.setColor(0.75,0.82,0.86)
    love.graphics.rectangle("line",x,y,w,h,8,8)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(label,x+3,y+15,w-6,"center")
end

local function drawUI()
    love.graphics.setColor(0.07,0.09,0.11,0.92)
    love.graphics.rectangle("fill",0,0,screenW,54)
    love.graphics.setColor(1,1,1)
    love.graphics.print("LAST HAVEN",12,8)
    love.graphics.print("Day "..day.."  "..string.format("%02d:00",math.floor(hour)),145,8)
    love.graphics.print("Wood "..math.floor(world.stock.wood).."  Stone "..math.floor(world.stock.stone).."  Food "..math.floor(world.stock.food),275,8)
    love.graphics.print("Research "..math.floor(research),screenW-150,8)
    local labels={"Select","Build","People","Research","Pause"}
    for i,l in ipairs(labels) do drawButton(i,#labels,l,ui.panel==l:lower() or (l=="Build" and ui.mode=="build")) end
    if ui.panel=="build" then
        love.graphics.setColor(0.06,0.08,0.1,0.96); love.graphics.rectangle("fill",10,66,190,260,8,8)
        love.graphics.setColor(1,1,1); love.graphics.print("BUILD",22,76)
        local i=0
        for id,def in pairs(BUILDINGS) do
            i=i+1
            love.graphics.setColor(0.18,0.22,0.25); love.graphics.rectangle("fill",18,98+i*30,174,26,4,4)
            love.graphics.setColor(1,1,1); love.graphics.print(def.name,25,102+i*30)
        end
    elseif ui.panel=="people" then
        love.graphics.setColor(0.06,0.08,0.1,0.96); love.graphics.rectangle("fill",10,66,240,180,8,8)
        love.graphics.setColor(1,1,1); love.graphics.print("COLONISTS",20,76)
        for i,s in ipairs(settlers) do
            love.graphics.print(s.name.." - "..s.job,20,98+i*28)
            love.graphics.print("HP "..math.floor(s.health).."  Mood "..math.floor(s.mood),20,112+i*28)
        end
    elseif ui.panel=="research" then
        love.graphics.setColor(0.06,0.08,0.1,0.96); love.graphics.rectangle("fill",10,66,300,255,8,8)
        love.graphics.setColor(1,1,1); love.graphics.print("RESEARCH - "..math.floor(research),20,76)
        for i,t in ipairs(TECH) do
            local done=researchDone[t.id]
            love.graphics.setColor(done and {0.2,0.48,0.3} or {0.18,0.22,0.25})
            love.graphics.rectangle("fill",18,96+i*42,280,36,5,5)
            love.graphics.setColor(1,1,1)
            love.graphics.print(t.name.."  "..(done and "DONE" or (t.cost.." RP")),25,101+i*42)
            love.graphics.setColor(0.75,0.78,0.8); love.graphics.print(t.desc,25,116+i*42)
        end
    end
    if selected and selected.name then
        love.graphics.setColor(0.05,0.07,0.09,0.9); love.graphics.rectangle("fill",screenW-190,66,180,105,8,8)
        love.graphics.setColor(1,1,1); love.graphics.print(selected.name,screenW-178,76)
        love.graphics.print(selected.role or "",screenW-178,98)
        love.graphics.print("Health: "..math.floor(selected.health),screenW-178,118)
        love.graphics.print("Mood: "..math.floor(selected.mood),screenW-178,138)
    end
    if ui.messageTime>0 then
        love.graphics.setColor(0.04,0.05,0.06,0.88); love.graphics.rectangle("fill",screenW/2-210,62,420,30,6,6)
        love.graphics.setColor(1,1,1); love.graphics.printf(ui.message,screenW/2-200,70,400,"center")
    end
end

local function saveGame()
    local data={day=day,hour=hour,stock=world.stock,buildings=buildings,settlers=settlers,research=research,researchDone=researchDone}
    local function serialize(v)
        if type(v)=="number" or type(v)=="boolean" then return tostring(v) end
        if type(v)=="string" then return string.format("%q",v) end
        if type(v)=="table" then
            local out={"{"}
            for k,val in pairs(v) do
                out[#out+1]="["..serialize(k).."]="..serialize(val)..","
            end
            out[#out+1]="}"
            return table.concat(out)
        end
        return "nil"
    end
    love.filesystem.write(SAVE_FILE,"return "..serialize(data))
    notify("Colony saved.")
end

local function loadGame()
    if not love.filesystem.getInfo(SAVE_FILE) then notify("No save found."); return end
    local chunk=love.filesystem.load(SAVE_FILE)
    local ok,data=pcall(chunk)
    if not ok or type(data)~="table" then notify("Save could not be loaded."); return end
    day,hour=data.day or 1,data.hour or 8
    world.stock=data.stock or world.stock
    buildings=data.buildings or buildings
    settlers=data.settlers or settlers
    research=data.research or 0
    researchDone=data.researchDone or {}
    notify("Colony loaded.")
end

local function handleTap(x,y)
    if y<54 then return end
    if y>screenH-65 then
        local labels={"select","build","people","research","pause"}
        for i,l in ipairs(labels) do
            local bx,by,bw,bh=buttonRect(i,#labels)
            if x>=bx and x<=bx+bw and y>=by and y<=by+bh then
                ui.panel=l
                if l=="build" then ui.mode="build"
                elseif l=="select" then ui.mode="select"
                elseif l=="pause" then speed=speed==0 and 1 or 0; notify(speed==0 and "Paused." or "Simulation resumed.")
                end
                return
            end
        end
    end
    if ui.panel=="build" and x<205 and y>98 then
        local idx=math.floor((y-99)/30)
        local list={"wall","bed","stockpile","farm","workshop","medbay","beacon"}
        if list[idx] then ui.mode="place:"..list[idx]; notify("Tap an empty tile to place "..BUILDINGS[list[idx]].name..".") end
        return
    elseif ui.panel=="research" and x<320 and y>110 then
        local idx=math.floor((y-97)/42)
        local t=TECH[idx]
        if t and not researchDone[t.id] then
            if research>=t.cost then research=research-t.cost; researchDone[t.id]=true; notify(t.name.." researched.")
            else notify("Not enough research points.") end
        end
        return
    end
    local wx,wy=screenToWorld(x,y)
    if ui.mode:sub(1,6)=="place:" then placeBuilding(ui.mode:sub(7),wx,wy); return end
    selected=nil
    for _,s in ipairs(settlers) do
        if dist(math.floor(s.x+0.5),math.floor(s.y+0.5),wx,wy)<=1 then selected=s; break end
    end
    if not selected then
        local b=buildingAt(wx,wy)
        if b then selected={name=BUILDINGS[b.kind].name,role="Structure",health=b.hp,mood=100} end
    end
end

function love.load()
    math.randomseed(os.time())
    screenW,screenH=love.graphics.getDimensions()
    newWorld()
    love.graphics.setDefaultFilter("nearest","nearest")
end

function love.resize(w,h)
    screenW,screenH=w,h
end

function love.update(dt)
    dt=math.min(dt,0.05)
    if speed>0 then updateWorld(dt*speed) end
end

function love.draw()
    screenW,screenH=love.graphics.getDimensions()
    drawWorld()
    drawUI()
end

function love.mousepressed(x,y,button)
    if button==1 then
        dragging=true; dragLastX,dragLastY=x,y
    end
end

function love.mousereleased(x,y,button)
    if button==1 then
        if dragging and math.abs(x-dragLastX)+math.abs(y-dragLastY)<10 then handleTap(x,y) end
        dragging=false
    end
end

function love.mousemoved(x,y,dx,dy)
    if dragging and dragLastY>54 and dragLastY<screenH-65 then
        camera.x=camera.x-dx/camera.zoom
        camera.y=camera.y-dy/camera.zoom
        dragLastX,dragLastY=x,y
    end
end

function love.wheelmoved(_,y)
    camera.zoom=math.max(0.55,math.min(1.7,camera.zoom+y*0.08))
end

function love.touchpressed(id,x,y)
    love.mousepressed(x*screenW,y*screenH,1)
end
function love.touchreleased(id,x,y)
    love.mousereleased(x*screenW,y*screenH,1)
end
function love.touchmoved(id,x,y,dx,dy)
    love.mousemoved(x*screenW,y*screenH,dx*screenW,dy*screenH)
end

function love.keypressed(k)
    if k=="escape" then ui.panel="main"; ui.mode="select"
    elseif k=="space" then speed=speed==0 and 1 or 0
    elseif k=="+" or k=="=" then camera.zoom=math.min(1.7,camera.zoom+0.1)
    elseif k=="-" then camera.zoom=math.max(0.55,camera.zoom-0.1)
    elseif k=="s" then saveGame()
    elseif k=="l" then loadGame()
    elseif k=="1" then speed=1
    elseif k=="2" then speed=2
    elseif k=="3" then speed=4
    end
end

-- Desktop convenience: middle mouse or WASD pans the map.
function love.keyreleased() end
