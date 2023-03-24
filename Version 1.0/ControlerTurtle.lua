------------------------------------------------
--				Global Variables			  --

-- 						 X    Y    Z  Orient
masterTurtlePosition = {nil, nil, nil, nil}
droneTurtlePosition = {nil, nil, nil, nil}
fuelMethod = nil
deployedTurtles = 0

-- Lookup Tables
-- 				   1        2       3        4 
orientations = {"north", "east", "south", "west"}

-- Database

-- Files
-- operationDetails.txt -- Contains Runtime Info


------------------------------------------------
--				   Utilities				  --

-- Check if table has value
function tableCheck(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- Returns current direction from table
function getDirection(input)
	local val = 0
	if (input == "north") or (input == "n") then val = 1
	elseif (input == "east") or (input == "e") then val = 2
	elseif (input == "south") or (input == "s") then val = 3
	elseif (input == "west") or (input == "w") then val = 4
	else val = 1
	end
	return val 
end

-- Check if file exists
function fExists(name)
	local f = io.open(name, "r")
	if f ~= nil then io.close(f) return true
	else return false end
end

-- If there are any turtles in storage
function turtleCheck()
	local turt = false
	local location = 0
	for i = 1, 16, 1 do
		local data = turtle.getItemDetail(i)
		if data then
			local name = tostring(data.name)
			if name == "computercraft:turtle_normal" then
				turt = true
				location = i
				break
			end
		end
	end
	return turt, location
end

-- Amount of turtles being Used
function utilizedTurtles(value)
	if value == -1 then deployedTurtles = deployedTurtles - 1
	elseif  value == 1 then deployedTurtles = deployedTurtles + 1
	end
end

------------------------------------------------
--				 Turtle Contol				  --

function turtleCoords()
	droneTurtlePosition[2] = masterTurtlePosition[2]
	-- Facing North
	if orientation == 1 then
		droneTurtlePosition[1] = masterTurtlePosition[1]
		droneTurtlePosition[3] = masterTurtlePosition[3] - 1
	-- Facing South
	elseif orientation == 3 then
		droneTurtlePosition[1] = masterTurtlePosition[1]
		droneTurtlePosition[3] = masterTurtlePosition[3] + 1
	--  Facing East
	elseif orientation == 2 then
		droneTurtlePosition[1] = masterTurtlePosition[1] + 1
		droneTurtlePosition[3] = masterTurtlePosition[3]
	-- Facing West
	elseif orientation == 4 then
		droneTurtlePosition[1] = masterTurtlePosition[1] - 1
		droneTurtlePosition[3] = masterTurtlePosition[3]
	end
end

function areaSetupTurtle()
	-- Check It has turtle in storage and place
	local haveTurt, turtLoc = turtleCheck()
	local setupTable = nil

	if haveTurt then
		turtle.select(turtLoc)
		turtle.place()
		utilizedTurtles(1)
	end

	-- Turn on turt
	peripheral.call("front", "turnOn")
	os.sleep(5)

	-- Broadcast Turtle Type && Coords
	rednet.broadcast("setup", "TurtleMode")
	setupTable = textutils.serialize(droneTurtlePosition)
	rednet.broadcast(setupTable, "TurtleInfo")
end

------------------------------------------------
--				Setup Functions				  --

function getDetails()
	-- Local Variables
	local facing = 'A'
	local facingStrings = {'n', 'north', 'e', 'east', 's', 'south', 'w', 'west'}
	local fuel = 'A'
	local fuelStrings = {'f', 'e'}

	print("\nController Setup")

	-- Cont Coordinates
	print("\nPlease Enter the Controller Coordinates: ")
	while not(numberCheck(masterTurtlePosition[1])) do 
		io.write("\nX = ")
		masterTurtlePosition[1] = io.read()
	end
	while not(numberCheck(masterTurtlePosition[2])) do
		io.write("\nY = ")
		masterTurtlePosition[2] = io.read()
	end
	while not(numberCheck(masterTurtlePosition[3])) do
		io.write("\nZ = ")
		masterTurtlePosition[3] = io.read()
	end
	print("\n")

	-- Cont Orientation
	io.write("\nPlease Enter the Direction the Controller is Facing (N S E W): ")
	facing = io.read()
	while not(tableCheck(facingStrings, string.lower(facing))) do
		io.write("\nDirection (N S E W): ")
		facing = io.read()
	end
	masterTurtlePosition[4] = getDirection(string.lower(facing))
	print("\n")

	io.write("\nIs the turtle using a Fuel Chest or a Ender Chest (F or E): ")
	fuelMethod = io.read()
	-- Loop till proper input
	while not(tableCheck(fuelStrings, string.lower(fuelMethod))) do
		io.write("\nFuel Chest or a Ender Chest (F or E): ")
		fuelMethod = io.read()
	end
    -------------------------------------------------------------------------------
    -- Design print for console screen
    -------------------------------------------------------------------------------
	print('\nPlease have the required chests placed and fuel ready!')
	os.sleep(0)
end

function writeToFile()

end
------------------------------------------------
--					  Main					  --

-- Open Network Access
rednet.open("right")

if not(fExists("operationDetails.txt")) then
	-- First Boot
	getDetails()
	turtleCoords()
	areaSetupTurtle()

end


