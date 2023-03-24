------------------------------------------------
--				Global Variables			  --

breakNumber = 0


------------------------------------------------
--					Functions			 	  --

function spin()
	turtle.turnRight()
	turtle.turnRight()
end

function smash()
	turtle.dig()
	breakNumber = breakNumber + 1
end

function place()
	turtle.place()
end

function dump()
	for i = 1, 16, 1  do
		turtle.select(i)
		turtle.drop()
	end
end


------------------------------------------------
--					  Main				 	  --
while true do
	print('Number of times broken: ' .. breakNumber)
	smash()
	spin()
	dump()
	spin()
end