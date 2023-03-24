------------------------------------------------
--				Global Variables			  --

storageX = nil
storageY = nil
storageZ = nil
facing = nil

-- Check if there is any items in inventory
function inventoryCheck()
	local items = false
	for  i = 1, 16, 1 do
		if turtle.getItemCount(i) > 0 then
			items = true -- Not Full
		end
	end
	return items
end

function coalCheck()
	local coal = false
	local location = nil
	for i = 1, 16, 1 do
		local data = turtle.getItemDetail(i)
		if data then
			local name = tostring(data.name)
			if name == "minecraft:coal" then
				coal = true
				location = i
				break
			end
		end
	end
	return coal, location
end

function turtleCheck()
	local turt = false
	local location = nil
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

-- Send out the fucker
function deployTurtle()
	local haveTurt, turtLoc = turtleCheck()
	if haveTurt then
		turtle.select(turtLoc)
		turtle.place()
	end

	-- Give Coal
	local haveCoal, coalLoc = coalCheck()
	if haveCoal then
		turtle.select(coalLoc)
		local quater = math.ceil(turtle.getItemCount(coalLoc)/4)
		turtle.drop(quater)
	end

	-- Start Turtle
	peripheral.call("front", "turnOn")
	os.sleep(10)
	--Give Storage
	rednet.broadcast(tostring(storageX), "StorageTurtleX")
	rednet.broadcast(tostring(storageY), "StorageTurtleY")
	rednet.broadcast(tostring(storageZ), "StorageTurtleZ")
	-- Give Face
	rednet.broadcast(tostring(facing), "FacingTurtle")
end

-- Initial Start
function initalStart()
	io.write("\nPlease Enter the cords of turtle dump")
	io.write("\nX = ")
	storageX = io.read()
	io.write("\nY = ")
	storageY = io.read()
	io.write("\nZ = ")
	storageZ = io.read()
	io.write("\n")
	io.write("Please Enter the turtles facing direction (N S E W): ")
	facing = io.read()
	io.write("\n")
end

--Collect Turtle After Mining Trip
function pickupTurtle()
	
	turtle.dig()
end

---------------------------------------------
-- Start By openning rednet ports
rednet.open("left")

-- Get Storage Location
initalStart()

--Loop and wait for msg
while true do 
	io.write("\nStart Loop\n")
	senderID, message, protocol = rednet.receive()
	io.write("Message: ", message)

	if message == "deployturtle" then
		deployTurtle(x, y, z)
	end

	if message == "complete" then
		pickupTurtle()
	end

end 