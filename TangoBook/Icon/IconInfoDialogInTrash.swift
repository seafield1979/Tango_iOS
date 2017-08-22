//
//  IconInfoDialogInTrash.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/29.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/01.
 *
 * ゴミ箱の中のアイコンをクリックした際に表示されるダイアログ
 */

public class IconInfoDialogInTrash : IconInfoDialog {
    /**
     * Enums
     */
    
    
    /**
     * Consts
     */
    static let TAG = "IconInfoDialogBook"
    private static let BG_COLOR = UIColor.lightGray
//    private let TOP_ITEM_Y = 35
    private let TEXT_VIEW_H = 35
    private let ICON_W = 40
    private let ICON_MARGIN_H = 10
//    private let MARGIN_V = 13
//    private let MARGIN_H = 13
    private let TEXT_SIZE = 17
    private let ICON_TEXT_SIZE = 12
    
    private let TEXT_COLOR = UIColor.black
    private let TEXT_BG_COLOR = UIColor.white
    
    /**
     * Member Variables
     */
    var isUpdate : Bool = true     // ボタンを追加するなどしてレイアウトが変更された
    private var textTitle : UTextView? = nil
    private var textWord : UTextView? = nil
    private var textCount : UTextView? = nil
    private var imageButtons : List<UButtonImage> = List()

    /**
     * Get/Set
     */
    
    /**
     * Constructor
     */
    public init(topScene : TopScene,
                iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
                windowCallbacks : UWindowCallbacks?,
                icon : UIcon,
                x : CGFloat, y : CGFloat,
                color : UIColor?)
    {
        super.init( topScene : topScene,
                    iconInfoCallbacks: iconInfoDialogCallbacks,
                    windowCallbacks : windowCallbacks,
                    icon : icon, x: x, y: y, color: color)
    }

    /**
     * createInstance
     */
    public static func createInstance(
        topScene : TopScene,
        iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
        windowCallbacks : UWindowCallbacks?,
        icon : UIcon,
        x : CGFloat, y : CGFloat) -> IconInfoDialogInTrash
    {
        let instance = IconInfoDialogInTrash(
            topScene: topScene,
            iconInfoDialogCallbacks: iconInfoDialogCallbacks,
            windowCallbacks : windowCallbacks, icon : icon,
            x: x, y: y, color: BG_COLOR)
        
        // 初期化処理
        instance.addToDrawManager()
        
        return instance
    }

    /**
     * Methods
     */
    
    /**
     * Windowのコンテンツ部分を描画する
     * @param canvas
     * @param paint
     */
    public override func drawContent(offset : CGPoint?) {
        if isUpdate {
            isUpdate = false
            updateLayout()
        }
        
        // Buttons
        for button in imageButtons {
            button!.draw()
        }
    }

