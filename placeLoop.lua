------------------------------------------------
--				Global Variables			  --

breakNumber = -1


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
	for i = 1, 16, 1  do
		local data = turtle.getItemDetail(i)
		if data then
			local name = tostring(data.name)
			print(name)
			if name == "minecraft:barrel" then
				print("pick me")

				turtle.select(i)
				turtle.place()
			end
		end
	end
end

function dump()
	for i = 1, 16, 1  do
		local data = turtle.getItemDetail(i)
		if data then
			local name = tostring(data.name)
			print(name)
			if name == "minecraft:barrel" then
				
			else
				turtle.select(i)
				turtle.drop()
			end
		end
	end
end




------------------------------------------------
--					  Main				 	  --
while true do
	place()
	spin()
	dump()
	spin()
end