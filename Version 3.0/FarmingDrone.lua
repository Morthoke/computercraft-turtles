-- Delay Start

sleep(10)

------------------------------------------------
--					GPS Vals		     	  --

turtleX, turtleY, turtleZ = gps.locate()

------------------------------------------------
--				Global Variables			  --

-- Save Start Location
startX = turtleX
startY = turtleY
startZ = turtleZ

-- Refuel Location
fuelX, fuelY, fuelZ = nil

-- Farming Square Coords
corner1X , corner1Y, corner1Z = nil
corner2X , corner2Y, corner2Z = nil
corner3X , corner3Y, corner3Z = nil
corner4X , corner4Y, corner4Z = nil

-------          Lookup Tables           -------
-- 				   1        2       3        4 
orientations = {"north", "east", "south", "west"}
orientation = 0
fuelTypesAccepted = {"thermal:charcoal_block", "minecraft:coal", "minecraft:charcoal"}

-- Crop Types               1                  2                   3                   4   
cropLookupTable = {"minecraft:potato", "minecraft:wheat", "minecraft:carrot", "minecraft:beetroot"}
cropPlantedNames = {"minecraft:potatoes", "minecraft:wheat"}

-- Crop Type as set
cropType = nil

-- Misc
totalHarvested = 0
status = "" -- waiting // farming // refueling // dumping
turtName = "" -- Determined at setup
longEdgeResult = nil -- X == 1 /// Z == 2
longEdgeCorner = nil -- C1 // C2 // C3 // C4
longEdgeDistance= nil
shortEdgeDistance = nil

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

-- Find Orientation //// Moves in one direction then determines face direction
function orientationDetermine()
	moveForward()
	-- West (X Went Down)
	if turtleX < startX then
		orientation = 4
	-- East (X Went Up)
	elseif turtleX > startX then
		orientation = 2
	-- North (Z Went Down)
	elseif turtleZ < startZ then
		orientation = 1
	-- South (Z Went Up)
	elseif turtleZ > startZ then
		orientation = 3
	end
	moveBack()
end

-- Find Item In Inventory // Provide String
-- Returns Item location if found // Returns -1 if not found
function find(item)
	local tmp = -1
	for i = 1, 16, 1 do
		data = turtle.getItemDetail(i)
		if data then
			local name = tostring(data.name)
			if item == name then
				tmp = i
				break
			end
		end
	end
	return tmp
end

-- Count Number of Crop Type in Inv
function countInv(item)
	for i = 1, 16, 1 do
		data = turtle.getItemDetail(i)
		if data and (data.name == item) then
			totalHarvested = totalHarvested + turtle.getItemCount()
		end
	end
end

-- Returns Current Heading
function getHeading(input)
	if (input == "north") or (input == "n") then val = 1
	elseif (input == "east") or (input == "e") then val = 2
	elseif (input == "south") or (input == "s") then val = 3
	elseif (input == "west") or (input == "w") then val = 4
	else val = 1
	end
	return val 
end

-- Go To
-- Due to turtle only moving along one height there is no need to change Y coord
function goTo(targetX, targetZ, distance)
	--print('Going to Z = ' .. targetZ)
	local cnt = 0
	-- Positive Z
	if targetZ > turtleZ then
		face("south")
		while (targetZ > turtleZ) and (cnt ~= distance) do
			moveForward()
			cnt = cnt + 1
		end
	end

	-- Negative Z
	if targetZ < turtleZ then
		face("north")
		while (targetZ < turtleZ) and (cnt ~= distance) do
			moveForward()
			cnt = cnt + 1
		end
	end

	--print('Going to X = ' .. targetX)
	-- Positive X
	if targetX > turtleX then
		face("east")
		while (targetX > turtleX) and (cnt ~= distance) do
			moveForward()
			cnt = cnt + 1
		end
	end

	-- Negative X
	if (targetX < turtleX) and (cnt ~= distance) then 
		face("west")
		while targetX < turtleX do
			moveForward()
			cnt = cnt + 1
		end
	end