    /**
     * レイアウト更新
     * @param canvas
     */
    func updateLayout() {
        var y = UDpi.toPixel(TOP_ITEM_Y)
        let iconW = UDpi.toPixel(ICON_W)
        let iconMargin = UDpi.toPixel(ICON_MARGIN_H)
        let marginH = UDpi.toPixel(MARGIN_H)
        let marginV = UDpi.toPixel(MARGIN_V)
        let dlgMargin = UDpi.toPixel(DLG_MARGIN)
        let textSize = UDpi.toPixel(TEXT_SIZE)
        
        let icons : List<ActionIconInfo> = IconInfoDialog.getInTrashIcons()
        
        var width = iconW * CGFloat(icons.count) +
            iconMargin * CGFloat(icons.count + 1)
        
        // SpriteKitのノードを削除
        parentNode.removeAllChildren()
        
        // Title
        textTitle = UTextView.createInstance(
            text: mIcon.getTitle()!, textSize: Int(textSize), priority: 0,
            alignment: UAlignment.None, createNode: true,
            multiLine: false, isDrawBG: true,
            x: marginH, y: y,
            width: width - marginH * 2, color: TEXT_COLOR, bgColor: TEXT_BG_COLOR)
        
        y += UDpi.toPixel(TEXT_VIEW_H) + marginV;
        
        // テキストの幅に合わせてダイアログのサイズ更新
        var textSize2 : CGSize = UDraw.getTextSize( text: mIcon.getTitle()!, textSize: Int(textSize))

        if width < UDpi.toPixel(200) {
            width = UDpi.toPixel(200)
        }
        if width < textSize2.width + marginH * 4  {
            width = textSize2.width + marginH * 4
        }
        
        // Count(Bookの場合のみ)
        if mIcon.getType() == IconType.Book {
            let count = TangoItemPosDao.countInParentType(
                parentType: TangoParentType.Book,
                parentId: mIcon.getTangoItem()!.getId()
            )
            
            textCount = UTextView.createInstance(
                text: UResourceManager.getStringByName("book_count") + ":" + count.description,
                textSize: Int(textSize),
                priority: 0,
                alignment: UAlignment.None, createNode: true,
                multiLine: false,
                isDrawBG: true,
                x: marginH, y: y,
                width: width - marginH * 2,
                color: TEXT_COLOR, bgColor:TEXT_BG_COLOR)
            
            // テキストの幅に合わせてダイアログのサイズ更新
            textSize2 = UDraw.getTextSize(
                text: textCount!.getText(),
                textSize: Int(textSize))
            if textSize2.width + marginH * 4 > width {
                width = textSize2.width + marginH * 4
            }
            
            y += UDpi.toPixel(TEXT_VIEW_H) + marginV;
        }
        // Action buttons
        var x = iconMargin
        for icon in icons {
            let image = UResourceManager.getImageWithColor(
                imageName: icon!.imageName, color: UColor
                    .DarkOrange)
            
            let imageButton = UButtonImage(
                callbacks: self,
                id: icon!.id.rawValue, priority: 0,
                x: x, y: y,
                width: iconW, height: iconW,
                image: image!, pressedImage: nil)
            
            // アイコンの下に表示するテキストを設定
            imageButton.addTitle(
                title: UResourceManager.getStringByName(icon!.titleName),
                textSize: UDpi.toPixel(ICON_TEXT_SIZE),
                alignment: .CenterX,
                                 x: imageButton.size.width / 2,
                                 y: imageButton.size.height + UDpi.toPixel(4),
                                 color: .black, bgColor: nil)
            
            imageButtons.append(imageButton)
            ULog.showRect(rect: imageButton.getRect())
            
            x += iconW + iconMargin;
        }

        y += iconW + UDpi.toPixel(MARGIN_V + 17);
        
        setSize(width, y);
        
        // Correct position
        // ダイアログが画面外にはみ出さないように補正
        if ( pos.x + size.width > topScene.getWidth() - dlgMargin) {
            pos.x = topScene.getWidth() - size.width - dlgMargin
        }
        if (pos.y + size.height > topScene.getHeight() - dlgMargin) {
            pos.y = topScene.getHeight() - size.height - dlgMargin
        }
        updateRect()
        
        
        // SpriteKitノード作成
        // SpriteKitのノードを生成する
        updateWindow()
        initSKNode()
        parentNode.position.toSK()
        addCloseIcon(pos: CloseIconPos.RightTop)
        
        if textTitle != nil {
            clientNode.addChild2( textTitle!.parentNode )
        }
        
        if textWord != nil {
            clientNode.addChild2( textWord!.parentNode )
        }
        if textCount != nil {
            clientNode.addChild2( textCount!.parentNode )
        }
        
        for button in imageButtons {
            clientNode.addChild2( button!.parentNode )
        }
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        let offset = pos
        
        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }
        
        for button in imageButtons {
            if button!.touchEvent(vt: vt, offset: offset) {
                return true
            }
        }
        
        return false
    }

    public override func doAction() -> DoActionRet {
        var ret = DoActionRet.None
        for button in imageButtons {
            let _ret = button!.doAction()
            switch _ret{
            case .None:
                break
            case .Done:
                return DoActionRet.Done
            case .Redraw:
                ret = DoActionRet.Redraw
            }
        }
        return ret
    }

    /**
     * Callbacks
     */
    
    /**
     * UButtonCallbacks
     */
    public override func UButtonClicked(id : Int, pressedOn : Bool) -> Bool {
        if super.UButtonClicked(id: id, pressedOn: pressedOn) {
            return true
        }
        
        ULog.printMsg(IconInfoDialogInTrash.TAG, "UButtonCkick:" + id.description)
        switch ActionIconId.toEnum(id) {
        case .Return:
            mIconInfoCallbacks!.IconInfoReturnIcon(icon: mIcon)
            
        case .Delete:
            mIconInfoCallbacks!.IconInfoDeleteIcon(icon: mIcon)
        default:
            break
        }
        return false
    }
    
    public func UButtonLongClick(id : Int) -> Bool {
        return false
    }
    
}

