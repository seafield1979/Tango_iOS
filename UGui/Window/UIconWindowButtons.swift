//
//  UIconWindowButtons.swift
//  TangoBook
//    UIconWindowSubの下部に表示するボタン
//  Created by Shusuke Unno on 2017/08/22.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

class UIconWindowButtons : UDrawable {
    // MARK: Consts
    private let MARGIN_H = 15
    private let MARGIN_V = 10
    private let ACTION_ICON_W = 34
    private let ICON_FONT_SIZE = 14

    private let BG_COLOR = UColor.LightYellow

    // MARK: Properties
    var bgNode : SKShapeNode?
    var buttonCallbacks : UButtonCallbacks
    private var mButtons : [UButtonImage] = []
    private var topX : CGFloat = 0
    
    // MARK: Initializer
    /**
     * Initializer
     */
    public init(callbacks : UButtonCallbacks, priority: Int, x: CGFloat, y: CGFloat)
    {
        topX = UDpi.toPixel(MARGIN_H)
        buttonCallbacks = callbacks
        
        super.init( priority: priority, x: x, y: y, width: 0, height: 0)
    }
    
    
    // MARK: Methods
    
    /**
     * アクションボタンを追加する
     */
    public func addButton(id : SubWindowActionId) {
        let info = UIconWindowSub.getActionInfo(id: id)
        let button = createActionButton(info: info, x: topX, y: UDpi.toPixel(MARGIN_V))
        mButtons.append(button)
        
        topX += UDpi.toPixel(ACTION_ICON_W + MARGIN_H)
    }
    
    public override func initSKNode() {
        size = CGSize(width: topX, height: UDpi.toPixel(MARGIN_V * 2 + ACTION_ICON_W + UButtonImage.FONT_SIZE))
        
        // bgNode
        bgNode = SKNodeUtil.createRectNode(
            rect: CGRect(x:0, y:0, width: size.width, height: size.height),
            color: BG_COLOR, pos: pos, cornerR: UDpi.toPixel(10))
        
        parentNode.addChild2( bgNode! )
        
        // buttons
        for button in mButtons {
            bgNode!.addChild2( button.parentNode )
        }
    }
    
    /**
     ウィンドウの下に表示するアクションボタンを生成する
     */
    func createActionButton(info : UIconWindowSub.ActionInfo, x: CGFloat, y: CGFloat) -> UButtonImage {
        let image = UResourceManager.getImageWithColor(imageName: info.imageName, color: info.color)!
        
        let button = UButtonImage(
            callbacks: buttonCallbacks,
            id: info.buttonId, priority: DrawPriority.SubWindowIcon.rawValue, x: x, y: y,
            width: UDpi.toPixel(ACTION_ICON_W),
            height: UDpi.toPixel(ACTION_ICON_W),
            image: image,
            pressedImage: nil)
        
        button.addTitle(title: info.title, fontSize: UDpi.toPixel(ICON_FONT_SIZE), alignment: .CenterX,
                        x: button.size.width / 2,
                        y: button.size.height + UDpi.toPixel(4), color: .black, bgColor: nil)
        return button
    }
    
    
    // MARK: UDrawable
    
    public override func doAction() -> DoActionRet {
        var ret : DoActionRet = .None

        for button in mButtons {
            ret = button.doAction()
            if ret == .Done {
                return ret
            }
        }
        return ret
    }
    
    /**
     * 描画前の処理
     */
    public override func draw() {
        if !(isShow && !isMoving) {
            return
        }
        for button in mButtons {
            button.draw()
        }
    }

    /**
     * タッチ処理
     * @param vt
     * @return trueならViewを再描画
     */
    override public func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        for button in mButtons {
            if button.touchEvent(vt: vt, offset: offset) {
                return true
            }
        }
        return false
    }
}
