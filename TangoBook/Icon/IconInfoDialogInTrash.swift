//
//  IconInfoDialogInTrash.swift
//  TangoBook
//      ゴミ箱の中のアイコンをクリックした際に表示されるダイアログ
//  Created by Shusuke Unno on 2017/07/29.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

public class IconInfoDialogInTrash : IconInfoDialog {
    // MARK: Enums
    enum BookItems : Int, EnumEnumerable {
        case Title
        case Count
    }
    
    enum CardItems : Int, EnumEnumerable {
        case WordA
        case WordB
    }
    
    //MARK: Constants
    static let TAG = "IconInfoDialogBook"
    private static let BG_COLOR = UIColor.lightGray
    private let TEXT_VIEW_H = 35
    private let ICON_W = 40
    private let ICON_MARGIN_H = 10
    private let FONT_SIZE_M = 14
    private let FONT_SIZE_L = 17
    private let ICON_FONT_SIZE = 12
    
    private let TEXT_COLOR = UIColor.black
    private let TEXT_BG_COLOR = UIColor.white
    private let BG_COLOR = UColor.makeColor(220,220,220)

    // MARK: Properties
    var isUpdate : Bool = true     // ボタンを追加するなどしてレイアウトが変更された
    private var textTitle : UTextView? = nil
    private var textWord : UTextView? = nil
    private var textCount : UTextView? = nil
    private var imageButtons : List<UButtonImage> = List()
    private var mItems : [IconInfoItem?] = Array(repeating: nil, count: CardItems.count)

