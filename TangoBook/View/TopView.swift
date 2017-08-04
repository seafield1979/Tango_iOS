//
//  TopView.swift
//  UGui
//    各ViewControllerで表示するView
//    TopViewクラスは抽象クラスなのでこのクラスを継承したサブクラスを使用すること。
//  Created by Shusuke Unno on 2017/07/06.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class TopView : UIView, UButtonCallbacks{
    
    // Consts
    public static let drawInterval : TimeInterval = 1.0 / 60.0
    
    // Propaties
    var vt : ViewTouch = ViewTouch()
    var subView : UIView? = nil
    var timer : Timer? = nil
    public var redraw : Bool = false
    var parentVC : UIViewController? = nil
    
    // long press
    var longPressBeginTime: TimeInterval = 0.2
    var lpGesture: UILongPressGestureRecognizer? = nil
    
    // Get/Set
    public func getWidth() -> CGFloat {
        return self.frame.size.width
    }
    
    public func getHeight() -> CGFloat {
        return self.frame.size.height
    }
    
    
    // View毎の個別のページマネージャー。サブクラスで生成する
    var mPageManager : UPageViewManager? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        // タッチ操作を許可する
        self.isUserInteractionEnabled = true
        
        // 背景色を設定
        self.backgroundColor = UIColor.white
        
        // ページマネージャーを初期化
        UDrawManager.getInstance().initialize()
        
        // DPI初期化
        UDpi.initialize()
        
        // タイマー
        // 画面更新用
        if timer == nil {
            // 0.3s 毎にTemporalEventを呼び出す
            timer = Timer.scheduledTimer(timeInterval: TopView.drawInterval, target: self, selector:#selector(TopView.TemporalEvent), userInfo: nil,repeats: true)
        }
        
        // 長押し判定用
        lpGesture = UILongPressGestureRecognizer(target: self,
                                               action: #selector(TopView.longPressed))
        
        lpGesture?.minimumPressDuration = 0.6
        self.addGestureRecognizer(lpGesture!)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setViewController(_ parentVC: UIViewController) {
        self.parentVC = parentVC
        
        mPageManager!.mParentVC = parentVC
    }
    
    /**
     描画処理
     - parameter rect: 再描画領域の矩形
     - throws: none
     - returns: none
     */
    override public func draw(_ rect: CGRect) {
        // 現在のページの描画
        if (mPageManager!.draw()) {
            redraw = true
        }
        
        // マネージャに登録した描画オブジェクトをまとめて描画
        if UDrawManager.getInstance().draw() == true {
            redraw = true
        }
//        clearMask()
    }
    
    
    /**
     タッチ開始 このViewをタッチしたときの処理
     - parameter touches: タッチ情報
     - parameter event:
     - throws: none
     - returns: none
     */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // タッチイベントを取得する
        let touch = touches.first
        if touch == nil {
            return
        }
        _ = vt.checkTouchType(e: TouchEventType.Down,
                          touch: touch!, view: self)
        
        // 描画オブジェクトのタッチ処理はすべてUDrawManagerにまかせる
        if UDrawManager.getInstance().touchEvent(vt) {
            invalidate()
        }
    }
    
    /**
     タッチ中の移動
     - parameter touches: タッチ情報
     - throws: none
     - returns: none
     */
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // タッチイベントを取得する
        let touch = touches.first
        if touch == nil {
            return
        }
        _ = vt.checkTouchType(e: TouchEventType.Move,
                              touch: touch!, view: self)
        
        
        // 描画オブジェクトのタッチ処理はすべてUDrawManagerにまかせる
        if UDrawManager.getInstance().touchEvent(vt) {
            invalidate()
        }
    }
    
    /**
     タッチ終了 Viewからタッチを離したときの処理
     - parameter touches: タッチ情報
     - parameter event:
     - throws: none
     - returns: none
     */
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // タッチイベントを取得する
        let touch = touches.first
        if touch == nil {
            return
        }
        _ = vt.checkTouchType(e: TouchEventType.Up,
                              touch: touch!, view: self)
        
        // 描画オブジェクトのタッチ処理はすべてUDrawManagerにまかせる
        if UDrawManager.getInstance().touchEvent(vt) {
            invalidate()
        }
    }
    
    /**
     タッチが外部からキャンセルされたときの処理
     - parameter touched: タッチ情報
     - throws: none
     - returns: none
     */
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // タッチイベントを取得する
        let touch = touches.first
        if touch == nil {
            return
        }
        _ = vt.checkTouchType(e: TouchEventType.Cancel,
                              touch: touch!, view: self)
        
    }

    /**
        UButtonCallbacks
     */
    /**
     * ボタンがクリックされた時の処理
     * @param id  button id
     * @param pressedOn  押された状態かどうか(On/Off)
     * @return
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch id {
        case 100:
            print("button is clicked")
        default:
            break
        }
        return true
    }
    
    func invalidate() {
        // 再描画
        self.setNeedsDisplay()
    }
    
    
    //一定タイミングで繰り返し呼び出される関数
    func TemporalEvent(){
        //画面再描画用
        // ※ drawメソッド内でinvalidateをかけても再描画されない
        if redraw {
            redraw = false
            invalidate()
        }
    }
    
    func stopTimer(){
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    /**
     長押しされたときの処理
     */
    func longPressed(longPress: UIGestureRecognizer)
    {
        if (longPress.state == UIGestureRecognizerState.ended)
        {
            // 長押しが完了（指を離した）
            let gestureTime = NSDate.timeIntervalSinceReferenceDate -
                longPressBeginTime + lpGesture!.minimumPressDuration
            print("Gesture time = \(gestureTime)")
//            _ = vt.checkTouchType(e: .Up, touch: nil, view: self)
        }
        else if (lpGesture!.state == UIGestureRecognizerState.began)
        {
            print("長押し開始")
            // 長押し開始
            _ = vt.checkTouchType(e: .LongPress, touch: nil, view: self)
            
            longPressBeginTime = NSDate.timeIntervalSinceReferenceDate
            
            // 描画オブジェクトのタッチ処理はすべてUDrawManagerにまかせる
            if UDrawManager.getInstance().touchEvent(vt) {
                invalidate()
            }
        }
    }

}
