------------------------------------------------
--				Global Variables			  --

startX = nil
startY = nil
startZ = nil
storageX = nil
storageY = nil
storageZ = nil
storageOrientation = nil
fuelX = nil
fuelY = nil
fuelZ = nil
fuelOrientation = nil
fuelType = nil -- 0 = Hard Fuel       1 = Ender Chest Method
miningHeight = nil
length1 = nil
length2 = nil
miningOrientation = nil
currentX = nil -- Not init Written
currentY = nil -- Not init written
currentZ = nil -- Not init written
orientation = 0 -- Not inite written
mode = 99 -- 1 = Mining Drone       0 = Setup Drone 	99 = No Mode
blocksMined = 0 -- Not init Written
totalArea = nil

-- Lookup Tables
orientations = {"north", "east", "south", "west"}
xDiff = {0, 1, 0, -1}
zDiff = {-1, 0, 1, 0}
fuelTypesAccepted = {"thermal:charcoal_block"}
blockedMineItems = {"minecraft:spawner", "forbidden_arcanus:stella_arcanum", "minecraft:glass", "tconstruct:seared_bricks", 
	"tconstruct:seared_stone", "create:gantry_shaft", "tconstruct:smeltery_controller", "tconstruct:seared_fuel_tank",
	"tconstruct:seared_drain", "create:redstone_link", "create:andesite_casing", "create:cogwheel", "create:large_cogwheel", 
	"create:belt", "create:water_wheel", "create:shaft", "create:chute", "create:andesite_belt_funnel", "create:encased_fan",
	"create:gearbox", "create:mechanical_pump", "create:fluid_pipe", "create:glass_fluid_pipe", "metalbarrels:gold_barrel",
	"create:framed_glass", "create:adjustable_chain_gearshift", "minecraft:lever", "minecraft:oak_wall_sign"}

-- Used Files
-- "DroneTurtleInfo.txt" Generic Info
-- "GPSLocation.txt" Current Coords
-- "MiningProgress.txt" Current Section of Mining

------------------------------------------------
--			    	Utility			 		  --

-- Check if value is in an array
-- Returns True if it is the array
function arrHasVal(tab, val)
	for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
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
--			    Direction Tracking			  --

-- File is called "GPS Location.txt"
function writeCoords()
	f = io.open("GPSLocation.txt", "w+")

	f:write(tostring(currentX) .. "\n")
	f:write(tostring(currentY) .. "\n")
	f:write(tostring(currentZ) .. "\n")
	f:write(tostring(orientation) .. "\n")

	f:close()
end

-- File is called "GPSLocation.txt"
function readCoords()
	local arr = fRead("GPSLocation.txt")

  	currentX = tonumber(arr[1])
  	currentY = tonumber(arr[2])
  	currentZ = tonumber(arr[3])
  	orientation = tonumber(arr[4])
end

--returns current direction from table
function getDirection(input)
	if (input == "north") or (input == "n") then val = 1
	elseif (input == "east") or (input == "e") then val = 2
	elseif (input == "south") or (input == "s") then val = 3
	elseif (input == "west") or (input == "w") then val = 4
	else val = 1
	end
	return val 
end

-- Look in compass direction
function look(direction)
	while direction ~= orientations[orientation] do
		turnRight()
	end
end

function turnLeft()
	orientation = orientation - 1
	orientation = (orientation - 1) % 4
	orientation = orientation + 1
	turtle.turnLeft()
end

function turnRight()
	orientation = orientation - 1
	orientation = (orientation + 1) % 4
	orientation = orientation + 1  
	turtle.turnRight()
end


------------------------------------------------
--			   	   Movement					  --

-- Track GPS and move Forward
function moveForward(digging)
	--Set Coords
	currentX = currentX + xDiff[orientation]
	currentZ = currentZ + zDiff[orientation]

	-- Diging 1 = Normal Move -- Diging 2 = 
	local moved = false
	if digging == 1 then 
		while not(moved) do 
			moved = turtle.forward() 
			end 
	end
	if digging == 0 then
		while not(moved) do
			moved = turtle.forward()
			if not(moved) then 
				mineFront()
			end
		end
	end

	writeCoords()
	-- Move	
