function love.load()
  balls = { createBallWithSpeed(), createBallWithSpeed() }

  meta = {}
  meta.scoreRight = 0
  meta.scoreLeft = 0
  meta.winScore = 5
  meta.initialPaddleHeight = 100
  meta.goalHeightPenalty = 10
  meta.hitHeightBonus = 5

  paddleLeft = {}
  paddleLeft.x = 0
  paddleLeft.y = 250
  paddleLeft.width = 20
  paddleLeft.height = meta.initialPaddleHeight

  paddleRight = {}
  paddleRight.x = 780
  paddleRight.y = 250
  paddleRight.width = 20
  paddleRight.height = meta.initialPaddleHeight
end

function love.update(dt)
  for i, ball in pairs(balls) do
    if (ball.x - ball.radius <= 0) then
      resetBallWithSpeed(ball)
      meta.scoreRight = meta.scoreRight + 1
      paddleLeft.height = paddleLeft.height - meta.goalHeightPenalty
    end

    if (ball.x + ball.radius >= love.graphics.getWidth()) then
      resetBallWithSpeed(ball)
      meta.scoreLeft = meta.scoreLeft + 1
      paddleRight.height = paddleRight.height - meta.goalHeightPenalty
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

    if (checkCollision(ball, paddleRight)) then
      ball.xSpeed = ball.xSpeed * -1.1
      paddleRight.height = paddleRight.height + meta.hitHeightBonus
    end
    if (checkCollision(ball, paddleLeft)) then
      ball.xSpeed = ball.xSpeed * -1.1
      paddleLeft.height = paddleLeft.height + meta.hitHeightBonus
    end

    ball.x = ball.x + ball.xSpeed*dt
    ball.y = ball.y + ball.ySpeed*dt
  end

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
  for i, ball in pairs(balls) do
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius, 20)
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", paddleLeft.x, paddleLeft.y, paddleLeft.width, paddleLeft.height)

  love.graphics.rectangle("fill", paddleRight.x, paddleRight.y, paddleRight.width, paddleRight.height)

  love.graphics.print(meta.scoreRight, 760, 10)
  love.graphics.print(meta.scoreLeft, 40, 10)

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
      for i, ball in pairs(balls) do
        resetBallWithSpeed(ball)
      end
    end
  end
end

function resetGame(meta)
  meta.winner = nil
  meta.scoreLeft = 0
  meta.scoreRight = 0

  paddleLeft.height = meta.initialPaddleHeight
  paddleRight.height = meta.initialPaddleHeight
end

function checkCollision(ball, paddle)
  verticalCollision = ((ball.y - ball.radius) > paddle.y and (ball.y - ball.radius) < paddle.y + paddle.height) or
                        ((ball.y + ball.radius) > paddle.y and (ball.y - ball.radius) < paddle.y + paddle.height)
  horizontalCollision = ((ball.x - ball.radius) > paddle.x and (ball.x - ball.radius) < paddle.x + paddle.width) or
                        ((ball.x + ball.radius) > paddle.x and (ball.x - ball.radius) < paddle.x + paddle.width)
  return verticalCollision and horizontalCollision
end

function resetBallWithSpeed(ball)
  ball.x = 375 + love.math.random(50)
  ball.y = 275 + love.math.random(50)

  if love.math.random(10)%2 == 0 then
    ball.xSpeed = 90
  else
    ball.xSpeed = -90
  end

  if love.math.random(10)%2 == 0 then
    ball.ySpeed = 90
  else
    ball.ySpeed = -90
  end
end

function resetBallWithoutSpeed(ball)
  ball.x = 400
  ball.y = 300
  ball.xSpeed = 0
  ball.ySpeed = 0
end

function createBallWithSpeed()
  ball  = {}
  ball.x = 400
  ball.y = 300
  ball.radius = 20
  resetBallWithSpeed(ball)
  return ball
end
