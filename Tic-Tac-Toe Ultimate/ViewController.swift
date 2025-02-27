import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {
    
    @IBOutlet weak var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            // Загрузка сцены из файла .sks
            if let scene = SKScene(fileNamed: "GameScene") {
                // Настройка аспектов представления сцены
                scene.scaleMode = .aspectFill
                
                // Отображение сцены
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
} 