end

-- Find which orientation is the long edge
function longEdge()

	-- Find longest edge
	local C1_C2 = math.sqrt((corner1X - corner2X)^2 + (corner1Z - corner2Z)^2)
	local C1_C4 = math.sqrt((corner1X - corner4X)^2 + (corner1Z - corner4Z)^2)

	-- C1 to C2 is longest edge find if its on x or z
	if C1_C2 > C1_C4 then
		local c1c2_Xdistance = math.abs(corner1X) - math.abs(corner2X)
		local c1c2_Zdistance = math.abs(corner1Z) - math.abs(corner2Z)
		if (c1c2_Xdistance ~= 0) then
			longEdgeResult = 1 -- X
			longEdgeDistance = c1c2_Xdistance
			shortEdgeDistance = C1_C4
		elseif (c1c2_Zdistance ~= 0) then
			longEdgeResult = 2 -- Z
			longEdgeDistance = c1c2_Zdistance
			shortEdgeDistance = C1_C4
		end
		longEdgeCorner = 2
	-- C1 to C4 is longest edge find if its on x or z
	elseif C1_C4 > C1_C2 then
		local c1c4_Xdistance = math.abs(corner1X) - math.abs(corner4X)
		local c1c4_Zdistance = math.abs(corner1Z) - math.abs(corner4Z)
		if (c1c4_Xdistance ~= 0) then
			longEdgeResult = 1 -- X
			longEdgeDistance = c1c4_Xdistance
			shortEdgeDistance = C1_C2
		elseif (c1c4_Zdistance ~= 0) then
			longEdgeResult = 2 -- Z
			longEdgeDistance = c1c4_Zdistance
			shortEdgeDistance = C1_C2
		end
		longEdgeCorner = 4
	end
end

-- Inventory Check
-- False if not full
function inventoryCheck()
	for i = 1,16,1 do
    	if turtle.getItemCount(i) == 0 then
     		return false
    	end
  	end
  	return true
end

-- Fuel Check // Returns True if need refuel
function fuelCheck()
	if turtle.getFuelLevel() < 250 then
		return true
	else
		return false
	end
end

-- Check if file exists // False // True
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

-- Block Check
function blockCheck()
	local success, data = turtle.inspectDown()
	if success then
		local name = tostring(data.name)
		return tableCheck(cropPlantedNames ,name)
	else
		return false
	end
end

------------------------------------------------
--				 Turtle Contol				  --

-- Update GPS /// Move forward
function moveForward()
	turtle.forward()
	turtleX, turtleY, turtleZ = gps.locate()
end

-- Update GPS /// Move Back
function moveBack()
	turtle.back()
	turtleX, turtleY, turtleZ = gps.locate()
end

-- Update GPS /// Move Up
function moveUp()
	turtle.up()
	turtleX, turtleY, turtleZ = gps.locate()
end

-- Update GPS /// Move Down
function moveDown()
	turtle.down()
	turtleX, turtleY, turtleZ = gps.locate()
end

-- Update Orientation // Turn Left
function turnLeft()
	orientation = orientation - 1
	orientation = (orientation - 1) % 4
	orientation = orientation + 1
	turtle.turnLeft()
	writeOp()
end

-- Update Orientation // Turn Right
function turnRight()
	orientation = orientation - 1
	orientation = (orientation + 1) % 4
	orientation = orientation + 1  
	turtle.turnRight()
	writeOp()
end

-- Move to Dump // Move Back
function dumpTrip()
	status = "dumping"
	reportStatus()
	local saveX, saveY, saveZ = gps.locate()
	local saveOrient = orientations[orientation]
	goTo(startX, startZ, -1)
	dumpInventory_ex1()
	goTo(saveX, saveZ, -1)
	face(saveOrient)
end

-- Dump All Slots Apart from 1st
function dumpInventory_ex1()
	for i = 2, 16, 1  do
		turtle.select(i)
		turtle.dropDown()
	end
end

