local atmos = require "atmos"
local pico  = require "pico"

pico.init(true)  -- TODO: asymmetric with open/close

pico.zet = pico.set     -- because of `set` keyword in Atmos

local M = {
    fps = 30,
    now = 0,
    mode = { primary=true, secondary=true },
}

function M.open ()
    --pico.init(true)
    pico.set.expert(true, M.fps)
end

function M.close ()
    pico.init(false)
end

local meta = {
    __atmos = function (awt, e)
        if not _is_(e.tag, awt[1]) then
            return false
        elseif _is_(e.tag, 'key') and type(awt[2])=='string' then
            if awt[2] ~= e.key then
                return false
            end
        elseif _is_(e.tag, 'mouse.button') and type(awt[2])=='string' then
            if awt[2] ~= e.but then
                return false
            end
        end

        local f = awt[#awt]
        if type(f) == 'function' then
            if not f(e) then
                return false
            end
        end

        return true, e, e
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