end

-- Track GPS Move UP
function moveUp()
	--Set Coords
	currentY = currentY + 1

	-- Move
	local moved = false
	while not(moved) do moved = turtle.up() end
end

-- Track GPS Move DOWN
function moveDown()
	--Set Coords
	currentY = currentY - 1

	-- Move
	local moved = false
	while not(moved) do moved = turtle.down() end
end

-- Move to a location, uses direction as to decide what axis to move along first
function goTo(direct, targetX, targetY, targetZ)
	-- Move along Z
	if direct == "z" then
		print('Going to Z = ' .. targetZ)
		-- Positive Z Direction
		if targetZ > currentZ then
			look("south")
			while targetZ > currentZ do
				moveForward(1)
			end
		end
		-- Negative Z Direction
		if targetZ < currentZ then
			look("north")
			while targetZ < currentZ do
				moveForward(1)
			end
		end

		print('Going to X = ' .. targetX)
		-- Negative X Direction
		if targetX < currentX then
			look("west")
			while targetX < currentX do
				moveForward(1)
			end
		end

		-- Positive X Direction
		if targetX > currentX then
			look("east")
			while targetX > currentX do
				moveForward(1)
			end
		end

	-- Move Along X
	elseif direct == "x" then
		print('Going to X = ' .. targetX)
		-- Negative X Direction
		if targetX < currentX then
			look("west")
			while targetX < currentX do
				moveForward(1)
			end
		end

		-- Positive X Direction
		if targetX > currentX then
			look("east")
			while targetX > currentX do
				moveForward(1)
			end
		end

		print('Going to Z = ' .. targetZ)
		-- Positive Z Direction
		if targetZ > currentZ then
			look("south")
			while targetZ > currentZ do
				moveForward(1)
			end
		end
		-- Negative Z Direction
		if targetZ < currentZ then
			look("north")
			while targetZ < currentZ do
				moveForward(1)
			end
		end
	end

	print('Going to Y = ' .. targetY)
	-- Negative Y Direction
	if targetY < currentY then
		while targetY < currentY do
			moveDown()
		end
	end

	-- Positive Y Direction
	if targetY > currentY then
		while targetY > currentY do
			moveUp()
		end
	end
end

-- Move to fuel and turn to face
function moveFuel()
	-- Save Start Coords + orient
	local saveX, saveY, saveZ = currentX, currentY, currentZ
	local saveFaceing = orientations[orientation] 

	moveDownTube()


	-- Move along z or x based on mining direction
	if miningOrientation == 1 or miningOrientation == 3 then
		goTo("x", fuelX, fuelY, fuelZ)
		local dirct = orientations[fuelOrientation]
		look(dirct)

	elseif miningOrientation == 2 or miningOrientation == 4 then
		goTo("z", fuelX, fuelY, fuelZ)
		local dirct = orientations[fuelOrientation]
		look(dirct)
	end

	-- SKULL SKULL SKULL
	slurp()

	-- Move Back to Start Point
	turnLeft()
	turnLeft()
	moveForward(1)
	goTo("x", currentX, saveY, currentZ)
	if miningOrientation == 1 or miningOrientation == 3 then
		goTo("z", saveX, saveY, saveZ)
		look(saveFaceing)
	elseif miningOrientation == 2 or miningOrientation == 4 then
		goTo("x", saveX, saveY, saveZ)
		look(saveFaceing)
	end

	turtle.select(1)
end

