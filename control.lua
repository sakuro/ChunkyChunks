-- ChunkyChunks. Factorio mod: Show grid lines.
-- Copyright (C) 2016  Qon

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>

local SHORTCUT_NAME = 'chunkychunks-toggle'
local HOTKEY_EVENT_NAME = 'chunkychunks-toggle'

local map = require('lib.functional').map
local fnn = require('lib.functional').fnn

local GRIDS_COUNT = 3
local BLOCK_SIZE = 1e4

function player_block(player_index, size, offset)
    local p = game.players[player_index]
    local sizemax = math.max(size[1], size[2])
    local pos = fromXY(p.position)
    local r = math.max(170, sizemax * 2)
    local topleft = sub(pos, {r, r})
    local bottomright = add(pos, {r, r})
    return {topleft = topleft, bottomright = bottomright}
end

function chunky(players, surface, topleft, bottomright, size, offset, spacing, color, only_in_alt_mode)
    topleft = sub(topleft, offset)
    topleft = map(topleft, function(q, i) return math.ceil(topleft[i] / size[i]) * size[i] end)
    topleft = add(topleft, offset)
    topleft = sub(topleft, size)
    bottomright = sub(bottomright, offset)
    bottomright = map(bottomright, function(q, i) return math.floor(bottomright[i] / size[i]) * size[i] end)
    bottomright = add(bottomright, offset)
    -- bottomright = add(bottomright, size)

    local sizemax = math.max(size[1], size[2])
    local width = math.ceil(sizemax / 16)

    local lines = {}
    for x = 1, 2 do
        local y = 3 - x
        if spacing[x] < size[x] / 2 then
            for square = -1, spacing[1] ~= 0 and spacing[x] >= 0 and 1 or 0, 2 do
                for xy = topleft[y], bottomright[y], size[y] do
                    local iterdim = xy + square * spacing[y] * (spacing[x] >= 0 and 1 or 0)
                    local space = math.max(0, math.abs(spacing[x]) * 2)
                    local dash_length = size[x] - space
                    if spacing[x] < 0 then
                        local tmp = dash_length
                        dash_length = math.min(space, size[x])
                        space = math.max(0, tmp)
                    end
                    table.insert(lines, rendering.draw_line{
                      color = color, width=width,
                      gap_length = space, dash_length = dash_length,
                      from = {[x] = topleft[x] + spacing[x], [y] = iterdim},
                      to =   {[x] = bottomright[x],          [y] = iterdim},
                      surface = surface,
                      players = players,
                      draw_on_ground = true,
                      only_in_alt_mode = only_in_alt_mode
                    })
                end
            end
        end
    end
    return lines
end

-- function enabled(player_index, set)
--     local p = game.players[player_index]
--     if set ~= nil then
--         p.set_shortcut_toggled(SHORTCUT_NAME, set)
--     end
--     return p.is_shortcut_toggled(SHORTCUT_NAME)
-- end

function enabled(player_index, set)
    local player = game.players[player_index]
    local player_settings = settings.get_player_settings(player)
    if set == nil then
        local enabled = false
        for g = 1, GRIDS_COUNT do
            local a = map({'enabled'}, function(q) return player_settings['chunkychunks-'..q..'-'..g].value end)
            if a[1] ~= 'Disabled' then
                enabled = true
                break
            end
        end
        return enabled
    end
    for g = 1, GRIDS_COUNT do
        local a = map({'enabled'}, function(q) player_settings['chunkychunks-'..q..'-'..g] = {value = set and 'Always' or 'Disabled'} end)
        -- player.set_shortcut_toggled(SHORTCUT_NAME, set) -- set in on_runtime_mod_setting_changed handler
    end
end

function toggle(event)
    -- game.print(helpers.table_to_json(event))
    if event.input_name ~= HOTKEY_EVENT_NAME and event.prototype_name ~= SHORTCUT_NAME then return end
    enabled(event.player_index, not enabled(event.player_index))
end

function printOrFly(p, text)
    if p.character ~= nil then
        p.create_local_flying_text({
            ['text'] = text,
            ['position'] = p.character.position,
            -- time_to_live = 2,
        })
    else
        p.print(text)
    end
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function parseDoubles(s)
    local a = s:split(' ')
    return fnn(map(a, function(q) if string.match(q, "^%-?%d+%.?%d*$") then return q + 0 else return nil end end))
