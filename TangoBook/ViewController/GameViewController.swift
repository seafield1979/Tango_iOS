//
//  GameViewController.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/18.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーにViewが重ならないようにする
        self.edgesForExtendedLayout = []
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = TopScene(fileNamed: "TopScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.parentVC = self
                scene.parentView = view
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            if UDebug.isDebug {
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
