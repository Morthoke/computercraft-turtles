-- Delay start for GPS to turn on

sleep(10)

------------------------------------------------
--					GPS Vals		     	  --

turtleX, turtleY, turtleZ = gps.locate()

function gps() turtleX, turtleY, turtleZ = gps.locate() end

------------------------------------------------
--				Global Variables			  --

orientation = 0
startX, startY, startZ = nil -- Location to end the operation at
storageX, storageY, storageZ = gps.locate() -- Storage Coords
fuelX, fuelY, fuelZ = gps.locate() -- Fuel Coords
storageO, fuelO = nil -- Storage and fuel orientation
downTubeX, downTubeY, downTubeZ = gps.locate() -- Down travel tube coords
upTubeX, upTubeY, upTubeZ = gps.locate()
fuelUsed = 0 -- Lookup table determines fuel type from this number


-- Runtime Variables
minningHeight = nil
length1, length2 = nil
miningOrientation = nil
operationType = -1 -- 1 == Minning Drone /// 2 == Setup Drone
blocksMined = 0
status = "" -- waiting // minning // fueling // dumping // moving // setup

-- LookupTables
orientations = {"north", "east", "south", "west"}
xDiff = {0, 1, 0, -1}
zDiff = {-1, 0, 1, 0}
fuelTypesAccepted = {"thermal:charcoal_block", "minecraft:coal", "minecraft:charcoal"}
blockedMineItems = {"minecraft:spawner", "forbidden_arcanus:stella_arcanum", "minecraft:glass", "tconstruct:seared_bricks", 
	"tconstruct:seared_stone", "create:gantry_shaft", "tconstruct:smeltery_controller", "tconstruct:seared_fuel_tank",
	"tconstruct:seared_drain", "create:redstone_link", "create:andesite_casing", "create:cogwheel", "create:large_cogwheel", 
	"create:belt", "create:water_wheel", "create:shaft", "create:chute", "create:andesite_belt_funnel", "create:encased_fan",
	"create:gearbox", "create:mechanical_pump", "create:fluid_pipe", "create:glass_fluid_pipe", "metalbarrels:gold_barrel",
	"create:framed_glass", "create:adjustable_chain_gearshift", "minecraft:lever", "minecraft:oak_wall_sign"}

------------------------------------------------
--				   Utilities				  --

-- Check if file exists // False // True
function fExists(name)
	local f = io.open(name, "r")
	if f ~= nil then io.close(f) return true
	else return false end
end

------------------------------------------------
--				   Reporting				  --

-- Report current state of turtle
function reportStatus()
	local repStat = "miningSetupDrone:status"
	rednet.broadcast(status, repStat)
	print("Current Drone Status: " .. status)
end


------------------------------------------------
--			   	   Movement					  --

-- If Digging set to 1 will mine block in front if the drone cannot move
-- If not digging set to 0 will not mine
function moveForward(digging)
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
end

function moveUp()
	-- Move
	local moved = false
	while not(moved) do moved = turtle.up() end
end

function moveDown()
	-- Move
	local moved = false
	while not(moved) do moved = turtle.down() end
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
		-- TO ADD IN BLOCK SKIPPING ALGORITHIM TO MOVE AROUND ANY BLACKLISTED BLOCKS
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

-- Digs 1 x 3 in front of it
function defualtDig()
	mineFront()
	moveForward(0)
	mineUp()
	mineDown()
end


------------------------------------------------
--			  		 Drones					  --

function setupDrone()
	-- Print the design of the area
	print("Layout of the fuel, storage and tunnels:\n")
	print(" _ _ _ _ _ _\n")
	print("| A   C   A |\n")
	print("| F   A   A |\n")
	print("| F   A   U |\n")
	print("| S   A   D |\n")
	print(" ‾ ‾ ‾ ‾ ‾ ‾\n")
	print("C = Controller // A = Air\n")
	print("F = Fuel // S = Storage\n")
	print("U = Up // D = Down \n")

	-- Wait for fuel to be inputed
	print("Please place fuel in the first slot (32 Coal)")
	while turtle.getFuelLevel() < 2560 do
		-- While turtle.getItemDetail(i).name ~= "minecraft:coal" do end
		turtle.select(1)
		turtle.refuel()
		print("Fuel is at " .. turtle.getFuelLevel() .. " it needs to be above 2560")
	end

	-- Dig out the required area for the setup drone
	print("Digging out requried area for operation!\n")
	print("Is this minecraft 1.18 or later? 1 = Yes\n 2 = No\n")
	local tmp = tostring(io.read())

	if tmp = 

	mineFront()
	moveForward(0)
	turnRight()
	moveForward(1)
	turnLeft()
	moveForward(1)
	moveForward(1)
	turnLeft()
	moveForward(1)
	moveForward(1)


	-- Dig down to Y level based on MC version
	while turtleY ~=  do
		turtle.digDown()
		blocksMined = blocksMined + 1
		moveDown()
	end

end

------------------------------------------------
--			  	Main Program				  --

rednet.open("left")

-- Startup Operations
if not("operationData.txt") then
	status = "setup"
	reportStatus()

	print("\nDrone Setup Phase")
	local senderID, protocol, operationType, tmp, setupSerialize = nil
	local infoPass = {}
	senderID, operationType, protocol = rednet.receive("controlDrone:deployedType")
	-- Setup Drone
	if operationType == "setupDrone" then 
		operationType = 2
		senderID, orientation, protocol = rednet.receive("setupDrone:setup")
		startX, startY, startZ = gps.locate()
		setupDrone() 
	elseif operationType == "miningDrone" then
		operationType = 1
		senderID, tmp, protocol = rednet.recieve("miningDrone:setup")
		infoPass = textutils.unserialize(tmp)
		orientation	= infoPass[1]
		fuelUsed = infoPass[2]
		startX, startY, startZ = gps.locate()

		-- Ask for lengths and directions
		rednet.broadcast("miningInfo", "miningDrone:detailRequest")
		senderID, tmp, protocol = rednet.recieve("miningDrone:receival")
		infopass = textutils.unserialize(tmp)
		length1 = infoPass[1]
		length2 = infoPass[2]
		miningHeight = infoPass[3]
		miningOrientation = infoPass[4]

		-- Establish Coords of storage, fuel drive
		-- North
		if orientation == 1 then
			fuelZ = fuelZ + 2
			storageZ = storageZ + 3
			downTubeX = downTubeX + 1
			downTubeZ = downTubeZ + 3
			upTubeX = upTubeX + 1
			upTubeZ = upTubeZ + 2
		
		-- East
		elseif orientation == 2 then
			fuelX = fuelX - 2
			storageX = storageX - 3
			downTubeX = downTubeX - 3
			downTubeZ = downTubeZ + 1
			upTubeX = upTubeX - 2
			upTubeZ = upTubeZ + 1

		-- South
		elseif orientation == 3 then
			fuelZ = fuelZ - 2
			storageZ = storageZ - 3
			downTubeX = downTubeX - 1
			downTubeZ = downTubeZ - 3
			upTubeX = upTubeX - 1
			upTubeZ = upTubeZ - 2
		
		-- East
		elseif orientation == 4 then
			fuelX = fuelX + 2
			storageX = storageX + 3
			downTubeX = downTubeX + 3
			downTubeZ = downTubeZ - 1
			upTubeX = upTubeX + 2
			upTubeZ = upTubeZ - 1
		end
	end
end

