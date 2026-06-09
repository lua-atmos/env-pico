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

function M.step ()
    local mcur = M.mode and M.mode.current

    local e, ms
    if mcur == 'secondary' then
        e = pico.input.event(0)
    else
        e,ms = pico.input.event()
        M.now = pico.get.now()
        emit(ms * 1000)
    end

    if e then
        emit(e)
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
