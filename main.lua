push = require'push'

Class = require'Class'

require 'Paddle'
 
require 'Ball'

WINDOW_HEIGHT =  640
WINDOW_WIDTH = 1280

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
AI_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())
 
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 16)
    largeFont = love.graphics.newFont('font.ttf', 12)

    sounds = {
      ['paddle_hit']= love.audio.newSource('sounds/paddle_hit.wav','static'),
      ['score']= love.audio.newSource('sounds/score.wav', 'static'),
      ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    love.graphics.setFont(smallFont)
    
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH, WINDOW_HEIGHT,{
    fullscreen = false, 
    resizable = true, 
    vsync = true
   }) 
  
   love.window.setTitle('PongAI')

   player1Score = 0
   player2Score = 0
   
   servingPlayer = 1

   winningPlayer = 0
   player1 = Paddle(10, 30, 5,20)
   player2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT-30, 5, 20)

   middlePaddleUpper = Paddle(VIRTUAL_WIDTH/2, 30,2,50)
   middlePaddleLower =Paddle(VIRTUAL_WIDTH/2, VIRTUAL_HEIGHT-80, 2, 50)

   ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4)

   gameState = 'start'

end

function love.resize(w, h)
push:resize(w, h)
end

function love.update(dt)
if gameState == 'serve' then

ball.dy = math.random(-50, 50)

   if servingPlayer == 1 then 
      ball.dx = math.random(140, 200)
    
   else
         ball.dx = -math.random(140, 200)
   end
end

if gameState == 'play' then

   if ball:collides(player1) then 
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5
   
      if ball.dy < 0 then 
         ball.dy = -math.random(10,150)
      else
         ball.dy = math.random(10, 150)
      end 

      sounds['paddle_hit']:play()

   end

   if ball:collides(player2) then 
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x -4
   
      if ball.dy < 0 then 
         ball.dy = -math.random(10,150)
      else
         ball.dy = math.random(10, 150)
      end 

      sounds['paddle_hit']:play()

   end
   if ball:collides(middlePaddleUpper) then 
     
      if ball.x + ball.width > middlePaddleUpper.x then 
         ball.dx = -ball.dx * 1.01 
  
      end
    
   
   

      if ball.dy < 0 then 
         ball.dy = -math.random(10,150)
      else
         ball.dy = math.random(10, 150)
      end 

      sounds['paddle_hit']:play()

   end
   if ball:collides(middlePaddleLower) then 
   
      if ball.x + ball.width > middlePaddleLower.x then 
         ball.dx = -ball.dx * 1.01 

      end

      if ball.dy < 0 then 
         ball.dy = -math.random(10,150)
      else
         ball.dy = math.random(10, 150)
      end 

      sounds['paddle_hit']:play()

   end

   if ball.y <= 0 then 
     ball.y = 0
     ball.dy = -ball.dy

      sounds['wall_hit']:play()

   end

   if ball.y >= VIRTUAL_HEIGHT - 4 then 
      ball.y = VIRTUAL_HEIGHT - 4 
      ball.dy = -ball.dy

      sounds['wall_hit']:play()

   end

   if ball.x < 0 then 
      servingPlayer = 1
      player2Score = player2Score + 1

       sounds['score']:play()

      if player2Score == 10 then 
         winningPlayer = 2
         gameState = 'done'
      else
         gameState = 'serve'
         ball:reset()
      end
   
   end
   if ball.x > VIRTUAL_WIDTH then 
      servingPlayer = 2
      player1Score = player1Score + 1

       sounds['score']:play()

      if player1Score == 10 then 
         winningPlayer = 1
         gameState = 'done'
      else
         gameState = 'serve'
         ball:reset()
      end

   end

end

   if love.keyboard.isDown('w') then 
    player1.dy = -PADDLE_SPEED
   elseif love.keyboard.isDown('s') then 
    player1.dy = PADDLE_SPEED
   else
      player1.dy = 0
   end
   
   if gameState == 'play' then  
      -- player 2 = AI controlled paddle
      -- due to some reason it is beatable 
  if ball.x >= VIRTUAL_WIDTH/2 then
      if ball.y + ball.height <= player2.y then 
          player2.dy = -PADDLE_SPEED
      elseif ball.y >= player2.y + player2.height then
          player2.dy = PADDLE_SPEED
      else
          player2.dy = 0
      end
  else
        player2.y = VIRTUAL_HEIGHT/2 
  
  
  end
  
    end

   

   if gameState == 'play' then 
    ball:update(dt)
   end

   player1:update(dt)
   player2:update(dt)

end

function love.keypressed(key)
   if key == 'escape' then 
      love.event.quit()
   elseif key == 'enter' or key == 'return' then
      
       if gameState == 'start' then 
         gameState = 'serve'
       elseif gameState == 'serve' then
         gameState = 'play' 
    
       elseif gameState == 'done' then
        
           gameState = 'serve'
           ball:reset()

           player1Score = 0 
           Player2Score = 0
      
           if winningPlayer == 1 then 
              servingPlayer = 2
           else
              servingPlayer = 1          
           end
       end
    end
end



function love.draw()
    push:apply('start')

    love.graphics.setColor(40,45,52,255)

    love.graphics.setFont(smallFont)

     displayScore()

     if gameState == 'start' then 
      love.graphics.setFont(smallFont)
     love.graphics.printf('Welcome To Pong!',0,10,VIRTUAL_WIDTH, 'center')
     love.graphics.printf('Press Enter To Begin!',0,20, VIRTUAL_WIDTH, 'center')

     elseif gameState == 'serve' then
      love.graphics.setFont(smallFont)
      love.graphics.printf('player ' .. tostring(servingPlayer) .. "'s serve!",0,10,VIRTUAL_WIDTH,'center')
      love.graphics.printf('press Enter to serve!',0, 20, VIRTUAL_WIDTH, 'center')
     elseif gameState == 'play' then 

     elseif gameState == 'done' then 
      player1Score = 0
      player2Score = 0
      love.graphics.setFont(largeFont)
      love.graphics.printf('player ' .. tostring(winningPlayer) .. ' wins!',
           0, 10, VIRTUAL_WIDTH, 'center')

      love.graphics.setFont(smallFont)
      love.graphics.printf('Press Enter To Restart!', 0, 30, VIRTUAL_WIDTH, 'center')

     end
     love.graphics.setColor(100,100,100)
     player1:render()
     player2:render()
     middlePaddleUpper:render()
     middlePaddleLower:render()

     ball:render()

     push:apply('end')

     displayFPS()
   end

function displayFPS()

love.graphics.setFont(smallFont)

love.graphics.setColor(0,255,0,255)
love.graphics.print('FPS : ' .. tostring(love.timer.getFPS()),10,10)

end

function displayScore()
   love.graphics.setFont(scoreFont)
love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)
end