end
function makeLen2(v)
    if #v == 1 then return {v[1], v[1]} end
    if #v == 2 then return {v[1], v[2]} end
    return nil
end
function parseXY(s)
    local v = parseDoubles(s)
    if #v == 1 then return {x = v[1], y = v[1]} end
    if #v == 2 then return {x = v[1], y = v[2]} end
    return nil
end
function toXY(v)
    if #v == 1 then return {x = v[1], y = v[1]} end
    if #v == 2 then return {x = v[1], y = v[2]} end
    return nil
end
function fromXY(v)
    return {v.x, v.y}
end

function add(p, q)
    return {p[1] + q[1], p[2] + q[2]}
end
function neg(p)
    return {-p[1], -p[2]}
end
function sub(p, q)
    return add(p, neg(q))
end
function mult(v, s)
    return {v[1] * s, v[2] * s}
end

function chunkifyPosition(pos, chunk)
    local size = chunk[1][1]
    local offset = chunk[2]
    if offset then offset = offset[1] end
    offset = {offset, offset}
    pos = {pos[1] - offset[1], pos[2] - offset[2]}
    pos = {math.floor(pos[1]/size), math.floor(pos[2]/size)}
    return pos
end

--[[pos is the position in the `chunk` coordinate system.--]]
function positionifyChunk(pos, chunk)
    local size = chunk[1][1]
    local offset = chunk[2]
    if offset then offset = offset[1] end
    offset = {offset or 0, offset or 0}
    pos = {pos[1]*size + offset[1], pos[2]*size + offset[2]}
    return pos
end

--[[pos is the position in the `chunk` coordinate system.--]]
function chunkArea(pos, chunk)
    return {positionifyChunk(pos, chunk), positionifyChunk(add(pos, {1, 1}), chunk)}
end

