------------------------------------------------
--				Global Variables			  --

orientation = 3
storageX = 0
storageY = 0
storageZ = 0
length1 = nil
length2 = nil
height = nil
startX = nil
startY = nil
startZ = nil
currentX = nil
currentY = nil
currentZ = nil


-- Lookup Tables
-- 				   0        1       2        3 
orientations = {"north", "east", "south", "west"}
xDiff = {0, 1, 0, -1}
zDiff = {-1, 0, 1, 0}

------------------------------------------------
--				Direction Tracking			  --

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
--			  		Movement				  --

-- Move to this point
function goTo(targetX, targetY, targetZ)
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

-- Move to Start Point
function startPoint()
	goTo(currentX, height, currentZ)
end

-- Track GPS and move Forward
function moveForward(digging)
	--Set Coords
	currentX = currentX + xDiff[orientation]
	currentZ = currentZ + zDiff[orientation]

	local moved = false
	if digging = 1 then while not(moved) do moved = turtle.forward() end end
	if digging = 0 then
		while not(moved) do
			moved = turtle.forward()
			if not(moved) then turtle.dig() end
		end
	end
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

------------------------------------------------
--			  Inventory Management			  --

-- Check if there is any items in inventory
function inventoryCheck()
	local full = true
	for  i = 1, 16, 1 do
		if turtle.getItemCount(i) == 0 then
			full = false
		end
	end
	return full
end

-- Empty All slots apart from fuel (Coal Slot)
function dumpInventory()
	for i = 2, 16, 1  do
		turtle.select(i)
		turtle.drop()
	end
end

-- Fuel
function slurp()
	turtle.select(1)
	if turtle.refuel(0) and turtle.getItemCount(1) > 1 and turtle.getFuelLevel() < 300 then
		local halfstack = math.ceil(turtle.getItemCount(1)/2) -- Halfs amount in the slot
		turtle.refuel(halfstack)
	end
	print('Fuel Level: ' .. turtle.getFuelLevel())
end

function emptyInventory()
	-- Save Location and Direction
	local saveX, saveY, saveZ = currentX, currentY, currentZ
	local saveFaceing = orientations[orientation]
	goTo(storageX, currentY, currentZ)
	goTo(storageX, storageY, storageZ)
	look("south")
	dumpInventory()
	goTo(currentX, saveY, currentZ)
	goTo(saveX, saveY, saveZ)
	look(saveFaceing)
end
				

------------------------------------------------
--			  		Digging			  		  --

-- Mining
function diggyHole(distance, last)
	-- Digs 1 x 3 and moves forward
	local function defualtDig()
		turtle.dig()
		moveForward(0)
		turtle.digUp()
		turtle.digDown()
	end

	-- Dig for length distance
	for i = 1, distance, 1 do
		defualtDig()

		--Check Inv
		if (i % 5 == 0) then
			-- Check Inv if full go back to dump and return
			print('Inventory Check')
			if inventoryCheck() then
				print('Inventory Full')
				emptyInventory()
			end
		end

	end

	-- Turn Right and Dig
	turnRight()
	defualtDig()

	-- Face Next Dig Direction
	turnRight()

	-- Dig for length distance
	for i = 1, distance, 1 do
		defualtDig()

		--Check Inv
		if (i % 5 == 0) then
			-- Check Inv if full go back to dump and return
			print('Inventory Check')
			if inventoryCheck() then
				print('Inventory Full')
				emptyInventory()
			end
		end
	end

	-- If is the last row then dont dig into wall
	if 1 == last then
		-- Turn Left and Dig
		turnLeft()
		defualtDig()
	
		-- Turn Left
		turnLeft()
	
	end
end

function halfDiggyHole(distance)
	-- Digs 1 x 3 and moves forward
	local function defualtDig()
		turtle.dig()
		moveForward(1)
		turtle.digUp()
		turtle.digDown()
	end

	-- Dig for length distance
	for i = 1, distance, 1 do
		defualtDig()
	end
end

