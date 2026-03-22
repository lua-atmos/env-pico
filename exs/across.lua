require "atmos"
local env  = require "atmos.env.pico"
local pico = require "pico"

pico.set.dim {'!', w=500, h=500}

local pt1 = {x=0, y=0}
local pt2 = {x=100, y=100}
local pt = {'!', x=0, y=0}

local dy = (pt2.y - pt1.y) / (pt2.x - pt1.x)

loop(function()
    par_or(function()
        every('draw',function()
            pico.output.draw.pixel(pt)
        end)
    end, function()
        for i=pt1.x, pt2.x do
            pt.x = i
            pt.y = i * dy
            await(clock{ms=50})
        end
    end)
end)
