local robot = require("robot")
local component = require("component")

function Forward()--move forward
    if component.navigation.getFacing() ~= 5.0 then
        FaceEast()
    end
    if robot.detect() then--if blocked  move backwards until up is clear
        if robot.detectUp() then
            BackwardLoop()
        end
        Up()
    end
    robot.forward()
    print("forward")
end
function Backward()--move backward
    if component.navigation.getFacing() ~= 5.0 then
        FaceEast()
    end
    if robot.detect() then--if blocked  move backwards until up is clear
        if robot.detectUp() then
            BackwardLoop()
        end
        Up()
    end
    robot.back()
    print("back")
end
function BackwardLoop()--move backward in loop until detect up is false
    robot.back()
    if robot.detectUp() then
        BackwardLoop()
    end
end
function Left()--move left
    if component.navigation.getFacing() ~= 2.0 then
        FaceNorth()
    end
    if robot.detect() then--if blocked  move backwards until up is clear
        if robot.detectUp() then
            BackwardLoop()
        end
        Up()
    end
    robot.forward()
    print("left")
end
function Right()--move right
    if component.navigation.getFacing() ~= 3.0 then
        FaceSouth()
    end
    if robot.detect() then--if blocked  move backwards until up is clear
        if robot.detectUp() then
            BackwardLoop()
        end
        Up()
    end
    robot.forward()
    print("right")
end
function Up()--move up
    if robot.detectUp() then--if blocked  move backwards until up is clear
        BackwardLoop()
    end
    robot.up()
    print("up")
end
function Down()-- move down
    if robot.detectDown() then--if blocked  move backwards until down is clear
        BackwardLoop()
        Down()
    end
    robot.down()
    print("down")
end



--must be east facing robot
function move(x,y,z)--the move function
    curX, curY, curZ = component.navigation.getPosition()--get current position
    if curX == x and curY == y and curZ == z then--if current position == home return
        FaceEast()
        return
    elseif curX < x then--curX+1
        Forward()
    elseif curX > x then--curX-1
        Backward()
    elseif curZ < z then--curZ+1
        Right()
    elseif curZ > z then--curZ-1
        Left()
    elseif curY < y then--curY+1
        Up()
    elseif curY > y then--curY-1
        Down()
    end
    return move(x,y,z)--recursive
end

function FaceEast()
    --make robot face east
    if component.navigation.getFacing() == 5.0 then--5.0 = east
        print("facing east")
    elseif component.navigation.getFacing() == 2.0 then--2.0 = north
        robot.turnRight()
    elseif component.navigation.getFacing() == 4.0 then--4.0 = west
        robot.turnAround()
    elseif component.navigation.getFacing() == 3.0 then--3.0 = south
        robot.turnLeft()
    end
end
function FaceWest()
    --make robot face west
    if component.navigation.getFacing() == 5.0 then--5.0 = east
        robot.turnAround()
    elseif component.navigation.getFacing() == 2.0 then--2.0 = north
        robot.turnLeft()
    elseif component.navigation.getFacing() == 4.0 then--4.0 = west
        print("facing west")
    elseif component.navigation.getFacing() == 3.0 then--3.0 = south
        robot.turnRight()
    end
end
function FaceSouth()
    --make robot face south
    if component.navigation.getFacing() == 5.0 then--5.0 = east
        robot.turnRight()
    elseif component.navigation.getFacing() == 2.0 then--2.0 = north
        robot.turnAround()
    elseif component.navigation.getFacing() == 4.0 then--4.0 = west
        robot.turnLeft()
    elseif component.navigation.getFacing() == 3.0 then--3.0 = south
        print("facing south")
    end
end
function FaceNorth()
    --make robot face north
    if component.navigation.getFacing() == 5.0 then--5.0 = east
        robot.turnLeft()
    elseif component.navigation.getFacing() == 2.0 then--2.0 = north
        print("facing north")
    elseif component.navigation.getFacing() == 4.0 then--4.0 = west
        robot.turnRight()
    elseif component.navigation.getFacing() == 3.0 then--3.0 = south
        robot.turnAround()
    end
