--Mod : Colorful Library v1.1
--© Lars Müller @appguru.eu, licensed under GNU GPLv3
--Library Usage : 
--Functions : 
--Basic : 
--toHex <number> - Converts <number>(0-255) to a hexadecimal string
--round <number> - Rounds <number>
--Advanced : 
--Arguments : 
--<r/g/b_steps> - How many red/green/blue levels
--<a> - Alpha level of the colorize/color overlay
--<extreme> - If even r/g/b steps(dividable by 2) are added 1
--<generate_crafts> - Can a new color be crafted by combining two colors
--create_colortable <r_steps> <g_steps> <b_steps> <extreme> <nodename> Creates a color table, each <nodename> node is assigned to a color 
--save_colortable <r_steps> <g_steps> <b_steps> <extreme> <nodename> <save_as> Same as above, but saves the color table as .anl
--Register-Functions : 
--Note : , Color : Red : ..., Green : ..., Blue : ... is appended to the description automatically, #color in the tile/inventory/wield-image string is replaced with the color, if not specified, appended automatically
--register_all_nodes <r_steps> <g_steps> <b_steps> <a> <extreme> <nodename> <node(data)> <generate_crafts> <append> <save_as> 
--1. Append specifies whether the color should be applied to the drop, drop should be registered in same colors, except if you want to make the nodes drop themselves. Only works if a drop is specified in <node(data)>
--2. If save_as is set this function offers save_colortable functionality besides its normal
--register_all_items <r_steps> <g_steps> <b_steps> <a> <extreme> <itemname> <item(data)> <generate_crafts>

HEX = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
local function toHex(number) --Converts a number from 0-255 into a hexadecimal string
	local result=""
	result=result..HEX[number % 16+1]
	result=result..HEX[((number - (number % 16)) / 16) % 16+1]
    return result:reverse()
end
local function round(number) --Rounds a number
    return math.floor(number+0.5)
end

function create_colortable(r_steps, g_steps, b_steps, extreme, nodename) --Creates a colortable for r/g/b steps using specified nodename
    local t={}
	local colors={}
    local rs=r_steps
    local bs=b_steps
    local gs=g_steps
    if extreme then
    	if r_steps % 2 == 0 then
            rs=rs+1
        end
        if b_steps % 2 == 0 then
            bs=bs+1
        end
        if g_steps % 2 == 0 then
            gs=gs+1
        end
    end
    local r_step=255/rs
    local b_step=255/bs
    local g_step=255/gs
    for r = 1,rs,1 do
        for b = 1,bs,1 do
            for g = 1,gs,1 do
            	local red=r_step*r
            	local blue=b_step*b
            	local green=g_step*g
                local register_as=nodename.."_"..red.."_"..green.."_"..blue
                t[red..","..green..","..blue]=register_as
            end
        end
    end
    return t
end

function save_colortable(r_steps, g_steps, b_steps, extreme, nodename, save_as) --Saves a colortable for r/g/b steps using specified nodename
    local result=""
	local colors={}
    local rs=r_steps
    local bs=b_steps
    local gs=g_steps
    if extreme then
    	if r_steps % 2 == 0 then
            rs=rs+1
        end
        if b_steps % 2 == 0 then
            bs=bs+1
        end
        if g_steps % 2 == 0 then
            gs=gs+1
        end
    end
    local r_step=255/rs
    local b_step=255/bs
    local g_step=255/gs
    for r = 1,rs,1 do
        for b = 1,bs,1 do
            for g = 1,gs,1 do
            	local red=r_step*r
            	local blue=b_step*b
            	local green=g_step*g
                local register_as=nodename.."_"..red.."_"..green.."_"..blue
                if save_as then
		            result=result.."\n"..red..","..green..","..blue..",255-"..register_as
                end
            end
        end
    end
    result=string.sub(result, 2)
    file=io.open(save_as, "w+")
    file:write(result)
    file:close()
end

