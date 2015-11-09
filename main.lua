--[[ Project: Code Name Dolphin
-- Date: January 28, 2013
-- Version: 1.6
-- File name: main.lua
-- Author: Carlos Paulino & Edward Paulino
-- File dependencies: none
-- Target devices: iOS, Android
-- Limitations:
-- Copyright (C) 2013. All Rights Reserved.
---------------------------------------------------------------------------------------]]--
local widget = require( "widget" )
require("mobdebug").start()
-------------------------
-- Settings
-------------------------

display.setStatusBar(display.HiddenStatusBar)

local halfW, halfH = (display.contentWidth / 2),(display.contentHeight/2)

local gameRunningTime = 0
local appRunningTime = 0
local enemySpeed = 0;
local scoreBoardValue = 0
local orbValue = 250
local gameTimeScoreMultiplier = 100;
local gameStarted = false
local isDebug = false

local factorH = 1;
if ( display.pixelHeight / display.pixelWidth > 1.72 ) then
		factorH = 540 / 640
end

-------------------------
-- Physics Setup
-------------------------

local physics = require("physics")
physics.start()
physics.setDrawMode( "normal" ) 
physics.setGravity( 0, 0 )

-------------------------
-- Sprite Sheet Loading
-------------------------
local options =
{
    -- array of tables representing each frame (required)
    frames =
    {
        -- FRAME 1: Mountain
        {
            x = 0, y = 0, width = 350, height = 350
        },
        
        -- FRAME 2: Mountain
        {
            x = 350, y = 0, width = 350, height = 350
        },		
       
        -- FRAME 3: Mountain
        {
            x = 700, y = 0, width = 350, height = 350
        },	
		
        -- FRAME 4: Mountain
        {
            x = 1050, y = 0, width = 350, height = 350
        },			
		
        -- FRAME 5: Mountain
        {
            x = 1400, y = 0, width = 350, height = 350
        },	
		
        -- FRAME 6: Cloud
        {
            x = 1750, y = 0, width = 175, height = 175
        },			

        -- FRAME 7: Cloud
        {
            x = 1925, y = 0, width = 175, height = 175
        },	

        -- FRAME 8: Cloud
        {
            x = 1750, y = 175, width = 175, height = 175
        },	

        -- FRAME 9: Cloud
        {
            x = 1925, y = 175, width = 174, height = 175
        },	

        -- FRAME 10: Buoy
        {
            x = 2100, y = 145, width = 130, height = 207
        },	

        -- FRAME 11: Net
        {
            x = 2230, y = 90, width = 120, height = 270
        },	

        -- FRAME 12: Crate
        {
            x = 2361, y = 266, width = 88, height = 84
        },	

        -- FRAME 13: mountain small
        {
            x = 0, y = 352, width = 200, height = 198
        },	

        -- FRAME 14: mountain small
        {
            x = 200, y = 352, width = 200, height = 198
        },	

        -- FRAME 15: mountain small
        {
            x = 400, y = 352, width = 200, height = 198
        },	

        -- FRAME 16: mountain small
        {
            x = 600, y = 352, width = 200, height = 198
        },	

        -- FRAME 17: mountain small
        {
            x = 800, y = 352, width = 200, height = 198
        },	
        -- FRAME 18: Floor
        {
            x = 1050, y = 351, width = 912, height = 132
        },	
		-- FRAME 19: Orb 1
        {
            x = 2300, y = 0, width = 50, height = 50
        },	

		-- FRAME 20: Orb 2
        {
            x = 2350, y = 0, width = 50, height = 50
        },	

        -- FRAME 21: Orb 3
        {
            x = 2400, y = 0, width = 50, height = 50
        },	

        -- FRAME 22: Dolphin Large 1
        {
            x = 0, y = 551, width = 256, height = 190
        },	

        -- FRAME 23: Dolphin Large 2
        {
            x = 256, y = 551, width = 256, height = 190
        },	

        -- FRAME 24: Dolphin Large 3
        {
            x = 512, y = 551, width = 256, height = 190
        },	

        -- FRAME 25: Dolphin Large 4
        {
            x = 768, y = 551, width = 256, height = 190
        },	

        -- FRAME 26: Dolphin Large 5
        {
            x = 1024, y = 551, width = 256, height = 190
        },	

        -- FRAME 27: Dolphin Eye 1
        {
            x = 1280, y = 550, width = 256, height = 190
        },	

        -- FRAME 28: Dolphin Eye 2
        {
            x = 1536, y = 550, width = 256, height = 190
        },	

        -- FRAME 29: Dolphin Eye 3
        {
            x = 1792, y = 550, width = 256, height = 190
        },	

    },
 
    -- optional params; used for dynamic resolution support
    sheetContentWidth = 2450,
    sheetContentHeight = 900
}
 
