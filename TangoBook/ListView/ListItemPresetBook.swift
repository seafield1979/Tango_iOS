//
//  ListItemPresetBook.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

/**
 * Created by shutaro on 2016/12/18.
 * <p>
 * プリセット単語帳ListViewのアイテム
 * プリセット追加用のボタンが表示されている
 *
 */

public class ListItemPresetBook : UListItem, UButtonCallbacks {
    
    // MARK: Constants
    public static let ButtonIdAdd : Int = 100100
    private let ITEM_H : Int = 67
    private let MARGIN_H : Int = 17
    private let ICON_W : Int = 34

    private let TEXT_COLOR : UIColor = .black
    private let BG_COLOR : UIColor = .white

    private let STAR_ICON_W : Int = 34

    private let FRAME_WIDTH : Int = 2
    private let FRAME_COLOR : UIColor = .black

    // MARK: Properties
    // SpriteKit Node
    private var textNode : SKLabelNode?
    private var iconNode : SKSpriteNode?
    
    private var mBook : PresetBook?
    private var mAddButton : UButtonImage?

    // Dpi計算済み
    private var iconW : CGFloat, marginH : CGFloat

    // MARK: Accessor
    public func getBook() -> PresetBook? {
        return mBook
    }

    // MARK: Initializer
    public init( listItemCallbacks : UListItemCallbacks?,
                 book : PresetBook?, width : CGFloat)
    {
        mBook = book
        iconW = UDpi.toPixel(ICON_W)
        marginH = UDpi.toPixel(MARGIN_H)

        super.init( callbacks : listItemCallbacks, isTouchable : true,
                    x : 0, width : width, height : UDpi.toPixel(ITEM_H),
                    bgColor : BG_COLOR, frameW : UDpi.toPixel(FRAME_WIDTH),
                    frameColor : FRAME_COLOR)

        
        let starIconW : CGFloat = UDpi.toPixel(STAR_ICON_W)
        // Add Button
        let image : UIImage? = UResourceManager.getImageWithColor( imageName: ImageName.add, color: UColor.Green)
        
        if image != nil {
            mAddButton = UButtonImage(
                callbacks : self, id : ListItemPresetBook.ButtonIdAdd, priority : 0,
                x : size.width - UDpi.toPixel(50), y : (size.height-starIconW) / 2,
                width : starIconW, height : starIconW, image : image!, pressedImage : nil)
            parentNode.addChild2( mAddButton!.parentNode )
        }
        
        mAddButton!.scaleRect(scaleH: 2.0, scaleV: 1.5)
        
        initSKNode()
    }
    
    /**
     * SpriteKitのノードを作成
     */
    public override func initSKNode() {
        var x : CGFloat = marginH
        
        // iconNode
        let image = UResourceManager.getImageWithColor( imageName: ImageName.cards, color: mBook!.mColor)
        iconNode = SKNodeUtil.createSpriteNode(image: image!, width: iconW, height: iconW, x: x, y: (size.height - iconW) / 2)
        parentNode.addChild2( iconNode! )
        
        x += iconW + marginH
        
        // textNode
        let text = mBook!.mName + "\n" + (mBook!.mComment ?? "")
        
        textNode = SKNodeUtil.createLabelNode(
            text: text, fontSize: UDraw.getFontSize(FontSize.M), color: TEXT_COLOR,
            alignment: UAlignment.CenterY,
            pos: CGPoint(x: x, y: size.height / 2)).node
        
        parentNode.addChild2( textNode! )
    }

    // MARK: Methods
    /**
     * 描画処理
     *
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        super.draw()
    }

    /**
     * 毎フレーム呼ばれる処理
     * @return
     */
    public override func doAction() -> DoActionRet{
        if mAddButton != nil  {
            return mAddButton!.doAction()
        }
        return DoActionRet.None
    }

    /**
     * @param vt
     * @return
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint? ) -> Bool {
        if mAddButton != nil {
            let offset2 = CGPoint(x: pos.x + offset!.x, y: pos.y + offset!.y)
            if mAddButton!.touchEvent(vt: vt, offset: offset2) {
                return true
            }
        }
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }
        return false
    }

    /**
     * 高さを返す
     */
    public override func getHeight() -> CGFloat{
        return size.height
    }


    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool{
        if mListItemCallbacks != nil {
            mListItemCallbacks!.ListItemButtonClicked(item: self, buttonId: id)
            return true
        }
        return false
    }
}
