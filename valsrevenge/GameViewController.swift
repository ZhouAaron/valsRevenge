//
//  GameViewController.swift
//  valsrevenge
//
//  Created by Aaron on 2022/3/26.
//

import UIKit
import SpriteKit
import GameplayKit

protocol GameViewControllerDelegate {
    func didChangeLayout()
}
class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let view = self.view as! SKView? {
            // Create the scene
            let scene = TitleScene(fileNamed: "TitleScene")
            
            // Set the scale mode to scale to fill the view window
            scene?.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            // Set the view options
            view.ignoresSiblingOrder = false
            view.showsPhysics = false
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let skView = self.view as? SKView,
              let gameViewControllerDelegate = skView.scene as?
                GameViewControllerDelegate else { return }
        
        gameViewControllerDelegate.didChangeLayout()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