end

function SuckAndEquiop(NumberOfItems)
    robot.select(1)--start slot
    for i=1,math.ceil((NumberOfItems/64)) do--for if number of crop stick is more than 64
        robot.suckDown(NumberOfItems)--number of Items to take
    end
    component.inventory_controller.equip()--equip 
end

function SuckAndEquiopTwice(NumberOfItems)
    robot.select(1)--start slot
    NumberOfItems = NumberOfItems*2--crop sticks for breeding
    for i=1,math.ceil((NumberOfItems/64)) do--for if number of crop stick is more than 64
        robot.suckDown(NumberOfItems)--number of Items to take *2
    end
    component.inventory_controller.equip()--equip 
end

function Plant(NumberOfPlants)
    for i = 1, NumberOfPlants do--loop to put first Plant
        ChangeTool()
        robot.useDown()--Plant
        robot.forward()--move forward
    end
    robot.turnAround()--turn around
    for i = 1, NumberOfPlants do--loop to return
        robot.forward()--move forward
    end
    robot.turnAround()--turn around to face orginal dirction  
end

function PlantTwice(NumberOfPlants)
    for i = 1, NumberOfPlants do--loop to put first crop 
        ChangeTool()
        robot.useDown()--Plant
        robot.forward()--move forward
    end
    robot.turnAround()--turn around
    for i = 1, NumberOfPlants do--loop to put second crop stick
        ChangeTool()
        robot.forward()--move forward
        robot.useDown()--Plant
    end
    robot.turnAround()--turn around to face farmland dirction  
end

function ChangeTool()--equip next slot
    result1, result2 = robot.durability()
    if result2 == "no tool equipped" then
        robot.select(robot.select()+1)--next slot
        component.inventory_controller.equip()
    end
end

function CropSticks(x,y,z,NumberOfBlocks)
    --NumberOfBlocks = number of farmland blocks to move
    SuckAndEquiopTwice(NumberOfBlocks)
    move(x,y,z)--first farmland postion
    PlantTwice(NumberOfBlocks)
    component.inventory_controller.equip()--to unequip the excess
end

function Break(NumberOfPlants)
    for i = 1, NumberOfPlants do--loop
        robot.swingDown()--break
        robot.forward()--move forward
    end
    robot.turnAround()--turn around
    for i = 1, NumberOfPlants do--loop to return
        robot.forward()--move forward
    end
    robot.turnAround()--turn around to face orginal dirction  
end

function BreakSticks(x,y,z,NumberOfBlocks)
    --NumberOfBlocks = number of farmland blocks to move
    move(x,y,z)--first farmland postion
    Break(NumberOfBlocks)
end

function DumpItems(x,y,z)
    move(x,y,z)--Dump location
    robot.select(1)
    for i = 1, robot.inventorySize() do--loop for all slots
        robot.select(i)--slect slot
        robot.dropDown()--dump
    end
    robot.select(1)
end

function DumpTool(x,y,z)
    move(x,y,z)--Dump location
    robot.select(1)
    component.inventory_controller.equip()--unequip tool
    robot.dropDown()--dump
end

DumpItems(-43.5,5.5,57.5)
DumpTool(-43.5,5.5,57.5)


move(-43.5,5.5,56.5) 
CropSticks(-42.5,5.5,56.5,44)
move(-43.5,5.5,56.5) 

BreakSticks(-42.5,5.5,56.5,12)
BreakSticks(-42.5,5.5,58.5,12)
BreakSticks(-42.5,5.5,60.5,12) 
move(-43.5,5.5,56.5)

move(-43.5,5.5,56.5) 
CropSticks(-42.5,5.5,56.5,44)
move(-43.5,5.5,56.5) 
CropSticks(-42.5,5.5,58.5,12)
move(-43.5,5.5,56.5)
CropSticks(-42.5,5.5,60.5,12) 
move(-43.5,5.5,56.5)