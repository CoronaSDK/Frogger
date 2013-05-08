-- Frogger Inspired Game
-- Developed by Carlos Yanez

-- Hide Status Bar

display.setStatusBar(display.HiddenStatusBar)

-- Physics

local physics = require('physics')
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode('hybrid')

-- Graphics

-- [Background]

local bg = display.newImage('bg.png')

-- [Title View]

local title
local playBtn
local creditsBtn
local titleView

-- [Credits]

local creditsView

-- Game Background

local gameBg

-- Frog

local frog

-- [Pad]

local up
local left
local down
local right

-- Alert

local alertView

-- Sounds

local moveSnd = audio.loadSound('move.mp3')
local loseSnd = audio.loadSound('lose.mp3')
local goalSnd = audio.loadSound('goal.mp3')

-- Variables

local lastY
local obstacles
local counter = 0

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local addObstacle = {}
local movePlayer = {}
local update = {}
local onCollision = {}
local alert = {}

-- Main Function

function Main()
	title = display.newImage('title.png', 64, 130)
	playBtn = display.newImage('playBtn.png', 134, 245)
	creditsBtn = display.newImage('creditsBtn.png', 114, 305)
	titleView = display.newGroup(bg, title, playBtn, creditsBtn)
	
	startButtonListeners('add')
end

function startButtonListeners(action)
	if(action == 'add') then
		playBtn:addEventListener('tap', showGameView)
		creditsBtn:addEventListener('tap', showCredits)
	else
		playBtn:removeEventListener('tap', showGameView)
		creditsBtn:removeEventListener('tap', showCredits)
	end
end

function showCredits:tap(e)
	playBtn.isVisible = false
	creditsBtn.isVisible = false
	creditsView = display.newImage('credits.png', 0, display.contentHeight)
	
	lastY = title.y
	transition.to(title, {time = 300, y = -20})
	transition.to(creditsView, {time = 300, y = 265, onComplete = function() creditsView:addEventListener('tap', hideCredits) end})
end

function hideCredits:tap(e)
	transition.to(creditsView, {time = 300, y = display.contentHeight + 25, onComplete = function() creditsBtn.isVisible = true playBtn.isVisible = true creditsView:removeEventListener('tap', hideCredits) display.remove(creditsView) creditsView = nil end})
	transition.to(title, {time = 300, y = lastY});
end


function showGameView:tap(e)
	transition.to(titleView, {time = 300, x = -titleView.height, onComplete = function() startButtonListeners('rmv') display.remove(titleView) titleView = nil end})
	
	-- [Add GFX]
	
	-- Game Background
	
	gameBg = display.newImage('gameBg.png')
	
	-- Cars Part 1
	
	obstacles = display.newGroup()
	addObstacle(184, 353, 'car2', false, 'l', 'car')
	addObstacle(184, 326, 'car', true, 'r', 'car')
	addObstacle(124, 293, 'car2', false, 'l', 'car')
	
	addObstacle(94, 386, 'car', true, 'r', 'car')
	addObstacle(64, 326, 'car', true, 'r', 'car')
	addObstacle(94, 293, 'car2', false, 'l', 'car')
	
	addObstacle(34, 386, 'car', true, 'r', 'car')
	addObstacle(4, 353, 'car2', false, 'l', 'car')
	addObstacle(4, 293, 'car2', false, 'l', 'car')
	
	addObstacle(274, 386, 'car', true, 'r', 'car')
	addObstacle(234, 353, 'car2', false, 'l', 'car')
	addObstacle(274, 326, 'car', true, 'r', 'car')

	-- Cars Part 2
	
	addObstacle(94, 226, 'car', true, 'r', 'car')
	addObstacle(94, 197, 'car2', false, 'l', 'car')
	addObstacle(94, 167, 'car', true, 'r', 'car')
	addObstacle(94, 137, 'car2', false, 'l', 'car')
	addObstacle(94, 107, 'car', true, 'r', 'car')
	addObstacle(274, 197, 'car2', false, 'l', 'car')
	addObstacle(94, 107, 'car', true, 'r', 'car')
	
	addObstacle(34, 226, 'car', true, 'r', 'car')
	addObstacle(34, 197, 'car2', false, 'l', 'car')
	addObstacle(184, 167, 'car', true, 'r', 'car')
	addObstacle(184, 137, 'car2', false, 'l', 'car')
	addObstacle(4, 107, 'car', true, 'r', 'car')
	addObstacle(274, 197, 'car2', false, 'l', 'car')
	addObstacle(274, 107, 'car', true, 'r', 'car')
	
	-- Pad
	
	up = display.newImage('up.png', 33.5, 369.5)
	left = display.newImage('left.png', 0, 402.5)
	down = display.newImage('down.png', 33.5, 436.5)
	right = display.newImage('right.png', 66.5, 402.5)
	
	up.name = 'up'
	down.name = 'down'
	left.name = 'left'
	right.name = 'right'
	
	-- Frog
	
	frog = display.newImage('frog.png', 148.5, 417.5)
	
	-- Goals
	
	local g1 = display.newRect(68, 70, 15, 15)
	g1.name = 'goal'
	local g2 = display.newRect(153, 70, 15, 15)
	g2.name = 'goal'
	local g3 = display.newRect(238, 70, 15, 15)
	g3.name = 'goal'
	
	-- Physics
	
	physics.addBody(frog)
	frog.isSensor = true
	physics.addBody(g1, 'static')
	g1.isSensor = true
	g1.isVisible = false
	physics.addBody(g2, 'static')
	g2.isSensor = true
	g2.isVisible = false
	physics.addBody(g3, 'static')
	g3.isSensor = true
	g3.isVisible = false
	
	gameListeners('add')
