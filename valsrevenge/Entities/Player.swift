//
//  Player.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/29.
//


import SpriteKit
import GameplayKit



class Player: SKSpriteNode {
    
    // 什么意思 这一步没看懂
    var stateMachine = GKStateMachine(states: [PlayerHasKeyState(),
                                               PlayerHasNoKeyState()])
    
    var agent = GKAgent2D()
    
    var movementSpeed: CGFloat = 5
    var maxProjectiles: Int = 1
    var numProjectiles: Int = 0
    var projectileSpeed: CGFloat = 25
    var projectileRange: TimeInterval  = 1
    
    let attackDelay = SKAction.wait(forDuration: 0.25)
    
    var hud = SKNode()
    private let treasureLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let keysLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    //  track how many keys Val has in her pockets and how much treasure she’s collected.
    private var keys: Int = GameData.shared.keys {
        didSet {
            keysLabel.text = "Keys: \(keys)"
            if keys < 1 {
                stateMachine.enter(PlayerHasNoKeyState.self)
            } else {
                stateMachine.enter(PlayerHasKeyState.self)
            }
        }
    }
    
    private var treasure: Int = GameData.shared.treasure {
        didSet {
            treasureLabel.text = "Treasure: \(treasure)"
        }
    }
    
    func setupHUD(scene: GameScene) {
        
        // Set up the treasure label
        treasureLabel.text = "Treasure: \(treasure)"
        treasureLabel.horizontalAlignmentMode = .right
        treasureLabel.verticalAlignmentMode = .center
        treasureLabel.position = CGPoint(x: 0, y: -treasureLabel.frame.height)
        treasureLabel.zPosition += 1
        
        // Set up the keys label
        keysLabel.text = "Keys: \(keys)"
        keysLabel.horizontalAlignmentMode = .right
        keysLabel.verticalAlignmentMode = .center
        keysLabel.position = CGPoint(x: 0,
                                     y: treasureLabel.frame.minY - keysLabel.frame.height)
        keysLabel.zPosition += 1
        
        // Add the labels to the HUD
        hud.addChild(treasureLabel)
        hud.addChild(keysLabel)
        
        // Add the HUD to the scene
        scene.addChild(hud)
    }
    // Override this method to allow for a class to work in the Scene Editor
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        stateMachine.enter(PlayerHasNoKeyState.self)
        agent.delegate = self
    }
    
    func getStats() -> (keys: Int, treasure: Int) {
        return (self.keys, self.treasure)
    }
    
    func collectItem(_ collectibleNode: SKNode) {
        guard let collectible = collectibleNode.entity?.component(ofType:
                                                                    CollectibleComponent.self) else {
            return
        }
        
        collectible.collectedItem()
        
        switch GameObjectType(rawValue: collectible.collectibleType) {
        case .key:
            // print("collected key")
            keys += collectible.value
            
        case .food:
            // 没懂
            // print("collected food")
            if let hc = entity?.component(ofType: HealthComponent.self) {
                hc.updateHealth(collectible.value, forNode: self)
            }
            
        case .treasure:
            // print("collected treasure")
            treasure += collectible.value
            
        default:
            break
        }
    }
    
    func useKeyToOpenDoor(_ doorNode: SKNode) {
        // print("Use key to open door")
        
        switch stateMachine.currentState {
        case is PlayerHasKeyState:
            keys -= 1
            
            doorNode.removeFromParent()
            run(SKAction.playSoundFileNamed("door_open",
                                            waitForCompletion: true))
        default:
            break
        }
    }
    
    func attack(direction: CGVector) {
        
        // Verify the direction isn't zero and that the player hasn't
        // shot more projectile than max allowed at one time
        if direction != .zero && numProjectiles < maxProjectiles {
            // Increase the number of "current" projectiles
            numProjectiles += 1
            
            // Set up the projectile
            let projectile = SKSpriteNode(imageNamed: "knife")
            projectile.position = CGPoint(x: 0.0, y: 0.0)
            projectile.zPosition += 1
            addChild(projectile)
            
            // set up the phsics for the projectiles
            let physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
            
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = true
            physicsBody.isDynamic = true
            
            physicsBody.categoryBitMask = PhysicsBody.projectile.categoryBitMask
            physicsBody.contactTestBitMask = PhysicsBody.projectile.contactTestBitMask
            physicsBody.collisionBitMask = PhysicsBody.projectile.collisionBitMask
            
            projectile.physicsBody = physicsBody
            
            // Set the throw direction
            let throwDirection = CGVector(dx: direction.dx * projectileSpeed, dy: direction.dy * projectileSpeed)
            
            // Create and run the actions to attack
            let wait = SKAction.wait(forDuration: projectileRange)
            let removeFromScene = SKAction.removeFromParent()
            
            let spin = SKAction.applyTorque(0.25, duration: projectileRange)
            let toss = SKAction.move(by: throwDirection, duration: projectileRange)
            
            let actionTTL = SKAction.sequence([wait, removeFromScene])
            let actionThrow = SKAction.group([spin, toss])
            
            let actionAttack = SKAction.group([actionTTL, actionThrow])
            projectile.run(actionAttack)
            
            // Set up attack governor (attack speed limiter)
            let reduceCount = SKAction.run({self.numProjectiles -= 1})
            let reduceSequence = SKAction.sequence([attackDelay, reduceCount])
            run(reduceSequence)
        }
    }
    
}
