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
        case Began, Moved, Ended, Cancelled
    }
    
    lazy var componentSystems: [GKComponentSystem] = {
        return [
            GKComponentSystem(componentClass: RadialGravityComponent.self),
            GKComponentSystem(componentClass: MoveComponent.self),
        ]
    }()
    
    lazy var entityManager: EntityManager = {
        return EntityManager(scene: self)
    }()
    
    let shipAgent = GKAgent2D()
    lazy var ship: GKEntity = {
        let node = self.childNode(withName: "ship")!
        
        node.physicsBody!.fieldBitMask = FieldMasks.Satellite.rawValue
        
        let entity = GKEntity()
        entity.addComponent(RenderComponent(node: node))
        entity.addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
        entity.addComponent(MoveComponent(maxSpeed: 50, maxAcceleration: 20, radius: 100, entityManager: self.entityManager))
        return entity
    }()
    
    lazy var sun: SKNode = {
        let node = self.childNode(withName: "sun")!
        let sunEmitter = SKEmitterNode(fileNamed: "Sun")!
        sunEmitter.setScale(5)
        node.addChild(sunEmitter)
        return node
    }()
    
    enum FieldMasks: UInt32 {
        case Satellite = 18
    }
    
    let enemyAgent = GKAgent2D()
    lazy var enemy: GKEntity = {
        let node: SKSpriteNode = SKSpriteNode(imageNamed: "Spaceship")
        let shipAgent = self.ship.component(ofType: MoveComponent.self)!
        
        node.position = CGPoint(x: 5500, y: 0)
        
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody!.fieldBitMask = 1
        node.physicsBody!.mass = 100
        node.physicsBody!.friction = 0
        node.physicsBody!.linearDamping = 0
        node.physicsBody!.angularDamping = 0

        let entity = GKEntity()
        entity.addComponent(RenderComponent(node: node))
        entity.addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
        
        let avoid = [self.venus.component(ofType: MoveComponent.self)!]
        
        let moveComponent = MoveComponent(maxSpeed: 6000, maxAcceleration: 8000, radius: 200, entityManager: self.entityManager)
        moveComponent.behavior = MoveBehavior(targetSpeed: 30, seek: shipAgent, avoid: avoid)
        entity.addComponent(moveComponent)
        
        let rotation = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 15)
        node.run(SKAction.repeatForever(rotation))
        
        return entity
    }()
    
    lazy var mars: GKEntity = {
        let node: SKNode = self.childNode(withName: "mars")!
        let shipAgent = self.ship.component(ofType: MoveComponent.self)!
        
        node.physicsBody?.fieldBitMask = 100
        
        let gravity = SKFieldNode.radialGravityField()
        gravity.strength = 10
        gravity.categoryBitMask = FieldMasks.Satellite.rawValue
        node.addChild(gravity)
        
        let light = SKLightNode()
        light.falloff = 2
        node.addChild(light)
        
        node.removeFromParent()
       
        let dustEmitter = SKEmitterNode(fileNamed: "Dust")!
        dustEmitter.advanceSimulationTime(15)
        dustEmitter.position = CGPoint(x: 0, y: -160)
        
        let cropNode = SKCropNode()
        cropNode.maskNode = SKSpriteNode(imageNamed: "mars")
        cropNode.zPosition = 1
        cropNode.addChild(dustEmitter)
        node.addChild(cropNode)
        
        let entity = GKEntity()
        entity.addComponent(RenderComponent(node: node))
        entity.addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
        
        let rotation = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 15)
        node.run(SKAction.repeatForever(rotation))
        
        return entity
    }()
    
    lazy var jupiter: GKEntity = {
        let node: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "jupiter"))
        let shipAgent = self.ship.component(ofType: MoveComponent.self)!
        
        node.position = CGPoint(x: 8000, y: 0)
        
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: CGSize(width: 500, height: 500))
        node.physicsBody!.fieldBitMask = 100
        node.physicsBody!.velocity = CGVector(dx: 0, dy: 1060.3)
        node.physicsBody!.mass = 10000000
        node.physicsBody!.friction = 0
        node.physicsBody!.linearDamping = 0
        node.physicsBody!.angularDamping = 0
        
        let rotation = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 15)
        node.run(SKAction.repeatForever(rotation))
        
        let gravity = SKFieldNode.radialGravityField()
        gravity.strength = 30
        gravity.falloff = 3
        gravity.categoryBitMask = FieldMasks.Satellite.rawValue
        node.addChild(gravity)
        
        let light = SKLightNode()
        light.falloff = 3
        node.addChild(light)
        
        let entity = GKEntity()
        entity.addComponent(RenderComponent(node: node))
        entity.addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
    
        return entity
    }()
    
    lazy var venus: GKEntity = {
        let node: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "venus"))
        let shipAgent = self.ship.component(ofType: MoveComponent.self)!
        
        node.position = CGPoint(x: 4000, y: 0)
        
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: CGSize(width: 300, height: 300))
        node.physicsBody!.fieldBitMask = 100
        node.physicsBody!.velocity = CGVector(dx: 0, dy: 1060.3)
        node.physicsBody!.mass = 10000000
        node.physicsBody!.friction = 0
        node.physicsBody!.linearDamping = 0
        node.physicsBody!.angularDamping = 0
        
        let gravity = SKFieldNode.radialGravityField()
        gravity.strength = 30
        gravity.categoryBitMask = FieldMasks.Satellite.rawValue
        node.addChild(gravity)
        
        let light = SKLightNode()
        light.falloff = 3
        node.addChild(light)
        
        let entity = GKEntity()
        entity.addComponent(RenderComponent(node: node))
        entity.addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
        
        let moveComponent = MoveComponent(maxSpeed: 0, maxAcceleration: 0, radius: 150, entityManager: self.entityManager)
        entity.addComponent(moveComponent)
        
        let rotation = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 15)
        node.run(SKAction.repeatForever(rotation))
        
        return entity
    }()
    
    lazy var saturn: GKEntity = {
        let node: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "saturn"))
        let shipAgent = self.ship.component(ofType: MoveComponent.self)!
        
        node.position = CGPoint(x: 9000, y: 0)
        
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.frame.size)
        node.physicsBody!.fieldBitMask = 100
        node.physicsBody!.velocity = CGVector(dx: 0, dy: 1060.3)
        node.physicsBody!.mass = 10000000
        node.physicsBody!.friction = 0
        node.physicsBody!.linearDamping = 0
        node.physicsBody!.angularDamping = 0
        
        func createSpec(x: Int) -> SKNode {
            let spec = SKShapeNode(circleOfRadius: 10)
            spec.fillColor = .lightGray
            spec.strokeColor = .lightGray
            spec.position = CGPoint(x: x, y: 0)
            spec.zPosition = 1
            spec.setScale(0)
            
            let orbitDuration = 2 as CGFloat
            let distance = spec.position.distance(toPoint: CGPoint(x: node.frame.width/2, y: 0))
            let duration = TimeInterval(distance * (orbitDuration / node.frame.width))
            let move = SKAction.move(to: CGPoint(x: node.frame.width/2+1, y: 0), duration: duration)
            let scaleUp = SKAction.scale(to: 1, duration: 0.5)
            let scaleDown = SKAction.scale(to: 0, duration: 0.5)
            let respawn = SKAction.run {
                spec.removeFromParent()
                _ = addSpec(x: -Int(node.frame.width/2))
            }
            spec.run(SKAction.sequence([scaleUp, move, scaleDown, respawn]))
            return spec
        }
        
        let xDistribution = GKRandomDistribution(lowestValue: Int(-node.frame.width/2.0), highestValue: Int(node.frame.width/2.0))

        func addSpec(x: Int) -> SKNode {
            let spec = createSpec(x: x)
            node.addChild(spec)
            return spec
        }
    
        for _ in 0..<18 {
            _ = addSpec(x: xDistribution.nextInt())
        }
        
        let gravity = SKFieldNode.radialGravityField()
        gravity.strength = 30
        gravity.falloff = 3
        gravity.categoryBitMask = FieldMasks.Satellite.rawValue
        node.addChild(gravity)
        
        let light = SKLightNode()
        light.falloff = 3
        node.addChild(light)
        
        let entity = GKEntity()
        entity.addComponent(RenderComponent(node: node))
        entity.addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
        
        let rotation = SKAction.rotate(byAngle: CGFloat(M_PI), duration: 15)
        node.run(SKAction.repeatForever(rotation))
        
        return entity
    }()

    var previousScale: CGFloat = 1
    
    func zoom(pinchGesture: UIPinchGestureRecognizer) {
        guard pinchGesture.state == .changed else {
            previousScale = 1
            return
        }
        
        guard let camera = camera else { return }
        
        if pinchGesture.scale > previousScale && camera.xScale > 0.6 {
                camera.setScale(camera.xScale * 0.925)
        } else if pinchGesture.scale < previousScale && camera.xScale < 10 {
                camera.setScale(camera.xScale * 1.075)
        }
        previousScale = pinchGesture.scale
    }

    lazy var screenSize: CGSize = {
        return self.view!.frame.size
    }()
    
    override func didMove(to view: SKView) {
        self.view?.ignoresSiblingOrder = true
        
//        scaleMode = .aspectFit
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.speed = 1
        
        entityManager.componentSystems = componentSystems
        
        run(SKAction.playSoundFileNamed("Tap", waitForCompletion: false))
    
        _ = sun
        
        let controlPanel = SKNode()
        let controlNode = SKShapeNode(circleOfRadius: 100)
        controlNode.fillColor = .clear
        controlNode.strokeColor = .white
        controlNode.position = CGPoint(x: -size.width/2 + controlNode.frame.width/2 + 50, y: -size.height/2 + controlNode.frame.height/2 + 50)
        
        controlPanel.addChild(controlNode)
        camera?.addChild(controlPanel)
        
        let randomDistance = GKRandomDistribution(lowestValue: 12000, highestValue: 13000)
        let randomX = GKRandomDistribution(lowestValue: -12000, highestValue: 13000)
        var randomSign: Int {
            return GKRandomDistribution().nextBool() ? -1 : 1
        }
        
        for _ in 0..<100 {
            let distance = CGFloat(randomDistance.nextInt())
            let x = CGFloat(randomX.nextInt())
            let y = sqrt(pow(distance, 2) - pow(x, 2)) * CGFloat(randomSign)
            
            let point1 = CGPoint.zero
            let point2 = CGPoint(x: x, y: y)
            
            let originPoint = CGPoint(x: point2.x - point1.x, y: point2.y - point1.y)
            let angle = atan2(originPoint.y, originPoint.x) + CGFloat(M_PI_2)
            
            let comet = SKShapeNode(circleOfRadius: 5)
            let cometEmitter = SKEmitterNode(fileNamed: "Comet")!
            comet.fillColor = cometEmitter.particleColor
            comet.position = CGPoint(x: x, y: y)
            comet.physicsBody = SKPhysicsBody()
            comet.physicsBody!.friction = 0
            comet.physicsBody!.linearDamping = 0
            comet.physicsBody!.angularDamping = 0
            comet.physicsBody!.mass = 10
            comet.addChild(cometEmitter)
            
            let speed = 1060.3 as CGFloat
            comet.physicsBody!.velocity = CGVector(dx: cos(angle)*speed, dy: sin(angle)*speed)
            cometEmitter.targetNode = self
            addChild(comet)
        }
        
        let zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(GameScene.zoom(pinchGesture:)))
        self.view?.addGestureRecognizer(zoomGesture)
        
        entityManager.add(entity: ship)
        entityManager.add(entity: enemy)
        entityManager.add(entity: venus)
        entityManager.add(entity: mars)
        entityManager.add(entity: jupiter)
        entityManager.add(entity: saturn)

        return
        
        let planets = [
            Planet(position: CGPoint(x: self.view!.frame.width*(0.2), y: self.view!.frame.height*(0.4)), radius: 10, mass: 10),
            Planet(position: CGPoint(x: self.view!.frame.width*(0.25), y: self.view!.frame.height*(0.7)), radius: 30, mass: 30),
            Planet(position: CGPoint(x: self.view!.frame.width*(0.8), y: self.view!.frame.height*(0.9)), radius: 50, mass: 50),
            Planet(position: CGPoint(x: self.view!.frame.width*(0.6), y: self.view!.frame.height*(0.3)), radius: 20, mass: 20),
        ]
        
        let vortex = SKFieldNode.vortexField()
        vortex.position = CGPoint(x: self.view!.frame.width*(0.5), y: self.view!.frame.height*(0.5))
        vortex.strength = 30
        addChild(vortex)
        
        planets.forEach(entityManager.add)
        
        let earthSize = CGSize(width: self.view!.frame.width, height: self.view!.frame.height/10)
        let earthPosition = CGPoint(x: self.view!.frame.width/2, y: earthSize.height/2)
        let earth = Earth(position: earthPosition, size: earthSize, mass: 100, velocity: .zero)
        entityManager.add(entity: earth)
        
        _ = createEnemy()
    }
    
    func createEnemy() -> GKEntity {
        let position = CGPoint(x: GKRandomDistribution(lowestValue: 0, highestValue: 300).nextInt(), y: GKRandomDistribution(lowestValue: 400, highestValue: 500).nextInt())
        
        let velocity = CGVector(dx: GKRandomDistribution(lowestValue: -300, highestValue: 300).nextInt(), dy: GKRandomDistribution(lowestValue: -100, highestValue: -30).nextInt())
        
        perform(#selector(GameScene.createEnemy), with: nil, afterDelay: 0.2)

        let radius = CGFloat(GKRandomDistribution(lowestValue: 10, highestValue: 20).nextInt())
        
        let enemy = Enemy(position: position, radius: radius, mass: 50, velocity: velocity)
        entityManager.add(entity: enemy)
        return enemy
    }
    
    var fingerTouch: UITouch?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            passTouchEvent(touch: touch, event: event, ofType: .Began)

            fingerTouch = fingerTouch == nil ? touch : nil
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
            
            fingerTouch = nil
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            passTouchEvent(touch: touch, event: event, ofType: .Cancelled)
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
        case .Cancelled:
            component?.touchCancelled?(touch, event)
        }
    }
    
    func entity(forNode node: SKNode) -> GKEntity? {
        return entityManager.entities.filter{
            $0.component(ofType: RenderComponent.self)?.node == node
        }.first
    }
    
    lazy var lastUpdateTime: TimeInterval = {
       return NSDate().timeIntervalSince1970
    }()

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTime
        
        entityManager.update(deltaTime: deltaTime)
        
        let shipNode = ship.component(ofType: RenderComponent.self)!.node
        
        if let touch = fingerTouch {
            let point1 = touch.location(in: self)
            let point2 = shipNode.position
            
            let angle = atan2(point2.y - point1.y, point2.x - point1.x)
            let thrust = CGVector(dx: cos(angle)*300, dy: sin(angle)*300)
            shipNode.physicsBody?.applyForce(thrust)
            shipNode.zRotation = angle - CGFloat(M_PI_2)
        }
        
        enumerateChildNodes(withName: "comet") { node, stop in
            let point1 = self.sun.position
            let point2 = node.position
            
            let angle = atan2(point2.y - point1.y, point2.x - point1.x)
            
            node.childNode(withName: "emitter")?.zRotation = angle - CGFloat(M_PI_2)
        }
        
        let dx = saturn.component(ofType: RenderComponent.self)!.node.position.x
        let dy = saturn.component(ofType: RenderComponent.self)!.node.position.y
        let distance = sqrt(pow(dx, 2) + pow(dy, 2))
        
        low = distance < low ? distance : low
        high = distance > high ? distance : high
        print("\(low) - \(high)")
        
        lastUpdateTime = currentTime
    }
    
    override func didFinishUpdate() {
        let shipNode = ship.component(ofType: RenderComponent.self)!.node
        camera!.position = shipNode.position
    }
    
    var low = 100000000 as CGFloat
    var high = 0 as CGFloat
}

