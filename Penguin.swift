import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // The player sprite
    var player: SKSpriteNode!
    
    // Time variables for obstacle spawning and update loop
    var lastUpdateTime: TimeInterval = 0
    var gameTimer: Timer?
    
    // Array to hold all the obstacles
    var obstacles = [SKSpriteNode]()
    
    // Time variable for last obstacle spawn
    var lastSpawnTime: TimeInterval = 0
    
    // Flag to track if the game is over
    var isGameOver = false
    
    // Score label
    let scoreLabel = SKLabelNode(fontNamed: "Helvetica")
    
    // Player score
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Called when the scene is loaded into memory
    override func didMove(to view: SKView) {
        
        // Set up physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5) // Set the gravity of the world
        self.physicsWorld.contactDelegate = self // Set the contact delegate to handle collisions
        
        // Set up player
        self.player = SKSpriteNode(imageNamed: "penguin") // Create the player sprite
        self.player.position = CGPoint(x: self.frame.midX - 100, y: self.frame.midY) // Set the initial position of the player
        self.player.zPosition = 1 // Set the z position to be in front of the obstacles
        self.player.physicsBody = SKPhysicsBody(circleOfRadius: self.player.size.height / 2) // Create the physics body for the player
        self.player.physicsBody?.isDynamic = true // Allow the player to move in response to physics
        self.player.physicsBody?.allowsRotation = false // Prevent the player from rotating
        self.player.physicsBody?.categoryBitMask = 1 // Assign a category bit mask for the player
        self.player.physicsBody?.collisionBitMask = 2 // Assign a collision bit mask for the player
        self.player.physicsBody?.contactTestBitMask = 2 // Assign a contact test bit mask for the player
        self.addChild(self.player) // Add the player to the scene
        
        // Set up score label
        self.scoreLabel.fontSize = 20
        self.scoreLabel.position = CGPoint(x: self.frame.midX + 100, y: self.frame.maxY - 50)
        self.addChild(self.scoreLabel)
        
        // Start the game timer to spawn obstacles
        self.gameTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(spawnObstacle), userInfo: nil, repeats: true)
    }
    
    // Called when the user touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isGameOver {
            // Apply an upward force to the player if the game is not over
            self.player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        } else {
            // Restart the game if the game is over
            self.removeAllChildren()
            self.obstacles.removeAll()
            self.isGameOver = false
            self.score = 0
            self.didMove(to: self.view!)
        }
    }
    
    // Called every frame to update the game state
    override func update(_ currentTime: TimeInterval) {
                if self.isGameOver {
            return
        }
        
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate the time since the last update
        let deltaTime = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Apply a downward force to the player
        self.player.physicsBody?.applyForce(CGVector(dx: 0, dy: -50))
        
        // Loop through all the obstacles and remove any that have gone offscreen
        for obstacle in self.obstacles {
            if obstacle.position.x < -obstacle.size.width {
                obstacle.removeFromParent()
                if let index = self.obstacles.index(of: obstacle) {
                    self.obstacles.remove(at: index)
                }
            }
        }
        
        // Spawn new obstacles at a fixed time interval
        let timeSinceLastSpawn = currentTime - self.lastSpawnTime
        if timeSinceLastSpawn > 1.5 {
            self.spawnObstacle()
            self.lastSpawnTime = currentTime
        }
        
        // Increment the player's score based on the distance traveled
        self.score += Int(deltaTime * 100)
    }
    
    // Spawn a new obstacle
    @objc func spawnObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "iceberg") // Create a new obstacle sprite
        obstacle.position = CGPoint(x: self.frame.maxX + obstacle.size.width / 2, y: CGFloat.random(in: self.frame.midY - 200...self.frame.midY + 200)) // Set the obstacle's initial position
        obstacle.zPosition = 0 // Set the z position to be behind the player
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size) // Create the physics body for the obstacle
        obstacle.physicsBody?.isDynamic = false // Make the obstacle static
        obstacle.physicsBody?.categoryBitMask = 2 // Assign a category bit mask for the obstacle
        obstacle.physicsBody?.collisionBitMask = 1 // Assign a collision bit mask for the obstacle
        obstacle.physicsBody?.contactTestBitMask = 1 // Assign a contact test bit mask for the obstacle
        self.addChild(obstacle) // Add the obstacle to the scene
        self.obstacles.append(obstacle) // Add the obstacle to the obstacles array
    }
    
    // Handle collisions between physics bodies
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == 1 || contact.bodyB.categoryBitMask == 1 {
            // If the player collides with an obstacle, end the game
            self.gameOver()
        }
    }
    
    // Handle game over
    func gameOver() {
        self.isGameOver = true
        self.gameTimer?.invalidate()
        self.gameTimer = nil
        let gameOverLabel = SKLabelNode(fontNamed: "Calibri")
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        gameOverLabel.text = "Game Over!"
        self.addChild(gameOverLabel)
    }
}

