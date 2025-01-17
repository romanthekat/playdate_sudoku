-- import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "boardClass"
import "button"
import "checkBoxButtons"

local gfx <const> = playdate.graphics
local menu = playdate.getSystemMenu()

local congratulationsTimer = nil

gfx.setImageDrawMode(gfx.kDrawModeNXOR)
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorXOR)
gfx.clear()

difficutly = {
    [1] = "simple",
    [2] = "easy",
    [3] = "intermediate",
    [4] = "expert"
}
math.randomseed(playdate.getSecondsSinceEpoch())

movespeed = 200
settings = {
  ["Dark Mode"]=false,
  ["Highlight same sumber as selected"] = false,
  ["Indicate where number can't go"] = false
}
function saveSettings()
  playdate.datastore.write(settings, "settings", true)
  useSettings()
end
function setSettings()
  if playdate.datastore.read("settings") ~= nil then
    settings = playdate.datastore.read("settings")
    useSettings()
  else
    saveSettings()
  end
end
function useSettings()
  if settings["Dark Mode"] then
    playdate.display.setInverted(true)
  else
    playdate.display.setInverted(false)
  end
end
setSettings()




function saveGameData(board)
  if board ~=nil then
    playdate.datastore.write(board, "board_table", true) 
  end
end

function removeGameData()
    playdate.datastore.delete("board_table") 
end
function doNothing()
end

-- removeGameData()


function allTrue(t)
    for _, v in pairs(t) do
        if not v then return false end
    end

    return true
end
function allFalse(t)
    for _, v in pairs(t) do
        if v then return false end
    end

    return true
end

function setUpTitleScreen()
    menu:removeAllMenuItems()
    gfx.sprite.removeAll()
    
    if congratulationsTimer ~= nil then
      removeGameData()
      congratulationsTimer:remove()
      congratulationsTimer = nil
    end
    
    local screenWidth= playdate.display.getWidth() 
    local screenHeight = playdate.display.getHeight() 
    local titleLabel = setupLabel("*Sudoku*", true, screenWidth / 2, screenHeight * (1 / 6))
    local continueButton = {}
    local newGameGameButton = {}
    local optionsButton = {}
    local instructionButton = {}
    local titleScreen = {}
    if playdate.datastore.read("board_table") ~= nil then
      continueButton = setupButton("*Continue*", true, true,screenWidth / 2, screenHeight* (3/10), resumeGame)
      newGameGameButton = setupButton("*New Game*", true, false, screenWidth / 2, screenHeight* (5/10), showDifficultyScreen)
      instructionButton = setupButton("*Instruction*", true, false, screenWidth / 2, screenHeight* (7/10), showInstructionScreen)
      settingsButton = setupButton("*Settings*", true, false, screenWidth / 2, screenHeight* (9/10), showSettingsScreen)
      titleScreen = {["title"]=titleLabel,["Buttons"]={continueButton,newGameGameButton,instructionButton,settingsButton}, ["selected"]=continueButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = true,["b"] = true
      }, ["backAction"] = doNothing}
    else
      newGameGameButton = setupButton("*New Game*", true, true, screenWidth / 2, screenHeight* (5/10), showDifficultyScreen)
      instructionButton = setupButton("*Instruction*", true, false, screenWidth / 2, screenHeight* (7/10), showInstructionScreen)
      settingsButton = setupButton("*Settings*", true, false, screenWidth / 2, screenHeight* (9/10), showSettingsScreen)
      titleScreen = {["title"]=titleLabel,["Buttons"]={newGameGameButton,instructionButton,settingsButton}, ["selected"]=newGameGameButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = true,["b"] = true
      }, ["backAction"] = doNothing}
    end
        handleButtonsforbuttons(titleScreen)
    return titleScreen
end

function setUpInstructionScreen()
    menu:removeAllMenuItems()
    gfx.sprite.removeAll()
    local screenWidth= playdate.display.getWidth() 
    local screenHeight = playdate.display.getHeight() 
    local titleLabel = setupLabel("*How to Play*", true, screenWidth / 2, screenHeight * (1/ 7) )
    local label1 = setupLabel("*A/B or crank* - increase/decrase Number", true, screenWidth / 2, screenHeight*(2/7) )
    local label2 = setupLabel("*D-Pad* - Move Selected Cell", true, screenWidth / 2, screenHeight*(3/7) )
    local label3 = setupLabel("*Menu* - Go Home", true, screenWidth / 4, screenHeight*(4/7) )
    local label3 = setupLabel("*A+B* - Notation Mode", true, screenWidth * (3 / 4), screenHeight*(4/7) )
    local label4 = setupLabel("*Game auto saves*", true, screenWidth / 2, screenHeight*(5/7))
    local label5 = setupLabel("Game auto dectects when you win", false, screenWidth / 2, screenHeight*(6/7))
    local label6 = setupLabel("and returns you home", false, screenWidth / 2, screenHeight*(6.5/7))
    local instructionScreen = {["title"]=titleLabel, ["backAction"] = showTitleScreen}
   function titleLabel:update()
     if playdate.buttonJustPressed( playdate.kButtonB ) then
      instructionScreen.backAction()
    end
   end
    return instructionScreen
