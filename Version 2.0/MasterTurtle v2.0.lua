------------------------------------------------
--				Global Variables			  --

masterX = nil
masterY = nil
masterZ = nil
turtleX = nil
turtleY = nil
turtleZ = nil
orientation = 0
fuelMethod = 0 -- 0 = Hard Fuel       1 = Ender Chest Method
deployedTurtles = 0 -- Number Of turtles in use

-- Lookup Tables
-- 				   1        2       3        4 
orientations = {"north", "east", "south", "west"}

------------------------------------------------
--				   Utilities				  --

-- Check Input is a number
function numberCheck(val)
	local isNum = tonumber(val)
	if	isNum == nil then
		return false
	end

	return true
end

-- Check if table has value
function tableCheck(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

--returns current direction from table
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

-- Type of Fuel storage
function getFuelType(input)
	local val = 0
	if (input == "f") then val = 0
	elseif (input == "e") then val = 1
	end
	return val
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

-- Check if file exists
-- Returns true if it does
function fExists(name)
	local f = io.open(name, "r")
	if f ~= nil then io.close(f) return true
	else return false end
end

-- Save Contents of file to Arr
-- Returns tbl with file contents
function fRead(name)
	local i = 0
	local content = {}
	local f = io.open(name)
	if fExists(name) then
		for line in f:lines() do
			i = i + 1
			content[i] = line
		end
		f:close()
	end

	return content
end


------------------------------------------------
--				 Turtle Contol				  --

function turtleCoords()
	turtleY = masterY
	-- Facing North
	if orientation == 1 then
		turtleX = masterX
		turtleZ = masterZ - 1
	-- Facing South
	elseif orientation == 3 then
		turtleX = masterX
		turtleZ = masterZ + 1
	--  Facing East
	elseif orientation == 2 then
		turtleX = masterX + 1
		turtleZ = masterZ
	-- Facing West
	elseif orientation == 4 then
		turtleX = masterX - 1
		turtleZ = masterZ
	end
end

-- Dig 2x3 Area to y = 5 infront of Master Turtle
function areaSetupTurtle()
	-- Place Turtle
	local haveTurt, turtLoc = turtleCheck()
	if haveTurt then
		turtle.select(turtLoc)
		turtle.place()
		utilizedTurtles(1)
	end

	-- Make Table with setup Conditions
	local setupTable = {}
	setupTable[1] = orientation -- Facing
	setupTable[2] = turtleX -- Turtle X Coord
	setupTable[3] = turtleY -- Turtle Y Coord
	setupTable[4] = turtleZ -- Turtle Z Coord

	-- Turn On
	peripheral.call("front", "turnOn")
	os.sleep(5)

	-- Tell turtle is a setup turtle and give Coords of start
	rednet.broadcast("setup", "TurtleMode")
	setupTable = textutils.serialize(setupTable)
	rednet.broadcast(setupTable, "TurtleInfo")
end

-- Deploy Mining Turtle
function deployTurtle()
	-- Place Turtle
	local haveTurt, turtLoc = turtleCheck()
	if haveTurt then
		turtle.select(turtLoc)
		turtle.place()
		utilizedTurtles(1)
	end

	-- Make Table with setup Conditions
	local setupTable = {}
	setupTable[1] = orientation -- Facing
	setupTable[2] = turtleX -- Turtle X Coord
	setupTable[3] = turtleY -- Turtle Y Coord
	setupTable[4] = turtleZ -- Turtle Z Coord

	-- Turn On
	peripheral.call("front", "turnOn")
	os.sleep(5)

	-- Tell turtle is a setup turtle and give Coords of start
	rednet.broadcast("mining", "TurtleMode")
	setupTable = textutils.serialize(setupTable)
	rednet.broadcast(setupTable, "TurtleInfo")
	rednet.broadcast(tostring(fuelMethod), "TurtleFuelMode")
	
end

-- Pickup Turtle
function jobDone()
	local success, data = turtle.inspect()
	if success then
		local name = tostring(data.name)
		if name == "computercraft:turtle_normal" then
			turtle.dig()
		end
	end
end

-- Report on if there are turtles left in storage and how many are in use
function turtleAmount()
	str = 'The amount of turtles in use is: ' .. deployedTurtles
	rednet.broadcast(str, "turtlesAmountMaster")
	local haveTurt, turtLoc = turtleCheck()
	if haveTurt then
		str = 'There are turtles in storage!'
		rednet.broadcast(str, "turtlesLeftMaster")
	else
		str = 'There are no turtles in storage. (╯°□°）╯︵ ┻━┻ '
		rednet.broadcast(str, "turtlesLeftMaster")
	end
end

------------------------------------------------
--				Setup Functions				  --

-- Get Info
function infoGather()
	-- Local Variables
	local facing = 'A'
	local facingStrings = {'n', 'north', 'e', 'east', 's', 'south', 'w', 'west'}
	local fuel = 'A'
	local fuelStrings = {'f', 'e'}

	print("\nMaster Turtle Setup")

	-- MT Coordinates
	print("\nPlease Enter the Master Turtle Coordinates: ")
	while not(numberCheck(masterX)) do 
		io.write("X = ")
		masterX = io.read()
	end
	while not(numberCheck(masterY)) do
		io.write("\nY = ")
		masterY = io.read()
	end
	while not(numberCheck(masterZ)) do
		io.write("\nZ = ")
		masterZ = io.read()
	end
	print("\n")

	-- MT Orientation
	io.write("\nPlease Enter the Direction the Master Turtle is Facing (N S E W): ")
	facing = io.read()
	-- Loop till proper input
	while not(tableCheck(facingStrings, string.lower(facing))) do
		io.write("\nDirection (N S E W): ")
		facing = io.read()
	end
	orientation = getDirection(string.lower(facing))

	print("\n")

	-- Fuel or Ender Chest
	io.write("\nIs the turtle using a Fuel Chest or a Ender Chest (F or E): ")
	fuel = io.read()
	-- Loop till proper input
	while not(tableCheck(fuelStrings, string.lower(fuel))) do
		io.write("\nFuel Chest or a Ender Chest (F or E): ")
		fuel = io.read()
	end
	fuelMethod = getFuelType(string.lower(fuel))

	print('\nPlease have the required chests placed and fuel ready!')
	os.sleep(0)
end

-- See if setup file exists
function checkFileExists()
	local f = io.open("MasterInfo.txt", "r")
	if f ~= nil then io.close(f) return true
	else return false
	end
end

-- File Ordering
-- L1 = masterX
-- L2 = masterY
-- L3 = masterZ
-- L4 = turtleX
-- L5 = turtleY
-- L6 = turtleZ
-- L7 = orientation
-- L8 = fuelMethod
-- L9 = deployedTurtles

-- Write all values required for operation in the setup file
function writeToFile()
	-- Open and clear the TXT File
	f = io.open("MasterInfo.txt", "w+")

	-- Write the info to file
	f:write(tostring(masterX) .. "\n")
	f:write(tostring(masterY) .. "\n")
	f:write(tostring(masterZ) .. "\n")
	f:write(tostring(turtleX) .. "\n")
	f:write(tostring(turtleY) .. "\n")
	f:write(tostring(turtleZ) .. "\n")
	f:write(tostring(orientation) .. "\n")
	f:write(tostring(fuelMethod) .. "\n")
	f:write(tostring(deployedTurtles) .. "\n")

	-- Close File
	f:close()
end

-- Read all values required for operation from setup file
function readFromFile()
	local arr = {}
	arr = fRead("MasterInfo.txt")
	masterX = tonumber(arr[1])
	masterY = tonumber(arr[2])
	masterZ = tonumber(arr[3])
	turtleX = tonumber(arr[4])
	turtleY = tonumber(arr[5])
	turtleZ = tonumber(arr[6])
	orientation = tonumber(arr[7])
	fuelMethod = tonumber(arr[8])
	deployedTurtles = tonumber(arr[9])
end


------------------------------------------------
--					  Main					  --

rednet.open("right")

-- Startup Operations
if not(checkFileExists()) then
	-- First Boot
	infoGather()
	turtleCoords()
	areaSetupTurtle()
	writeToFile()
end

-- Normal Operation
readFromFile()

print('\nStart Loop')
while true do
	senderID, message, protocol = rednet.receive()

	-- Deploy Mining Turtle
	if message == "dmt" then print("Mining Turtle"); deployTurtle() end

	-- Pickup Complete Turtle
	if message == "jobcomplete" then print("Job Complete"); jobDone() end

	-- Report on amount of turtles in use
	if message == "turtlesinuse" then print("Turtle Info Request"); turtleAmount() end
end


if fExists("DroneTurtle") then shell.run(rm "Mining Progress.txt") end