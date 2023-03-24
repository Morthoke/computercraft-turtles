function deployTurtle()
	--Send Deploy MSG
	
	rednet.broadcast("dmt")
	-- Get y Level
	io.write('Please Enter the Y Level: ')
	local y = io.read()

	-- Get Length 1
	io.write('Please Enter Length 1: ')
	local x = io.read()

	-- get Length 2
	io.write('Please Enter Length 2: ')
	local z = io.read()

	-- Get Direction
	io.write('Please Enter Direction to Mine: ')
	local d = io.read()

	-- Mining Size 
	-- L1 x L2 x 3
	local totalSize = 3 * x * z
	totalSize = math.abs(totalSize)
	io.write('Total Amount of Blocks to be Mined: ', totalSize)

	--Debug
	--io.write('y = ', y, ' x = ', x,' z = ', z, 'totalSize = ', totalSize)
	

	-- Broadcast 
	os.sleep(10)
	rednet.broadcast(tostring(x), "Length1Turtle") -- Length 1
	rednet.broadcast(tostring(z), "Length2Turtle") -- Length 2
	rednet.broadcast(tostring(y), "MineHeightTurtle") -- Y
	rednet.broadcast(tostring(d), "MiningDirection")
	
end

function menu()
	io.write("Current Programs:\n")
	io.write("Deploy -- Send out Mining Turtle\n")
	io.write("Help -- Display Help Menu\n")

	io.write("\n\nCurrently used Ports:\n")
	io.write("Blackberry to Master -- 1001\n")
	io.write("Turtles -- 1002\n")
end


function anyCont()
	local input
	repeat
	print("\n\n\n\n\nType y to continue")
	input = read()
	until string.lower(input) == "y"
end

--------------------------------------------------------------------------------------------
rednet.open("back")


while true do
	term.clear()
	term.setCursorPos(1, 1)
	write("Command: ")
	input = string.upper(read())

	-- Deploy Turtle
	if input == "DEPLOY" then
		deployTurtle()
		anyCont()
	end

	if input == "HELP" then
		menu()
		anyCont()
	end

end