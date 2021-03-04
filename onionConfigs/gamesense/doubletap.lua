   -- create a table for our menu pos, makes it easier to change where our controls are
    local menu = {
        "RAGE",
        "Aimbot"
    }
    -- create a table for our modes and our dynamic options, this makes it easier to control our ui options
    local modes = {
        "Off",
        "Consistent",
        "Fast",
        "Instant",
        "Dynamic"
    }
    local indicator_options = {
        "Player name",
        "Player icon",
        "Rainbow (fading)",
        "Always on"
    }
    local dynamic_options = {
        "Latency",
        "Enemy lagcompensation",
        "Enemy vulnerability",
        "Local vulnerability",
        "Handle hitchance"
    }

    -- create our controls (master key for enable/disable, tickbase modes, dynamic controls, indicator controls, ...)
    local mode = ui.new_combobox(menu[1], menu[2], "[smoldt] Tickbase", modes)
    local dynamic = ui.new_multiselect(menu[1], menu[2], "[smoldt] Dynamic options", dynamic_options)
    local indic = ui.new_checkbox(menu[1], menu[2], "[smoldt] Indicator")
    local picker = ui.new_color_picker(menu[1], menu[2], "[smoldt] picker", 144, 152, 240, 255)
    local indic_options = ui.new_multiselect(menu[1], menu[2], "[smoldt] Indicator options", indicator_options)

    -- we need a few references
    local dt, dt_key = ui.reference("RAGE", "Other", "Double tap")
    local dt_fake_lag = ui.reference("RAGE", "Other", "Double tap fake lag limit")
    local dt_hit_chance = ui.reference("RAGE", "Other", "Double tap hit chance")
    local dt_mode = ui.reference("RAGE", "Other", "Double tap mode")
    local maxusrcmdprocessticks = ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks")

    -- set this to false so people can't see maxusrcmdprocessticks
    -- kinda useless but just do it for sanity
    ui.set_visible(maxusrcmdprocessticks, false)

    -- function for easy multiselect access (c: rigz? maybe)
    local contains = function(table, value)
        for _, v in ipairs(ui.get(table)) do
            if v == value then return true end
        end
    
        return false
    end

    -- function for local player or spectated player (c: kez)
    -- we can use this for showing our indicator even when dead
    local lp = function()
        local real_lp = entity.get_local_player()
        if entity.is_alive(real_lp) then
            return real_lp
        else
            local obvserver = entity.get_prop(real_lp, "m_hObserverTarget")
            return obvserver ~= nil and obvserver <= 64 and obvserver or nil
        end
    end

    -- lethal function
    -- is it still stealing if I take it from myself?
    local csgo_weapons = require("gamesense/csgo_weapons") or client.error_log("[smoldt] Weapons library required:\nhttps://gamesense.pub/forums/viewtopic.php?id=18807")
    local vector = require "vector"
    local calc_dmg = function(local_player, player, distance)
        local weapon_ent = entity.get_player_weapon(local_player)
        if weapon_ent == nil then return end
        
        local weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
        if weapon_idx == nil then return end
        
        local weapon = csgo_weapons[weapon_idx]
        if weapon == nil then return end
    
        local dmg_after_range= (weapon.damage * math.pow(weapon.range_modifier, (distance * 0.002))) * 1.25 --dmg to stomach mult
        local armor = entity.get_prop(player,"m_ArmorValue")
        if armor == nil then armor = 0 end
        local newdmg = dmg_after_range * (weapon.armor_ratio * 0.5)
        if dmg_after_range - (dmg_after_range * (weapon.armor_ratio * 0.5)) * 0.5 > armor then
            newdmg = dmg_after_range - (armor / 0.5)
        end
        return newdmg
    end

    -- dragging function
    local _draggable = (function()local a={}local b,c,d,e,f,g,h,i,j,k,l,m,n,o;local p={__index={drag=function(self,...)local q,r=self:get()local s,t=a.drag(q,r,...)if q~=s or r~=t then self:set(s,t)end;return s,t end,set=function(self,q,r)local j,k=client.screen_size()ui.set(self.x_reference,q/j*self.res)ui.set(self.y_reference,r/k*self.res)end,get=function(self)local j,k=client.screen_size()return ui.get(self.x_reference)/self.res*j,ui.get(self.y_reference)/self.res*k end}}function a.new(u,v,w,x)x=x or 10000;local j,k=client.screen_size()local y=ui.new_slider("LUA","A",u.." window position",0,x,v/j*x)local z=ui.new_slider("LUA","A","\n"..u.." window position y",0,x,w/k*x)ui.set_visible(y,false)ui.set_visible(z,false)return setmetatable({name=u,x_reference=y,y_reference=z,res=x},p)end;function a.drag(q,r,A,B,C,D,E)if globals.framecount()~=b then c=ui.is_menu_open()f,g=d,e;d,e=ui.mouse_position()i=h;h=client.key_state(0x01)==true;m=l;l={}o=n;n=false;j,k=client.screen_size()end;if c and i~=nil then if(not i or o)and h and f>q and g>r and f<q+A and g<r+B then n=true;q,r=q+d-f,r+e-g;if not D then q=math.max(0,math.min(j-A,q))r=math.max(0,math.min(k-B,r))end end end;table.insert(l,{q,r,A,B})return q,r,A,B end;return a end)()

    -- we're going to create a few 'global' data sets, we'll edit these values across our different functions
    -- we'll use these for most of our conditionals and math
    local data = {
        old_tickbase = 0,
        old_sim_time = 0,
        shifted_ticks = 0,
        old_command_num = 0,
        skip_next_differ = false,
        charged_before = false,
        did_shift_before = false,
        can_shift_tickbase = 0,
        is_cmd_safe = true,
        last_charge = 0,
        validate_cmd = ui.get(maxusrcmdprocessticks),
        lag_state = nil,
        delay = 0
    }
    local player = {
        in_attack = 0,
        command_number = 0,
        choked_commands = 0
    }
    local shift_info = {
        data = {}, 
        shift_time = 0, 
        shift_data = {}
    }
    local indicator = {
        label = "",
        width = 0,
        height = 0,
        pos = _draggable.new("Indicators", 10, 200),
        alpha = 0,
        bar = 0,
        hbar = 0,
        shot = false,
        shot_label = "",
        shot_timer = 0,
        shot_alpha = 255,
        recharge = false,
        recharge_label = "",
        recharge_timer = 0,
        recharge_alpha = 255
    }
    local vulnerable_items = {
        "CKnife",
        "CSmokeGrenade",
        "CFlashbang",
        "CHEGrenade",
        "CDecoyGrenade",
        "CIncendiaryGrenade",
        "CMolotovGrenade",
        "CC4"
    }

    -- bullshit function used for accessing a table
    -- I don't recognise it so I must have made it in a red bull induced psychosis 
    -- as far as I can tell it writes to/unpacks a table inside a table (?)
    -- we need it for writing to/unpacking shift info (it has tables inside of it)
    local by = function(bz)
        local b9 = 0
        for _, v in pairs(bz) do
            b9 = b9 + 1
        end
        return b9
    end

    -- vec lib (Vector3)
    local type=type;local setmetatable=setmetatable;local tostring=tostring;local a=math.pi;local b=math.min;local c=math.max;local d=math.deg;local e=math.rad;local f=math.sqrt;local g=math.sin;local h=math.cos;local i=math.atan;local j=math.acos;local k=math.fmod;local l={}l.__index=l;function Vector3(m,n,o)if type(m)~="number"then m=0.0 end;if type(n)~="number"then n=0.0 end;if type(o)~="number"then o=0.0 end;m=m or 0.0;n=n or 0.0;o=o or 0.0;return setmetatable({x=m,y=n,z=o},l)end;function l.__eq(p,q)return p.x==q.x and p.y==q.y and p.z==q.z end;function l.__unm(p)return Vector3(-p.x,-p.y,-p.z)end;function l.__add(p,q)local r=type(p)local s=type(q)if r=="table"and s=="table"then return Vector3(p.x+q.x,p.y+q.y,p.z+q.z)elseif r=="table"and s=="number"then return Vector3(p.x+q,p.y+q,p.z+q)elseif r=="number"and s=="table"then return Vector3(p+q.x,p+q.y,p+q.z)end end;function l.__sub(p,q)local r=type(p)local s=type(q)if r=="table"and s=="table"then return Vector3(p.x-q.x,p.y-q.y,p.z-q.z)elseif r=="table"and s=="number"then return Vector3(p.x-q,p.y-q,p.z-q)elseif r=="number"and s=="table"then return Vector3(p-q.x,p-q.y,p-q.z)end end;function l.__mul(p,q)local r=type(p)local s=type(q)if r=="table"and s=="table"then return Vector3(p.x*q.x,p.y*q.y,p.z*q.z)elseif r=="table"and s=="number"then return Vector3(p.x*q,p.y*q,p.z*q)elseif r=="number"and s=="table"then return Vector3(p*q.x,p*q.y,p*q.z)end end;function l.__div(p,q)local r=type(p)local s=type(q)if r=="table"and s=="table"then return Vector3(p.x/q.x,p.y/q.y,p.z/q.z)elseif r=="table"and s=="number"then return Vector3(p.x/q,p.y/q,p.z/q)elseif r=="number"and s=="table"then return Vector3(p/q.x,p/q.y,p/q.z)end end;function l.__tostring(p)return"( "..p.x..", "..p.y..", "..p.z.." )"end;function l:clear()self.x=0.0;self.y=0.0;self.z=0.0 end;function l:unpack()return self.x,self.y,self.z end;function l:length_2d_sqr()return self.x*self.x+self.y*self.y end;function l:length_sqr()return self.x*self.x+self.y*self.y+self.z*self.z end;function l:length_2d()return f(self:length_2d_sqr())end;function l:length()return f(self:length_sqr())end;function l:dot(t)return self.x*t.x+self.y*t.y+self.z*t.z end;function l:cross(t)return Vector3(self.y*t.z-self.z*t.y,self.z*t.x-self.x*t.z,self.x*t.y-self.y*t.x)end;function l:dist_to(t)return(t-self):length()end;function l:is_zero(u)u=u or 0.001;if self.x<u and self.x>-u and self.y<u and self.y>-u and self.z<u and self.z>-u then return true end;return false end;function l:normalize()local v=self:length()if v<=0.0 then return 0.0 end;self.x=self.x/v;self.y=self.y/v;self.z=self.z/v;return v end;function l:normalize_no_len()local v=self:length()if v<=0.0 then return end;self.x=self.x/v;self.y=self.y/v;self.z=self.z/v end;function l:normalized()local v=self:length()if v<=0.0 then return Vector3()end;return Vector3(self.x/v,self.y/v,self.z/v)end;function clamp(w,x,y)if w<x then return x elseif w>y then return y end;return w end;function normalize_angle(z)local A;local B;B=tostring(z)if B=="nan"or B=="inf"then return 0.0 end;if z>=-180.0 and z<=180.0 then return z end;A=k(k(z+360.0,360.0),360.0)if A>180.0 then A=A-360.0 end;return A end;function vector_to_angle(C)local v;local D;local E;v=C:length()if v>0.0 then D=d(i(-C.z,v))E=d(i(C.y,C.x))else if C.x>0.0 then D=270.0 else D=90.0 end;E=0.0 end;return Vector3(D,E,0.0)end;function angle_forward(z)local F=g(e(z.x))local G=h(e(z.x))local H=g(e(z.y))local I=h(e(z.y))return Vector3(G*I,G*H,-F)end;function angle_right(z)local F=g(e(z.x))local G=h(e(z.x))local H=g(e(z.y))local I=h(e(z.y))local J=g(e(z.z))local K=h(e(z.z))return Vector3(-1.0*J*F*I+-1.0*K*-H,-1.0*J*F*H+-1.0*K*I,-1.0*J*G)end;function angle_up(z)local F=g(e(z.x))local G=h(e(z.x))local H=g(e(z.y))local I=h(e(z.y))local J=g(e(z.z))local K=h(e(z.z))return Vector3(K*F*I+-J*-H,K*F*H+-J*I,K*G)end;function get_FOV(L,M,N)local O;local P;local Q;local R;P=angle_forward(L)Q=(N-M):normalized()R=j(P:dot(Q)/Q:length())return c(0.0,d(R))end

    -- prediction, we're going to do math and back up data here for accuracy
    local on_predict_cmd = function(player)
        local shift = 0

        -- get our local player weapon
        local local_player = entity.get_local_player()
        local local_player_weapon = entity.get_player_weapon(local_player)

        -- we're going to make a function that returns a bool, this will tell us if we can shift tickbase
        local can_shift = function(local_player, local_player_weapon, buffer)
            -- if we don't have a local player we can't shift tickbase
            if local_player_weapon == nil then return false end
            
            -- get our tickbase and an accurate interval
            local local_tickbase = entity.get_prop(local_player, "m_nTickBase")
            local interval = globals.tickinterval() * (local_tickbase - buffer)

            -- if we're going to attack again always return false (we don't want to recharge while shooting)
            if interval < entity.get_prop(local_player, "m_flNextAttack") then
                return false
            end
            if interval < entity.get_prop(local_player_weapon, "m_flNextPrimaryAttack") then
                return false
            end

            -- return true
            return true
        end
        
        -- we're going to take one from our maxusrcmdprocessticks (used for anti aim or some shit, just needed for being accurate)
        if data.validate_cmd > 0 then
            data.validate_cmd = data.validate_cmd - 1
        end

        -- create two bool values from our function
        local ushift = can_shift(local_player, local_player_weapon, 13)
        local absshift = can_shift(local_player, local_player_weapon, math.abs(-1 - shift))
        
        -- we're going to use them to set did shift before in our data set
        if ushift == true or absshift == false and data.did_shift_before == true then
            shift = 13
        else
            shift = 0
        end

        -- get our tickbase again (last time it wasn't in scope)
        local local_tickbase = entity.get_prop(local_player, "m_nTickBase")
        -- essentially (...) a check for tickbase being too low to charge
        if data.old_tickbase ~= 0 and local_tickbase < data.old_tickbase then
            if data.old_tickbase - local_tickbase > 11 then
                data.skip_next_differ = true
                data.charged_before = false
                data.can_shift_tickbase = false
            end
        end

        -- get an accurate command number
        local current_cmd_num = player.command_number - data.old_command_num
        -- accurate tickbase calculations (...)
        if current_cmd_num >= 11 and current_cmd_num <= ui.get(maxusrcmdprocessticks) then
            data.can_shift_tickbase = not data.skip_next_differ
            data.charged_before = data.can_shift_tickbase
            data.last_charge = current_cmd_num + 1
            data.is_cmd_safe = current_cmd_num > 3 and math.abs(ui.get(maxusrcmdprocessticks) - current_cmd_num) <= 3
            data.delay = math.abs(ui.get(maxusrcmdprocessticks) - data.last_charge)
            
            indicator.recharge = true
            indicator.recharge_timer = globals.curtime()
            indicator.recharge_label = string.format("[+] Recharge | %sms | shift: %s", data.delay, data.last_charge)
            indicator.recharge_alpha = 255
        end

        -- more checks if we can shift
        if ushift == false then
            data.can_shift_tickbase = false
        else
            data.can_shift_tickbase = data.charged_before
        end

        -- set our values at the end of prediction so we can compare next time
        data.old_tickbase = local_tickbase
        data.old_command_num = player.command_number
        data.skip_next_differ = false
        data.did_shift_before = shift ~= 0
        data.can_shift_tickbase = data.can_shift_tickbase and 2 or 0

        -- if we're waiting to recharge then can shift is 1
        if data.can_shift_tickbase == 0 and data.charged_before == true then
            data.can_shift_tickbase = 1
        end

        -- if we can't charge then charge is 0
        if data.can_shift_tickbase == 0 then
            data.last_charge = 0
        end
    end

    -- setup, we're going to run our checks here and finalise our data
    local on_setup_cmd = function(player)
        -- disable dt if we are lagging or if we are breaking lby (opposite aa)
        if data.lag_state ~= nil and data.can_break_lby then
            ui.set(dt, data.lag_state)
            data.lag_state = nil
        end

        -- create a bunch of variables
        -- we're going to use all of these for our checks
        local is_fast = ui.get(mode) == "Fast" or ui.get(mode) == "Instant"
        local dt_enabled = ui.get(dt) and ui.get(dt_key)
        local player_can_shift = data.can_shift_tickbase
        local is_offensive = dt_enabled and ui.get(dt_mode) == "Offensive"
        local should_attack = false
        local local_player_velocity = {entity.get_prop(entity.get_local_player(), "m_vecVelocity")}
        local floored_velocity = math.floor(math.sqrt(local_player_velocity[1] ^ 2 + local_player_velocity[2] ^ 2 + local_player_velocity[3] ^ 2) + 0.5)
        local will_attack = false
        data.can_break_lby = false
        
        if shift_info.shift_time > 0 then
            -- back up last charge for accurate calucations
            local current_last_charge = data.last_charge
            -- use the fucked up function to unpack data
            local shift_info_data_unpacked = shift_info.data[by(shift_info.data)]
            
            -- if we're using a faster mode and if our data isn't nil or negative (?)
            if is_fast and by(shift_info.data) > 0 and shift_info_data_unpacked ~= nil then
                -- essentially (...) just sanity for if player is attacking
                player.in_attack = 1
                if shift_info.shift_time == current_last_charge or current_last_charge < 1 then
                    should_attack = true
                    will_attack = true
                end
                if should_attack and player.in_attack == 0 then
                    player.in_attack = 1
                end
            end

            -- update the data (shift time, can shift, choked cmd, tickbase, tickcount, dt enabled, ...)
            shift_info.shift_data[#shift_info.shift_data + 1] = {
                shift_info.shift_time,
                player_can_shift,
                player.chokedcommands,
                entity.get_prop(entity.get_local_player(), "m_nTickBase"),
                globals.tickcount(),
                "false"
            }

            -- getting bored of this data bullshit (...)
            if shift_info.shift_time ~= 0 and (will_attack == true or shift_info.shift_time == current_last_charge or current_last_charge < 1) then
                shift_info.shift_time = 0
                shift_info.shift_data = {}
                shift_info.data = {}
            else
                shift_info.shift_time = shift_info.shift_time + 1
            end
        end

        -- update our data for accuracy (velocity, dt mode, if we are attacking, ...)
        if shift_info.shift_time == 0 and should_attack == false and (is_offensive == true and player_can_shift == 0 or floored_velocity <= 1.01 and player_can_shift == 2) then
            data.lag_state = dt_enabled
            if by(shift_info.shift_data) > 0 then
                shift_info.shift_data[by(shift_info.shift_data)][6] = tostring(dt_enabled)
            end
        end

        -- do this again because we changed data
        if data.lag_state ~= nil and data.can_break_lby then
            ui.set(dt, false)
        end
    end

    -- math shit, mostly vectors, we will use for our breaking lagcomp check
    local vec_data, flip = { }, true
    local length_2d_sqr = function(vec) return (vec[1]*vec[1] + vec[2]*vec[2]) end
    local vec_enemy_vec = function(vec, vec1) return { vec[1]-vec1[1], vec[2]-vec1[2] } end
    local function normalize_yaw(angle)
        angle = (angle % 360 + 360) % 360
        return angle > 180 and angle - 360 or angle
    end
    local function world2screen(xdelta, ydelta)
        if xdelta == 0 and ydelta == 0 then
            return 0
        end
        return math.deg(math.atan2(ydelta, xdelta))
    end

    -- best entity shit
    local best_player  = function()
        local idx = nil
        local close = math.huge
    
        local myorigin = {entity.get_origin(lp())}
        local myview = {client.camera_angles()}
        local enemies = entity.get_players(true)
    
        for i=1, #enemies do 
            if entity.is_alive(i) and entity.is_enemy(i) and entity.is_dormant(i) == false then
                local origin = {entity.get_origin(i)}
                if origin[1] then
                    local fov = math.abs(normalize_yaw(world2screen(origin[1] - myorigin[1], origin[2] - myorigin[2]) - myview[2]))
                    if fov < close then
                        idx = i
                        close = fov
                    end
                end
            end
        end
        return idx
    end

    -- finally check if closest enemy is breaking lagcomp
    -- this is kinda scuffed but I can't think of a better way rn 
    local lagcomp = function()
        if (vec_data[0] and vec_data[1]) then
            local lag_dst = length_2d_sqr(vec_enemy_vec(vec_data[0], vec_data[1]))

            lag_dst = lag_dst - 64 * 64 
            lag_dst = lag_dst < 0 and 0 or lag_dst / 30
            lag_dst = lag_dst > 62 and 62 or lag_dst

            -- its same to assume that anyone with a lag distance more than 0 is going to be breaking
            if lag_dst > 0 then return true end
            return false
        end
    end

    -- make a function to check if closest enemy is vulnerable
    local enemy_vuln = function()
        local enemy = best_player()
        local enemy_weapon = entity.get_player_weapon(enemy)
        local enemy_weapon_classname = entity.get_classname(enemy_weapon)

        if enemy == nil then return false end
        local local_origin = vector(entity.get_prop(entity.get_local_player(), "m_vecAbsOrigin"))
		local distance = local_origin:dist(vector(entity.get_prop(enemy, "m_vecOrigin")))
        local enemy_health = entity.get_prop(enemy, "m_iHealth")
		local damage = calc_dmg(entity.get_local_player(), enemy, distance)

        if enemy_health <= damage then return true end

        for i=0, #vulnerable_items do
            if enemy_weapon_classname == vulnerable_items[i] then 
                return true
            end
        end

        return false
    end
    
    -- make a check for if local player is vulnerable
    -- enemy has awp or enemy has scout and we are lethal
    -- or we low hp
    local local_vuln = function()
        local enemy_weapon = entity.get_player_weapon(best_player())
        local enemy_weapon_classname = entity.get_classname(enemy_weapon)

        local enemy_origin = vector(entity.get_prop(entity.get_local_player(), "m_vecAbsOrigin"))
		local distance = enemy_origin:dist(vector(entity.get_prop(best_player(), "m_vecOrigin")))
		local local_health = entity.get_prop(entity.get_local_player(), "m_iHealth")
		local damage = calc_dmg(best_player(), entity.get_local_player(), distance)

        if best_player() ~= nil then
            if enemy_weapon_classname == "CWeaponAwp" then 
                return true
            end
        end

        return false
    end

    -- function to convert units to feet
    -- for hitchance handling
    local units_to_feet = function(units)
        local units_to_meters = units * 0.0254
    
        return units_to_meters * 3.281
    end

    -- gonna make a function to easily set dt values
    local dt_set = function(fl, cmd, clock)
        ui.set(dt_fake_lag, fl)
        ui.set(maxusrcmdprocessticks, cmd)
        cvar.cl_clock_correction:set_int(clock)
    end

    -- simple finalisation for our double tap modes
    -- we can run our dynamic checks in here
    local on_run_cmd = function(cmd)
        -- disable dt if we are lagging or if we are breaking lby (opposite aa)
        if data.lag_state ~= nil and data.can_break_lby then
            ui.set(dt, data.lag_state)
            data.lag_state = nil
        end

        -- we're going to set up our data for lagcompensation check
        if best_player() ~= nil and cmd.chokedcommands == 0 then
            local x, y, z = entity.get_prop(best_player(), "m_vecOrigin")
            vec_data[flip and 0 or 1] = { x, y }
            flip = not flip
        end
        
        -- finally we set our maxusrcmdprocessticks and double tap fake lag based on our dt mode
        -- we won't use is_cmd_safe on instant because it should always be 1
        -- but for fast and consistent we will run a check because consistency is key
        -- we're going to use clock correction to get even faster double tap
        -- necessarily speaking it sets our values to unsafe but if what we want is speed it's no issue
        -- considering it's unsafe I've seperated the modes out and will only use it on instant
        
        if ui.get(mode) == "Instant" then
            dt_set(1, 19, data.is_cmd_safe and 0 or 1)
        end
        
        if ui.get(mode) == "Fast" then
            dt_set(data.is_cmd_safe and 1 or 2, 18, 1)
        end

        if ui.get(mode) == "Consistent" then
            dt_set(data.is_cmd_safe and 1 or 2, 17, 1)
        end

        -- this code gets fucking ugly
        -- I don't want to code some kind of tier system so, I will just do if after if in order
        if ui.get(mode) == "Dynamic" then
            if contains(dynamic, "Handle hitchance") then
                local local_origin = vector(entity.get_prop(entity.get_local_player(), "m_vecAbsOrigin"))
		        local distance = local_origin:dist(vector(entity.get_prop(best_player(), "m_vecOrigin")))

                -- if no entity or we can't get the distance
                -- just set hc to 1
                if (distance == nil) then
                    ui.set(dt_hit_chance, 1)
                    return
                end

                distance = units_to_feet(distance)

                -- set hit chance to 'rounded' 
                if distance <= 100 then
                    ui.set(dt_hit_chance, math.floor(50 * (distance / 100) + 0.5))
                end

                -- if above 100ft away just set to 50
                if distance > 100 then
                    ui.set(dt_hit_chance, 50)
                end
            end

            if contains(dynamic, "Local vulnerability") and local_vuln() then
                dt_set(1, 19, data.is_cmd_safe and 0 or 1)
            elseif contains(dynamic, "Enemy vulnerability") and enemy_vuln() then
                dt_set(1, 19, data.is_cmd_safe and 0 or 1)
            else
                if contains(dynamic, "Enemy lagcompensation") and lagcomp() == true then
                    dt_set(data.is_cmd_safe and 1 or 2, 17, 1)
                else
                    if contains(dynamic, "Latency") then
                        local latency = math.floor(math.min(1000, client.latency() * 1000) + 0.5)
                        local latency_value = math.floor(latency / 25)
                        -- we take our latency value and create 4 different thresholds 
                        latency_value = latency_value < 3 and latency_value or 3
                        -- use our threshold to set a value based on ping
                        local value_to_set = ({[3] = 16, [2] = 17, [1] = 18, [0] = 19})[latency_value]
                        dt_set(1, value_to_set, 1)
                    else
                        -- if nothing else is triggered or enabled we will check safe cmd and set a fast mode
                        dt_set(1, data.is_cmd_safe and 19 or 18, data.is_cmd_safe and 0 or 1)
                    end
                end
            end
        end
    end

    -- on net update is I guess the best place to check our ticks
    local on_net_update = function()
        -- get ticks, tick count and sim time (local player)
        local ticks = globals.tickinterval()
        local tick_count = globals.tickcount()
        local simulation_time = entity.get_prop(entity.get_local_player(), "m_flSimulationTime")
        if simulation_time ~= nil then
            -- if sim time is different
            if data.old_sim_time ~= simulation_time then
                -- shifted ticks is euqal to our current sim time over the current tick interval minus overall tick count
                data.shifted_ticks = (simulation_time/ticks - tick_count)
                data.old_sim_time = simulation_time
            end
        end
    end

    -- paint functions we need for the fucking disgusting rainbow
    local function hsv_to_rgb(h, s, v)
        local r, g, b
    
        local i = math.floor(h * 6);
        local f = h * 6 - i;
        local p = v * (1 - s);
        local q = v * (1 - f * s);
        local t = v * (1 - (1 - f) * s);
    
        i = i % 6
    
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        elseif i == 5 then r, g, b = v, p, q
        end
    
        return r * 255, g * 255, b * 255
    end
    local function rainbow(frequency, rgb_split_ratio)
        local r, g, b, a = hsv_to_rgb(globals.realtime() * frequency, 1, 1, 1)
    
        r = r * rgb_split_ratio
        g = g * rgb_split_ratio
        b = b * rgb_split_ratio
        return r, g, b
    end

    -- we'll use bullet impact for telling us if we shot
    -- if we used aim_fire it would only tell us if the ragebot shot
    local on_bullet_impact = function(c)
        if entity.is_alive(entity.get_local_player()) then
            local ent = client.userid_to_entindex(c.userid)
            if entity.get_local_player() == ent then
                if ui.get(dt) and ui.get(dt_key) then
                    local latency = math.min(999, client.latency() * 1000)
                    -- simple shit, if we were the one that shot then show an indicator
                    indicator.shot = true
                    indicator.shot_timer = globals.curtime()
                    indicator.shot_label = string.format("[-] Fired DT | %sms %s| safe: %s", math.floor(latency + 0.5), contains(dynamic, "Handle hitchance") and string.format("| hc: %s ", ui.get(dt_hit_chance)) or "", data.is_cmd_safe)
                    indicator.shot_alpha = 255
                end
            end
        end
    end

    -- ui callback so we can set visibility regardless of in game/dead/alive 
    local on_paint_ui = function()
        local e = ui.get(mode) == "Off"
        ui.set_visible(indic, not e)
        ui.set_visible(picker, not e)
        ui.set_visible(indic_options, ui.get(indic) and not e)

        local d = ui.get(mode) == "Dynamic"
        ui.set_visible(dynamic, d)

        ui.set_visible(maxusrcmdprocessticks, false)
    end

    -- I'm not commenting ANY of this I can't be assed it's an indicator (wow)
    -- currently the way I handle indicators needs improving, right now I just use a data set and change bool/alpha values
    
    --local surface  = require("gamesense/surface") or client.error_log("[smoldt] Surface library required:\nhttps://gamesense.pub/forums/viewtopic.php?id=18793")
    -- we'll need images for player icon
    local images = require("gamesense/images") or client.error_log("[smoldt] Images library required:\nhttps://gamesense.pub/forums/viewtopic.php?id=22917")

    local on_paint = function()
        if not entity.is_alive(entity.get_local_player()) then data.last_charge = 0 end
        if not entity.is_alive(lp()) then return end
        if not ui.get(indic) then return end
        if ui.get(mode) == "Off" then return end

        local r, g, b, a = ui.get(picker)
        local rr, gr, br = rainbow(0.5, 1)

        local hincrement = 12 * globals.frametime()
        local hdecrement = 3 * globals.frametime()
        local increment = 6 * globals.frametime()
        local decrement = 5 * globals.frametime()
        
        if ui.get(dt) and ui.get(dt_key) or ui.is_menu_open() or contains(indic_options, "Always on") or not entity.is_alive(entity.get_local_player()) then
            indicator.alpha = indicator.alpha + decrement
            if indicator.alpha > 1 then
                indicator.alpha = 1
            end
        else
            indicator.alpha = indicator.alpha - decrement
            if indicator.alpha <= 0 then
                indicator.alpha = 0
            end
        end

        if ui.get(dt) and ui.get(dt_key) and (data.can_shift_tickbase == 2 or data.shifted_ticks < 0) then
            indicator.hbar = indicator.hbar + hincrement
            if indicator.hbar > 1 then
                indicator.hbar = 1
            end
            
            indicator.bar = indicator.bar + increment
            if indicator.bar > 1 then
                indicator.bar = 1
            end
        else
            indicator.hbar = indicator.hbar - hdecrement
            if indicator.hbar <= 0 then
                indicator.hbar = 0
            end

            indicator.bar = indicator.bar - decrement
            if indicator.bar <= 0 then
                indicator.bar = 0
            end
        end

        if indicator.shot == true then
            if globals.curtime() >= indicator.shot_timer then
                indicator.shot_alpha = indicator.shot_alpha - 1
            end
            if indicator.shot_alpha <= 0 then
                indicator.shot_alpha = 0
                indicator.shot = false
            end
        end

        if indicator.recharge == true then
            if globals.curtime() >= indicator.recharge_timer then
                indicator.recharge_alpha = indicator.recharge_alpha - 1
            end
            if indicator.recharge_alpha <= 0 then
                indicator.recharge_alpha = 0
                indicator.recharge = false
            end
        end

        indicator.label = string.format("smoldt [%s] | tickbase: %s%s", ui.get(mode), data.last_charge, contains(indic_options, "Player name") and string.format(" | %s", entity.get_player_name(lp())) or "")

        indicator.width, indicator.height = renderer.measure_text(nil, indicator.label)

        local w = contains(indic_options, "Player icon") and indicator.width + 18 or indicator.width

        local x, y = indicator.pos:get()

        renderer.rectangle(x - 1, y - 2, w + 10, 2, 90, 90, 90, indicator.alpha * 255)
        renderer.rectangle(x - 1, y - 2, indicator.hbar * (w + 10), 2, 255, 255, 255, indicator.alpha * 255)

        if contains(indic_options, "Rainbow (fading)") then
            renderer.rectangle(x - 1, y - 2, indicator.bar * (w + 10), 2, rr, gr, br, indicator.alpha * 255)
        else
            renderer.rectangle(x - 1, y - 2, indicator.bar * (w + 10), 2, r, g, b, indicator.alpha * a)
        end

        renderer.rectangle(x - 1, y - 2, indicator.bar * (w+ 10), 1, 150, 150, 150, indicator.alpha * 150)

        renderer.rectangle(x - 1, y, w + 10, indicator.height + 5, 0, 0, 0, indicator.alpha * 40)
        renderer.text(x + 4, y + 2, 255, 255, 255, indicator.alpha * 255, "", 0, indicator.label)

        if contains(indic_options, "Player icon") then
            local steamid3 = entity.get_steam64(lp())
            local avatar = images.get_steam_avatar(steamid3)
            avatar:draw(x + w - 9, y + 2, 13, 13, 255, 255, 255, indicator.alpha * 255, true, "f")
        end

        if indicator.shot == true and ui.get(dt) and ui.get(dt_key) then
            renderer.text(x + 2, y + 6 + indicator.height, 255, 255, 255, 255 - (255 * indicator.shot_alpha), "", 0, indicator.shot_label)
        end

        if indicator.recharge == true and indicator.shot ~= true and ui.get(dt) and ui.get(dt_key) then
            renderer.text(x + 2, y + 6 + indicator.height, 255, 255, 255, 255 - (255 * indicator.recharge_alpha), "", 0, indicator.recharge_label)
        end

        indicator.pos:drag(w + 10, indicator.height + 5)
    end

    -- when the lua is unloaded shutdown will run, we'll use it to reset things like maxusrcmd
    local on_shutdown = function()
        ui.set(maxusrcmdprocessticks, 16)
        cvar.cl_clock_correction:set_int(1)
    end
    -- we can create our own callback so that if our mode is set to disabled, shutdown will also run
    ui.set_callback(mode,function() if ui.get(mode) == "Off" then on_shutdown() end end)

    -- callbacks (predict, setup, run, paint, ...)
    client["set_event_callback"]("predict_command", on_predict_cmd)
    client["set_event_callback"]("setup_command", on_setup_cmd)
    client["set_event_callback"]("run_command", on_run_cmd)
    client["set_event_callback"]("paint", on_paint)
    client["set_event_callback"]("paint_ui", on_paint_ui)
    client["set_event_callback"]("bullet_impact", on_bullet_impact)
    client["set_event_callback"]("net_update_start", on_net_update)
    client["set_event_callback"]("shutdown", on_shutdown)