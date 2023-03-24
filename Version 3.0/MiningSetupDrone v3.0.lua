-- Delay start for GPS to turn on

sleep(10)

------------------------------------------------
--					GPS Vals		     	  --

turtleX, turtleY, turtleZ = gps.locate()

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
fuelTypesAccepted = {"thermal:charcoal_block", "minecraft:coal", "minecraft:charcoal"
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
--			  		 Drones					  --

function setupDrone()

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

		-- Move Drone Forwards 1 Spot

	end
end

