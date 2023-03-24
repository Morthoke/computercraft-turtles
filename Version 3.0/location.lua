-- Add following line to "startup.lua"
-- shell.run("location")
x,y,z = gps.locate()
f = io.open("location.txt", "w+")
f:write(tostring(x) .. "\n")
f:write(tostring(y) .. "\n")
f:write(tostring(z) .. "\n")
f:close()