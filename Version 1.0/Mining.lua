------------------------------------------------
--				Global Variables			  --

orientation = 3
storageX = 0
storageY = 0
storageZ = 0
length1 = nil
length2 = nil
height = 43
startX = 378
startY = 43
startZ = -825
currentX = 378
currentY = 43
currentZ = -825


-- Lookup Tables
-- 				   0        1       2        3 
orientations = {"north", "east", "south", "west"}
zDiff = {-1, 0, 1, 0}
xDiff = {0, 1, 0, -1}


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




-- Move to this point
function goTo(targetX, targetY, targetZ)
	

	print('Going to X = ' .. targetX)
	-- Negative X Direction
	if targetX < currentX then
		look("west")
		while targetX < currentX do
			moveForward()
		end
	end

	-- Positive X Direction
	if targetX > currentX then
		look("east")
		while targetX > currentX do
			moveForward()
		end
	end

	print('Going to Z = ' .. targetZ)
	-- Positive Z Direction
	if targetZ > currentZ then
		look("south")
		while targetZ > currentZ do
			moveForward()
		end
	end
	-- Negative Z Direction
	if targetZ < currentZ then
		look("north")
		while targetZ < currentZ do
			moveForward()
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

-- Track GPS and move Forward
function moveForward()
	--Set Coords
	currentX = currentX + xDiff[orientation]
	currentZ = currentZ + zDiff[orientation]
	
	-- Move
	local moved = false
	while not(moved) do moved = turtle.forward() end
end

-- Look in compass direction
function look(direction)
	while direction ~= orientations[orientation] do
		turnRight()
	end
end

goTo(383, 68, -830)