--Mod : Colorful
--© Lars Müller @appguru.eu, licensed under GNU GPL v3
HEX={"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
local function toHex(number)
	local result=""
	result=result..HEX[number % 16+1]
	result=result..HEX[((number - (number % 16)) / 16) % 16+1]
    return result:reverse()
end

function create_colortable(r_steps, g_steps, b_steps, a, extreme, nodename, save_as)
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
    local r_step=255/rs
    local b_step=255/bs
    local g_step=255/gs
    for r = 1,rs,1 do
        for b = 1,bs,1 do
            for g = 1,gs,1 do
            	local red=r_step*r
            	local blue=b_step*b
            	local green=g_step*g
                local register_as="colorful:"..nodename.."_"..red.."_"..green.."_"..blue
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

function register_all_nodes(r_steps, g_steps, b_steps, a, extreme, nodename, node, save_as)
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
                for key, value in ipairs(node) do
    	            copied_table[key]=value
                end
            	for index, tile in ipairs(node["tiles"]) do
                     tiles_colorized[index]=tile.."^[colorize:#"..toHex(red)..toHex(green)..toHex(blue)..alpha
                end
                copied_table["tiles"]=tiles_colorized
                copied_table["description"]=node["description"]..", Color : Red : "..red..", Green : "..green..", Blue : "..blue
                local register_as="colorful:"..nodename.."_"..red.."_"..green.."_"..blue
                minetest.register_node(register_as, copied_table)
                if save_as then
		            result=result.."\n"..red..","..green..","..blue..",255-"..register_as
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

function register_all_items(r_steps, g_steps, b_steps, a, extreme, itemname, item)
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
                for key, value in ipairs(item) do
    	            copied_table[key]=value
                end
            	copied_table["inventory_image"]=item["inventory_image"].."^[colorize:#"..toHex(red)..toHex(green)..toHex(blue)..alpha
            	if copied_table["wield_image"] then
            	    copied_table["wield_image"]=item["wield_image"].."^[colorize:#"..toHex(red)..toHex(green)..toHex(blue)..alpha
                else
                    copied_table["wield_image"]=item["inventory_image"].."^[colorize:#"..toHex(red)..toHex(green)..toHex(blue)..alpha
                end
                copied_table["description"]=item["description"]..", Color : Red : "..red..", Green : "..green..", Blue : "..blue
                minetest.register_craftitem("colorful:"..itemname.."_"..red.."_"..green.."_"..blue, copied_table)
            end
        end
    end
end

register_all_items(4,4,4, 100, true, "colored_paper", { --Colored Paper, specs out of default/craftitems.lua
	description = "Paper",
	inventory_image = "default_paper.png",
})

register_all_nodes(4,4,4, 100, true, "colored_stone" , { --Colored Stone, specs out of default/nodes.lua
	description = "Stone",
	tiles = {"default_stone.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
}--[[, "colored_stone.anl"]] --[[Saves an .anl file]])
