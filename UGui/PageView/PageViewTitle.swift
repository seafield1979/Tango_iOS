//
//  PageViewTitle.swift
//  UGui
//  アプリ起動時に表示されるページ
//
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit


/**
 * Created by shutaro on 2016/12/15.
 *
 * Debug page
 */
/**
 * Struct
 */
public struct ButtonInfo {
    var id : Int
    var name : String
}


public class PageViewTitle : UPageView, UButtonCallbacks {

    
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTitle"
    private var buttonInfo : [ButtonInfo] = []
    public static let buttonId1 = 100
    public static let buttonId2 = 101
    public static let buttonId3 = 102
    public static let buttonId4 = 103
    public static let buttonId5 = 104
    public static let buttonId6 = 105
    
    /**
     * Member variables
     */
    
    
    /**
     * Constructor
     */
    public override init( topView : TopView, title : String) {
        super.init( topView: topView, title: title)
        
        buttonInfo.append(ButtonInfo(id: 100, name: "ボタン"))
        buttonInfo.append(ButtonInfo(id: 101, name: "ダイアログ"))
        buttonInfo.append(ButtonInfo(id: 102, name: "Logwindow"))
        buttonInfo.append(ButtonInfo(id: 103, name: "メニューバー"))
        buttonInfo.append(ButtonInfo(id: 104, name: "リストView"))
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
        
        let x : CGFloat = 100.0
        var y : CGFloat = 100.0
        
        for button in buttonInfo {
            let textButton = UButtonText(callbacks: self, type: UButtonType.BGColor, id: button.id, priority: 100, text: button.name,
                                         x: x, y: y,
                                         width: 200.0, height: 50.0, textSize: 20,
                                         textColor: UColor.White, color: UColor.Blue)
            textButton.addToDrawManager()
            
            y += 60.0
        }
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
        case PageViewTitle.buttonId1:
            // ページ切り替え
            _ = PageViewManager.getInstance().stackPage(pageId: PageView.Test1)
            
        case PageViewTitle.buttonId2:
            // ページ切り替え
            _ = PageViewManager.getInstance().stackPage(pageId: PageView.Test2)
        case PageViewTitle.buttonId3:
            // ページ切り替え
            _ = PageViewManager.getInstance().stackPage(pageId: PageView.Test3)
        case PageViewTitle.buttonId4:
            // ページ切り替え
            _ = PageViewManager.getInstance().stackPage(pageId: PageView.Test4)
        case PageViewTitle.buttonId5:
            // ページ切り替え
            _ = PageViewManager.getInstance().stackPage(pageId: PageView.Test5)
        case PageViewTitle.buttonId6:
            // ページ切り替え
            _ = PageViewManager.getInstance().stackPage(pageId: PageView.Test6)
        default:
            break
        }
        return true
    }
}