-- Move to storage
-- Given value determines if it stops at storage
-- 1 == stop 	0 == go back to original position
function moveStorage(half)

	if half == 0 then
		-- Save Start Coords + orient
		local saveX, saveY, saveZ = currentX, currentY, currentZ
		local saveFaceing = orientations[orientation] 

		moveDownTube()

		-- Move along z or x based on mining direction
		if (miningOrientation == 1) or (miningOrientation == 3) then
			goTo("x", storageX, storageY, storageZ)
			local dirct = orientations[storageOrientation]
			look(dirct)

		elseif (miningOrientation == 2) or (miningOrientation == 4) then
			goTo("z", storageX, storageY, storageZ)
			local dirct = orientations[storageOrientation]
			look(dirct)
		end

		-- Take a Dump
		dumpInventory()

		-- Move to start Point
		turnLeft()
		turnLeft()
		moveForward(1)
		goTo("x", currentX, saveY, currentZ)
		if (miningOrientation == 1) or (miningOrientation == 3) then
			goTo("z", saveX, saveY, saveZ)
			look(saveFaceing)
		elseif (miningOrientation == 2) or (miningOrientation == 4) then
			goTo("x", saveX, saveY, saveZ)
			look(saveFaceing)
		end

		--Reset to slot 1
		turtle.select(1)
	elseif half == 1 then
		moveDownTube()

		-- Move along z or x based on mining direction
		if (miningOrientation == 1) or (miningOrientation == 3) then
			goTo("x", storageX, storageY, storageZ)
			local dirct = orientations[storageOrientation]
			look(dirct)

		elseif (miningOrientation == 2) or (miningOrientation == 4) then
			goTo("z", storageX, storageY, storageZ)
			local dirct = orientations[storageOrientation]
			look(dirct)
		end

		-- Take a Dump
		dumpInventory()
	end
end

-- Down tube as centeral start point
function moveDownTube()
	local downX, downY, downZ = nil

	if storageOrientation == 1 then
		downX = storageX
		downY = storageY
		downZ = storageZ + 1
	elseif storageOrientation == 2 then
		downX = storageX - 1
		downY = storageY
		downZ = storageZ
	elseif storageOrientation == 3 then
		downX = storageX
		downY = storageY
		downZ = storageZ - 1
	elseif storageOrientation == 4 then
		downX = storageX + 1
		downY = storageY
		downZ = storageZ
	end
	
	if miningOrientation == 1 or miningOrientation == 3 then goTo("x", downX, currentY, downZ)
	elseif miningOrientation == 2 or miningOrientation == 4 then goTo("z", downX, currentY, downZ) end
end


function moveResumeMining(valX, valY, valZ, orient)
	-- Move along z or x based on mining direction
	if miningOrientation == 1 or miningOrientation == 3 then
		goTo("x", valX, valY, valZ)
		local dirct = orientations[orient]
		look(dirct)

	elseif miningOrientation == 2 or miningOrientation == 4 then
		goTo("z", valX, valY, valZ)
		local dirct = orientations[orient]
		look(dirct)
	end
end

------------------------------------------------
--			   Inventory Management		  	  --

-- Empty All slots -- Not slot 1 if using E chest for fuel
function dumpInventory()
	if fuelType == 0 then
		for i = 1, 16, 1  do
			turtle.select(i)
			turtle.drop()
		end
	elseif fuelType == 1 then
		for i = 2, 16, 1  do
			turtle.select(i)
			turtle.drop()
		end
	end
end

-- Check if there is any items in inventory
-- False if not full
function inventoryCheck()
	for  i = 1, 16, 1 do
		if turtle.getItemCount(i) == 0 then
			return false
		else
			return true
		end
	end
end

-- Check if 16th slot has item
-- False if it does not
function inventoryCheck16()
	if turtle.getItemCount(16) == 0 then return false
	else return true end
end

-- Refuel to 5760
function slurp()
	-- Refuel till fuel > 5760
	while turtle.getFuelLevel() < 5760 do
		-- Take 1 item from fuel chest
		for i = 1, 16, 1 do
			if turtle.getItemCount(i) == 0 then
				turtle.select(i)
				turtle.suck(1)
				break
			end
		end

		-- Find fuel
		for i = 1, 16, 1 do
			-- If the item is fuel refuel
			local data = turtle.getItemDetail(i)
			if data then
				local name = tostring(data.name)
				if arrHasVal(fuelTypesAccepted, name) then
					turtle.refuel()
				end
			end
		end
	end