script.on_event(defines.events.on_tick, function(event)
    -- game.print(filter == nil)
    -- game.print(helpers.table_to_json({#rendering.get_all_ids('ChunkyChunks'), #rendering.get_all_ids()}))
    -- game.print(helpers.table_to_json(rendering.get_all_ids('ChunkyChunks')))
    -- for _, id in pairs(rendering.get_all_ids('ChunkyChunks')) do id.destroy() end
    -- rendering.clear('ChunkyChunks')

    -- iterate_surfaces()

    for _, blockset in pairs(storage.temp_lines or {}) do for _, id in pairs(blockset) do id.destroy() end end
    storage.temp_lines = {}

    for index, surface in pairs(storage.surfaces) do
        local empty = true
        for _ in pairs(surface) do
            empty = false
            break
        end
        if empty then iterate_surface_chunks(game.surfaces[index]) end
    end

    for _, p in pairs(game.connected_players) do
        storage.players[p.index] = storage.players[p.index] or {}
        local d = storage.players[p.index]

        if d.delete_lines and #d.delete_lines > 0 then
            local blockset = table.remove(d.delete_lines)
            if game.surfaces[blockset.surface_index] and game.surfaces[blockset.surface_index].valid then
                for _, id in pairs(blockset.lines) do id.destroy() end
            end
            -- for i = 1, math.min(100, #blockset) do
            --     local id = table.remove(blockset)
            --     id.destroy()
            -- end
            -- if #blockset > 0 then table.insert(d.delete_lines, blockset) end
            -- p.print('lines deleted '..#d.delete_lines)
        end

        d.surfaces = d.surfaces or {}
        storage.surfaces[p.surface.index] = storage.surfaces[p.surface.index] or {} -- storage.surfaces[x] will be nil instead of {} until a player enters it
        d.covered_block_count = d.covered_block_count or 0
        d.lines = d.lines or {}

        if d.covered_block_count < #storage.mixed_surface_blocks then
            d.covered_block_count = d.covered_block_count + 1
            local block_data = storage.mixed_surface_blocks[d.covered_block_count]
            if game.surfaces[block_data.surface_index] == nil or not game.surfaces[block_data.surface_index].valid then
                table.remove(storage.mixed_surface_blocks, d.covered_block_count)
                for _, pd in pairs(storage.players) do
                    if pd.covered_block_count >= d.covered_block_count then
                        pd.covered_block_count = pd.covered_block_count - 1
                    end
                end
            else
                -- p.print('covered '..d.covered_block_count..'  to cover '..#storage.mixed_surface_blocks)
                for g = 1, GRIDS_COUNT do
                    local a = map({'size', 'offset', 'spacing', 'color', 'enabled'}, function(q) return p.mod_settings['chunkychunks-'..q..'-'..g].value end)
                    local size    = makeLen2(parseDoubles(a[1]))
                    local offset  = makeLen2(parseDoubles(a[2]))
                    local spacing = makeLen2(parseDoubles(a[3]))
                    local color  = a[4]
                    color.r = color.r * color.a
                    color.g = color.g * color.a
                    color.b = color.b * color.a
                    local enabled = a[5]
                    if enabled ~= 'Disabled' and size and offset and (math.min(size[1], size[2]) > 15) then
                        local only_in_alt_mode = (enabled == 'ALT-mode')
                        local block = {topleft = mult(block_data.block_pos, BLOCK_SIZE), bottomright = mult(add(block_data.block_pos, {1, 1}), BLOCK_SIZE)}
                        local lines = chunky({p}, block_data.surface_index, block.topleft, block.bottomright, size, offset, spacing, color, only_in_alt_mode)
                        table.insert(d.lines, {surface_index = block_data.surface_index, lines = lines})
                        if p.mod_settings['chunkychunks-centre-mark-'..g].value and size ~= nil and math.max(size[1], size[2]) >= 2 then
                            -- offset = add(parseXY(a[2]), mult(size, 0.5))
                            local size_ = map(size, function(q) return math.max(1, math.floor((math.log(q)/math.log(2)) - 4)) end)
                            spacing = add(mult(size, 0.5), mult(size_, -1))
                            local lines = chunky({p}, p.surface, block.topleft, block.bottomright, size, offset, spacing, color, only_in_alt_mode)
                            table.insert(d.lines, {surface_index = block_data.surface_index, lines = lines})
                        end
                    end
                end
            end
        end

        -- if p.is_shortcut_toggled(SHORTCUT_NAME) then
        --     for g = 1, 3 do
        --         local a = map({'size', 'offset', 'spacing', 'color', 'enabled'}, function(q) return p.mod_settings['chunkychunks-'..q..'-'..g].value end)
        --         local size    = makeLen2(parseDoubles(a[1]))
        --         local offset  = makeLen2(parseDoubles(a[2]))
        --         local spacing = makeLen2(parseDoubles(a[3]))
        --         local color  = parseColour(a[4]) or {r = 0, g = 0, b = 0, a = 1}
        --         color.r = color.r * color.a
        --         color.g = color.g * color.a
        --         color.b = color.b * color.a
        --         local enabled = a[5]
        --         if enabled ~= 'Disabled' and size and offset and (math.min(size[1], size[2]) > 0) then
        --             local only_in_alt_mode = (enabled == 'ALT-mode')
        --             local block = player_block(p.index, size, offset, spacing)
        --             local lines = chunky({p}, p.surface, block.topleft, block.bottomright, size, offset, spacing, color, only_in_alt_mode)
        --             table.insert(storage.temp_lines, {surface_index = block_data.surface_index, lines = lines})
        --             if p.mod_settings['chunkychunks-centre-mark-'..g].value and size ~= nil and math.max(size[1], size[2]) >= 2 then
        --                 -- offset = add(parseXY(a[2]), mult(size, 0.5))
        --                 local size_ = map(size, function(q) return math.max(1, math.floor((math.log(q)/math.log(2)) - 4)) end)
        --                 spacing = add(mult(size, 0.5), mult(size_, -1))
        --                 local lines = chunky({p}, p.surface, block.topleft, block.bottomright, size, offset, spacing, color, only_in_alt_mode)
        --                 table.insert(storage.temp_lines, {surface_index = block_data.surface_index, lines = lines})
        --             end
        --         end
        --     end
        -- end
    end
end)

function blockify(chunk)
    -- local block = {{1e4, 1e4}, {0, 0}}
    -- local position = mult(chunk.position, 32)
    -- local block_pos = chunkifyPosition(position, block)
    -- local block_pos = {math.floor(chunk.position[1] * 32 / 1e4), math.floor(chunk.position[2] * 32 / 1e4)} --

    -- game.print(helpers.table_to_json({chunk, chunk.surface.index}))

    local block_pos = map(chunk.position, function(q) return math.floor(q * 32 / BLOCK_SIZE) end)
    local surface_index = chunk.surface.index
    local gsurfd = storage.surfaces[surface_index]
    if gsurfd then
        if not gsurfd[helpers.table_to_json(block_pos)] then
            gsurfd[helpers.table_to_json(block_pos)] = block_pos
            table.insert(storage.mixed_surface_blocks, {surface_index = surface_index, block_pos = block_pos})
        end
    end
end

function iterate_surfaces()
    local c = 0
    for _, surface in pairs(game.surfaces) do
        c = c + iterate_surface_chunks(surface)
    end
    -- game.print(helpers.table_to_json({c, #storage.mixed_surface_blocks, map(storage.mixed_surface_blocks, function(q) return {q.surface_index, q.block_pos} end)}))
end

function iterate_surface_chunks(surface)
    local c = 0
    for chunk in surface.get_chunks() do
      c = c + 1
      blockify({position = fromXY(chunk), surface = surface})
    end
    return c
end

script.on_event(defines.events.on_chunk_generated, function(event) blockify({position = fromXY(event.position), surface = event.surface}) end)
script.on_event(defines.events.on_surface_created, function(event) storage.surfaces[event.surface_index] = {} end)

script.on_event(defines.events.on_lua_shortcut, toggle)
script.on_event('chunkychunks-toggle', toggle)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    -- player_index :: uint (optional): The player who changed the setting or nil if changed by script.
    -- setting :: string: The setting name that changed.
    -- setting_type :: string: The setting type: "runtime-per-user", or "runtime-storage".

    -- game.print(event.tick..'  '..event.setting)
    -- log(event.tick..'  '..helpers.table_to_json(event))

    if not string.match(event.setting, '^chunkychunks') then return nil end
    if not event.player_index then return nil end

    local d = storage.players[event.player_index]
    if not d then -- if game starts paused then storage.players is uninitialised and we can't enable grids anyways
        game.print(script.mod_name..': Not yet possible to modify grid settings on tick 0, and the grids don\'t update while the game is paused.')
        return nil -- This is just to not crash. It will mean the settings changed will just be discarded on tick 0.
        -- TODO make it possible to enable grids while paused and on tick 0 (init data and build grids off tick handler).
    end
    local player = game.players[event.player_index]
    player.set_shortcut_toggled(SHORTCUT_NAME, enabled(event.player_index))
    if d.mod_setting_changed_tick == event.tick then return nil end -- run handler once per tick per player

    d.mod_setting_changed_tick = event.tick
    -- game.print('----------------------'..helpers.table_to_json(event))
    -- if d.delete_lines and #d.delete_lines > 0 then
    --     game.print('deleting all lines')

    --     -- rendering.clear('ChunkyChunks')
    --     -- d.delete_lines = {}
    -- end
    while d.delete_lines and #d.delete_lines > 0 do
        local blockset = table.remove(d.delete_lines)
        if game.surfaces[blockset.surface_index] and game.surfaces[blockset.surface_index].valid then
            for _, id in pairs(blockset.lines) do id.destroy() end
        end
    end
    d.delete_lines = d.lines
    -- if d.delete_lines and #d.delete_lines > 0 then
    --     game.print('after '..#d.delete_lines)
    --     local c = 0
    --     for _, blockset in pairs(d.delete_lines) do
    --         c = c + #blockset
    --     end
    --     game.print('count '..c)
    -- end
    d.lines = nil
    d.covered_block_count = nil
end)

-- script.on_event(defines.events.on_player_toggled_alt_mode, function(event)
--     local p = game.players[event.player_index]
--     if not p.mod_settings['chunkychunks-follow-alt-mode'].value then return nil end
--     enabled(event.player_index, p.game_view_settings.show_entity_info)
-- end)

function clean()
    rendering.clear('ChunkyChunks')
    -- for k in pairs(storage) do
    --     storage[k] = nil
    -- end
    storage.surfaces = {}
    storage.mixed_surface_blocks = {}
    storage.players = {}
    storage.temp_lines = {}

    iterate_surfaces()
end

script.on_init(clean)
script.on_configuration_changed(function(event)
    local cmc = event.mod_changes['ChunkyChunks']
    if cmc and cmc.old_version ~= cmc.new_version then clean() end
end)