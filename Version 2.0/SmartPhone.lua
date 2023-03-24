------------------------------------------------
--			  Global Variables				  --

height = nil
length1 = nil
length2 = nil


------------------------------------------------
--			  	   Functions				  --

--Main Purpose
function deployTurtle()
	--Send Deploy MSG
	
	rednet.broadcast("deployturtle")
	-- Get y Level
	io.write('Please Enter the Y Level: ')
	height = io.read()

	-- Get Length 1
	io.write('Please Enter Length 1: ')
	length1 = io.read()

	-- get Length 2
	io.write('Please Enter Length 2: ')
	length2 = io.read()

	-- Mining Size 
	-- L1 x L2 x 3
	local totalSize = 3 * length1 * length2
	totalSize = math.abs(totalSize)
	io.write('Total Amount of Blocks to be Mined: ', totalSize)

	--Debug
	--io.write('y = ', y, ' x = ', x,' z = ', z, 'totalSize = ', totalSize)
	

	-- Broadcast 
	rednet.broadcast(length1, "Length1Turtle") -- Length 1
	rednet.broadcast(length2, "Length2Turtle") -- Length 2
	rednet.broadcast(height, "MineHeightTurtle") -- Y
	
end

function loopStarts(loopName)
	if loopName == "b" then
		rednet.broadcast(1, "startBreakLoop")
	end
	
end

--Current Programs
function menu()
	io.write("Current Programs:\n")
	io.write("Deploy -- Send out Mining Turtle\n")
	io.write("Help -- Display Help Menu\n")
end

--Press Y to continue
function anyBtn()
	local input
	repeat
		print("\n\nType y to continue")
		input = read()
	until string.lower(input) == "y"
end


------------------------------------------------
--			  	Main Program				  --

rednet.open("back")

while true do
	term.clear()
	term.setCursorPos(1, 1)
	write("Command: ")
	input = string.upper(read())

	-- Deploy Turtle
	if input == "DEPLOY" then
		deployTurtle()
		anyBtn()
	end

	if input == "HELP" then
		menu()
		anyBtn()
	end

	if input == "BREAK LOOP" then
		loopStarts("b")
		anyBtn()
	end

end