local imageSheet = graphics.newImageSheet( "sprite_sheet_master.png", options )
local dolphinImageSheet = graphics.newImageSheet( "sprite_sheet_128.png", {	width = 128, height = 128, numFrames = 24, sheetContentWidth = 1024, sheetContentHeight = 384 } )

-------------------------
-- Backgrounds
-------------------------

--Gradient Water

mainbgtop = display.newRect( display.viewableContentWidth/2, display.viewableContentHeight / 4, display.viewableContentWidth, display.contentHeight /2) 
mainbgtop.fill = {149/255 , 210/255, 244/255}

mainbgbottom = display.newRect( display.viewableContentWidth/2, display.viewableContentHeight/1.333, display.viewableContentWidth,  display.viewableContentHeight/2) 
mainbgbottom.fill = {0/255 , 95/255, 178/255}

-------------------------
-- Bottom Background
-------------------------

background_floor1 = display.newImage(imageSheet, 18) background_floor1.x, background_floor1.y = 0, (display.contentHeight - (background_floor1.height/2 - 20))
background_floor2 = display.newImage(imageSheet, 18) background_floor2.x, background_floor2.y = 911, (display.contentHeight - (background_floor1.height/2 - 20))
background_floor3 = display.newImage(imageSheet, 18) background_floor3.x, background_floor3.y = 1822, (display.contentHeight - (background_floor1.height/2 - 20))

function updateBottomBackgrounds() --Floor scrolls past the screen
	background_floor1.x = background_floor1.x - (8)
	background_floor2.x = background_floor2.x - (8)
	background_floor3.x = background_floor3.x - (8)
	
	if(background_floor1.x < -1190) then
		background_floor1.x = 1539
	end
	if(background_floor2.x < -1190) then
		background_floor2.x = 1539
	end
	if(background_floor3.x < -1190) then
		background_floor3.x = 1539
	end
end

-------------------------
-- Top Background
-------------------------

--Big Mountains
for i = 0, 10 do
	local mountain = display.newImage(imageSheet, math.random(1, 5))
	mountain.y = halfH - ((mountain.height) / 2)
	mountain:setFillColor(84/255,60/255 ,22/255)
	mountain.x = i * 150
	mountain.alpha = .95
end

-------------------------
--Clouds
-------------------------

cloudSet = {}
for i = 0, 20 do
	local clouds = display.newImage(imageSheet, math.random(6,9)) 
	clouds.y = display.contentHeight/6 - math.random(0,135)
	clouds.x = (i * 280) + math.random(0,80)
	cloudSet[i + 1] = clouds
end

function updateClouds()
	for i = 1, 20 do
		cloudSet[i].x = cloudSet[i].x - .70
		if cloudSet[i].x < (0 - cloudSet[i].width) then
			cloudSet[i].x = 20 * 250
		end
	end
end

--Small, moving mountains
local mountains_front = {}
for i = 0, 50 do
	local mountain = display.newImage(imageSheet, math.random(13, 17))
	mountain.y = halfH - ((mountain.height) / 2)
	mountain:setFillColor  (222/255  ,159/255 ,58/255)
	mountain.x = (i * 100)
	mountains_front[i + 1] = mountain
	-- math.randomseed( i * 321 )
end

function updateTopBackgrounds()
	for i = 1, table.maxn(mountains_front) do
		mountains_front[i].x = mountains_front[i].x  - .5		
		
		if mountains_front[i].x < (0 - mountains_front[i].width) then
			mountains_front[i].x = 46 * 100
		end		
	end		
end

-------------------------
-- Dolphin Information
-------------------------

local dolphin_eyes = display.newSprite( dolphinImageSheet, { name="blink", start=17, count=4, time = 1500 } )
local dolphin_body = display.newSprite( dolphinImageSheet, { name="swim", start=1, count=8,  time=700 } )
local dolphin = display.newGroup()
dolphin:insert( dolphin_body )
dolphin:insert( dolphin_eyes )
dolphin.x = display.contentWidth / 12
dolphin:scale(factorH, factorH)
dolphin.y = halfH
dolphin_body:play("swim")
dolphin.alpha = 0
dolphin.myName = "dolphin"

dolphinSolid = function() 
	dolphin.alpha=1