end


function setUpDifficultyScreen()
    local screenWidth= playdate.display.getWidth() 
    local screenHeight = playdate.display.getHeight() 
    local titleLabel = setupLabel("*Select Difficutly*", true, screenWidth / 2, screenHeight / 8)
    local easyButton = {}
    local normalButton = {}
    local hardButton = {}
    local veryHardButton = {}
    local difficutlyScreen = {}
    -- local testBoard = setUpBoard(1)
    -- saveGameData(testBoard)
    easyButton = setupButton("*Easy*", true, true,screenWidth / 2, screenHeight* (3/10), startNewGame)
    normalButton = setupButton("*Normal*", true, false, screenWidth / 2, screenHeight* (5/10), startNewGame)
    hardButton = setupButton("*Hard*", true, false, screenWidth / 2, screenHeight* (7/10), startNewGame)
    veryHardButton = setupButton("*Very Hard*", true, false, screenWidth / 2, screenHeight* (9/10), startNewGame)
    difficutlyScreen = {["title"]=titleLabel,["Buttons"]={easyButton,normalButton,hardButton, veryHardButton}, ["selected"]=easyButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = false,["b"] = true
    },["difficulty"]=1, ["backAction"] = showTitleScreen}
    handleButtonsforbuttons(difficutlyScreen)
    playdate.timer.new(movespeed,setBoolToTrue, "a", difficutlyScreen)
    return difficutlyScreen
end

function setUpSettingsScreen()
    local screenWidth= playdate.display.getWidth() 
    local screenHeight = playdate.display.getHeight() 
    local titleLabel = setupLabel("*Settings*", true, screenWidth / 2, screenHeight / 8)
    local darkModeButton = {}
    local similarButton = {}
    local wrongButton = {}
    local settingsScreen = {}
    darkModeButton = setupCheckBoxAndLabel("*Dark Mode*", true, true,screenWidth / 2, screenHeight* (3/10), togglePropertyInSettings, "Dark Mode")
    similarButton = setupCheckBoxAndLabel("*Highlight Similar*", true, false, screenWidth / 2, screenHeight* (5/10), togglePropertyInSettings,  "Highlight same sumber as selected")
    wrongButton = setupCheckBoxAndLabel("*Show Blocked Boxs*", true, false, screenWidth / 2, screenHeight* (7/10), togglePropertyInSettings,  "Indicate where number can't go")
    settingsScreen = {["title"]=titleLabel,["Buttons"]={darkModeButton,similarButton,wrongButton}, ["selected"]=darkModeButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = false,["b"] = true
    }, ["backAction"] = showTitleScreen}
    handleButtonsforCheckBoxs(settingsScreen)
    return settingsScreen
end

function togglePropertyInSettings(property)
  settings[property] = not settings[property]
  saveSettings()
end


function setupLabel(text,isBold, x, y,lines)
  lines = lines or 1
    local label = gfx.sprite.new()
    local labelWidth = gfx.getTextSize(text)
    local labelHeight = gfx.getFont(isBold and gfx.font.kVariantBold or gfx.font.kVariantNormal):getHeight() * (lines)
    label:add()
    label:setSize(labelWidth, labelHeight)
    label:moveTo(x, y)
    function label:draw(x, y, width, height)
        gfx.drawText(text, x,y)
    end
    return label
end






