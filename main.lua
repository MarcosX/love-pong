function love.load()
  initialTime = love.timer.getTime()

  meta = {}
  meta.scoreRight = 0
  meta.scoreLeft = 0
  meta.winScore = 5
  meta.initialPaddleSpeed = 200
  meta.goalSpeedPenalty = meta.initialPaddleSpeed*0.1
  meta.initialPaddleHeight = 120
  meta.goalHeightPenalty = meta.initialPaddleHeight*0.05
  meta.hitHeightBonus = meta.initialPaddleHeight*0.1
  meta.maxBalls = 3
  meta.ballCreationDelay = 2
  meta.initalBallSpeed = 90
  meta.ballSpawLocationVariation = 50

  balls = {}
  table.insert(balls, createBallWithSpeed())

  paddleLeft = {}
  paddleLeft.x = 0
  paddleLeft.y = 250
  paddleLeft.width = 20
  paddleLeft.ySpeed = 100
  paddleLeft.ballHitCount = 0
  paddleLeft.height = meta.initialPaddleHeight

  paddleRight = {}
  paddleRight.x = 780
  paddleRight.y = 250
  paddleRight.width = 20
  paddleRight.ySpeed = 100
  paddleRight.ballHitCount = 0
  paddleRight.height = meta.initialPaddleHeight
end

function love.update(dt)
  if (shouldAddNewBall(delta)) then
    table.insert(balls, createBallWithSpeed())
  end

  for i, ball in pairs(balls) do
    if (ball.x - ball.radius <= 0) then
      meta.scoreRight = meta.scoreRight + 1
      goalScoredAgainst(paddleLeft, ball)
      table.remove(balls, i)
    end

    if (ball.x + ball.radius >= love.graphics.getWidth()) then
      meta.scoreLeft = meta.scoreLeft + 1
      goalScoredAgainst(paddleRight, ball)
      table.remove(balls, i)
    end

    if (meta.scoreRight >= meta.winScore) then
      meta.winner = 'Player on the right wins!'
      resetBallWithoutSpeed(ball)
    end
    if (meta.scoreLeft >= meta.winScore) then
      meta.winner = 'Player on the left wins!'
      resetBallWithoutSpeed(ball)
    end

    if (ballHitWalls(ball)) then
      ball.ySpeed = ball.ySpeed * -1.1
      ball.hitCount = ball.hitCount + 1
    end

    if (checkCollision(ball, paddleRight)) then
      ball.x = paddleRight.x - paddleRight.width
      ballDeflected(paddleRight, ball)
    end
    if (checkCollision(ball, paddleLeft)) then
      ball.x = paddleLeft.x + paddleLeft.width + ball.radius
      ballDeflected(paddleLeft, ball)
    end

    ball.x = ball.x + ball.xSpeed*dt
    ball.y = ball.y + ball.ySpeed*dt
  end

  if (love.keyboard.isDown("w")) then
    paddleLeft.y = paddleLeft.y - dt*paddleLeft.ySpeed
  end

  if (love.keyboard.isDown("s")) then
    paddleLeft.y = paddleLeft.y + dt*paddleLeft.ySpeed
  end

  if (love.keyboard.isDown("up")) then
    paddleRight.y = paddleRight.y - dt*paddleRight.ySpeed
  end

  if (love.keyboard.isDown("down")) then
    paddleRight.y = paddleRight.y + dt*paddleRight.ySpeed
  end
end

function love.draw()
  for i, ball in pairs(balls) do
    love.graphics.setColor(255, 255 - ball.hitCount * 10, 255 - ball.hitCount * 10)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius, 20)
  end

  love.graphics.setColor(255 - paddleLeft.ballHitCount * 20, 255, 255 - paddleLeft.ballHitCount * 20)
  love.graphics.rectangle("fill", paddleLeft.x, paddleLeft.y, paddleLeft.width, paddleLeft.height)

  love.graphics.setColor(255 - paddleRight.ballHitCount * 20, 255, 255 - paddleRight.ballHitCount * 20)
  love.graphics.rectangle("fill", paddleRight.x, paddleRight.y, paddleRight.width, paddleRight.height)

  love.graphics.setColor(255, 255, 255)
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

  if key == "return" and meta.winner then
    resetGame(meta)
  end
end

function resetGame(meta)
  meta.winner = nil
  meta.scoreLeft = 0
  meta.scoreRight = 0

  paddleLeft.height = meta.initialPaddleHeight
  paddleLeft.ballHitCount = 0
  paddleLeft.ySpeed = meta.initialPaddleSpeed

  paddleRight.height = meta.initialPaddleHeight
  paddleRight.ballHitCount = 0
  paddleRight.ySpeed = meta.initialPaddleSpeed

  balls = {createBallWithSpeed()}
  initialTime = love.timer.getTime()
end

function checkCollision(ball, paddle)
  local verticalCollision = ((ball.y - ball.radius) > paddle.y and (ball.y - ball.radius) < paddle.y + paddle.height) or
                        ((ball.y + ball.radius) > paddle.y and (ball.y + ball.radius) < paddle.y + paddle.height)
  local horizontalCollision = ((ball.x - ball.radius) > paddle.x and (ball.x - ball.radius) < paddle.x + paddle.width) or
                        ((ball.x + ball.radius) > paddle.x and (ball.x + ball.radius) < paddle.x + paddle.width)
  return verticalCollision and horizontalCollision
end

function resetBallWithSpeed(ball)
  ball.hitCount = 0
  ball.x = (love.graphics.getWidth()/2 - meta.ballSpawLocationVariation) + love.math.random(meta.ballSpawLocationVariation*2)
  ball.y = (love.graphics.getHeight()/2 - meta.ballSpawLocationVariation) + love.math.random(meta.ballSpawLocationVariation*2)

  local speeds = {90, -90}
  ball.xSpeed = speeds[love.math.random(2)]
  ball.ySpeed = speeds[love.math.random(2)]
end

function resetBallWithoutSpeed(ball)
  ball.x = 400
  ball.y = 300
  ball.xSpeed = 0
  ball.ySpeed = 0
  ball.hitCount = 0
end

function createBallWithSpeed()
  ball  = {}
  ball.x = 400
  ball.y = 300
  ball.radius = 20
  ball.hitCount = 0
  resetBallWithSpeed(ball)
  return ball
end

function goalScoredAgainst(paddle, ball)
  paddle.height = paddle.height - meta.goalHeightPenalty * ball.hitCount
  paddle.ballHitCount = 0
  paddle.ySpeed = meta.initialPaddleSpeed
end

function ballDeflected(paddle, ball)
  ball.xSpeed = ball.xSpeed * -1.1
  if (paddle.height < meta.initialPaddleHeight*1.5) then
    paddle.height = paddle.height + meta.hitHeightBonus
  end
  if (paddle.ySpeed > meta.initialPaddleSpeed/5) then
    paddle.ySpeed = paddle.ySpeed - meta.goalSpeedPenalty
  end
  paddle.ballHitCount = paddle.ballHitCount + 1
  ball.hitCount = ball.hitCount + 1
end

function ballHitWalls(ball)
  return (ball.y - ball.radius <= 0) or
      (ball.y + ball.radius >= love.graphics.getHeight())
end

function shouldAddNewBall(delta)
  local currentTime = love.timer.getTime()
  local timeDelta = math.floor(currentTime - initialTime)
  return table.getn(balls) < meta.maxBalls and
    (timeDelta%meta.ballCreationDelay) == 0 and
    table.getn(balls) <= (timeDelta/meta.ballCreationDelay)
end
