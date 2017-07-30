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
    private let ICON_TEXT_SIZE = 10
    
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
    public init(parentView : TopView,
                iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
                windowCallbacks : UWindowCallbacks?,
                icon : UIcon,
                x : CGFloat, y : CGFloat,
                color : UIColor?)
    {
        super.init( parentView : parentView,
                    iconInfoCallbacks: iconInfoDialogCallbacks,
                    windowCallbacks : windowCallbacks,
                    icon : icon, x: x, y: y, color: color)
    }

    /**
     * createInstance
     */
    public static func createInstance(
        parentView : TopView,
        iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
        windowCallbacks : UWindowCallbacks?,
        icon : UIcon,
        x : CGFloat, y : CGFloat) -> IconInfoDialogInTrash
    {
        let instance = IconInfoDialogInTrash(
            parentView: parentView,
            iconInfoDialogCallbacks: iconInfoDialogCallbacks,
            windowCallbacks : windowCallbacks, icon : icon,
            x: x, y: y, color: BG_COLOR)
        
        // 初期化処理
        instance.addCloseIcon(pos: CloseIconPos.RightTop);
        
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
            
            // 閉じるボタンの再配置
            updateCloseIconPos()
        }
        
        // BG
        UDraw.drawRoundRectFill( rect: getRect(), cornerR: UDpi.toPixel(7),
                                 color: bgColor!,
                                 strokeWidth: UDpi.toPixel(FRAME_WIDTH),
                                 strokeColor: FRAME_COLOR)
        
        if (textTitle != nil) {
            textTitle!.draw(pos)
        }
        if (textCount != nil) {
            textCount!.draw(pos)
        }
        
        // Buttons
        for button in imageButtons {
            button!.draw(pos)
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
        
        // Action buttons
        var x = iconMargin
        for icon in icons {
            let image = UResourceManager.getImageWithColor(
                imageName: icon!.imageName, color: UColor
                .DarkOrange)
            
            let imageButton = UButtonImage.createButton(
                callbacks: self,
                id: icon!.id.rawValue, priority: 0,
                x: x, y: y,
                width: iconW, height: iconW,
                image: image, pressedImage: nil)
            
            // アイコンの下に表示するテキストを設定
            imageButton.setTitle(
                title: UResourceManager.getStringByName(icon!.titleName),
                size: Int(UDpi.toPixel(ICON_TEXT_SIZE)),
                color: UIColor.black)
            
            imageButtons.append(imageButton)
            ULog.showRect(rect: imageButton.getRect())
            
            x += iconW + iconMargin;
        }
        y += iconW + UDpi.toPixel(MARGIN_V + 17);
        
        // Title
        textTitle = UTextView.createInstance(
            text: mIcon.getTitle()!, textSize: Int(textSize), priority: 0,
            alignment: UAlignment.None,
            multiLine: false, isDrawBG: true,
            x: marginH, y: y,
            width: width - marginH * 2, color: TEXT_COLOR, bgColor: TEXT_BG_COLOR)
        
        y += UDpi.toPixel(TEXT_VIEW_H) + marginV;
        
        // テキストの幅に合わせてダイアログのサイズ更新
        var textSize2 : CGSize = UDraw.getTextSize( text: mIcon.getTitle()!, textSize: Int(textSize))
        if textSize2.width + marginH * 4 > width {
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
                alignment: UAlignment.None,
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
        
        setSize(width, y);
        
        // Correct position
        if ( pos.x + size.width > parentView.getWidth() - dlgMargin) {
            pos.x = parentView.getWidth() - size.width - dlgMargin
        }
        if (pos.y + size.height > parentView.getHeight() - dlgMargin) {
            pos.y = parentView.getHeight() - size.height - dlgMargin
        }
        updateRect()
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