end 

------------------------------------------------
--			  	   Digging					  --

-- Check If block to be dug is on black list
function blockCheck(direct)
	local success, data, name = nil
	if direct == "up" then
		success, data = turtle.inspectUp()
		name = tostring(data.name)
		return arrHasVal(blockedMineItems, name)
	elseif direct == "down" then
		success, data = turtle.inspectDown()
		name = tostring(data.name)
		return arrHasVal(blockedMineItems, name)
	elseif direct == "front" then
		success, data = turtle.inspect()
		name = tostring(data.name)
		return arrHasVal(blockedMineItems, name)
	end
end

-- Mine Functions
function mineFront()
	if not(blockCheck("front")) then
		turtle.dig()
		blocksMined = blocksMined + 1
	else
		dodgeBlock()
	end
end
function mineUp()
	if not(blockCheck("up")) then
		turtle.digUp()
		blocksMined = blocksMined + 1
	end
end
function mineDown()
	if not(blockCheck("down")) then
		turtle.digDown()
		blocksMined = blocksMined + 1
	end
end

-- Move Around Not Mineable Block
function dodgeBlock()
	moveUp()
	mineFront()
	moveDown()
	moveDown()
	mineFront()
	moveForward(0)
	mineFront()
	mineUp()
	moveUp()
	mineUp()
end

-- Digs 1 x 3 in front of it
function defualtDig()
	mineFront()
	moveForward(0)
	mineUp()
	mineDown()
end

-- Full Dig (2 Rows)
function dig(last)

	-- First Row
	for i = 1, length1, 1 do
		defualtDig()

		-- Check Inv
		if inventoryCheck16() then moveStorage(0) end
		-- Check Fuel
		if turtle.getFuelLevel() < 500 then moveFuel() end 
	end

	turnRight()
	defualtDig()
	turnRight()

	-- Second Row
	-- First Row
	for i = 1, length1, 1 do
		defualtDig()

		-- Check Inv
		if inventoryCheck16() then moveStorage(0) end
		-- Check Fuel
		if turtle.getFuelLevel() < 500 then moveFuel() end 
	end

	-- Last Row of Even -- Dont dig wall
	if 1 == last then
		-- Turn Left and Dig
		turnLeft()
		defualtDig()
	
		-- Turn Left
		turnLeft()
	end
end

------------------------------------------------
--			  		 Drones					  --

function setupDrone()
	--Save Start Y Lvl
	local startY = currentY

	-- Delay and wait for fuel
	print("Please place fuel in the first slot (32 Coal)")
	while turtle.getFuelLevel() < 2560 do
		--while turtle.getItemDetail(i).name ~= "minecraft:coal" do end
		turtle.select(1)
		turtle.refuel()
		print("Fuel is at " .. turtle.getFuelLevel() .. " it needs to be above 2560")
	end

	-- Move to first dig hole
	moveForward(1)

	-- Dig First Hole down to y = 5
	while currentY ~= 5 do
		turtle.digDown()
		blocksMined = blocksMined + 1
		moveDown()
	end

	-- Move to second dig hole
	turnRight()
	turtle.dig()
	moveForward(1)

	-- Dig second Hole down to y = 5
	while currentY ~= startY do
		turtle.digUp()
		blocksMined = blocksMined + 1
		moveUp()
	end

	-- move to third dig hole
	turnLeft()
	moveForward(1)

	-- Dig third Hole down to y = 5
	while currentY ~= 5 do
		turtle.digDown()
		blocksMined = blocksMined + 1
		moveDown()
	end

	-- move to last dig hole
	turnLeft()
	turtle.dig()
	moveForward(1)

	-- Dig last Hole down to y = 5
	while currentY ~= startY do
		turtle.digUp()
		blocksMined = blocksMined + 1
		moveUp()
	end

	--Turn to dump
	turnRight()
	fuelType = 0
	dumpInventory()

	-- Complete
	turnRight()
	turnRight()
	moveForward(1)
	moveForward(1)
	complete()