-- Move to Refuel // Move back
function refuelTrip()
	status = "refueling"
	reportStatus()
	local saveX, saveY, saveZ = gps.locate()
	local saveOrient = orientations[orientation]
	goTo(fuelX, fuelZ, -1)
	slurp()
	goTo(saveX, saveZ, -1)
	face(saveOrient)
end

-- Refuel till 1000 Fuel
function slurp()
	while turtle.getFuelLevel() < 1000 do
		-- Take 1 item from fuel chest
		for i = 1, 16, 1 do
			if turtle.getItemCount(i) == 0 then
				turtle.select(i)
				turtle.suckDown(1)
				break
			end
		end

		-- Delay
		sleep(0.05)

		-- Find fuel
		for i = 1, 16, 1 do
			-- If the item is fuel refuel
			local data = turtle.getItemDetail(i)
			if data then
				local name = tostring(data.name)
				if tableCheck(fuelTypesAccepted, name) then
					turtle.refuel()
				end
			end
		end
	end
end

-- Face Direction /// Provide heading 
-- north // south // east // west
function face(heading)
	while heading ~= orientations[orientation] do
		turnRight()
	end
end

------------------------------------------------
--				   Reporting				  --

-- Report Status // Current goal of turtle
function reportStatus()
	local repStat = turtName .. ":status"
	rednet.broadcast(status, repStat)
	print("Current Turtle Status: " .. status)
end

-- Report Count of items 
function reportcount()
	local repCount = turtName .. ":count"
	rednet.broadcast(totalHarvested, repCount)
	print("Current Amount Harvested: " .. totalHarvested)
end

-- New Turtle Creation
function reportNewTurt()
	rednet.broadcast(turtName, "NewFarmTurtle")
	local repType = turtName .. ":cropType"
	rednet.broadcast(cropType, repType)
end

------------------------------------------------
--			   Farming Functions			  --

-- Harvest Below /// Plant Below
function farm()
	if blockCheck() then 
		turtle.digDown() 
		turtle.select(1)
		turtle.placeDown()
	end
end

-- Check if Block Below is crop // Checks if fully grown
-- Returns true if grown // False if not
function growthDone()
	local success, data = turtle.inspectDown()
	if success then
		if data.metadata() == 7 then 
			return true
		end
	else
		return false
	end
end

-- Farm In Straight Line
function farmStraight(coordX, coordZ, distance, howFar)
	
	-- Farming Things
	farm()
	-- Move
	goTo(coordX, coordZ, distance)

	-- Looooop
	for i = 1, (howFar - 1), 1 do
		-- Farming Things
		farm()
		-- Inv Management
		if inventoryCheck() then dumpTrip() end
		-- Move
		moveForward()
	end
end

-- Tracktor go BRRRRRRR
function farmingOperation()
	-- Checklist
	-- Move to start point
	goTo(corner1X, corner1Z, -1)
	for i = 1, (shortEdgeDistance + 1), 1 do
		
		if (longEdgeResult == 1) and (longEdgeCorner == 2) and (corner3X == turtleX) then farmStraight(corner1X, turtleZ, 1, longEdgeDistance) -- X C2 // Direction C1
		elseif (longEdgeResult == 1) and (longEdgeCorner == 2) and (corner1X == turtleX) then farmStraight(corner3X, turtleZ, 1, longEdgeDistance) -- X C2 // Direction C3
		elseif (longEdgeResult == 1) and (longEdgeCorner == 4) and (corner3X == turtleX) then farmStraight(corner1X, turtleZ, 1, longEdgeDistance) -- X C4 // Direction C1
		elseif (longEdgeResult == 1) and (longEdgeCorner == 4) and (corner1X == turtleX) then farmStraight(corner3X, turtleZ, 1, longEdgeDistance) -- X C4 // Direction C3
		elseif (longEdgeResult == 2) and (longEdgeCorner == 2) and (corner3Z == turtleZ) then farmStraight(turtleX, corner1Z, 1, longEdgeDistance) -- Z C2 // Direction C1
		elseif (longEdgeResult == 2) and (longEdgeCorner == 2) and (corner1Z == turtleZ) then farmStraight(turtleX, corner3Z, 1, longEdgeDistance) -- Z C2 // Direction C3
		elseif (longEdgeResult == 2) and (longEdgeCorner == 4) and (corner3Z == turtleZ) then farmStraight(turtleX, corner1Z, 1, longEdgeDistance) -- Z C4 // Direction C1
		elseif (longEdgeResult == 2) and (longEdgeCorner == 4) and (corner1Z == turtleZ) then farmStraight(turtleX, corner3Z, 1, longEdgeDistance) -- Z C4 // Direction C3
		end

		-- Turtle Health
		if fuelCheck() then refuelTrip() end
		if inventoryCheck() then dumpTrip() end
		
		-- Farmer Tings
		farm()

		-- Movement
		if (longEdgeResult == 1) and (longEdgeCorner == 2) then goTo(turtleX, corner3Z, 1) -- X C2
		elseif (longEdgeResult == 1) and (longEdgeCorner == 4) then goTo(turtleX, corner3Z, 1) -- X C4
		elseif (longEdgeResult == 2) and (longEdgeCorner == 2) then goTo(corner3X, turtleZ, 1) -- Z C2
		elseif (longEdgeResult == 2) and (longEdgeCorner == 4) then goTo(corner3X, turtleZ, 1) -- Z C2
		end
	end
