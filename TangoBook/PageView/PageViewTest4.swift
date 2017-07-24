//
//  PageViewTest4.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/17.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class PageViewTest4 : UPageView, UMenuItemCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTest4"
    
    /**
     * Propaties
     */
    var logWindow : ULogWindow? = nil
    var menuBar : MenuBarTest1? = nil
    
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
        
        // MenuBar
        menuBar = MenuBarTest1.createInstance(parentView: mTopView!, callbacks: self,
                                              parentW: mTopView!.frame.size.width,
                                              parentH: mTopView!.frame.size.height, bgColor: nil)
        
        // ULogWindow
        // 自動で描画リストに追加される
        logWindow = ULogWindow.createInstance(
            parentView: mTopView!, type: LogWindowType.Fix,
            x: 0, y: UUtil.navigationBarHeight(),
            width: CGFloat(UUtil.screenWidth()),
            height: CGFloat(UUtil.screenHeight()) / 2 - UUtil.navigationBarHeight())
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
     * UMenuBarCallbacks
     */
    // メニューの項目がクリックされたときのコールバック
    public func menuItemClicked(itemId : Int, stateId : Int) {
        switch itemId {
        case MenuBarTest1.MenuItemId.Debug1.rawValue:
            logWindow?.addLog("debug1 clicked")
        case MenuBarTest1.MenuItemId.Debug2.rawValue:
            logWindow?.addLog("debug2 clicked")
        case MenuBarTest1.MenuItemId.Debug3.rawValue:
            logWindow?.addLog("debug3 clicked")
        default:
            break
        }
    }
}
