//
//  PageViewTest3.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/15.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class PageViewTest3 : UPageView, UButtonCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTest3"
    
    public static let buttonId1 = 100
    public static let buttonId2 = 101
    public static let buttonId3 = 102
    public static let buttonId4 = 103
    
    /**
     * Propaties
     */
    private var logWindow : ULogWindow? = nil
    
    
    /**
     * Constructor
     */
    public override init( topView : TopView, title : String) {
        super.init( topView: topView, title: title)
    }
    
    /**
     * Methods
     */
    
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide();
    }
    
    /**
     * 描画処理
     * サブクラスのdrawでこのメソッドを最初に呼び出す
     * @param canvas
     * @param paint
     * @return
     */
    override func draw() -> Bool {
        if isFirst {
            isFirst = false
            initDrawables()
        }
        return false
    }
    
    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent(vt : ViewTouch) -> Bool {
        
        return false
    }
    
    /**
     * そのページで表示される描画オブジェクトを初期化する
     */
    override public func initDrawables() {
        UDrawManager.getInstance().initialize()
        
        let x : CGFloat = 50.0
        var y : CGFloat = 50.0
        let buttonW : CGFloat = 200.0
        let buttonH : CGFloat = 50.0
        
        // UButtonText
        let textButton = UButtonText(callbacks: self, type: UButtonType.Press, id: PageViewTest3.buttonId1, priority: 100, text: "button1", x: x, y: y, width: buttonW, height: buttonH, textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        textButton.addToDrawManager()
        
        y += 70.0
        
        let textButton2 = UButtonText(callbacks: self, type: UButtonType.Press2, id: PageViewTest3.buttonId2, priority: 100, text: "button2", x: x, y: y, width: buttonW, height: buttonH, textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        textButton2.addToDrawManager()
        
        y += 70.0
        
        // ULogWindow
        // 自動で描画リストに追加される
        logWindow = ULogWindow.createInstance(
            parentView: mTopView!, type: LogWindowType.Fix,
            x: 0, y: y,
            width: CGFloat(UUtil.screenWidth()),
            height: CGFloat(UUtil.screenHeight()) - y - 40.0)
    }
    
    // ダイアログを表示する
    func showDialog() {
        let dialog = UPopupWindow(parentView: mTopView!,
                                  popupType: UPopupType.OKCancel,
                                  title: "hoge", isAnimation: true,
                                  screenW: CGFloat(UUtil.screenWidth()),
                                  screenH: CGFloat(UUtil.screenHeight()))
        dialog.addToDrawManager()
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }
    
    /**
     * Callbacks
     */
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        switch(id) {
        case PageViewTest1.buttonId1:
            if logWindow != nil {
                logWindow!.addLog("button1 clicked")
            }
            break
        case PageViewTest1.buttonId2:
            if logWindow != nil {
                logWindow!.addLog("button2 clicked")
            }
            break
        default:
            break
        }
        return true
    }
}
