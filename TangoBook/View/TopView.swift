//
//  TopView.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/06.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class TopView : UIView, UButtonCallbacks{
    
    // Consts
    public static let drawInterval : TimeInterval = 1.0 / 30.0
    
    // Propaties
    var vt : ViewTouch = ViewTouch()
    var subView : UIView? = nil
    var timer : Timer? = nil
    public var redraw : Bool = false
    var parentVC : UIViewController? = nil
    
    private var mPageManager : UPageViewManager? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        // タッチ操作を許可する
        self.isUserInteractionEnabled = true
        
        // 背景色を設定
        self.backgroundColor = UIColor(red:0.5, green:0.5, blue:0.5, alpha:1.0)
        
        // ページマネージャーを初期化
        UDrawManager.getInstance().initialize()
        mPageManager = PageViewManager.createInstance(topView: self)
        
        // DPI初期化
        UDpi.initialize()
        
        // タイマー
        // 画面更新用
        if timer == nil {
            // 0.3s 毎にTemporalEventを呼び出す
            timer = Timer.scheduledTimer(timeInterval: TopView.drawInterval, target: self, selector:#selector(TopView.TemporalEvent), userInfo: nil,repeats: true)
        }
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
        
        vt.touchStart(touch: touch!, view: self)
        
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
//        print("touchesMoved:");
        // タッチイベントを取得する
        let touch = touches.first
        
        vt.touchMove(touch: touch!, view: self)
        
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
        _ = vt.touchEnd(touch: touches.first!, view: self)
        
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
        print("touchesCancelled")
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
    
    func draw1() {
        let w : CGFloat = 100.0
        let h : CGFloat = 100.0
        var x : CGFloat = 10
        var y : CGFloat = 10
        let margin : CGFloat = 5
        
        // ライン描画
        UDraw.drawLine(x1: x, y1: y, x2: x + 50.0, y2: y + 50.0, lineWidth: 2, color: UIColor.black)
        
        y = 100
        
        // 矩形描画
        var rect = CGRect(x: x, y: y, width: w, height: h)
        UDraw.drawRect(rect: rect, width: 2, color: UIColor.black)
        
        x += w + margin
        // 角丸矩形描画
        rect = CGRect(x: x, y: y, width: w, height: h)
        UDraw.drawRoundRect(rect: rect, width: 2, radius: 10, color: UIColor.black)
        
        x += w + margin
        // 塗りつぶし矩形
        rect = CGRect(x: x, y: y, width: w, height: h)
        UDraw.drawRectFill(rect: rect, color: UIColor.orange)
        
        x = 10
        y += h + margin
        // 塗りつぶし＆枠
        rect = CGRect(x: x, y: y, width: w, height: h)
        UDraw.drawRectFill(rect: rect, color: UIColor.orange, strokeWidth: 4.0, strokeColor: UIColor.black)
        
        x += w + margin
        // 塗りつぶし＆角丸＆枠
        rect = CGRect(x: x, y: y, width: w, height: h)
        UDraw.drawRoundRectFill(rect: rect, cornerR: 10.0, color: UIColor.orange, strokeWidth: 4.0, strokeColor: UIColor.black)
        
        x += w + margin
        // 円（線）
        let radius : CGFloat = w / 2
        UDraw.drawCircle(center: CGPoint(x:x + radius, y:y + radius), radius: radius, lineWidth: 4, color: UIColor.blue)
        
        // 円(塗りつぶし)
        x = 10
        y += h + margin
        UDraw.drawCircleFill(center: CGPoint(x:x + radius, y: y + radius), radius: radius, color: UIColor.orange)
        
        // 三角形（線）
        x += w + margin
        UDraw.drawTriangle(center: CGPoint(x: x + radius, y: y + radius), radius: radius, rotation: 90, lineWidth: 4.0, color: UIColor.black)
        
        // 三角形（塗りつぶし）
        x += w + margin
        UDraw.drawTriangleFill(center: CGPoint(x: x + radius, y: y + radius), radius: radius, rotation: 0, color: UIColor.orange)
        
    }
    
    /**
     テキストの描画テスト
     */
    func draw2() {
        let x : CGFloat = 150
        var y : CGFloat = 50
        let margin : CGFloat = 5
        
        UDraw.drawText(text: "hoge\nhoge", alignment: UAlignment.Center, textSize: 40, x: x, y: y, color: UIColor.black)
        UDraw.drawCheck(x: x, y: y, color: UIColor.red)
        
        y += 100
        UDraw.drawText(text: "hoge2", alignment: UAlignment.Left, textSize: 40, x: x, y: y, color: UIColor.black)
        UDraw.drawCheck(x: x, y: y, color: UIColor.red)
        
        y += 50 + margin
        UDraw.drawText(text: "hoge3", alignment: UAlignment.Right, textSize: 40, x: x, y: y, color: UIColor.black)
        UDraw.drawCheck(x: x, y: y, color: UIColor.red)
        
        y += 50 + margin
        UDraw.drawText(text: "hoge4", alignment: UAlignment.CenterX, textSize: 40, x: x, y: y, color: UIColor.black)
        UDraw.drawCheck(x: x, y: y, color: UIColor.red)
        
        y += 50 + margin
        UDraw.drawText(text: "hoge5", alignment: UAlignment.CenterY, textSize: 40, x: x, y: y, color: UIColor.black)
        UDraw.drawCheck(x: x, y: y, color: UIColor.red)
        
        y += 50 + margin
        UDraw.drawText(text: "hoge6", alignment: UAlignment.Right_CenterY, textSize: 40, x: x, y: y, color: UIColor.black)
        UDraw.drawCheck(x: x, y: y, color: UIColor.red)
    }
    
    /**
     画像描画のテスト
     */
    func draw3() {
        let image = UIImage(named: "image/ume.png")!
        
        // サイズを指定して描画
        UDraw.drawImage(image: image, x:50, y:50, width:100, height:100)
        
        // UIImageの元々のサイズで描画
        UDraw.drawImage(image: image, x: 50, y: 150)
        
    }
    
}