end

------------------------------------------------
--			    File Operations		    	  --

-- Write Operational Values to txt file
function writeOp()
	-- Open File
	f = io.open("operationalData.txt", "w+")

	-- Write info
	f:write(tostring(startX) .. "\n")
	f:write(tostring(startY) .. "\n")
	f:write(tostring(startZ) .. "\n")
	f:write(tostring(fuelX) .. "\n")
	f:write(tostring(fuelY) .. "\n")
	f:write(tostring(fuelZ) .. "\n")
	f:write(tostring(orientation) .. "\n")
	f:write(tostring(corner1X) .. "\n")
	f:write(tostring(corner1Y) .. "\n")
	f:write(tostring(corner1Z) .. "\n")
	f:write(tostring(corner2X) .. "\n")
	f:write(tostring(corner2Y) .. "\n")
	f:write(tostring(corner2Z) .. "\n")
	f:write(tostring(corner3X) .. "\n")
	f:write(tostring(corner3Y) .. "\n")
	f:write(tostring(corner3Z) .. "\n")
	f:write(tostring(corner4X) .. "\n")
	f:write(tostring(corner4Y) .. "\n")
	f:write(tostring(corner4Z) .. "\n")
	f:write(tostring(totalHarvested) .. "\n")
	f:write(tostring(turtName) .. "\n")
	

	-- Close File
	f:close()
end

-- Read operational Vals
function readOp()
	local arr = fRead("operationalData.txt")
	startX = tonumber(arr[1])
	startY = tonumber(arr[2])
	startZ = tonumber(arr[3])
	fuelX = tonumber(arr[4])
	fuelY = tonumber(arr[5])
	fuelZ = tonumber(arr[6])
	orientation = tonumber(arr[7])
	corner1X = tonumber(arr[8])
	corner1Y = tonumber(arr[9])
	corner1Z = tonumber(arr[10])
	corner2X = tonumber(arr[11])
	corner2Y = tonumber(arr[12])
	corner2Z = tonumber(arr[13])
	corner3X = tonumber(arr[14])
	corner3Y = tonumber(arr[15])
	corner3Z = tonumber(arr[16])
	corner4X = tonumber(arr[17])
	corner4Y = tonumber(arr[18])
	corner4Z = tonumber(arr[19])
	totalHarvested = tonumber(arr[20])
	turtName = tostring(arr[21])
end


------------------------------------------------
--			  	Main Program				  --

rednet.open("left")

-- Get Fuel
if turtle.getFuelLevel() < 100 then
	print("Please put fuel in slot 1!")
	while turtle.getFuelLevel() < 100 do
		turtle.select(1)
		turtle.refuel()
	end
	print("Thanks!")