end

function miningDrone()
	print("P1")
	-- Variables
	local loopSection = 1
  	local sectionX = 0
  	local sectionY = 0
  	local sectionZ = 0
  	local sectionOrient = 0

	-- If first boot
	if not(fExists("MiningProgress.txt")) then
		print("Yeet?")
		-- Local Variables
		local last = nil

		-- Get Start Fuel
		turnLeft()
		turtle.select(1)
		turtle.suck(1)
		turtle.refuel()
		print("P2")
		-- Get Fuel Required for work
		turnRight()
		turnRight()
		print("P3")
		moveForward(1)
		turnLeft()
		moveForward(1)
		turnRight()
		slurp()

		-- Move to dig height
		turnRight()
		turnRight()
		moveForward(1)
		goTo("x", currentX, miningHeight, currentZ)

		-- Face Direction of dig
		local direct = orientations[miningOrientation]
		look(direct)
	else
		print("Sugma")
		loopSection, sectionX, sectionY, sectionZ, sectionOrient = resumeMining()
		-- Move to start point
		moveDownTube()
		goTo("x", currentX, miningHeight, currentZ)
		moveResumeMining(sectionX, sectionY, sectionZ, sectionOrient)
	end
	
	-- What needs to be save, current L2 i value, coords of start of section and facing direction
	-- on reboot start at beginning of L2 section

	-- Do the deed
	if length2 % 2 == 0 then
		print("There is " .. length2 / 2 .. " sections")
		-- Loop for 1/2 of Length 2 -- 1 loop is called a section
		for i = loopSection, length2 / 2, 1 do
			-- Save Current State
			writeMiningInfo(i)

			-- Debug Info
			print("Run Number: " .. i)

			-- Check if last run
			-- Doesnt Dig out an extra row if it is the last run
			local last = 1
			if i == (length2 / 2) then last = 0 end

			-- Last Run
			print("Diggy Hole: " .. length1)
			dig(last)
		end
	else
		print("There is " .. length2 / 2 .. " sections")
		-- Loop for 1/2 of Length 2 -- 1 loop is called a section
		for i = loopSection, (length2 - 1) / 2, 1 do
			-- Save Current State
			writeMiningInfo(i)
			-- Debug Info
			print("Run Number: " .. i)
			print("Diggy Hole: " .. length1)
			dig(1)
		end

		-- First Row
		for i = 1, length1, 1 do
			defualtDig()

			-- Check Inv
			if inventoryCheck16() then moveStorage(0) end
			-- Check Fuel
			if turtle.getFuelLevel() < 500 then moveFuel() end 
		end

	end

	-- Return Home
	moveStorage(1)
	turnRight()
	turnRight()
	moveForward(1)
	moveForward(1)
	complete()
end

------------------------------------------------
--			  Startup And Finish			  --

function writeBasicInfo()
	-- Open and clear the TXT File
	f = io.open("DroneTurtleInfo.txt", "w+")

	-- Write the info to file
	f:write(tostring(startX) .. "\n")
	f:write(tostring(startY) .. "\n")
	f:write(tostring(startZ) .. "\n")
	f:write(tostring(storageX) .. "\n")
	f:write(tostring(storageY) .. "\n")
	f:write(tostring(storageZ) .. "\n")
	f:write(tostring(storageOrientation) .. "\n") -- wrong
	f:write(tostring(fuelX) .. "\n")
	f:write(tostring(fuelY) .. "\n")
	f:write(tostring(fuelZ) .. "\n")
	f:write(tostring(fuelOrientation) .. "\n") -- wrong
	f:write(tostring(fuelType) .. "\n") -- Dont have
	f:write(tostring(miningHeight) .. "\n")
	f:write(tostring(length1) .. "\n")
	f:write(tostring(length2) .. "\n")
	f:write(tostring(miningOrientation) .. "\n")
	f:write(tostring(mode) .. "\n")
	f:write(tostring(totalArea) .. "\n")

	-- Close File
	f:close()
