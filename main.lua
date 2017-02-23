function love.load()
  ball  = {}
  ball.x = 400
  ball.y = 300
  ball.radius = 20
  resetBallWithSpeed(ball)

  paddleLeft = {}
  paddleLeft.x = 0
  paddleLeft.y = 250
  paddleLeft.width = 20
  paddleLeft.height = 100

  paddleRight = {}
  paddleRight.x = 780
  paddleRight.y = 250
  paddleRight.width = 20
  paddleRight.height = 100

  meta = {}
  meta.scoreRight = 0
  meta.scoreLeft = 0
  meta.winScore = 1

  math.randomseed( os.time() )
end

function love.update(dt)
  meta.dt = dt

  if (ball.x - ball.radius <= 0) then
    resetBallWithSpeed(ball)
    meta.scoreRight = meta.scoreRight + 1
  end

  if (ball.x + ball.radius >= love.graphics.getWidth()) then
    resetBallWithSpeed(ball)
    meta.scoreLeft = meta.scoreLeft + 1
  end

  if (meta.scoreRight >= meta.winScore) then
    meta.winner = 'Player on the right wins!'
    resetBallWithoutSpeed(ball)
  end
  if (meta.scoreLeft >= meta.winScore) then
    meta.winner = 'Player on the left wins!'
    resetBallWithoutSpeed(ball)
  end

  if (ball.y - ball.radius <= 0) then
    ball.ySpeed = ball.ySpeed * -1.1
  end
  if (ball.y + ball.radius >= love.graphics.getHeight()) then
    ball.ySpeed = ball.ySpeed * -1.1
  end
  if (checkCollision(ball, paddleRight) or
      checkCollision(ball, paddleLeft)) then
    ball.xSpeed = ball.xSpeed * -1.1
  end

  ball.x = ball.x + ball.xSpeed*dt
  ball.y = ball.y + ball.ySpeed*dt

  if (love.keyboard.isDown("w")) then
    paddleLeft.y = paddleLeft.y - dt*100
  end

  if (love.keyboard.isDown("s")) then
    paddleLeft.y = paddleLeft.y + dt*100
  end

  if (love.keyboard.isDown("up")) then
    paddleRight.y = paddleRight.y - dt*100
  end

  if (love.keyboard.isDown("down")) then
    paddleRight.y = paddleRight.y + dt*100
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle("fill", ball.x, ball.y, ball.radius, 20)

  if ball.previousX1 and ball.previousY1 then
    love.graphics.setColor(255, 255, 255, 70)
    love.graphics.circle("fill", ball.previousX1, ball.previousY1, ball.radius, 20)
  end
  if ball.previousX2 and ball.previousY2 then
    love.graphics.setColor(255, 255, 255, 40)
    love.graphics.circle("fill", ball.previousX2, ball.previousY2, ball.radius, 20)
  end
  if ball.previousX3 and ball.previousY3 then
    love.graphics.setColor(255, 255, 255, 10)
    love.graphics.circle("fill", ball.previousX3, ball.previousY3, ball.radius, 20)
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", paddleLeft.x, paddleLeft.y, paddleLeft.width, paddleLeft.height)

  love.graphics.rectangle("fill", paddleRight.x, paddleRight.y, paddleRight.width, paddleRight.height)

  love.graphics.print(meta.scoreRight, 760, 10)
  love.graphics.print(meta.scoreLeft, 40, 10)
--  love.graphics.print(meta.dt, 600, 20)
  if (meta.winner) then
    love.graphics.print(meta.winner, 350, 100)
    love.graphics.print('Press esc to quit or enter to restart' , 300, 400)
  end
end

function love.keyreleased(key)
  if key == "escape" then
    love.event.quit()
  end

  if key == "return" then
    if meta.winner then
      resetGame(meta)
      resetBallWithSpeed(ball)
    end
  end
end

function resetGame(meta)
  meta.winner = nil
  meta.scoreLeft = 0
  meta.scoreRight = 0
end

function checkCollision(ball, paddle)
  verticalCollision = ((ball.y - ball.radius) > paddle.y and (ball.y - ball.radius) < paddle.y + paddle.height) or
                        ((ball.y + ball.radius) > paddle.y and (ball.y - ball.radius) < paddle.y + paddle.height)
  horizontalCollision = ((ball.x - ball.radius) > paddle.x and (ball.x - ball.radius) < paddle.x + paddle.width) or
                        ((ball.x + ball.radius) > paddle.x and (ball.x - ball.radius) < paddle.x + paddle.width)
  return verticalCollision and horizontalCollision
end

function resetBallWithSpeed(ball)
  ball.x = 400
  ball.y = 300

  if math.random(10)%2 == 0 then
    ball.xSpeed = 100
  else
    ball.xSpeed = -100
  end

  if math.random(10)%2 == 0 then
    ball.ySpeed = 100
  else
    ball.ySpeed = -100
  end
end

function resetBallWithoutSpeed(ball)
  ball.x = 400
  ball.y = 300
  ball.xSpeed = 0
  ball.ySpeed = 0
end