end

-- Startup Operations
if not(fExists("operationalData.txt")) then
	-- First Boot
	print("Place Storage Under Farming Drone \n")

	-- Fuel Coords
	print("Please enter Refuel GPS: ")
	while not(numberCheck(fuelX)) do
		io.write("X = ")
		fuelX = tonumber(io.read())
	end
	while not(numberCheck(fuelY)) do
		io.write("Y = ")
		fuelY = tonumber(io.read())
	end
	while not(numberCheck(fuelZ)) do
		io.write("Z = ")
		fuelZ = tonumber(io.read())
	end

	-- Corner 1
	print("Please enter Corner 1 Coords: ")
	while not(numberCheck(corner1X)) do
		io.write("X = ")
		corner1X = tonumber(io.read())
	end
	while not(numberCheck(corner1Y)) do
		io.write("Y = ")
		corner1Y = tonumber(io.read())
	end
	while not(numberCheck(corner1Z)) do
		io.write("Z = ")
		corner1Z = tonumber(io.read())
	end

	-- Corner 2
	print("Please enter Corner 2 Coords: ")
	while not(numberCheck(corner2X)) do
		io.write("X = ")
		corner2X = tonumber(io.read())
	end
	while not(numberCheck(corner2Y)) do
		io.write("Y = ")
		corner2Y = tonumber(io.read())
	end
	while not(numberCheck(corner2Z)) do
		io.write("Z = ")
		corner2Z = tonumber(io.read())
	end

	-- Corner 3
	print("Please enter Corner 3 Coords: ")
	while not(numberCheck(corner3X)) do
		io.write("X = ")
		corner3X = tonumber(io.read())
	end
	while not(numberCheck(corner3Y)) do
		io.write("Y = ")
		corner3Y = tonumber(io.read())
	end
	while not(numberCheck(corner3Z)) do
		io.write("Z = ")
		corner3Z = tonumber(io.read())
	end

	-- Corner 4
	print("Please enter Corner 4 Coords: ")
	while not(numberCheck(corner4X)) do
		io.write("X = ")
		corner4X = tonumber(io.read())
	end
	while not(numberCheck(corner4Y)) do
		io.write("Y = ")
		corner4Y = tonumber(io.read())
	end
	while not(numberCheck(corner4Z)) do
		io.write("Z = ")
		corner4Z = tonumber(io.read())
	end

	-- Crop Type
	print("Please enter crop type:\n1: Potato\n2: Wheat\n3: Carrot\n4: Beetroot")
	while not(numberCheck(cropType)) do
		io.write("Please select a number: ")
		cropType = tonumber(io.read())
	end

	-- Name
	print("Please Name your turtle: ")
	local done = true
	while (done) do
		turtName = tostring(io.read())
		print("Your turtle is named: " .. turtName)
		
		local tmp = nil
		while (tmp ~= "Y") do
			io.write("Is this okay? Y/N: ")
			tmp = tostring(io.read())
			if (tmp == "N") then 
				io.write("Please enter a new name: ")
				turtName = tostring(io.read())
			elseif (tmp == "Y") then
				done = false
			end
		end
	end

	-- Do calcs
	longEdge()

	-- Start Position
	startX = turtleX
	startY = turtleY
	startZ = turtleZ

	-- Find Orientation 
	reportNewTurt()
	orientationDetermine()
	writeOp()
else
	print("Restarting.........")
	readOp()
	longEdge()
end

-- Move to start position
goTo(startX, startZ, -1)

-- Do the farming
status = "farming"
reportStatus()
farmingOperation()

-- Main Loop
while true do
	-- Check if fuel needed
	if turtle.getFuelLevel() < 250 then refuelTrip() end
	-- Inv Management
	if inventoryCheck() then dumpTrip() end

	-- Wait for Growth
	status = "waiting"
	goTo(startX, startZ, -1)
	reportStatus()
	sleep(2500)

	-- Do the farming
	status = "farming"
	reportStatus()
	farmingOperation()
end