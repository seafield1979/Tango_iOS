//
//  GameScene.swift
//  SK_UGui
//    SpriteKitのトップシーン
//    本アプリはこのシーンだけで全てのページの表示を行う
//  Created by Shusuke Unno on 2017/08/10.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class TopScene: SKScene {
    enum PoserSavingMode : Int {
        case None           // 省電力モードOFF
        case Mode1          // 第一段階 FPSを下げる
        case Mode2          // 第二段階 FPSを大幅に下げる
    }
    
    // MARK: Constants
    private let POWER_SAVING_TIME_1 : Double = 10.0     // 省電力モードに遷移するまでの時間
    private let POWER_SAVING_TIME_2 : Double = 60.0     // 超省電力モードに遷移するまでの時間
    private let DEFULT_FPS = 60                         // 通常時のFPS
    private let POWER_SAVING_FPS_1 = 8                 // 省電力時のFPS
    private let POWER_SAVING_FPS_2 = 2                  // 超省電力時のFPS
    
    // MARK: Properties
    private var mPageManager : UPageViewManager?
    public static var instance : TopScene?
    public var parentVC : UIViewController?
    public var parentView : SKView?
    var vt : ViewTouch = ViewTouch()
    
    private var mPowerSavingMode : PoserSavingMode = .None
    private var mLastTouchedTime : Double = 0       // 最後にタッチ処理を行った時間
    
    private var dimPanel : SKShapeNode?
    
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
        
        mLastTouchedTime = Date().timeIntervalSince1970
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if updateLastTouchedTime() {
            return
        }
        
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
        // 省電力モードに遷移するかチェック
        checkPowerSaving()
        
        // 省電力モード中は処理しない
        if mPowerSavingMode != .None {
            return
        }
        // 長押し判定
        if vt.checkLongTouch() {
            _ = UDrawManager.getInstance().touchEvent(vt)
        }
        
        // 現在のページの描画
        _ = mPageManager!.draw()
        
        // マネージャに登録した描画オブジェクトをまとめて描画
        if UDrawManager.getInstance().draw() == true {
        }
    }
    
    /**
     * タッチ処理が行われた時間を更新
     * return : 省電力モードが解除されたらtrueを返す(そのタッチを処理しない)
     */
    private func updateLastTouchedTime() -> Bool {
        mLastTouchedTime = Date().timeIntervalSince1970

        if mPowerSavingMode != .None {
            let mode = mPowerSavingMode
            // 省電力モードを解除
            setPowerSavingMode(mode: .None)

            // モード２の場合のみタッチを無効化
            if mode == .Mode2 {
                return true
            }
        }
        return false
    }
    
    /**
     * 省電力モード遷移チェック
     * 一定時間タッチ処理が行われなかった場合、自動で省電力モードに遷移する
     *
     *   ※SpriteKitで60fpsで画面を更新し続けると電力をもりもり消費するので、操作していない時は省電力モードにする
     */
    private func checkPowerSaving() {
        switch mPowerSavingMode {
        case .None:
            // 最後のタッチからの時間を取得
            if Date().timeIntervalSince1970 - mLastTouchedTime >= POWER_SAVING_TIME_1 {
                // 省電力モードに遷移
                setPowerSavingMode(mode: .Mode1)
            }
        case .Mode1:
            if Date().timeIntervalSince1970 - mLastTouchedTime >= POWER_SAVING_TIME_2 {
                // 超消費電力モードに遷移
                setPowerSavingMode(mode: .Mode2)
            }
        default:
            break
        }
    }
    
    /**
     * 外から省電力モードをOFFにする
     */
    public func resetPowerSavingMode() {
        setPowerSavingMode(mode: .None)
    }
   
    /**
     * 省電力モード遷移(ON / OFF)
     */
    private func setPowerSavingMode( mode : PoserSavingMode ) {
        mPowerSavingMode = mode

        switch mode {
        case .None:
            //parentView!.preferredFramesPerSecond = DEFULT_FPS
            parentView!.isPaused = false
            
            if let n = dimPanel {
                n.removeFromParent()
                dimPanel = nil
            }
            mLastTouchedTime = Date().timeIntervalSince1970
        case .Mode1:
            // FPSを低下させる
            parentView!.isPaused = true
            
        case .Mode2:
            parentView!.isPaused = true
            
            // 画面を暗くする
            dimPanel = SKShapeNode(rect: CGRect(x:0, y:0, width: self.frame.size.width, height: self.frame.size.height).convToSK())
            dimPanel!.alpha = 0.6
            dimPanel!.zPosition = 10000
            dimPanel!.fillColor = .black
            self.addChild2(dimPanel!)
        }
    }
}