end

-- Read all saved info
function readBasicInfo()
	-- Get inf
	local arr = fRead("DroneTurtleInfo.txt")

  	-- Assign Values that are pulled from file
  	startX = tonumber(arr[1])
	startY = tonumber(arr[2])
	startZ = tonumber(arr[3])
	storageX = tonumber(arr[4])
	storageY = tonumber(arr[5])
	storageZ = tonumber(arr[6])
	storageOrientation = tonumber(arr[7])
	fuelX = tonumber(arr[8])
	fuelY = tonumber(arr[9])
	fuelZ = tonumber(arr[10])
	fuelOrientation = tonumber(arr[11])
	fuelType = tonumber(arr[12]) -- 0 = Hard Fuel       1 = Ender Chest Method
	miningHeight = tonumber(arr[13])
	length1 = tonumber(arr[14])
	length2 = tonumber(arr[15])
	miningOrientation = tonumber(arr[16])
	mode = tonumber(arr[17]) -- 1 = Mining Drone       0 = Setup Drone
	totalArea = tonumber(arr[18])

	for i = 1, 18, 1 do
		print(arr[i])  
	end
end

-- Get Basic Info
function initalStart()
	local senderID, protocol, operationType, setupSerialize = nil
	local setupTable = {}

	print("Boot Up")
	-- Mode
	senderID, operationType, protocol = rednet.receive("TurtleMode")
	if operationType == "mining" then mode = 1
	elseif operationType == "setup" then mode = 0 end
	print("Timeout")
	print("Mode: " .. operationType, mode)

	-- Turtle Start Coords
	senderID, setupSerialize, protocol = rednet.receive("TurtleInfo")
	setupTable = textutils.unserialize(setupSerialize)
	orientation = setupTable[1]
	startX = setupTable[2]
	startY = setupTable[3]
	startZ = setupTable[4]
	currentX = startX
	currentY = startY
	currentZ = startZ

	-- Work out cords
	-- North
	if orientation == 1 then
		storageX = startX 
		storageY = startY
		storageZ = startZ - 2
		storageOrientation = 1
		fuelX = startX + 1
		fuelY = startY
		fuelZ = startZ - 1
		fuelOrientation = 2
		
 
	-- East
	elseif orientation == 2 then
		storageX = startX + 2
		storageY = startY
		storageZ = startZ
		storageOrientation = 2
		fuelX = startX + 1
		fuelY = startY
		fuelZ = startZ + 1
		fuelOrientation = 3

	-- South
	elseif orientation == 3 then
		storageX = startX
		storageY = startY
		storageZ = startZ + 2
		storageOrientation = 3
		fuelX = startX - 1
		fuelY = startY
		fuelZ = startZ + 1
		fuelOrientation = 4

	-- West
	elseif orientation == 4 then
		storageX = startX - 2
		storageY = startY
		storageZ = startZ 
		storageOrientation = 4
		fuelX = startX - 1
		fuelY = startY
		fuelZ = startZ - 1
		fuelOrientation = 1
	end


	-- If Mining Turtle
	if mode == 1 then
		-- Fuel Type
		senderID, fuelType, protocol = rednet.receive("TurtleFuelMode")
		if fuelType == 0 then print("Hard Fuel Selected")
		elseif fuelType == 1 then print("Enderchest Fuel Method Selected") end

		-- Get Lengths
		senderID, length1, protocol = rednet.receive("Length1Turtle")
		print("Length 1: " .. length1)
		senderID, length2, protocol = rednet.receive("Length2Turtle")
		print("Length 2: " .. length2)
		senderID, miningHeight, protocol = rednet.receive("MineHeightTurtle")
		-- Debug
		totalArea = 3 * length1 * length2
		totalArea = math.abs(totalArea)
		print('Total Amount of Blocks to be Mined: ', totalArea)

		-- Get Direction
		senderID, miningOrientation, protocol = rednet.receive("MiningDirection")
		print("Direction to mine: " .. miningOrientation)

		-- Make Sure they are all Ints
		fuelType = tonumber(fuelType)
		miningHeight = tonumber(miningHeight)
		length1 = tonumber(length1)
		length2 = tonumber(length2)
		miningOrientation = tonumber(miningOrientation)
	end
	
	-- Make Sure they are all Ints
	startX = tonumber(startX)
	startY = tonumber(startY)
	startZ = tonumber(startZ)
	storageX = tonumber(storageX)
	storageY = tonumber(storageY)
	storageZ = tonumber(storageZ)
	storageOrientation = tonumber(storageOrientation)
	fuelX = tonumber(fuelX)
	fuelY = tonumber(fuelY)
	fuelZ = tonumber(fuelZ)
	fuelOrientation = tonumber(fuelOrientation)
	currentX = tonumber(currentX)
	currentY = tonumber(currentY)
	currentZ = tonumber(currentZ)
	orientation = tonumber(orientation)
