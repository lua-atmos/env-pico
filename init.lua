local atmos = require "atmos"
local pico  = require "pico"

pico.zet = pico.set     -- because of `set` keyword in Atmos

local M = {
    fps = 30,
    now = 0,
    mode = { primary=true, secondary=true },
}

pico.init(true)
pico.set.expert(true, M.fps)

function M.quit ()
    pico.init(false)
end

local meta = {
    __atmos = function (awt, e2)
        local t1, e1, v1 = table.unpack(awt)
        -- awt = { '==', <tag>, <filter>... } : index 1 is the run.lua marker
        -- only the '==' form carries a tag in e1 (vs 'func' / 'bool')
        if t1 ~= '==' then
            return nil  -- standard emit/await check
        elseif not _is_(e2.tag, e1) then
            return false
        elseif _is_(e2.tag, 'key') and type(v1)=='string' then
            if v1 ~= e2.key then
                return false
            end
        elseif _is_(e2.tag, 'mouse.button') and type(v1)=='string' then
            if not e2[v1] then   -- mouse['left']
                return false
            end
        end

        local f = awt[#awt]
        if type(f) == 'function' then
            if not f(e2) then
                return false
            end
        end

        return true, e2, e2
    end
}

function M.step ()
    local mcur = M.mode and M.mode.current

    local e, ms
    if mcur == 'secondary' then
        e = pico.input.event(0)
    else
        e,ms = pico.input.event()
        M.now = pico.get.now()
        emit('clock', ms, M.now)
    end

    if e then
        emit(setmetatable(e, meta))
        if e.tag == 'quit' then
            return true
        end
    end
    pico.output.clear()
    emit('draw')
    pico.output.present()
end

atmos.env(M)

return M