end
dolphin_eyes:play()
local dolphin_y = dolphin.y

-------------------------
-- Dolphin Actions
-------------------------

physics.addBody(dolphin, "dynamic", { density = 1.0, friction = 0, bounce = 0, radius = 15 })

-- Jumping Reset
-------------------------

local jumpReset = function()
    transition.to (dolphin, { time=130, y=halfH, rotation=0, transition=linear} )
	return true
end

-- Jumping
-------------------------

dolphinState = nil

local jump4 = function()
	transition.to (dolphin, {time=100, y=display.contentHeight/2.2, rotation=35, transition=linear, onComplete=jumpReset } )
	return true
end

local jump3 = function()
	transition.to (dolphin, {time=130, y=display.contentHeight/2.8, rotation=25, transition=linear, onComplete=jump4 } )
	return true
end

local jump2 = function()
	transition.to (dolphin, {time=120, y=display.contentHeight/3.2, rotation=-18, transition=linear, onComplete=jump3 } )
	return true
end

local jump1 = function()
	transition.to (dolphin, { time=190, y=display.contentHeight/2.8, rotation=-40, transition=linear,  onComplete=jump2 } )  
	return true
end

-- Diving
-------------------------
local dive4 = function()
    transition.to (dolphin, {time=175, y=display.contentHeight/1.86, rotation=-40, transition=linear, onComplete=jumpReset } )
	return true
end

local dive3 = function()
	transition.to (dolphin, { time=90, y=display.contentHeight/1.49, transition=linear, rotation=-10, onComplete=dive4 } )
	return true
end

local dive2 = function()
	transition.to (dolphin, { time=135, y=display.contentHeight/1.55, transition=linear, rotation=15, onComplete=dive3 } )
	return true
end

local dive1 = function()
   transition.to (dolphin, { time=120, y=display.contentHeight/1.78, transition=linear, rotation=35, onComplete=dive2 } )  
   return true
end

-------------------------
-- Action Buttons
-------------------------

local buttontop = display.newRect( display.contentWidth / 2, display.contentHeight /4, display.contentWidth, halfH) 
buttontop.fill = {0,0,0,.01}

local buttonbottom = display.newRect( display.contentWidth / 2, display.contentHeight /1.333 , display.contentWidth, display.contentHeight / 2 ) 
buttonbottom.fill = {0,0,0,.01}

local function buttontopAction( event )
	if dolphin.y  == (halfH) then
		jump1()
	end
	return true
end 

local function buttonbottomAction( event )
	if dolphin.y  == (halfH) then
		dive1() 
	end
	return true
end 

buttontop:addEventListener( "touch", buttontopAction )
buttonbottom:addEventListener( "touch", buttonbottomAction )

-------------------------
-- Enemies and Bonus Information
-------------------------

local removeEnemy = function (enemy) 
	enemy:removeSelf()
end

local function orbCollision( orb, event )
	orb:removeSelf()
	scoreBoardValue = scoreBoardValue + orbValue;
end

local orb_animation = { name="flash", start=19, count=3,  time=500, loopDirection = "bounce" }
local allEnemies = {}
local allEnemiesCount = 0
local generateEnemy = function()

	if( gameStarted == true ) then 
		local r = math.random(1,3);
		
		local enemy = {}
		local orb = {}
		-- 1 : Buoy
		-- 2 : Net 
		-- 3 : Crate

		if ( r == 1 ) then 
			enemy = display.newImage(imageSheet, 10)
			enemy.y = (display.contentHeight / 2.75)
		elseif ( r == 2 ) then
			enemy = display.newImage(imageSheet, 11) 
			enemy.y = (display.contentHeight / 1.5)
		elseif ( r == 3 ) then
			enemy = display.newImage(imageSheet, 12) 
			enemy.y = display.contentHeight/2
			
			local orb_probability = math.random(100)

			if((orb_probability % 5) == 0) then		
				local orb_position = math.random(2);
				-------------------------
				--Orb
				-------------------------
				
				orb = display.newSprite(imageSheet, orb_animation)
				
				if(orb_position == 2) then
					orb.y = display.contentHeight / 2 + 100
				else 
					orb.y = display.contentHeight /2 - 100
				end
				
				
				orb.x = enemy.x
				orb:play("flash")
				orb.myName = "orb"
			end
			
		end
		
		enemy:scale(factorH,factorH)
		
		-- We position the enemies at the end of the screen
		enemy.x = display.contentWidth + enemy.x
		
		
		if next(orb) ~= nil then
			orb.x = enemy.x
			physics.addBody(orb, "kinematic", { density = 0, friction = 0, bounce = 0 ,isSensor = true})
			orb:setLinearVelocity( enemySpeed * -1, 0 )
			orb.collision  = orbCollision
			orb:addEventListener("collision", orb )
		end
		
		-- Its going to take 1500 seconds for the enemy to reach the beginning of the screen
		--transition.to (enemy, { time=1, x = (-1 * enemy.width) , rotation=0, transition=linear,  onComplete=removeEnemy } )
		
		allEnemiesCount = allEnemiesCount + 1
		table.insert(allEnemies, enemy)
		
		physics.addBody(enemy, "kinematic", { density = 1.0, friction = 0, bounce = 0, isSensor = true })
		
		enemy:setLinearVelocity( enemySpeed * -1, 0 )
		enemy.myName = "enemy"
	end
