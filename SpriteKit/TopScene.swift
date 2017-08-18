//
//  GameScene.swift
//  SK_UGui
//
//  Created by Shusuke Unno on 2017/08/10.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit
import GameplayKit

public class TopScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var mPageManager : UPageViewManager?
    
    public static var instance : TopScene?
    public var parentVC : UIViewController?
    
    var vt : ViewTouch = ViewTouch()
    
    
    public static func getInstance() -> TopScene {
        return instance!
    }
    
    override public func didMove(to view: SKView) {
        let n = SKShapeNode(rect: CGRect(x:0, y:0, width: 100, height: 100))
        n.fillColor = .red
        n.strokeColor = .clear
        n.position = CGPoint(x:100, y:100)
        self.addChild(n)
//        self.scaleMode = SKSceneScaleMode.resizeFill
//        // ページマネージャーを初期化
//        UDrawManager.getInstance().initialize()
//        mPageManager = PageViewManager.createInstance(topScene: self)
//        if parentVC != nil {
//            mPageManager?.mParentVC = parentVC
//        }
//        
//        // DPI初期化
//        UDpi.initialize()
//        
//        TopScene.instance = self
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // タッチイベントを取得する
        let touch = touches.first
        
        if touch != nil {
            let pos = self.convertPoint(toView: touch!.location(in: self))
            _ = vt.checkTouchType(e: TouchEventType.Down,
                                  touch: touch!, pos: pos)
        }
        
        // 描画オブジェクトのタッチ処理はすべてUDrawManagerにまかせる
        if UDrawManager.getInstance().touchEvent(vt) {
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチイベントを取得する
        let touch = touches.first
        let pos = self.convertPoint(toView: touch!.location(in: self))
        
        _ = vt.checkTouchType(e: TouchEventType.Move,
                              touch: touch!, pos: pos)
        
        // 描画オブジェクトのタッチ処理はすべてUDrawManagerにまかせる
        if UDrawManager.getInstance().touchEvent(vt) {
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let pos = self.convertPoint(toView: touch!.location(in: self))
        
        _ = vt.checkTouchType(e: TouchEventType.Up,
                              touch: touch!, pos: pos)
        
        // 描画オブジェクトのタッチ処理はすべてUDrawManagerにまかせる
        if UDrawManager.getInstance().touchEvent(vt) {
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let pos = self.convertPoint(toView: touch!.location(in: self))
        
        _ = vt.checkTouchType(e: TouchEventType.Cancel,
                              touch: touch!, pos: pos)
    }
    
    
    override public func update(_ currentTime: TimeInterval) {
        // todo 
        return
        
        // 現在のページの描画
        if (mPageManager!.draw()) {
            
        }
        
        // マネージャに登録した描画オブジェクトをまとめて描画
        if UDrawManager.getInstance().draw() == true {
            //            redraw = true
        }
    }
}
