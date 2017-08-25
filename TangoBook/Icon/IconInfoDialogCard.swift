//
//  IconInfoDialogCard.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/29.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit


/**
 * カードアイコンをクリックした際に表示されるダイアログ
 * カードの情報(WordA,WordB)とアクションアイコン(ActionIcons)を表示する
 */
public class IconInfoDialogCard : IconInfoDialog {
    /**
     * Enums
     */
    enum ButtonId : Int, EnumEnumerable{
         case Edit
         case Copy
         case MoveToTrash
         case Favorite
     }

    enum Items : Int, EnumEnumerable {
         case WordA
         case WordB
//         case Comment
//         case History
     }

     /**
      * Consts
      */
     private let TAG = "IconInfoDialogCard"
     private let ICON_W = 40
     private let ICON_MARGIN_H = 10
     private let FONT_SIZE_M = 14
     private let FONT_SIZE_L = 17
     private let ICON_FONT_SIZE = 10

     private let TITLE_COLOR = UIColor.black
     private let TEXT_COLOR = UIColor.black
     private let TEXT_BG_COLOR = UIColor.white

    /**
     * Member Variables
     */
    var isUpdate = true     // ボタンを追加するなどしてレイアウトが変更された
    private var mTitleView : UTextView? = nil
    private var mItems : [IconInfoItem?] = Array(repeating: nil, count: Items.count) 
    private var mCard : TangoCard? = nil
    private var imageButtons : List<UButtonImage> = List()

    /**
     * Get/Set
     */

    /**
     * Constructor
     */
    public init( topScene : TopScene,
                 iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
                 windowCallbacks : UWindowCallbacks?,
                 icon: UIcon,
                 x: CGFloat, y: CGFloat,
                 color: UIColor?)
    {
        super.init( topScene: topScene,
                    iconInfoCallbacks : iconInfoDialogCallbacks,
                    windowCallbacks : windowCallbacks,
                    icon: icon,
                    x: x, y: y, color: color)
        if icon is IconCard {
            let cardIcon = icon as! IconCard
            
            mCard = cardIcon.card

            var color = color
            if color == nil {
                color = UIColor.lightGray
            }

            bgColor = UColor.setBrightness(argb: color!, brightness: 220.0 / 255.0)
            frameColor = UColor.setBrightness(argb: color!, brightness: 140.0 / 255.0)
        }
    }

