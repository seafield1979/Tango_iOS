//
//  GameScene.swift
//  SK_UGui
//
//  Created by Shusuke Unno on 2017/08/10.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class TopScene: SKScene {
    
    // MARK: Constants
    
    // MARK: Properties
    private var mPageManager : UPageViewManager?
    public static var instance : TopScene?
    public var parentVC : UIViewController?
    var vt : ViewTouch = ViewTouch()
    
    // MARK: Methods
    public static func getInstance() -> TopScene {
        return instance!
    }
    
    override public func didMove(to view: SKView) {
        
        self.scaleMode = SKSceneScaleMode.resizeFill
        // ページマネージャーを初期化
        UDrawManager.getInstance().initialize()
        mPageManager = PageViewManagerMain.createInstance(topScene: self, vc : parentVC)

        // DPI初期化
        UDpi.initialize()
        
        TopScene.instance = self
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
    
    /**
     * 毎フレームの描画前に呼ばれる
     */
    override public func update(_ currentTime: TimeInterval) {
        // 長押し判定
        if vt.checkLongTouch() {
            _ = UDrawManager.getInstance().touchEvent(vt)
        }
        
        // 現在のページの描画
        _ = mPageManager!.draw()
        
        // マネージャに登録した描画オブジェクトをまとめて描画
        if UDrawManager.getInstance().draw() == true {
            //            redraw = true
        }

    }
    
}