end

-- Complete Jov
function complete()
	-- Remove All Files
	if fExists("DroneTurtleInfo.txt") then shell.run("delete DroneTurtleInfo.txt") end
	if fExists("GPSLocation.txt") then shell.run("delete GPSLocation.txt") end
	if fExists("MiningProgress.txt") then shell.run("delete MiningProgress.txt") end
	if fExists("DroneTurtle") then shell.run("delete DroneTurtle") end

	-- Local Variables
	local completeInfo = {}

	-- Save Data to array to be sent
	completeInfo[1] = miningHeight
	completeInfo[2] = totalArea
	completeInfo[3] = blocksMined

	-- 
	completeInfo = textutils.serialize(completeInfo)
	rednet.broadcast(completeInfo, "TurtleCompleteInfo")
	rednet.broadcast("jobcomplete")
end

-- Write i value of current section and section start coords and orient
function writeMiningInfo(val)
	-- Open the file to write the value too
	f = io.open("MiningProgress.txt", "w+")

	-- Write All needed values to file
	f:write(tostring(val) .. "\n")
	f:write(tostring(currentX) .. "\n")
	f:write(tostring(currentY) .. "\n")
	f:write(tostring(currentZ) .. "\n")
	f:write(tostring(orientation) .. "\n")

	-- Close File
	f:close()
end

-- Resume previous action before reboot
function resumeMining()
	-- Check Inv in case that operation was happening
	if inventoryCheck() then 
		moveStorage(0)
		dumpInventory()
	end
	-- Check Fuel lvl in case that operation was happening
	if turtle.getFuelLevel() < 5760 then
		moveFuel()
		slurp()
	end

	-- Read and Save from 
	local arr = fRead("MiningProgress.txt")

  	-- Save to local Vars
  	local l2 = tonumber(arr[1])
  	local sectionX = tonumber(arr[2])
  	local sectionY = tonumber(arr[3])
  	local sectionZ = tonumber(arr[4])
  	local sectionOrient = tonumber(arr[5])

  	-- Return Needed values
  	return l2, sectionX, sectionY, sectionZ, sectionOrient
end

------------------------------------------------
--			  	Main Program				  --

rednet.open("right")

-- First Boot
if not(fExists("DroneTurtleInfo.txt")) then
	initalStart()
	writeBasicInfo()
	writeCoords()
end

-- Normal Operation
readBasicInfo()
readCoords()


-- Main Loop
while true do
	print("Loop Start")
	if mode == 0 then 
		print("Setup Drone")
		setupDrone()
	elseif mode == 1 then 
		print("Mining Drone")
		miningDrone()
	end
end