     /**
      * createInstance
      */
     public static func createInstance(
            topScene : TopScene,
            iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
            windowCallbacks : UWindowCallbacks?,
            icon : UIcon,
            x : CGFloat, y : CGFloat) -> IconInfoDialogCard
     {
        let instance = IconInfoDialogCard(
            topScene : topScene,
            iconInfoDialogCallbacks : iconInfoDialogCallbacks,
            windowCallbacks : windowCallbacks, icon : icon,
            x : x, y : y,
            color : UColor.makeColor(argb: UInt32((icon.getTangoItem() as! TangoCard).color)))

        // 初期化処理
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
    public override func drawContent(offset : CGPoint?){
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
        // ダイアログのアイテムは clientNode 以下に配置する
        clientNode.removeAllChildren()
        
        var y = UDpi.toPixel(TOP_ITEM_Y)

        let icons : List<ActionIconInfo> = IconInfoDialog.getCardIcons()

        var width = UDpi.toPixel(ICON_W) * CGFloat(icons.count) + UDpi.toPixel(ICON_MARGIN_H) * CGFloat(icons.count + 1) + UDpi.toPixel(DLG_MARGIN)
        let fontSize = UDraw.getFontSize(FontSize.M)

        // タイトル(カード)
        mTitleView = UTextView.createInstance(
           text : UResourceManager.getStringByName("card"),
           fontSize : UDpi.toPixel(FONT_SIZE_M),
           priority : 0,
           alignment : UAlignment.None, createNode: true,
           multiLine : false, isDrawBG : false,
           x : UDpi.toPixel(MARGIN_H),
           y : y, width : width-UDpi.toPixel(MARGIN_H)*2,
           color : TITLE_COLOR, bgColor : TEXT_BG_COLOR)
        y += UDpi.toPixel(FONT_SIZE_L + MARGIN_V)

        var titleStr : String? = nil
        var bodyStr : String? = nil
        let bgColor = UIColor.white

        for item in Items.cases {
            switch item {
                case .WordA:
                    titleStr = UResourceManager.getStringByName("word_a")
                    bodyStr = UUtil.convString(text: mCard!.wordA!, cutNewLine: false, maxLines: 2, maxLength: 0)
               
                case .WordB:
                    titleStr = UResourceManager.getStringByName("word_b")
                    bodyStr = UUtil.convString(text: mCard!.wordB!, cutNewLine: false, maxLines: 2, maxLength: 0)
            }
            // title
            var titleView : UTextView? = nil
            if titleStr != nil && titleStr!.isEmpty == false {
                titleView = UTextView.createInstance(
                   text : titleStr!,
                   fontSize : fontSize,
                   priority : 0, alignment : UAlignment.None, createNode: true,
                   multiLine : false, isDrawBG : false,
                   x : UDpi.toPixel(MARGIN_H), y : y,
                   width : size.width-UDpi.toPixel(MARGIN_H),
                   color : TEXT_COLOR, bgColor : nil)

                y += titleView!.getHeight() + UDpi.toPixel(MARGIN_V_S)
            }

            // body
            var bodyView : UTextView? = nil
            if bodyStr != nil && bodyStr!.isEmpty == false {
                bodyView = UTextView.createInstance(
                   text : bodyStr!, fontSize : fontSize, priority : 0,
                   alignment : UAlignment.None, createNode: true,
                   multiLine : true, isDrawBG : true,
                   x : UDpi.toPixel(MARGIN_H),
                   y : y, width : size.width-UDpi.toPixel(MARGIN_H),
                   color : TEXT_COLOR, bgColor : bgColor)
               
                y += bodyView!.getHeight() + UDpi.toPixel(MARGIN_V_S)
                
                // 幅は最大サイズに合わせる
                let _width = bodyView!.getWidth() + UDpi.toPixel(MARGIN_H) * 2
                if _width > width {
                    width = _width
                }
            }
            mItems[item.rawValue] = IconInfoItem(title: titleView, body: bodyView)
        }
        y += UDpi.toPixel(MARGIN_V)

        // タイトルのwidthを揃える
        for item in mItems {
            if item == nil {
                continue
            }
            if item!.title != nil {
                item!.title!.setWidth(width - UDpi.toPixel(MARGIN_H) * 2)
            }
        }

        // アクションボタン
        var x = (width - (UDpi.toPixel(ICON_W) * CGFloat(icons.count) + UDpi.toPixel(MARGIN_H) * CGFloat(icons.count - 1))) / 2
        for icon in icons {
            let color = (icon!.id == ActionIconId.Favorite) ? UColor.LightYellow : frameColor

            var imageButton : UButtonImage
            // お気に入りはON/OFF用の２つ画像を登録する
            if icon!.id == ActionIconId.Favorite {
                let image = UResourceManager.getImageWithColor(
                    imageName: ImageName.favorites,
                    color: UColor.OrangeRed)
                let image2 = UResourceManager.getImageWithColor(
                    imageName: ImageName.favorites2,
                    color: UColor.OrangeRed)

                imageButton = UButtonImage(
                    callbacks : self,
                    id : icon!.id.rawValue, priority : 0,
                    x : x, y : y, width : UDpi.toPixel(ICON_W), height : UDpi.toPixel(ICON_W),
                    image : image!, pressedImage : nil)

                imageButton.addState(image: image2!)
                if mCard!.star {
                    imageButton.setState(mCard!.star ? 1 : 0)
                }
            } else {
                let image = UResourceManager.getImageWithColor(
                    imageName: icon!.imageName, color: color);
                imageButton = UButtonImage(
                    callbacks : self, id : icon!.id.rawValue,
                    priority : 0, x : x, y : y,
                    width : UDpi.toPixel(ICON_W), height : UDpi.toPixel(ICON_W),
                    image : image!, pressedImage : nil)
            }

            // アイコンの下に表示するテキストを設定
            imageButton.addTitle(title: UResourceManager.getStringByName(icon!.titleName),
                                 fontSize: UDpi.toPixel(ICON_FONT_SIZE),
                                 alignment: .CenterX,
                                 x: imageButton.size.width / 2,
                                 y: imageButton.size.height + UDpi.toPixel(4),
                                 color: .black, bgColor: nil)
            
            imageButtons.append(imageButton)
            ULog.showRect(rect: imageButton.getRect())

            x += UDpi.toPixel(ICON_W + ICON_MARGIN_H)
        }
        y += UDpi.toPixel(ICON_W + MARGIN_V + 17)

        setSize(width, y)

        // 座標補正
        if pos.x + size.width > topScene.getWidth() - UDpi.toPixel(DLG_MARGIN) {
            pos.x = topScene.getWidth() - size.width - UDpi.toPixel(DLG_MARGIN)
        }
        if (pos.y + size.height > topScene.getHeight() - UDpi.toPixel(DLG_MARGIN)) {
            pos.y = topScene.getHeight() - size.height - UDpi.toPixel(DLG_MARGIN)
        }
        updateRect()
        
        
        
        
        // SpriteKitのノードを生成する
        updateWindow()
        initSKNode()
        parentNode.position.toSK()
        addCloseIcon(pos: CloseIconPos.RightTop)
        
        
        if mTitleView != nil {
            clientNode.addChild2( mTitleView!.parentNode )
        }
        
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

    public override func touchEvent(vt : ViewTouch, offset : CGPoint?) -> Bool {
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

     public override func doAction() -> DoActionRet {
         var ret = DoActionRet.None
         for button in imageButtons {
             let _ret = button!.doAction()
             switch _ret{
             case .Done:
                 return DoActionRet.Done;
             case .Redraw:
                 ret = DoActionRet.Redraw;
             default:
                break
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

        switch ActionIconId.toEnum(id) {
        case .Edit:
            mIconInfoCallbacks!.IconInfoEditIcon(icon: mIcon)
        
        case .MoveToTrash:
            mIconInfoCallbacks!.IconInfoThrowIcon(icon: mIcon)
        
        case .Copy:
            mIconInfoCallbacks!.IconInfoCopyIcon(icon: mIcon)
        
        case .Favorite:
            let card = mIcon.getTangoItem() as! TangoCard
            let star = TangoCardDao.toggleStar(card: card)
            card.star = star

            // 表示アイコンを更新
            imageButtons[ButtonId.Favorite.rawValue].setState(star ? 1 : 0)
        default:
            break
        }
        return false
    }

    public func UButtonLongClick(id : Int) -> Bool {
        return false
    }
}
