//
//  IconInfoDialogBook.swift
//  TangoBook
//    移植してみたはいいが、単語帳をタップした時に表示されるダイアログは実は使用しなくなった
//  Created by Shusuke Unno on 2017/07/29.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/11/30.
 *
 * Bookアイコンをクリックした際に表示されるダイアログ
 * Bookの情報(Name)とアクションアイコン(ActionIcons)を表示する
 */
public class IconInfoDialogBook : IconInfoDialog {
    /**
     * Enums
     */
    enum Items : Int, EnumEnumerable {
        case Name
        case Comment
        case Count
        case Date
    }

    /**
     * Consts
     */
    private let TAG = "IconInfoDialogBook";
    private let ICON_W = 40;
    private let ICON_MARGIN_H = 10;
    private let TEXT_SIZE = 17;
    private let TEXT_SIZE_S = 13;

    private let TEXT_COLOR = UIColor.black
    private let TEXT_BG_COLOR = UIColor.white

    /**
     * Member Variables
     */
    var isUpdate = true     // ボタンを追加するなどしてレイアウトが変更された
    private var textTitle : UTextView? = nil
    private var mItems : [IconInfoItem?] = Array(repeating: nil, count: Items.count)
    private var mBook : TangoBook? = nil
    private var imageButtons : List<UButtonImage> = List()

    /**
     * Get/Set
     */

    /**
     * Constructor
     */
    public init(topScene : TopScene,
                   iconInfoDialogCallbacks : IconInfoDialogCallbacks,
                   windowCallbacks : UWindowCallbacks,
                   icon : UIcon,
                   x : CGFloat, y : CGFloat,
                   color : UIColor?)
    {
        super.init( topScene : topScene,
                    iconInfoCallbacks : iconInfoDialogCallbacks,
                    windowCallbacks : windowCallbacks,
                    icon : icon, x : x, y : y,
                    color : color)
        if icon is IconBook {
            let bookIcon = icon as! IconBook
            mBook = bookIcon.book!
        }

        var color = color
        if color == nil {
            color = UIColor.lightGray
        }

        bgColor = UColor.setBrightness(argb: color!, brightness: 220.0 / 255.0)
        frameColor = UColor.setBrightness(argb: color!, brightness: 140.0 / 220.0)
    }

    /**
     * createInstance
     */
    public static func createInstance(
        topScene : TopScene,
        iconInfoDialogCallbacks : IconInfoDialogCallbacks,
        windowCallbacks : UWindowCallbacks,
        icon : UIcon,
        x : CGFloat, y : CGFloat) -> IconInfoDialogBook
    {
        let instance = IconInfoDialogBook(
            topScene : topScene,
            iconInfoDialogCallbacks : iconInfoDialogCallbacks,
            windowCallbacks : windowCallbacks,
            icon : icon, x : x, y : y,
            color : (icon.getTangoItem() as! TangoBook).color.toColor())

        // 初期化処理
        instance.addCloseIcon(pos: CloseIconPos.RightTop)
        instance.addToDrawManager()

        return instance;
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
        UDraw.drawRoundRectFill(rect : getRect(),
                                cornerR : UDpi.toPixel(7), color : bgColor!,
                                strokeWidth : UDpi.toPixel(FRAME_WIDTH),
                                strokeColor : frameColor)

        // Buttons
        for button in imageButtons {
            button!.draw()
        }

        if textTitle != nil {
            textTitle!.draw()
        }
        for item in mItems {
            if item!.title != nil {
                item!.title!.draw()
            }
            if item!.title != nil {
                item!.body!.draw()
            }
        }
    }