-- Mine Out Area
function doTheThing(L1, L2)
	-- Even Number of rows
	if (L2 % 2 == 0) then
		print('Even')
	
	
		-- Loop for Half length 2
		for i = 1, L2 / 2, 1 do
			-- Debug
			io.write('\nRun Number: ', i, '\n')
		
		
			local last = 1 -- Check if last run
			if i == (L2 / 2) then last = 0 end

			print('Diggy Hole: ' .. L1)
			diggyHole(L1, last) -- DIGGY DIGGY HOLE

			-- Check Inv if full go back to dump and return
			print('Inventory Check')
			if inventoryCheck() then
				print('Inventory Full')
				emptyInventory()
			end

			print('refuel')
			-- Fuel Check
			slurp()

		end
	else
		print('Odd')
		-- Make Even
		L2 = L2 - 1
		-- Loop for Half length 2
		for i = 1, L2 / 2, 1 do
			-- Debug
			io.write('\nRun Number: ', i, '\n')
			print('diggyHole: ' .. L1)
			diggyHole(L1, false) -- Has 1 run after for loop
			print('inventoryCheck')
			-- Check Inv if full go back to dump and return
			if inventoryCheck() then
				print('emptyInventory')
				emptyInventory()
			end
			-- Fuel Check
			print('refuel')
			slurp()
		end

		-- Last Row to be done for ODD
		print('halfDiggyHole')
		halfDiggyHole()
	end
end


------------------------------------------------
--			  Startup And Finish			  --

-- Get the storage location, facing direction and mining area
function initialStart()
	local senderID, protocol, facing  = nil
	-- Debug
	print("Boot Up\n")
	-- Storage Location
	senderID, storageX, protocol = rednet.receive("StorageTurtleX")
	senderID, storageY, protocol = rednet.receive("StorageTurtleY")
	senderID, storageZ, protocol = rednet.receive("StorageTurtleZ")
	-- Debug
	print("Storage location: " .. storageX .. ", " .. storageY .. ", " .. storageZ)

	-- Facing Direction
	senderID, facing, protocol= rednet.receive("FacingTurtle")
	orientation = getDirection(string.lower(facing))
	-- Debug
	print("Direction Facing: " .. orientations[orientation])

	-- Start Coords
	senderID, currentX, protocol = rednet.receive("TurtleX")
	senderID, currentY, protocol = rednet.receive("TurtleY")
	senderID, currentZ, protocol = rednet.receive("TurtleZ")
	startX = currentX
	startY = currentY
	startZ = currentZ
	-- Debug
	print('Start Coords: ' .. currentX .. ", " .. currentY .. ", " .. currentZ)

	-- Mining Area
	senderID, length1, protocol = rednet.receive("Length1Turtle")
	print("Length 1: " .. length1)
	senderID, length2, protocol = rednet.receive("Length2Turtle")
	print("Length 2: " .. length2)
	senderID, height, protocol = rednet.receive("MineHeightTurtle")
	-- Debug
	local totalSize = 3 * length1 * length2
	totalSize = math.abs(totalSize)
	print('Total Amount of Blocks to be Mined: ', totalSize)

	-- To Ints
	storageX = tonumber(storageX)
	storageY = tonumber(storageY)
	storageZ = tonumber(storageZ)
	length1 = tonumber(length1)
	length2 = tonumber(length2)
	height = tonumber(height)
	startX = tonumber(startX)
	startY = tonumber(startY)
	startZ = tonumber(startZ)
	currentX = tonumber(currentX)
	currentY = tonumber(currentY)
	currentZ = tonumber(currentZ)
end

--DONEEEEEEEEE
function complete()
	print('My Coords Are: ' .. currentX .. ", " .. currentY .. ", " .. currentZ)

	goTo(storageX, storageY, storageZ)
	dumpInventory()
	goTo(startX, startY, startZ)
	rednet.broadcast("complete")
end

------------------------------------------------
--			  	Main Program				  --

rednet.open("right")
initialStart()
print('Startup Complete\n')
slurp()
print('Fueled like a big boi\n')
startPoint()
print('Time to rock and roll')
doTheThing(length1, length2)
print('Done -- Going Home')
complete()