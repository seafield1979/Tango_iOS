//
//  UCheckBox.swift
//  TangoBook
//      チェックボックス
//      タップでON/OFFを切り替えられる
//      右側にテキストを表示できる
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public protocol UCheckBoxCallbacks : class {
    /**
     * チェックされた時のイベント
     */
    func UCheckBoxChanged(checked : Bool)
}

public class UCheckBox : UDrawable {

    // MARK: Constants
    public static let TAG = "UCheckBox"

    private let MARGIN_H : Int = 14
    private let COLLISION_MARGIN : Int = 10
    private let COLOR_BOX : UIColor = UColor.LightBlue

    // MARK: Properties
    // SpriteKit Node
    private var frameNode : SKShapeNode?
    private var checkedNode : SKSpriteNode?
    private var labelNode : SKLabelNode?
    
    private weak var mCheckBoxCallbacks : UCheckBoxCallbacks?
    public var isChecked : Bool = false
    private var mBoxWidth : CGFloat
    private var mText : String?
    private var mFontSize : CGFloat
    private var mFontColor : UIColor

    // MARK: Accessor

    // MARK: Initializer
    public init(callbacks : UCheckBoxCallbacks, drawPriority : Int,
                x : CGFloat, y : CGFloat,
                boxWidth : CGFloat, text : String, fontSize : CGFloat, fontColor : UIColor)
    {
        mCheckBoxCallbacks = callbacks
        mBoxWidth = boxWidth
        mText = text
        mFontSize = fontSize
        mFontColor = fontColor

        super.init(priority: drawPriority, x: x, y: y, width: 0, height: 0)
        
        // 描画サイズを計算する
        size.width = boxWidth
        size.height = boxWidth
        
        initSKNode()
    }
    
    public override func initSKNode() {
        // check box frame
        frameNode = SKNodeUtil.createRectNode(rect: CGRect(x:0, y:0, width: mBoxWidth, height: mBoxWidth), color: COLOR_BOX, pos: CGPoint(), cornerR: UDpi.toPixel(3))
        parentNode.addChild2( frameNode! )
        
        // check box
        checkedNode = SKNodeUtil.createSpriteNode( imageNamed: ImageName.checked2, width: mBoxWidth, height: mBoxWidth)
        checkedNode!.isHidden = false
        parentNode.addChild2( checkedNode! )
        
        // text
        if mText != nil {
            labelNode = SKNodeUtil.createLabelNode(text: mText!, fontSize: mFontSize, color: mFontColor, alignment: .CenterY, pos: CGPoint(x: mBoxWidth + UDpi.toPixel(MARGIN_H), y: mBoxWidth / 2)).node
            
            parentNode.addChild2( labelNode! )
        }
        
        self.size = CGSize(width: mBoxWidth + UDpi.toPixel(MARGIN_H) + labelNode!.frame.size.width, height: mBoxWidth)
    }

    /**
     * Methods
     */
    public override func draw() {
        if isChecked {
            frameNode!.isHidden = true
            checkedNode!.isHidden = false
        } else {
            frameNode!.isHidden = false
            checkedNode!.isHidden = true
        }
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool
    {
        var offset = offset
        if offset == nil {
            offset = CGPoint()
        }
        // チェック判定
        // 当たりは実際の見た目より大きく判定する
        // CheckBox部分をクリックしたらチェック状態が変わる
        if vt.type == TouchType.Click {
            let margin = UDpi.toPixel(COLLISION_MARGIN)
            let rect = CGRect( x: pos.x - margin, y: pos.y - margin,
                               width: pos.x + size.width + margin,
                               height: pos.y + mBoxWidth + margin)
            if rect.contains(x: vt.touchX(offset: offset!.x), y: vt.touchY(offset: offset!.y))
            {
                isChecked = !isChecked
                if mCheckBoxCallbacks != nil {
                    mCheckBoxCallbacks!.UCheckBoxChanged(checked: isChecked)
                }
                return true
            }
        }
        return false
    }
}

