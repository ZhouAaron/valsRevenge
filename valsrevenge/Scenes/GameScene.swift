//
//  GameScene.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    let agentComponentSystem = GKComponentSystem(componentClass: GKAgent2D.self)
    
    let mainGameStateMachine = GKStateMachine(states: [PauseState(), PlayingState()])
    private var lastUpdateTime : TimeInterval = 0
    private var player: Player?
    
    let margin: CGFloat = 20.0
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        mainGameStateMachine.enter(PauseState.self)
        
        setupPlayer()
        
        setupCamera()
        
        let grassMapNode = childNode(withName: "Grass Tile Map") as? SKTileMapNode
        grassMapNode?.setupEdgeLoop()
        
        let dungeonMapNode = childNode(withName: "Dungeon Tile Map") as? SKTileMapNode
        dungeonMapNode?.setupMapPhysics()
        
        physicsWorld.contactDelegate = self
        
        startAdvancedNavigation()
    }
    
    func setupCamera() {
        guard let player = player else { return }
        let distance = SKRange(constantValue: 0)
        let playerConstraint = SKConstraint.distance(distance, to: player)
        
        camera?.constraints = [playerConstraint]
    }
    
    func setupPlayer() {
        player = childNode(withName: "player") as? Player
        
        if let player = player {
            player.move(.stop)
            agentComponentSystem.addComponent(player.agent)
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        mainGameStateMachine.enter(PlayingState.self)
        
        let nodeAtPoint = atPoint(pos)
        if let touchedNode = nodeAtPoint as? SKSpriteNode {
            if touchedNode.name?.starts(with: "controller_") == true {
                let direction = touchedNode.name?.replacingOccurrences(
                    of: "controller_", with: "")
                player?.move(Direction(rawValue: direction ?? "stop")!)
            } else if touchedNode.name == "button_attack" {
                player?.attack()
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        let nodeAtPoint = atPoint(pos)
        if let touchedNode = nodeAtPoint as? SKSpriteNode {
            if touchedNode.name?.starts(with: "controller_") == true {
                let direction = touchedNode.name?.replacingOccurrences(
                    of: "controller_", with: "")
                player?.move(Direction(rawValue: direction ?? "stop")!)
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let nodeAtPoint = atPoint(pos)
        if let touchedNode = nodeAtPoint as? SKSpriteNode {
            if touchedNode.name?.starts(with: "controller_") == true {
                player?.stop()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        // Update the component systems
        agentComponentSystem.update(deltaTime: dt)
        self.lastUpdateTime = currentTime
    }
    
    override func didFinishUpdate() {
        updateControllerLocation()
    }
    
    func updateControllerLocation() {
        let controller = childNode(withName: "//controller")
        controller?.position = CGPoint(x: (viewLeft + margin + insets.left),
                                       y: (viewBottom + margin + insets.bottom))
        
        let attackButton = childNode(withName: "//attackButton")
        attackButton?.position = CGPoint(x: (viewRight - margin - insets.right),
                                         y: (viewBottom + margin + insets.bottom))
    }
    
    func startAdvancedNavigation() {
        
        // Check for a navigaton graph and a key node
        guard let sceneGraph = graphs.values.first, let keyNode = childNode(withName: "key") as? SKSpriteNode else {
            return
        }
        
        // Set up the agent
        let agent = GKAgent2D()
        
        // Set up the agent's properties
        agent.mass = 1
        agent.speed = 50
        agent.maxSpeed = 100
        agent.maxAcceleration = 100
        agent.radius = 60
        
        // Find obstacles (generators)
        var obstacles = [GKCircleObstacle]()
        
        // Locate generator nodes
        enumerateChildNodes(withName: "generator_*") { (node, stop) in
            // Create compatible obstacles
            let circle = GKCircleObstacle(radius: Float(node.frame.size.width / 2))
            circle.position = vector_float2(Float(node.position.x), Float(node.position.y))
            
            obstacles.append(circle)
        }
        
        // Find the path
        if let nodesOnPath = sceneGraph.nodes as? [GKGraphNode2D] {
            
            // Show the path (option code)
            for (index, node) in nodesOnPath.enumerated() {
                let shapeNode = SKShapeNode(circleOfRadius: 10)
                shapeNode.fillColor = .green
                shapeNode.position = CGPoint(x: CGFloat(node.position.x), y: CGFloat(node.position.y))
                
                // Add node number
                let number = SKLabelNode(text: "\(index)")
                number.position.y = 15
                shapeNode.addChild(number)
                
                addChild(shapeNode)
            }
            // End (option code)
            
            // Create a path to follow
            let path = GKPath(graphNodes: nodesOnPath, radius: 0)
            path.isCyclical = true
            
            // set up the goals
            let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true)
            let avoidObstacles = GKGoal(toAvoid: obstacles, maxPredictionTime: 1.0)
            
            // add behavior based on goals
            agent.behavior = GKBehavior(goals: [followPath, avoidObstacles])
            
            // Set goal weights
            agent.behavior?.setWeight(0.5, for: followPath)
            agent.behavior?.setWeight(100, for: avoidObstacles)
            
            // Add agent to component system
            agentComponentSystem.addComponent(agent)
        }
    }
    
}