     /**
      * レイアウト更新
      * @param canvas
      */
    func updateLayout() {
        var y = UDpi.toPixel(TOP_ITEM_Y)

        let icons : List<ActionIconInfo> = IconInfoDialog.getCardIcons()

        var width = UDpi.toPixel(ICON_W) * CGFloat(icons.count) +
                UDpi.toPixel(ICON_MARGIN_H) * CGFloat(icons.count + 1);
        // 単語帳
        textTitle = UTextView.createInstance(
            text: UResourceManager.getStringByName("book"),
          textSize: Int(UDpi.toPixel(TEXT_SIZE)), priority: 0,
          alignment: UAlignment.None, createNode: true,
          multiLine: false, isDrawBG: false,
          x: UDpi.toPixel(MARGIN_H), y: y,
          width: width - UDpi.toPixel(MARGIN_H) * 2,
          color: TEXT_COLOR, bgColor: TEXT_BG_COLOR)
        
        y += UDpi.toPixel(TEXT_SIZE + 10)

        var titleStr : String? = nil
        var bodyStr : String? = nil
        let bgColor = UIColor.white
        for item in Items.cases {
            switch item {
                case .Name:  // Book名
                    titleStr = UResourceManager.getStringByName("name")
                    bodyStr = mBook!.getName()
                
                case .Comment:
                    titleStr = UResourceManager.getStringByName("comment")
                    bodyStr = mBook!.getComment()
                
                case .Count:  // カード枚数
                    let bookId = mIcon.getTangoItem()!.getId()
                    let count = TangoItemPosDao.countInParentType(
                        parentType: TangoParentType.Book,
                        parentId: bookId )
                    let ngCount = TangoItemPosDao.countCardInBook(
                        bookId: bookId,
                        countType: TangoItemPosDao.BookCountType.NG)

                    titleStr = UResourceManager.getStringByName("card_count")

                    let allCount = UResourceManager.getStringByName("all_count")
                    let countUnit = UResourceManager.getStringByName("card_count_unit")
                    bodyStr = allCount + " : " +
                            count.description + countUnit + "   " +
                            UResourceManager.getStringByName("count_not_learned") +
                            " : " + ngCount.description + countUnit
                
                case .Date:   // 最終学習日時
                    let date = TangoBookHistoryDao.selectMaxDateByBook(bookId: mBook!.getId())
                    let dateStr = (date == nil) ? " --- " :
                            UUtil.convDateFormat(date: date!, mode: ConvDateMode.DateTime)

                    titleStr = UResourceManager.getStringByName("studied_date")
                    bodyStr = dateStr
                
            }
            // title
            let title = UTextView.createInstance(
                text: titleStr! ,
                textSize: Int(UDpi.toPixel(TEXT_SIZE_S)),
                priority: 0,
                alignment: UAlignment.None, createNode: true,
                multiLine: false, isDrawBG: false,
                x: UDpi.toPixel(MARGIN_H), y: y, width: size.width - UDpi.toPixel(MARGIN_H),
                color: TEXT_COLOR, bgColor: nil)
            y += title.getHeight() + UDpi.toPixel(3)

            // body
            let body = UTextView.createInstance(
                text: bodyStr!,
                textSize: Int(UDpi.toPixel(TEXT_SIZE_S)), priority: 0,
                alignment: UAlignment.None, createNode: true, multiLine: true, isDrawBG: true,
                x: UDpi.toPixel(MARGIN_H), y: y,
                width: size.width - UDpi.toPixel(MARGIN_H), color: TEXT_COLOR, bgColor: bgColor)
            y += body.getHeight() + UDpi.toPixel(MARGIN_V_S)

            // 幅は最大サイズに合わせる
            let _width = body.getWidth() + UDpi.toPixel(MARGIN_H) * 2;
            if _width > width {
                width = _width;
            }
            
            mItems[item.rawValue] = IconInfoItem(title: title, body: body)
            
        }
        y += UDpi.toPixel(MARGIN_V)

        // タイトルのwidthを揃える
        for item in mItems {
            if item!.title != nil {
                item!.title!.setWidth(width - UDpi.toPixel(MARGIN_H) * 2)
            }
        }

        // Action buttons
        var x = UDpi.toPixel(ICON_MARGIN_H)
        for icon in icons {
            let image = UResourceManager.getImageWithColor(
                imageName: icon!.imageName, color: frameColor)
            
            let imageButton = UButtonImage(
                callbacks : self, id : icon!.id.rawValue,
                priority : 0, x : x, y : y,
                width : UDpi.toPixel(ICON_W), height : UDpi.toPixel(ICON_W),
                image : image!, pressedImage : nil)
            
            // アイコンの下に表示するテキストを設定
            imageButton.setTitle(title: UResourceManager.getStringByName(icon!.titleName),
                                 size: Int(UDpi.toPixel(30)),
                                 color: UIColor.black)

            imageButtons.append(imageButton)
            ULog.showRect(rect: imageButton.getRect())

            x += UDpi.toPixel(ICON_W + ICON_MARGIN_H);
        }
        y += UDpi.toPixel(ICON_W + MARGIN_V + 10)

        setSize(width, y)

        // Correct position
        if ( pos.x + size.width > topScene.getWidth() - UDpi.toPixel(DLG_MARGIN)) {
            pos.x = topScene.getWidth() - size.width - UDpi.toPixel(DLG_MARGIN)
        }
        if (pos.y + size.height > topScene.getHeight() - UDpi.toPixel(DLG_MARGIN)) {
            pos.y = topScene.getHeight() - size.height - UDpi.toPixel(DLG_MARGIN)
        }
        updateRect()
    }

    // Book
    public func touchEvent( vt : ViewTouch, offset : CGFloat?) -> Bool {
        let offset = pos

        if super.touchEvent(vt: vt, offset: offset) {
            return true
        }

        for button in imageButtons {
            if button!.touchEvent(vt: vt, offset: offset) {
                return true
            }
        }

        if super.touchEvent2(vt: vt, offset: nil) {
            return true
        }

        return false
    }

    public override func doAction() -> DoActionRet{
        return DoActionRet.None
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

        ULog.printMsg(TAG, "UButtonCkick:" + id.description)
        switch ActionIconId.toEnum(id) {
        case .Open:
            mIconInfoCallbacks!.IconInfoOpenIcon(icon: mIcon)
        
        case .Edit:
            mIconInfoCallbacks!.IconInfoEditIcon(icon: mIcon)
        
        case .MoveToTrash:
            mIconInfoCallbacks!.IconInfoThrowIcon(icon: mIcon)
        
        case .Copy:
            mIconInfoCallbacks!.IconInfoCopyIcon(icon: mIcon)
        default:
            break
        }
        return false
    }

    public func UButtonLongClick(id : Int) -> Bool {
        return false
    }

}