end

---------------------------
-- Menu Screen
---------------------------

gradient_menu = display.newRect( display.contentWidth/2, display.contentHeight/2 , display.contentWidth, display.contentHeight )
gradient_menu.fill = {1, 0.5, 0}

title_name = display.newImage( "title.png")
title_name.x, title_name.y = display.contentWidth/2,  ((display.contentHeight/5.5) + 20)
title_name:scale( .65, .65)

---------------------------
-- Big Dolphin
---------------------------

local reset_menu_dolphin = function()
	transition.to(big_dolphin, {time=2000, y=halfH, x=halfW})
end

local sequenceData = 
{
	{name = "dolphin_big_swim", frames = {22, 23, 24, 23, 22, 25, 26, 25 }, time=1200, loopCount=0},
	{name = "dolphin_big_blink", frames = {27, 28, 29}, time=300, loopCount=0}
}
	
local big_swim = display.newSprite( imageSheet, {name = "dolphin_big_swim", frames = {22, 23, 24, 23, 22, 25, 26, 25 }, time=1200, loopCount=0} )
local big_eyes = display.newSprite( imageSheet, {name = "dolphin_big_blink", frames = {27, 28, 29}, time=300, loopCount=1, loopDirection="bounce"} )
--big_dolphin = display.newImageGroup( imageSheet )
big_dolphin = display.newGroup()
big_dolphin:insert(big_swim)
big_dolphin:insert(big_eyes)
big_dolphin.x = halfW
big_dolphin.y = halfH + 75
big_swim:play()
big_eyes:play()

local gameStartTime = 0
local appStartTime = os.time()


function gameTime()
		if gameStartTime ~= 0 then
        	gameRunningTime = os.difftime( os.time(), gameStartTime) 
			
			if isDebug == true then 
				print("gameRunningTime:  "..gameRunningTime)
			end
		end
		appRunningTime = os.difftime( os.time(), appStartTime) 
		
		if isDebug == true then
			print("appRunningTime:  "..appRunningTime)
		end
end

local speedCap = 1200

local speedModifier = function()
	if enemySpeed < speedCap then
		enemySpeed = 650 + (gameRunningTime * 4)
	end
	
	if isDebug == true then
		print("speed is "..enemySpeed)
	end
end

local menu_dolphin = function()
	updown = math.random(1,4)
		if updown == 1 then
			transition.to (big_dolphin, { time=2000, y=(big_dolphin.y + math.random(50,100)), x=(big_dolphin.x + math.random(70,200)), onComplete=reset_menu_dolphin})
		end
		if updown == 2 then
			transition.to (big_dolphin, { time=2000, y=(big_dolphin.y - math.random(50,100)), x=(big_dolphin.x - math.random(70,200)), onComplete=reset_menu_dolphin})
		end
		if updown == 3 then
			transition.to (big_dolphin, { time=2000, y=(big_dolphin.y + math.random(50,100)), x=(big_dolphin.x - math.random(70,200)), onComplete=reset_menu_dolphin})
		end
		if updown == 4 then
			transition.to (big_dolphin, { time=2000, y=(big_dolphin.y - math.random(50,100)), x=(big_dolphin.x + math.random(70,200)), onComplete=reset_menu_dolphin})
		end
end

startEnemies = function()	
	gameStarted = true
	timer.performWithDelay(1000 , generateEnemy, 0) 
	if isDebug == true then
		print("called generate enemy")
	end
end

local removeBig = function(big_dolphin)   
	big_dolphin:removeSelf()
end