function myGameSetUp(board)
    local midpointx, midpointy = playdate.display.getWidth() / 2, playdate.display.getHeight() / 2
    local boardSize = playdate.display.getHeight() *.95
    board:add()
    board:setSize(boardSize,boardSize)
    board:moveTo(midpointx,midpointy)
    timerLabel = gfx.sprite.new()
    timerLabel:add()
    timerLabel:setSize(70, 18)
    timerLabel:moveTo(playdate.display.getWidth()-40,225)
    -- board.boardData.timeInSeconds = 0
    function board:OncePerSecond()
        board.boardData.timeInSeconds = board.boardData.timeInSeconds + 1
        boardTimer = playdate.timer.new(1000,board.OncePerSecond)
        timerLabel:markDirty()
    end
    boardTimer = playdate.timer.new(1000,board.OncePerSecond)
    function timerLabel:draw(x, y, width, height)
      -- gfx.drawRect(x,y,width,height)
      local minute = board.boardData.timeInSeconds//60 > 9 and tostring(board.boardData.timeInSeconds//60) or "0"..tostring(board.boardData.timeInSeconds//60)
      local second = board.boardData.timeInSeconds%60 > 9 and tostring(board.boardData.timeInSeconds%60) or "0"..tostring(board.boardData.timeInSeconds%60)
      gfx.drawTextAligned(minute..":"..second, x + width/2, y + 1, kTextAlignment.center)
    end
    local menuItem, error = menu:addMenuItem("Sudoku Home", function()
      boardTimer:remove()
        saveGameData(board)
        titleScreen = setUpTitleScreen()
    end)
end



function startNewGame(screen)
  gfx.sprite.removeAll()
  local dif = screen.difficulty ~= nil and screen.difficulty or 1
  mainBoard = setUpBoard(dif)
  myGameSetUp(mainBoard)
end
function resumeGame()
  gfx.sprite.removeAll()
  mainBoard = reSetUpBoard(playdate.datastore.read("board_table"))
  myGameSetUp(mainBoard)
end


function setBoolToTrue(bool, data)
    data.buttonCanBePressed[bool] = true
end

function finshedBoard(board)
  saveGameData(board)
  board.completed = true
  gfx.sprite:removeAll()
  board:add()
  timerLabel:add()
  boardTimer:remove()
  local screenWidth= playdate.display.getWidth() 
  local screenHeight = playdate.display.getHeight() 
  local congratulationsLabel = gfx.sprite.new()
  congratulationsLabel:add()
  local text = "*Congradulations*"
  local labelWidth = gfx.getTextSize(text)
  local labelHeight = gfx.getFont(gfx.font.kVariantBold):getHeight()
  timerLabel:moveTo((labelWidth/2) *1.2,200)
  congratulationsLabel:setSize(labelWidth*1.1,labelHeight*4.1)
  congratulationsLabel:moveTo((labelWidth/2) *1.2, screenHeight/2)
  congratulationsLabel.countDown = 11
  board:moveBy(labelWidth/2,0)
  board.boardData.selected = nil
  function board:update()
    
  end
  function congratulationsLabel:draw(x, y, width, height)
    gfx.fillRect(x,y,width,height)
    -- gfx.drawText(text,x+labelWidth*0.05,y+labelHeight*0.05)
    gfx.drawTextAligned("*Congradulations*", x+(labelWidth/2)+(labelWidth*0.05),y+(labelHeight/2)+(labelHeight*0.05), kTextAlignment.center)
    gfx.drawTextAligned("Return Home In:", x+(labelWidth/2)+(labelWidth*0.05),y+(labelHeight/2)+(labelHeight*1.1), kTextAlignment.center)
    gfx.drawTextAligned(self.countDown, x+(labelWidth/2)+(labelWidth*0.05),y+(labelHeight/2)+(labelHeight*2.05), kTextAlignment.center)
  end
  function congratulationsLabel:updateCountDown()
    if congratulationsLabel.countDown >1 then
      congratulationsLabel.countDown = congratulationsLabel.countDown-1
      congratulationsLabel:markDirty()
      congratulationsTimer = playdate.timer.new(1000,congratulationsLabel.updateCountDown)
    else
      setUpTitleScreen()
    end
  end
  congratulationsLabel.updateCountDown()
  -- playdate.timer.new(11000,setUpTitleScreen)
end

function showDifficultyScreen()
  gfx.sprite.removeAll()
  difficutlyScreen = setUpDifficultyScreen()
end
function showSettingsScreen()
  gfx.sprite.removeAll()
  settingsScreen = setUpSettingsScreen()
end
function showInstructionScreen()
  gfx.sprite.removeAll()
  instructionScreen = setUpInstructionScreen()
end
function showTitleScreen()
  gfx.sprite.removeAll()
  titlScreenScreen = setUpTitleScreen()
end

local titleScreen = setUpTitleScreen()

function playdate.update()
    gfx.sprite.update()
    playdate.timer.updateTimers()
end

function playdate.gameWillTerminate()
  saveGameData(mainBoard)
end

function playdate.deviceWillSleep()
  saveGameData(mainBoard)
end
function playdate.deviceWillLock()
  saveGameData(mainBoard)
end
