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
    // MARK: Enums
    enum ButtonId : Int, EnumEnumerable{
         case Edit
         case Copy
         case MoveToTrash
         case Favorite
     }

    enum Items : Int, EnumEnumerable {
         case WordA
         case WordB
     }

     // MARK: Constants
     private let TAG = "IconInfoDialogCard"
     private let ICON_W = 40
     private let ICON_MARGIN_H = 10
     private let FONT_SIZE_M = 14
     private let FONT_SIZE_L = 17
     private let ICON_FONT_SIZE = 10

     private let TITLE_COLOR = UIColor.black
     private let TEXT_COLOR = UIColor.black
     private let TEXT_BG_COLOR = UIColor.white

    // MARK: Properties
    var isUpdate = true     // ボタンを追加するなどしてレイアウトが変更された
    private var mTitleView : UTextView? = nil
    private var mItems : [IconInfoItem?] = Array(repeating: nil, count: Items.count) 
    private var mCard : TangoCard? = nil
    private var imageButtons : List<UButtonImage> = List()

    // MARK: Initializer
    public init( topScene : TopScene,
                 iconInfoDialogCallbacks : IconInfoDialogCallbacks?,
                 windowCallbacks : UWindowCallbacks?,
                 icon: UIcon,
                 x: CGFloat, y: CGFloat,
                 bgColor: UIColor?)
    {
        super.init( topScene: topScene,
                    iconInfoCallbacks : iconInfoDialogCallbacks,
                    windowCallbacks : windowCallbacks,
                    icon: icon,
                    x: x, y: y, bgColor: bgColor)
        if icon is IconCard {
            let cardIcon = icon as! IconCard
            
            mCard = cardIcon.card

            var bgColor = bgColor
            if bgColor == nil {
                bgColor = UIColor.lightGray
            }

            self.bgColor = UColor.setBrightness(argb: bgColor!, brightness: 220.0 / 255.0)
            frameColor = UColor.setBrightness(argb: bgColor!, brightness: 140.0 / 255.0)
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
            bgColor : UColor.makeColor(argb: UInt32((icon.getTangoItem() as! TangoCard).color)))

        // 初期化処理
        instance.addToDrawManager()

        return instance;
    }

     // MARK: Methods
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

        var width = topScene.getWidth() - UDpi.toPixel(DLG_MARGIN) * 2
        var x = width / 2
        let fontSize = UDraw.getFontSize(FontSize.M)

        // タイトル(カード)
        mTitleView = UTextView.createInstance(
           text : UResourceManager.getStringByName("card"),
           fontSize : UDpi.toPixel(FONT_SIZE_M),
           priority : 0,
           alignment : UAlignment.CenterX, createNode: true,
           isFit : false, isDrawBG : false,
           x : x, y : y,
           width : width - UDpi.toPixel(MARGIN_H) * 2,
           color : TITLE_COLOR, bgColor : TEXT_BG_COLOR)
        y += mTitleView!.size.height + UDpi.toPixel(MARGIN_V)

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
                   priority : 0, alignment : UAlignment.CenterX, createNode: true,
                   isFit : false, isDrawBG : false,
                   x : x, y : y,
                   width : size.width - UDpi.toPixel(MARGIN_H),
                   color : TEXT_COLOR, bgColor : nil)

                y += titleView!.getHeight() + UDpi.toPixel(MARGIN_V_S)
            }

            // body
            var bodyView : UTextView? = nil
            if bodyStr != nil && bodyStr!.isEmpty == false {
                bodyView = UTextView.createInstance(
                   text : bodyStr!, fontSize : fontSize, priority : 0,
                   alignment : UAlignment.CenterX, createNode: true,
                   isFit : false, isDrawBG : true,
                   x : x,
                   y : y, width : size.width - UDpi.toPixel(MARGIN_H),
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
        x = (width - (UDpi.toPixel(ICON_W) * CGFloat(icons.count) + UDpi.toPixel(MARGIN_H) * CGFloat(icons.count - 1))) / 2
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

        // ダイアログの座標
        pos.x = (topScene.getWidth() - width) / 2
        pos.y = (topScene.getHeight() - y) / 2
        
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