end

function gameListeners(action)
	if(action == 'add') then
		Runtime:addEventListener('enterFrame', update)
		up:addEventListener('tap', movePlayer)
		left:addEventListener('tap', movePlayer)
		down:addEventListener('tap', movePlayer)
		right:addEventListener('tap', movePlayer)
		frog:addEventListener('collision', onCollision)
	else
		Runtime:removeEventListener('enterFrame', update)
		up:removeEventListener('tap', movePlayer)
		left:removeEventListener('tap', movePlayer)
		down:removeEventListener('tap', movePlayer)
		right:removeEventListener('tap', movePlayer)
		frog:removeEventListener('collision', onCollision)
	end
end

function addObstacle(X, Y, graphic, inverted, dir, name)
	local c = display.newImage(graphic .. '.png', X, Y)
	c.dir = dir
	c.name = name
	
	--Rotate graphic if going right
	
	if(inverted) then
		c.xScale = -1
	end
	
	-- Physics
	
	physics.addBody(c, 'static')
	c.isSensor = true
	
	obstacles:insert(c)
end

function movePlayer(e)
	audio.play(moveSnd)
	if(e.target.name == 'up') then
		frog.y = frog.y - 31
	elseif(e.target.name == 'left') then
		frog.x = frog.x - 31
	elseif(e.target.name == 'down') then
		frog.y = frog.y + 31
	elseif(e.target.name == 'right') then
		frog.x = frog.x + 31
	end
end


function update()
	-- Move Obstacles
	
	for i = 1, obstacles.numChildren do
		if(obstacles[i].dir == 'l') then
			obstacles[i].x = obstacles[i].x - 1
		else
			obstacles[i].x = obstacles[i].x + 1
		end
		
		-- Respawn obstacle when out of stage
		--Right
		if(obstacles[i].dir == 'r' and obstacles[i].x > display.contentWidth + (obstacles[i].width * 0.5)) then
			obstacles[i].x = -(obstacles[i].width * 0.5)
		end
		
		-- Respawn obstacle when out of stage
		--Left
		if(obstacles[i].dir == 'l' and obstacles[i].x < -(obstacles[i].width * 0.5)) then
			obstacles[i].x = display.contentWidth + (obstacles[i].width * 0.5)
		end
	end
end

function onCollision(e)
	if(e.other.name == 'car') then
		display.remove(e.target)
		audio.play(loseSnd)
		alert('lose')
	elseif(e.other.name == 'goal') then
		display.remove(e.other)
		local f = display.newImage('frog.png', e.other.x - 12, e.other.y - 18)
		audio.play(goalSnd)
		timer.performWithDelay(10, function() frog.x = 160 frog.y = 426 end, 1)
		counter = counter + 1
	end
	--check if goals complete
	if(counter == 3) then
		alert()
	end
end

function alert(action)
	gameListeners('rmv')
	display.remove(obstacles)
	if(action == 'lose') then
		alertView = display.newImage('lose.png', 127.5, 345)
	else
		alertView = display.newImage('win.png', 132, 345)
	end
	
	transition.from(alertView, {time = 200, alpha = 0.1})
end

Main()