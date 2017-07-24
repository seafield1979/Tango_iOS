//
//  PageViewTest6.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/17.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class PageViewTest6 : UPageView {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTest6"
    
    public static let buttonId1 = 100
    public static let buttonId2 = 101
    public static let buttonId3 = 102
    public static let buttonId4 = 103
    
    /**
     * Propaties
     */
    
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
        
    }
    
    // ダイアログを表示する
    func showDialog() {
        let dialog = UPopupWindow(parentView: mTopView!, popupType: UPopupType.OKCancel,
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
    
}
