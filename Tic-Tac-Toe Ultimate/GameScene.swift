import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var lastUpdateTime : TimeInterval = 0
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Расчет дельты времени
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        let _ = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Вызов обновлений для каждого компонента
        
        // Обновления игровой логики происходят здесь
    }
    
    override func didMove(to view: SKView) {
        // Настройка сцены после добавления в представление
    }
    
    func touchDown(atPoint pos : CGPoint) {
        // Логика при касании экрана
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        // Логика при перемещении касания
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // Логика при окончании касания
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        // Обработка нажатий клавиш
    }
} 