extension CGPoint {
    func distance(toPoint: CGPoint) -> CGFloat {
        let dx = self.x - toPoint.x
        let dy = self.y - toPoint.y
        return sqrt((dx * dx) + (dy * dy))
    }
}

enum ContactTypes: UInt32 {
    case Earth
    case Planet
    case Enemy
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
    
    init(position: CGPoint, radius: Float, mass: Float) {
        let node = SKShapeNode(circleOfRadius: CGFloat(radius))
        node.fillColor = UIColor.blue
        node.position = position

        node.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        node.physicsBody!.isDynamic = false
        node.physicsBody!.mass = CGFloat(mass)
        
        super.init()
        
        addComponent(RenderComponent(node: node))
        addComponent(PhysicsComponent(physicsBody: node.physicsBody!))
        
        let radialGravity = RadialGravityComponent()
        node.addChild(radialGravity.gravitationalField)
        addComponent(radialGravity)
        
        addComponent(TouchComponent(touchBegan: { touch, event in
            self.radialGravityComponent?.gravitationalField.strength = 3.0 * (mass/50.0)
            
            }, touchMoved: { touch, event in
                
            }, touchEnded: { touch, event in
            self.radialGravityComponent?.gravitationalField.strength = 0
            }, touchCancelled: { touch, event in
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
        let node = SKShapeNode(circleOfRadius: radius)
        node.name = "enemy"
        node.position = position
        
        let colors: [UIColor] = [.red, .blue, .black, .green, .darkGray, .brown]
        node.fillColor = colors[GKRandomDistribution(lowestValue: 0, highestValue: 5).nextInt()]
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
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

class Earth: GKEntity {
    
    var renderComponent: RenderComponent? {
        return component(ofType: RenderComponent.self)
    }
    
    var physicsComponent: PhysicsComponent? {
        return component(ofType: PhysicsComponent.self)
    }
    
    init(position: CGPoint, size: CGSize, mass: CGFloat, velocity: CGVector) {
        let node = SKSpriteNode(imageNamed: "earth")
        node.position = position
        node.size = size
        node.name = "earth"
        
        node.physicsBody = SKPhysicsBody(rectangleOf: size)
        node.physicsBody!.friction = 0
        node.physicsBody!.isDynamic = false
        node.physicsBody!.mass = mass
        node.physicsBody!.velocity = velocity
        node.physicsBody!.contactTestBitMask = ContactTypes.Enemy.rawValue
        
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
    
    override func update(deltaTime seconds: TimeInterval) {

    }
}

class RadialGravityComponent: GKComponent {
    
    let gravitationalField = SKFieldNode.vortexField()
    
    override init() {
        gravitationalField.strength = 300
        gravitationalField.falloff = 0
        
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
    var touchCancelled: TouchBlock? = nil
    
    init(touchBegan: TouchBlock? = nil, touchMoved: TouchBlock? = nil, touchEnded: TouchBlock? = nil, touchCancelled: TouchBlock? = nil) {
        self.touchBegan = touchBegan
        self.touchMoved = touchMoved
        self.touchEnded = touchEnded
        self.touchCancelled = touchCancelled
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MoveComponent : GKAgent2D, GKAgentDelegate {
    
    let entityManager: EntityManager
    
    init(maxSpeed: Float, maxAcceleration: Float, radius: Float, entityManager: EntityManager) {
        self.entityManager = entityManager
        super.init()
        delegate = self
        self.maxSpeed = maxSpeed
        self.maxAcceleration = maxAcceleration
        self.radius = radius
        self.mass = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: RenderComponent.self) else { return }
        position = float2(x: Float(spriteComponent.node.position.x), y: Float(spriteComponent.node.position.y))
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        guard let spriteComponent = entity?.component(ofType: RenderComponent.self) else { return }
        spriteComponent.node.position = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    }
}

class MoveBehavior: GKBehavior {
    
    init(targetSpeed: Float, seek: GKAgent, avoid: [GKAgent]) {
        super.init()

        if targetSpeed > 0 {
//            setWeight(0.1, for: GKGoal(toReachTargetSpeed: targetSpeed))

            setWeight(30.0, for: GKGoal(toSeekAgent: seek))

            setWeight(60.0, for: GKGoal(toAvoid: avoid, maxPredictionTime: 3))
        }
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
    var toRemove = Set<GKEntity>()

    let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func add(entity: GKEntity) {
        entities.insert(entity)
        if let spriteNode = entity.component(ofType: RenderComponent.self)?.node {
            if !scene.children.contains(spriteNode) {
                scene.addChild(spriteNode)
            }
        }
        
        componentSystems.forEach { $0.addComponent(foundIn: entity) }
    }
    
    func remove(entity: GKEntity) {
        if let spriteNode = entity.component(ofType: RenderComponent.self)?.node {
            spriteNode.removeFromParent()
        }
        entities.remove(entity)
        toRemove.insert(entity)
    }
    
    func update(deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        for curRemove in toRemove {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: curRemove)
            }
        }
        toRemove.removeAll()
    }
}
