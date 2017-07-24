//
//  PageViewTest2.swift
//  UGui
//  ダイアログのテスト用ページ
//  Created by Shusuke Unno on 2017/07/14.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class PageViewTest2 : UPageView, UButtonCallbacks, UDialogCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTest2"
    
    public static let buttonId1 = 100
    public static let buttonId2 = 101
    public static let buttonId3 = 102
    public static let buttonId4 = 103
    public static let buttonId5 = 105
    
    public static let MARGIN : CGFloat = 20.0

    /**
     * Member variables
     */
    private var buttonInfo : [ButtonInfo] = []
    
    /**
     * Constructor
     */
    public override init( topView : TopView, title : String) {
        super.init( topView: topView, title: title)
        
        buttonInfo.append(ButtonInfo(id: PageViewTest2.buttonId1, name: "ダイアログ1"))
        buttonInfo.append(ButtonInfo(id: PageViewTest2.buttonId2, name: "ダイアログ2"))
        buttonInfo.append(ButtonInfo(id: PageViewTest2.buttonId3, name: "ダイアログ3"))
        buttonInfo.append(ButtonInfo(id: PageViewTest2.buttonId4, name: "ダイアログ4"))
        buttonInfo.append(ButtonInfo(id: PageViewTest2.buttonId5, name: "ダイアログ5"))
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
        
        let x : CGFloat = PageViewTest1.MARGIN
        var y : CGFloat = UUtil.navigationBarHeight() + PageViewTest1.MARGIN
        
        for button in buttonInfo {
            let textButton = UButtonText(callbacks: self, type: UButtonType.BGColor, id: button.id, priority: 100, text: button.name,
                                         x: x, y: y,
                                         width: 200.0, height: 50.0, textSize: 20,
                                         textColor: UColor.White, color: UColor.Blue)
            textButton.addToDrawManager()
            
            y += 60.0
        }
    }
    
    //
    // ダイアログを表示する
    //
    
    // OK/Cancelを選択 モーダル
    func showDialog1() {
        let dialog = UPopupWindow(parentView : mTopView!,
                                  popupType: UPopupType.OKCancel,
                                  title: "hoge", isAnimation: true,
                                  screenW: CGFloat(UUtil.screenWidth()),
                                  screenH: CGFloat(UUtil.screenHeight()))
        dialog.addToDrawManager()
    }
    
    // OK/Cancelを選択
    func showDialog2() {
        let dialog = UDialogWindow.createInstance(
            parentView: mTopView!,
            buttonCallbacks: self, dialogCallbacks: nil,
            buttonDir: UDialogWindow.ButtonDir.Vertical,
            screenW: CGFloat(UUtil.screenWidth()), screenH: CGFloat(UUtil.screenHeight()))
        dialog.setTitle("ダイアログ")
        dialog.addTextView(text: "テキスト1", alignment: UAlignment.Center,
                           multiLine: true, isDrawBG: false, textSize: 20,
                           textColor: UIColor.green, bgColor: nil)
        dialog.addTextView(text: "テキスト2", alignment: UAlignment.Center,
                           multiLine: true, isDrawBG: false, textSize: 20,
                           textColor: UIColor.green, bgColor: nil)
        dialog.addCloseButton(text: "閉じる")
        dialog.addToDrawManager()
    }
    func showDialog3() {
        let dialog = UPopupWindow(parentView : mTopView!,
                                  popupType: UPopupType.OKCancel,
                                  title: "hoge", isAnimation: true,
                                  screenW: CGFloat(UUtil.screenWidth()),
                                  screenH: CGFloat(UUtil.screenHeight()))
        dialog.addToDrawManager()
    }
    func showDialog4() {
        let dialog = UPopupWindow(parentView : mTopView!,
                                  popupType: UPopupType.OKCancel,
                                  title: "hoge", isAnimation: true,
                                  screenW: CGFloat(UUtil.screenWidth()),
                                  screenH: CGFloat(UUtil.screenHeight()))
        dialog.addToDrawManager()
    }
    func showDialog5() {
        let dialog = UPopupWindow(parentView : mTopView!,
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
        case PageViewTest2.buttonId1:
            showDialog1()
            
        case PageViewTest2.buttonId2:
            showDialog2()
        case PageViewTest2.buttonId3:
            showDialog3()
        case PageViewTest2.buttonId4:
            showDialog4()
        case PageViewTest2.buttonId5:
            showDialog5()
        default:
            break
        }
        return true
    }
    
    /**
     * UDialogCallback
     */
    public func dialogClosed(dialog : UDialogWindow) {
        
    }
}