    // MARK: Initializer
    public init(topScene : TopScene,
                iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
                windowCallbacks : UWindowCallbacks?,
                icon : UIcon,
                x : CGFloat, y : CGFloat)
    {
        super.init( topScene : topScene,
                    iconInfoCallbacks: iconInfoDialogCallbacks,
                    windowCallbacks : windowCallbacks,
                    icon : icon, x: x, y: y, bgColor: BG_COLOR)
    }

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
            x: x, y: y)
        
        // 初期化処理
        instance.addToDrawManager()
        
        return instance
    }

    // MARK: Methods
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
     */
    func updateLayout() {
        var y = UDpi.toPixel(TOP_ITEM_Y)
        let iconW = UDpi.toPixel(ICON_W)
        let iconMargin = UDpi.toPixel(ICON_MARGIN_H)
        let fontSize = UDpi.toPixel(FONT_SIZE_L)
        
        let icons : List<ActionIconInfo> = IconInfoDialog.getInTrashIcons()
        var width = topScene.getWidth() - UDpi.toPixel(MARGIN_H) * 2
        var x : CGFloat = width / 2
        
        // SpriteKitのノードを削除
        parentNode.removeAllChildren()
        
        var titleStr : String? = nil
        var bodyStr : String? = nil
        let bgColor = UIColor.white
        let marginVS = UDpi.toPixel(MARGIN_V_S)
        
        if mIcon.getType() == IconType.Card {
            let mCard : TangoCard = (mIcon.getTangoItem() as? TangoCard)!

            // タイトル(カード)
            textTitle = UTextView.createInstance(
                text : UResourceManager.getStringByName("card"),
                fontSize : UDpi.toPixel(FONT_SIZE_M),
                priority : 0,
                alignment : UAlignment.Center, createNode: true,
                isFit : true, isDrawBG : false,
                x : x, y : y,
                width : width - UDpi.toPixel(MARGIN_H) * 2,
                color : TEXT_COLOR, bgColor : TEXT_BG_COLOR)
            
            y += textTitle!.size.height + UDpi.toPixel(MARGIN_V)
            
            for item in CardItems.cases {
                switch item {
                case .WordA:
                    titleStr = UResourceManager.getStringByName("word_a")
                    bodyStr = UUtil.convString(text: mCard.wordA!, cutNewLine: false, maxLines: 2, maxLength: 0)
                    
                case .WordB:
                    titleStr = UResourceManager.getStringByName("word_b")
                    bodyStr = UUtil.convString(text: mCard.wordB!, cutNewLine: false, maxLines: 2, maxLength: 0)
                }
                // title
                var titleView : UTextView? = nil
                if titleStr != nil && titleStr!.isEmpty == false {
                    titleView = UTextView.createInstance(
                        text : titleStr!,
                        fontSize : fontSize,
                        priority : 0, alignment : UAlignment.CenterX, createNode: true,
                        isFit : true, isDrawBG : false,
                        x : x, y : y,
                        width : size.width - UDpi.toPixel(MARGIN_H),
                        color : TEXT_COLOR, bgColor : nil)
                    
                    y += titleView!.getHeight() + marginVS
                }
                
                // body
                var bodyView : UTextView? = nil
                if bodyStr != nil && bodyStr!.isEmpty == false {
                    bodyView = UTextView.createInstance(
                        text : bodyStr!, fontSize : fontSize, priority : 0,
                        alignment : UAlignment.CenterX, createNode: true,
                        isFit : true, isDrawBG : true,
                        x : x, y : y,
                        width : size.width - UDpi.toPixel(MARGIN_H),
                        color : TEXT_COLOR, bgColor : bgColor)
                    
                    y += bodyView!.getHeight() + marginVS
                    
                    // 幅は最大サイズに合わせる
                    let _width = bodyView!.getWidth() + UDpi.toPixel(MARGIN_H) * 2
                    if _width > width {
                        width = _width
                    }
                }
                mItems[item.rawValue] = IconInfoItem(title: titleView, body: bodyView)
            }
        } else {
            // 単語帳
            let mBook : TangoBook = (mIcon.getTangoItem() as? TangoBook)!

            // タイトル(単語帳)
            textTitle = UTextView.createInstance(
                text : UResourceManager.getStringByName("book"),
                fontSize : UDpi.toPixel(FONT_SIZE_M),
                priority : 0,
                alignment : UAlignment.Center, createNode: true,
                isFit : true, isDrawBG : false,
                x : x, y : y, width : width - UDpi.toPixel(MARGIN_H) * 2,
                color : TEXT_COLOR, bgColor : TEXT_BG_COLOR)

            y += UDpi.toPixel(FONT_SIZE_L + MARGIN_V)
            
            for item in BookItems.cases {
                switch item {
                case .Title:
                    titleStr = UResourceManager.getStringByName("book_name2")
                    bodyStr = UUtil.convString(text: mBook.getTitle(), cutNewLine: false, maxLines: 2, maxLength: 0)
                    
                case .Count:
                    titleStr = UResourceManager.getStringByName("card_count")
                    let count = TangoItemPosDao.countInParentType(
                        parentType: TangoParentType.Book,
                        parentId: mBook.getId()
                    )
                    bodyStr = UUtil.convString(text: count.description, cutNewLine: false, maxLines: 2, maxLength: 0)
                }
                // title
                var titleView : UTextView? = nil
                if titleStr != nil && titleStr!.isEmpty == false {
                    titleView = UTextView.createInstance(
                        text : titleStr!,
                        fontSize : fontSize,
                        priority : 0, alignment : UAlignment.CenterX, createNode: true,
                        isFit : true, isDrawBG : false,
                        x : x, y : y,
                        width : size.width - UDpi.toPixel(MARGIN_H),
                        color : TEXT_COLOR, bgColor : nil)
                    
                    y += titleView!.getHeight() + marginVS
                }
                
                // body
                var bodyView : UTextView? = nil
                if bodyStr != nil && bodyStr!.isEmpty == false {
                    bodyView = UTextView.createInstance(
                        text : bodyStr!, fontSize : fontSize, priority : 0,
                        alignment : UAlignment.CenterX, createNode: true,
                        isFit : true, isDrawBG : true,
                        x : x, y : y,
                        width : size.width-UDpi.toPixel(MARGIN_H),
                        color : TEXT_COLOR, bgColor : bgColor)
                    
                    y += bodyView!.getHeight() + marginVS
                    
                    // 幅は最大サイズに合わせる
                    let _width = bodyView!.getWidth() + UDpi.toPixel(MARGIN_H) * 2
                    if _width > width {
                        width = _width
                    }
                }
                mItems[item.rawValue] = IconInfoItem(title: titleView, body: bodyView)
            }
        }
        y += UDpi.toPixel(MARGIN_V)
        
        // Action buttons
        x = (width - (UDpi.toPixel(ICON_W) * CGFloat(icons.count) + UDpi.toPixel(MARGIN_H) * CGFloat(icons.count - 1))) / 2
        
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
                fontSize: UDpi.toPixel(ICON_FONT_SIZE),
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
        
        // ダイアログの座標
        pos.x = (topScene.getWidth() - width) / 2
        pos.y = (topScene.getHeight() - y) / 2
        
        updateRect()
        
        // SpriteKitノード作成
        // SpriteKitのノードを生成する
        updateWindow()
        initSKNode()
        parentNode.position.toSK()
        addCloseIcon(pos: CloseIconPos.RightTop)
        
        // ノードを追加
        clientNode.addChild2( textTitle!.parentNode )

        for item in mItems {
            if let _title = item!.title {
                clientNode.addChild2( _title.parentNode )
            }
            if let _body = item!.body {
                clientNode.addChild2( _body.parentNode )
            }
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

    // MARK: Callbacks
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

