//
//  PageViewTest1.swift
//  UGui
//  テストページ1
//      UButtonのサンプル
//  Created by Shusuke Unno on 2017/07/13.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation
import UIKit

public class PageViewTest1 : UPageView, UButtonCallbacks {
    /**
     * Enums
     */
    /**
     * Constants
     */
    public static let TAG = "PageViewTest1"
    
    public static let buttonId1 = 100
    public static let buttonId2 = 101
    public static let buttonId3 = 102
    public static let buttonId41 = 110
    public static let buttonId42 = 111
    public static let buttonId5 = 120
    public static let buttonId6 = 130
    
    public static let MARGIN : CGFloat = 20.0
    
    /**
     * Member variables
     */
    var pressedButton1 : UButtonText? = nil
    var pressedButton2 : UButtonText? = nil
    
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
        
        let x : CGFloat = PageViewTest1.MARGIN
        var y : CGFloat = UUtil.navigationBarHeight() + PageViewTest1.MARGIN
        let buttonW : CGFloat = CGFloat(UUtil.screenWidth()) - PageViewTest1.MARGIN * 2
        let buttonH : CGFloat = 50.0
        
        let colorButton = UButtonText(callbacks: self, type: UButtonType.BGColor, id: PageViewTest1.buttonId1, priority: 100, text: "button1", x: x, y: y, width: buttonW, height: buttonH, textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        colorButton.addToDrawManager()
        
        y += buttonH + PageViewTest1.MARGIN

        // UButtonText
        // Press 押したら凹むボタン
        let textButton = UButtonText(callbacks: self, type: UButtonType.Press, id: PageViewTest1.buttonId2, priority: 100, text: "button2", x: x, y: y, width: buttonW, height: buttonH, textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        textButton.addToDrawManager()
        
        y += buttonH + PageViewTest1.MARGIN

        // Press2 押すたびにON/OFFが切り替わるボタン
        let textButton2 = UButtonText(callbacks: self, type: UButtonType.Press2, id: PageViewTest1.buttonId3, priority: 100, text: "button3", x: x, y: y, width: buttonW, height: buttonH, textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        textButton2.addToDrawManager()

        y += buttonH + PageViewTest1.MARGIN
        
        // Press3 
        // 押されたら凹んで戻らないボタン。戻すには isPressed を falseに設定する
        pressedButton1 = UButtonText(callbacks: self, type: UButtonType.Press3, id: PageViewTest1.buttonId41, priority: 100, text: "button41", x: x, y: y, width: buttonW / 2, height: buttonH, textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        pressedButton1?.addToDrawManager()
        
        pressedButton2 = UButtonText(callbacks: self, type: UButtonType.Press3, id: PageViewTest1.buttonId42, priority: 100, text: "button42",
                                       x: x + buttonW / 2 + 10.0, y: y, width: buttonW / 2, height: buttonH, textSize: 20, textColor: UIColor.white, color: UIColor.blue)
        pressedButton2?.addToDrawManager()
        
        y += buttonH + PageViewTest1.MARGIN

        // 画像ボタン(ONとOFFで別の画像を設定している)
        let image1 = UResourceManager.getImageByName(ImageName.miro)
        let image2 = UResourceManager.getImageByName(ImageName.ume)
        let imageButton = UButtonImage.createButton(callbacks: nil, id: PageViewTest1.buttonId5, priority: 100, x: x, y: y, width: buttonW, height: buttonH, image: image1, pressedImage: image2)
        imageButton.addToDrawManager()
        
        y += buttonH + PageViewTest1.MARGIN
        
        // UButtonClose
        let closeButton = UButtonClose(callbacks: self, type: UButtonType.BGColor, id: PageViewTest1.buttonId6, priority: 100, x: x, y: y, color: UIColor.red)
        closeButton.addToDrawManager()
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
            print("button1 clicked")
        case PageViewTest1.buttonId2:
            print("button2 clicked")
        case PageViewTest1.buttonId3:
            print("button3 clicked")
        case PageViewTest1.buttonId41:
            pressedButton2?.setPressedOn(pressedOn: false)
        case PageViewTest1.buttonId42:
            pressedButton1?.setPressedOn(pressedOn: false)
            print("button4 clicked")
        case PageViewTest1.buttonId5:
            print("button4 clicked")
        case PageViewTest1.buttonId6:
            print("button4 clicked")
        default:
            break
        }
        return true
    }
}