--Start Button
local startButton = widget.newButton
{
   	left = 0,
   	top = 0,
   	label = "Start",
   	labelAlign = "center",
   	font = "Arial",
   	fontSize = 30,
   	labelColor = { default = {0,0,0}, over = {0,0,0} },
   	fillColor = { default={ 1, 1, 1, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
   	strokeColor = { default={ 173, 173, 175, 1 }, over={ 0.8, 0.8, 1, 1 } },
    shape="roundedRect",
	strokeWidth = 4
}

local function onButtonEvent( event )
	local phase = event.phase
	local target = event.target
	if ( "began" == phase ) then
		transition.to(big_dolphin, {time=1000, x=dolphin.x, y=halfH, xScale=(.5*factorH), yScale=(.5*factorH), transition=easing.outExpo, onComplete=startEnemies})
		transition.to(big_dolphin, {time=1000, onComplete=removeBig})
		transition.to(gradient_menu, {time=1000, alpha=0})
		transition.to(title_name, {time=900, alpha=0})		
		start_button_remove()
		transition.to(big_dolphin, {time=1000, onComplete = dolphinSolid})
		transition.to(big_dolphin, {time=1000})
		gameStartTime = os.time()

		if isDebug == true then
			print("clicked start button")		
			print( target.id .. "Start" )
		end

		target:setLabel( "Start" )  --set a new label
		startButton:removeEventListener("touch", onButtonEvent )
	elseif ( "ended" == phase ) then
		if isDebug == true then
			print( target.id .. " released" )
		end
		target:setLabel( target.baseLabel )  --reset the label
	end
	return true
end

local gameStartTime = 0
local appStartTime = os.time()
		
startButton.baseLabel = "Start"
startButton.x, startButton.y = display.contentWidth/2, display.contentHeight - 50
startButton:addEventListener("touch", onButtonEvent )

start_button_remove = function()
  display.remove( startButton )
end

-------------------------
-- Scoreboard
-------------------------

local scoreBoard = display.newText("", 50 , display.contentHeight - 30 - 10, nil, 30)
scoreBoard.anchorX = 0
function updateScoreBoard()
	if (gameStarted == true ) then
		scoreBoardValue = scoreBoardValue + 100
		scoreBoard.text = tostring(scoreBoardValue)
		scoreBoard.x = 50
	end
end

-------------------------
-- Collision Detection
-------------------------

local tryAgainButton = widget.newButton
{
	left = 0,
	top = 0,
	label = "Try Again",
	labelAlign = "center",
	font = "Arial",
	fontSize = 30,
	labelColor = { default = {0,0,0}, over = {0,0,0} },
	fillColor = { default={ 1, 1, 1, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
	strokeColor = { default={ 173, 173, 175, 1 }, over={ 0.8, 0.8, 1, 1 } },
	shape="roundedRect",
	strokeWidth = 4
}
tryAgainButton.x, tryAgainButton.y = display.contentWidth/2, display.contentHeight - 50
tryAgainButton.isVisible = false

local function onTryAgain( event )
	local phase = event.phase
	local target = event.target
	
	if ( "ended" == phase ) then
		transition.to(gradient_menu, {time=1000, alpha=0})
		tryAgainButton.isVisible = false
		scoreBoardValue = 0
		gameStarted = true
		allEnemies = {}
		allEnemiesCount = 0		
		enemySpeed = 0
		dolphin.isVisible = true
	end
end

tryAgainButton:addEventListener("touch", onTryAgain )	

local gameover_overlay = nil



local function onLocalCollision( self, event )
	if gameStarted == true then 
		if (event.other.myName == "enemy") then 
      gameStarted = false
			for i = 1, #allEnemies do 
				allEnemies[i]:removeSelf()
			end
			
			if isDebug == true then
				print("Dolphin Died")	
			end
			transition.to(gradient_menu, {time=1000, alpha=100})
			tryAgainButton.isVisible = true
			dolphin.isVisible = false
			enemySpeed = 650
		end
	end
end
 
-------------------------
-- Game Events and Game Timers
-------------------------

dolphin.collision = onLocalCollision
dolphin:addEventListener( "collision", dolphin )

Runtime:addEventListener( "enterFrame", updateClouds )
Runtime:addEventListener( "enterFrame", updateBottomBackgrounds )
Runtime:addEventListener( "enterFrame", updateTopBackgrounds )

-- The faster time, the closer the enemies are going to be

timer.performWithDelay(1000, gameTime, 0)
timer.performWithDelay(1000, speedModifier, 0)
timer.performWithDelay(50, updateScoreBoard, 0)