function register_all_nodes(r_steps, g_steps, b_steps, a, extreme, nodename, node, generate_crafts, append, save_as) --Register all nodes with specified values
    local result=""
	local alpha=toHex(a)
	local colors={}
    local rs=r_steps
    local bs=b_steps
    local gs=g_steps
    if extreme then
    	if r_steps % 2 == 0 then
            rs=rs+1
        end
        if b_steps % 2 == 0 then
            bs=bs+1
        end
        if g_steps % 2 == 0 then
            gs=gs+1
        end
    end
    local items={}
    if generate_crafts then
        items=create_colortable(r_steps, g_steps, b_steps, extreme, nodename)
    end
    local r_step=255/rs
    local b_step=255/bs
    local g_step=255/gs
    for r = 1,rs,1 do
        for b = 1,bs,1 do
            for g = 1,gs,1 do
            	local red=r_step*r
            	local blue=b_step*b
            	local green=g_step*g
            	local tiles_colorized={}
            	local copied_table={}
            	local color=toHex(red)..toHex(green)..toHex(blue)..alpha
                for key, value in pairs(node) do
    	            copied_table[key]=value
                end
            	for index, tile in pairs(node["tiles"]) do
            		if not string.match(tile,"#color") then
                        tiles_colorized[index]=tile.."^[colorize:#"..color
                    else 
                        tiles_colorized[index]=string.gsub(tile,"#color","^[colorize:#"..color)
                    end
                end
                if append then 
                    if type(node["drop"])=="table" then
                    	local drop_items={}
                        for index, drop in ipairs(node["drop"]["items"]) do
                            drop_items[index]=drop.."_"..red.."_"..green.."_"..blue
                        end
                        copied_table["drop"]["items"]=drop_items
                    elseif copied_table["drop"] then
                        copied_table["drop"]=copied_table["drop"].."_"..red.."_"..green.."_"..blue
                    end
                end
                copied_table["tiles"]=tiles_colorized
                if copied_table["inventory_image"] then
                	if not string.match(copied_table["inventory_image"],"#color") then
                        copied_table["inventory_image"]=copied_table["inventory_image"].."^[colorize:#"..color
                    else 
                        copied_table["inventory_image"]=string.gsub(copied_table["inventory_image"],"#color","^[colorize:#"..color)
                    end
                end
            	if copied_table["wield_image"] then
            	    if not string.match(copied_table["wield_image"],"#color") then
                        copied_table["wield_image"]=copied_table["wield_image"].."^[colorize:#"..color
                    else 
                        copied_table["wield_image"]=string.gsub(copied_table["wield_image"],"#color","^[colorize:#"..color)
                    end
                end
                if copied_table["description"] then
            	    if not string.match(copied_table["description"],"#color") then
                        copied_table["description"]=copied_table["description"]..node["description"]..", Color : Red : "..red..", Green : "..green..", Blue : "..blue
                    else 
                        copied_table["description"]=string.gsub(copied_table["description"],"#color",", Color : Red : "..red..", Green : "..green..", Blue : "..blue)
                    end
                end
                local register_as=nil
                if not string.match(nodename,"#color") then
                    register_as=nodename.."_"..red.."_"..green.."_"..blue
                else
                    register_as=string.gsub(nodename, "#color", red.."_"..green.."_"..blue)
                end
                minetest.register_node(register_as, copied_table)
                if save_as then
		            result=result.."\n"..red..","..green..","..blue..",255-"..register_as
                end
                if generate_crafts then
                    for color_value, name in pairs(items) do
                        local splut=color_value:split(",")
                        local red_value=round((tonumber(splut[1])+red)/2/r_step)*r_step
                        local green_value=round((tonumber(splut[2])+green)/2/b_step)*b_step
                        local blue_value=round((tonumber(splut[3])+blue)/2/g_step)*g_step
                        minetest.register_craft({
	               		    type = "shapeless",
	                	    output = nodename.."_"..red_value.."_"..green_value.."_"..blue_value.." 2",
							recipe = {name, register_as},
						})
                    end
                end
            end
        end
    end
    if save_as then
        result=string.sub(result, 2)
        file=io.open(save_as, "w+")
        file:write(result)
        file:close()
    end
end

function register_all_items(r_steps, g_steps, b_steps, a, extreme, itemname, item, generate_crafts) --Register all items with specified values
	local alpha=toHex(a)
	local colors={}
    local rs=r_steps
    local bs=b_steps
    local gs=g_steps
    if extreme then
    	if r_steps % 2 == 0 then
            rs=rs+1
        end
        if b_steps % 2 == 0 then
            bs=bs+1
        end
        if g_steps % 2 == 0 then
            gs=gs+1
        end
    end
    local items={}
    if generate_crafts then
        items=create_colortable(r_steps, g_steps, b_steps, extreme, itemname)
    end
    local r_step=255/rs
    local b_step=255/bs
    local g_step=255/gs
    for r = 1,rs,1 do
        for b = 1,bs,1 do
            for g = 1,gs,1 do
            	local red=r_step*r
            	local blue=b_step*b
            	local green=g_step*g
            	local color=toHex(red)..toHex(green)..toHex(blue)..alpha
            	local tiles_colorized={}
            	local copied_table={}
                for key, value in ipairs(item) do
    	            copied_table[key]=value
                end
            	if copied_table["inventory_image"] then
                    if not string.match(copied_table["inventory_image"],"#color") then
                        copied_table["inventory_image"]=copied_table["inventory_image"].."^[colorize:#"..color
                    else 
                        copied_table["inventory_image"]=string.gsub(copied_table["inventory_image"],"#color","^[colorize:#"..color)
                    end
                end
                if copied_table["wield_image"] then
                    if not string.match(copied_table["wield_image"],"#color") then
                        copied_table["wield_image"]=copied_table["wield_image"].."^[colorize:#"..color
                    else 
                        copied_table["wield_image"]=string.gsub(copied_table["wield_image"],"#color","^[colorize:#"..color)
                    end
                end
                if copied_table["description"] then
            	    if not string.match(copied_table["description"],"#color") then
                        copied_table["description"]=copied_table["description"]..node["description"]..", Color : Red : "..red..", Green : "..green..", Blue : "..blue
                    else 
                        copied_table["description"]=string.gsub(copied_table["description"],"#color",", Color : Red : "..red..", Green : "..green..", Blue : "..blue)
                    end
                end
                local register_as=nil
                if not string.match(nodename,"#color") then
                    register_as=itemname.."_"..red.."_"..green.."_"..blue
                else
                    register_as=string.gsub(nodename, "#color", red.."_"..green.."_"..blue)
                end
                minetest.register_craftitem(register_as, copied_table)
                if generate_crafts then
                    for color_value, name in pairs(items) do
                        local splut=color_value:split(",")
                        local red_value=round((tonumber(splut[1])+red)/2/r_step)*r_step
                        local green_value=round((tonumber(splut[2])+green)/2/b_step)*b_step
                        local blue_value=round((tonumber(splut[3])+blue)/2/g_step)*g_step
                        minetest.register_craft({
	               		    type = "shapeless",
	                	    output = itemname.."_"..red_value.."_"..green_value.."_"..blue_value.." 2",
							recipe = {name, register_as},
						})
                    end
                end
            end
        end
    end
end
