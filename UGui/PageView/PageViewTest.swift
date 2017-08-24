//
//  PageViewTop.swift
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


public class PageViewTest : UPageView, UButtonCallbacks {

    
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTop"
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
    public override init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, title: title)
        
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
            let textButton = UButtonText(
                callbacks: self, type: UButtonType.BGColor, id: button.id,
                priority: 100, text: button.name, createNode: true,
                x: x, y: y,
                width: 200.0, height: 50.0, fontSize: UDpi.toPixel(20),
                textColor: UColor.White, bgColor: .blue)
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
        case PageViewTest.buttonId1:
            // ページ切り替え
            _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdTest1.Test1.rawValue)
            
        case PageViewTest.buttonId1:
            // ページ切り替え
            _ = PageViewManagerTest1.getInstance().stackPage(pageId: PageIdTest1.Test2.rawValue)
        case PageViewTest.buttonId3:
            // ページ切り替え
            _ = PageViewManagerTest1.getInstance().stackPage(pageId: PageIdTest1.Test3.rawValue)
        case PageViewTest.buttonId4:
            // ページ切り替え
            _ = PageViewManagerTest1.getInstance().stackPage(pageId: PageIdTest1.Test4.rawValue)
        case PageViewTest.buttonId5:
            // ページ切り替え
            _ = PageViewManagerTest1.getInstance().stackPage(pageId: PageIdTest1.Test5.rawValue)
        case PageViewTest.buttonId6:
            // ページ切り替え
            _ = PageViewManagerTest1.getInstance().stackPage(pageId: PageIdTest1.Test6.rawValue)
        default:
            break
        }
        return true
    }
}
