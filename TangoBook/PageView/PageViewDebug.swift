//
//  PageViewBackup.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/24.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class PageViewDebug : UPageView, UButtonCallbacks {
    /**
     * Enums
     */
    // MARK: Constants
    public static let TAG = "PageViewDebug"
    
    private let MARGIN_V : Int = 20
    
    // button id
    private let buttonId1 = 100
    private let buttonId2 = 101
    private let DRAW_PRIORITY = 100
    
    // MARK: Properties
    private var mButton1 : UButtonText?
    private var mButton2 : UButtonText?
    
    // MARK: Initializer
    public init( topScene : TopScene, title : String) {
        super.init( topScene: topScene, pageId: PageIdMain.Debug.rawValue, title: title)
    }
    
    deinit {
        print("PageViewDebug.denint")
        mButton1 = nil
        mButton2 = nil
    }
    
    // MARK: Methods
    override func onShow() {
    }
    
    override func onHide() {
        super.onHide();
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
        
        var y : CGFloat = 50
        
        // 描画オブジェクトクリア
        UDrawManager.getInstance().initialize()
        
        // ここにページで表示するオブジェクト生成処理を記述
        let width = self.mTopScene.getWidth()
        
        mButton1 = UButtonText(
            callbacks: self, type: UButtonType.Press,
            id: buttonId1, priority: DRAW_PRIORITY,
            text: "データベース", createNode: true, x: 50, y: y,
            width: width - 100, height: 100,
            fontSize: UDpi.toPixel(20), textColor: UIColor.white, bgColor: .blue)
        mButton1!.addToDrawManager()
        
        y += mButton1!.size.height + UDpi.toPixel(MARGIN_V)
        
        mButton2 = UButtonText(
            callbacks: self, type: UButtonType.Press,
            id: buttonId2, priority: DRAW_PRIORITY,
            text: "UToast", createNode: true, x: 50, y: y,
            width: width - 100, height: 100,
            fontSize: UDpi.toPixel(20), textColor: UIColor.white, bgColor: .blue)
        mButton2!.addToDrawManager()
        
        y += mButton2!.size.height + UDpi.toPixel(MARGIN_V)
    }
    
    /**
     * ソフトウェアキーの戻るボタンを押したときの処理
     * @return
     */
    public override func onBackKeyDown() -> Bool {
        return false
    }
    
    // MARK: Callbacks
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
        switch id {
        case buttonId1:
            // データベースデバッグページに遷移
            _ = PageViewManagerMain.getInstance().stackPage(pageId: PageIdMain.DebugDB.rawValue)
        case buttonId2:
            // UToast
            UToast(x: mTopScene.getWidth() / 2, y: mTopScene.getHeight() / 2, text: "hello world\nhogehoge\nhogehoge", fontSize: UDpi.toPixel(20), alignment: .Center, duration: 2.0).show()
        default:
            break
        }
        return true
    }
}

