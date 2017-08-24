//
//  PageViewTemplate.swift
//  UGui
//    PageViewのテンプレート
//    新しいページはこれをベースに作成する
//  Created by Shusuke Unno on 2017/07/17.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import UIKit

public class PageViewTemplate : UPageView, UButtonCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTemplate"
    
    // button id
    private static let buttonId1 = 100
    
    private static let DRAW_PRIORITY = 100
    
    /**
     * Propaties
     */
    
    /**
     * Constructor
     */
    public override init( topScene: TopScene, title : String) {
        super.init( topScene: topScene, title: title)
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
        // 描画オブジェクトクリア
        UDrawManager.getInstance().initialize()

        // ここにページで表示するオブジェクト生成処理を記述
        let width = self.mTopScene.getWidth()
        
        let button = UButtonText(
            callbacks: self, type: UButtonType.Press,
            id: PageViewTemplate.buttonId1, priority: PageViewTemplate.DRAW_PRIORITY,
            text: "test", createNode: true, x: 50, y: 100,
            width: width - 100, height: 100,
            fontSize: UDpi.toPixel(20), textColor: UIColor.white, bgColor: .blue)
        button.addToDrawManager()

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
    /**
     * ボタンがクリックされた時の処理
     * @param id  button id
     * @param pressedOn  押された状態かどうか(On/Off)
     * @return
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool
    {
        return true
    }
}
