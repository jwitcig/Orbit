//
//  GameScene.swift
//  Orbit
//
//  Created by Developer on 9/9/16.
//  Copyright (c) 2016 JwitApps. All rights reserved.
//

import GameKit
import SpriteKit

class GameScene: SKScene {
    
    enum TouchEvent {
        case Began, Moved, Ended
    }
    
    lazy var entityManager: EntityManager = {
        return EntityManager(scene: self)
    }()

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        
        self.view?.ignoresSiblingOrder = true
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let gravitySystem = GKComponentSystem(componentClass: RadialGravityComponent.self)
        entityManager.componentSystems.append(gravitySystem)
        
        let planets = [
            Planet(position: CGPoint(x: self.view!.frame.width/2, y: self.view!.frame.height*(0.4)), radius: 30, mass: 30),
            Planet(position: CGPoint(x: self.view!.frame.width/4, y: self.view!.frame.height*(0.7)), radius: 30, mass: 30)
        ]
        
        planets.forEach(entityManager.add)
        
        _ = createEnemy()
    }
    
    func createEnemy() -> GKEntity {
        let position = CGPoint(x: GKRandomDistribution(lowestValue: 0, highestValue: 300).nextInt(), y: GKRandomDistribution(lowestValue: 400, highestValue: 500).nextInt())
        
        let velocity = CGVector(dx: GKRandomDistribution(lowestValue: -300, highestValue: 300).nextInt(), dy: GKRandomDistribution(lowestValue: -300, highestValue: -30).nextInt())
        
        perform(#selector(GameScene.createEnemy), with: nil, afterDelay: 2.0)

        let enemy = Enemy(position: position, radius: 5, mass: 5, velocity: velocity)
        entityManager.add(entity: enemy)
        return enemy
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            passTouchEvent(touch: touch, event: event, ofType: .Began)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            passTouchEvent(touch: touch, event: event, ofType: .Moved)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            passTouchEvent(touch: touch, event: event, ofType: .Ended)
        }
    }
  
    func passTouchEvent(touch: UITouch, event: UIEvent?, ofType eventType: TouchEvent) {
        let location = touch.location(in: self)
        let node = atPoint(location)
        let touchedEntity = entity(forNode: node)
        let component = touchedEntity?.component(ofType: TouchComponent.self)
        
        switch eventType {
        case .Began:
            component?.touchBegan?(touch, event)
        case .Moved:
            component?.touchMoved?(touch, event)
        case .Ended:
            component?.touchEnded?(touch, event)
        }
    }
    
    func entity(forNode node: SKNode) -> GKEntity? {
        return entityManager.entities.filter{
            $0.component(ofType: RenderComponent.self)?.node == node
        }.first
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
}

extension CGPoint {
    func distance(toPoint: CGPoint) -> CGFloat {
        let dx = self.x - toPoint.x
        let dy = self.y - toPoint.y
        return sqrt((dx * dx) + (dy * dy))
    }
}

class Planet: GKEntity {
    
    var renderComponent: RenderComponent? {
        return component(ofType: RenderComponent.self)
    }
    
    var physicsComponent: PhysicsComponent? {
        return component(ofType: PhysicsComponent.self)
    }
    
    var radialGravityComponent: RadialGravityComponent? {
        return component(ofType: RadialGravityComponent.self)
    }
    
    var touchComponent: TouchComponent? {
        return component(ofType: TouchComponent.self)
    }
    
    init(position: CGPoint, radius: CGFloat, mass: CGFloat) {
        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = UIColor.blue
        node.position = position

        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        node.physicsBody!.isDynamic = false
        node.physicsBody!.mass = mass
        
        super.init()
        
        addComponent(RenderComponent(node: node))
        addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
        
        let radialGravity = RadialGravityComponent()
        node.addChild(radialGravity.gravitationalField)
        addComponent(radialGravity)
        
        addComponent(TouchComponent(touchBegan: { touch, event in
            self.radialGravityComponent?.gravitationalField.strength = 3
            
            print()
            }, touchMoved: { touch, event in
                
            }, touchEnded: { touch, event in
                
            self.radialGravityComponent?.gravitationalField.strength = 0
        }))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Enemy: GKEntity {
    
    var renderComponent: RenderComponent? {
        return component(ofType: RenderComponent.self)
    }
    
    var physicsComponent: PhysicsComponent? {
        return component(ofType: PhysicsComponent.self)
    }
    
    init(position: CGPoint, radius: CGFloat, mass: CGFloat, velocity: CGVector) {
        let node = SKShapeNode(circleOfRadius: 5)
        node.name = "enemy"
        node.fillColor = .red
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        node.physicsBody!.friction = 0
        node.physicsBody!.mass = mass
        node.physicsBody!.velocity = velocity
        
        super.init()

        addComponent(RenderComponent(node: node))
        addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RenderComponent: GKComponent {
    
    let node: SKNode
    
    init(node: SKNode) {
        self.node = node
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RadialGravityComponent: GKComponent {
    
    let gravitationalField = SKFieldNode.radialGravityField()
    
    override init() {
        gravitationalField.strength = 0
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhysicsComponent: GKComponent {
    
    let physicsBody: SKPhysicsBody
    
    init(physicsBody: SKPhysicsBody) {
        self.physicsBody = physicsBody
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TouchComponent: GKComponent {
    typealias TouchBlock = ((UITouch, UIEvent?)->())
    
    var touchBegan: TouchBlock? = nil
    var touchMoved: TouchBlock? = nil
    var touchEnded: TouchBlock? = nil
    
    init(touchBegan: TouchBlock? = nil, touchMoved: TouchBlock? = nil, touchEnded: TouchBlock? = nil) {
        self.touchBegan = touchBegan
        self.touchMoved = touchMoved
        self.touchEnded = touchEnded
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EntityManager {
    
    var componentSystems = [GKComponentSystem]() {
        didSet {
            entities.forEach { entity in
                componentSystems.forEach { system in
                    system.addComponent(foundIn: entity)
                }
            }
        }
    }
    
    var entities = Set<GKEntity>()
    let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func add(entity: GKEntity) {
        entities.insert(entity)
        if let spriteNode = entity.component(ofType: RenderComponent.self)?.node {
            scene.addChild(spriteNode)
        }
        
        componentSystems.forEach { $0.addComponent(foundIn: entity) }
    }
    
    func remove(entity: GKEntity) {
        if let spriteNode = entity.component(ofType: RenderComponent.self)?.node {
            spriteNode.removeFromParent()
        }
        entities.remove(entity)
    }
}
