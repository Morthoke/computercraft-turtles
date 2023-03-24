-- Delay start for GPS to turn on

sleep(10)

------------------------------------------------
--					GPS Vals		     	  --

turtleX, turtleY, turtleZ = gps.locate()

------------------------------------------------
--				Global Variables			  --

orientation = 0 -- 0 == NIL // 1 = N // 2 = E // 3 = S // 4 = W
dronesInUse = 0
fuelUsed = 0
status = "" -- operating // setup // no drones
turtName = "" -- Determined at setup



-------          Lookup Tables           -------
-- 				   1        2       3        4 
orientations = {"north", "east", "south", "west"}
fuelTypesAccepted = {"thermal:charcoal_block", "minecraft:coal", "minecraft:charcoal"} -- Can Add in modded items as we find fuel types
fuelTypesNames = {"charcoal Blocks", "Coal", "Charcoal"}



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

-- If there are any turtles in storage returns the true and location of turtle
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

-- Deploy Minning Turtle
function deployMiningDrone()
	local haveDrone, droneInvLoc = turtleCheck()
		if haveDrone then
			turtle.select(turtLoc)
			turtle.place()
			dronesInUse = dronesInUse + 1
			reportDeployed()
		end

		-- Add All data to table
		local setupTable = {}
		setupTable[1] = orientation
		setupTable[2] = fuelUsed
		local infoPass = textutils.serialize(setupTable)
		-- Turn on and wait for boot
		peripheral.call("front", "turnOn")
		sleep(5)

		rednet.broadcast("miningDrone", "controlDrone:deployedType")
		rednet.broadcast(infoPass, "miningDrone:setup")
end


------------------------------------------------
--				   Reporting				  --

-- Report current state of turtle
function reportStatus()
	local repStat = turtName .. ":status"
	rednet.broadcast(status, repStat)
	print("Current Turtle Status: " .. status)
end

-- Report qty of turtles deployed
function reportDeployed()
	local repDep = dronesInUse .. ":deployedCount"
	rednet.broadcast(dronesInUse, repDep)
end

-- Might need to add future control turtles for farms
function reportNewTurt()
	rednet.broadcast(turtName, "NewMineControl")
	-- local repType = turtname .. ":controlType"
	-- rednet.broadcast(controlType, repType)
end

------------------------------------------------
--			    File Operations		    	  --

-- Write Operational Values to txt file
function writeOp()
	-- Open File
	f = io.open("operationalData.txt", "w+")

	-- Write info
	f:write(tostring(turtName) .. "\n")
	f:write(tostring(orientation) .. "\n")
	f:write(tostring(dronesInUse) .. "\n")
	f:write(tostring(fuelUsed) .. "\n")

	-- Close File
	f:close()
end

-- Read operational Vals
function readOp()
	local arr = fRead("operationalData.txt")
	turtName = tostring(arr[1])
	orientation = tostring(arr[2])
	dronesInUse = tostring(arr[3])
	fuelUsed = tostring(arr[4])
end


------------------------------------------------
--					  Main					  --

rednet.open("left")

-- Startup Operations
if not(fExists("operationalData.txt")) then
	
	status = "setup"
	reportStatus()

	orientationDetermine()
	print("\n Mine Control Turtle Setup")

	-- Name Turtle
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

	-- Fuel Selection
	print("\n Please select fuel type: ")
	local tmpCount = 1
	for #fuelTypesNames do
		print(tmpCount .. ": " fuelTypesNames[tmpCount])
		tmpCount = tmpCount + 1
	end
	fuelUsed = tonumber(io.read())

	-- Deploy Setup Drone
	-- turn on // tell where is setup script // pass orient // when done break drone // wait for completion before moving on
	local setupOperation = false
	while(not setupOperation) do
		-- Check and place turtle
		local haveDrone, droneInvLoc = turtleCheck()
		if haveDrone then
			turtle.select(turtLoc)
			turtle.place()
			dronesInUse = dronesInUse + 1
			reportDeployed()
		end

		-- Turn on and wait for boot
		peripheral.call("front", "turnOn")
		sleep(5)

		rednet.broadcast("setupDrone", "controlDrone:deployedType")
		local infoPass = textutils.serialize(orientation)
		rednet.broadcast(infoPass, "setupDrone:setup")
		local setupComplete = false
		
		print("\n\n\n\n\n\nSetup Drone Deployment /// Please wait for completion")
		while (not setupComplete) do
			local senderID, protocol, setupDroneStatus, setupSerialize = nil
			senderID, setupDroneStatus, protocol = rednet.receive("setupDrone:status")
			if setupDroneStatus == "complete" then 
				local success, data = turtle.inspect()
				if success then
					setupComplete = true
					local name = tostring(data.name)
					if name == "computercraft:turtle_normal" then
						turtle.dig()
					end
				end
			end
		end
	end
	writeOp()
	print("\n\nSetup Complete")
else 
	readOp()
end

-- Main Function
status = "operating"
reportStatus()

print("Main Functionality Begins")
while true do
	local senderID, message, protocol = rednet.receive()

	-- Deploy Turtle from remote connection
	if message == "controlDrone:deployDrone" then print("Mining Turtle Deployment"); deployMiningDrone() end

	-- Mining Turtle Complete
	if message == "controlDrone:droneDone" then print("Mining Job Complete"); jobDone() end
end