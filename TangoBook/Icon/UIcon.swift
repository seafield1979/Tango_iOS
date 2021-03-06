//
//  UIcon.swift
//  TangoBook
//    単語帳編集ページで表示するアイコンの親クラス
//  Created by Shusuke Unno on 2017/07/25.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

/**
 * アイコンをクリックしたりドロップした時のコールバック
 */
public protocol UIconCallbacks : class {
    func iconClicked(icon : UIcon)
    func longClickIcon(icon : UIcon)
    func iconDroped(icon : UIcon)
}

// アイコンの挿入位置
public enum AddPos : Int, EnumEnumerable {
    case SrcNext     // コピー元の次
    case Top         // リストの先頭
    case Tail        // リストの末尾
}

/**
 * アイコンの種類
 * 単語帳編集ページに表示されるアイコンのタイプ
 */

public enum IconType : Int, EnumEnumerable {
    case Card       // 単語カード
    case Book       // 単語帳
    case Trash       // ゴミ箱
}


/**
 * 単語帳ソートの種類
 */
public enum IconSortMode : Int, EnumEnumerable {
    case None
    case TitleAsc           // タイトル文字列でソート（昇順）
    case TitleDesc          // タイトル文字列でソート（降順）
    case CreateTimeAsc      // 作成日時でソート（昇順）
    case CreateTimeDesc     // 作成日時でソート（降順）
    case StudiedTimeAsc     // 最終学習日時でソート（昇順）
    case StudiedTimeDesc     // 最終学習日時でソート（降順）
    ;    
}

 /**
 * ViewのonDrawで描画するアイコンの情報
 *  ※抽象クラス
 */
public class UIcon : UDrawable, CustomStringConvertible {

    /**
    * Constants
    */
    private static let TAG = "UIcon"
    private let DRAW_PRIORITY = 200

    public let FONT_SIZE = 15
    let TEXT_MARGIN = 4

    // タッチ領域の拡張幅
    let TOUCH_MARGIN = 10

    public let DISP_TITLE_LEN = 8
    public let DISP_TITLE_LEN_J = 5       // 日本語表示時の最大文字列数

    private let CHECKED_WIDTH = 24    // 選択中のアイコンのチェックの幅
    private let CHECKED_FRAME = 3    // 選択中のアイコンのチェックの枠

    let NEW_FONT_SIZE = 10
    let NEW_TEXT_MARGIN = 5
    let NEW_TEXT_COLOR = UColor.makeColor(200, 255, 80, 80)
    private let COLOR_BOX : UIColor = UColor.LightBlue
    
    // アニメーション用
    public let ANIME_FRAME = 20

    private let SELECTED_COLOR = UColor.makeColor(80, 255, 100, 100)
    private let TOUCHED_COLOR = UColor.makeColor(100,200,100)
    
    
    /**
     * Member variables
     */
    private static var count : Int = 0

    // SpriteKit Node
    var selectedBgNode : SKShapeNode?           // 選択時のBG
    var dragedBgNode : SKShapeNode?           // タップ中のBG
    var imageNode : SKSpriteNode?        // アイコンの画像
    var imageBgNode : SKNode?
    var checkedNode : SKNode?      // 選択状態時に表示するチェック枠画像
    
    var titleView : UTextView?          // アイコンのタイトルを表示するView
    var newTextView : UTextView?            // "New" バッジ用

    public var id : Int = 0
    weak var parentWindow : UIconWindow?
    private weak var callbacks : UIconCallbacks?
    var image : UIImage?


    // 各種状態
    var isChecking : Bool = false      // 選択可能状態(チェックボックスが表示される)
    var isChecked : Bool = false       // 選択中
    var isDraging : Bool = false        // ドラッグ中
    var isDroped : Bool = false        // ドロップ中(上に他のアイコンがドラッグ)
    var isTouched : Bool = false        // タッチ中
    var isLongTouched : Bool = false    // 長押し中

    var touchedColor : UIColor?
    var longPressedColor : UIColor?

    var title : String?             // アイコンの下に表示するテキスト
    var type = IconType.Card

    /**
     * Get/Set
     */
    private func clearFlags() {
        isTouched = false
        isLongTouched = false
        isDraging = false
    }

     // 保持するTangoItemを返す
    public func getTangoItem() -> TangoItem? {
        // 抽象メソッド
        return nil
    }

    public func getTitle() -> String? {
        return title
    }

    public func updateTitle() {
        // 抽象メソッド
    }

    // タッチしやすいように少し領域を広げたRectを返す
    override public func getRect() -> CGRect{
       return CGRect(x:rect.x - UDpi.toPixel(TOUCH_MARGIN),
                     y:rect.y - UDpi.toPixel(TOUCH_MARGIN),
                     width: rect.width + UDpi.toPixel(TOUCH_MARGIN) * 2,
                     height: rect.height + UDpi.toPixel(TOUCH_MARGIN) * 2)
    }

    // MARK: Initializer
    public init(parentWindow : UIconWindow, iconCallbacks : UIconCallbacks?,
                type : IconType, x : CGFloat,
                y : CGFloat, width : CGFloat, height : CGFloat)
    {
        super.init(priority: DRAW_PRIORITY, x: x, y: y, width: width, height: height)
        self.parentWindow = parentWindow
        self.callbacks = iconCallbacks
        self.id = UIcon.count
        self.type = type
        self.setPos(x, y, convSKPos: false)
        self.setSize(width, height)
        updateRect()
        UIcon.count += 1
        
        initSKNode()
    }
    
    deinit {
        if UDebug.isDebug {
            print("UIcon.deinit:\(title!)")
        }
    }
    
    /**
     * SpriteKitのノードを作成
     */
    override public func initSKNode() {
        parentNode.zPosition = CGFloat(drawPriority)
        parentNode.position = pos
        
        // selectedBgNode
        selectedBgNode = SKShapeNode(rect: CGRect(x:0, y:0, width: size.width, height: size.height).convToSK(), cornerRadius: UDpi.toPixel(5))
        selectedBgNode!.zPosition = 0
        selectedBgNode!.fillColor = SELECTED_COLOR
        selectedBgNode!.strokeColor = .clear
        selectedBgNode!.isAntialiased = true
        selectedBgNode!.isHidden = true
        parentNode.addChild2(selectedBgNode!)
        
        // dragedBg
        dragedBgNode = SKShapeNode(rect: CGRect(x:0, y:0, width: size.width, height: size.height).convToSK(), cornerRadius: UDpi.toPixel(5))
        dragedBgNode!.zPosition = 0.1
        dragedBgNode!.fillColor = TOUCHED_COLOR
        dragedBgNode!.strokeColor = .clear
        dragedBgNode!.isAntialiased = true
        dragedBgNode!.isHidden = true
        parentNode.addChild2(dragedBgNode!)
        
        // icon bg
        imageBgNode = SKNode()
        parentNode.addChild2(imageBgNode!)
        
        // icon image
        imageNode = SKSpriteNode()
        imageNode!.zPosition = 0.2
        imageNode!.anchorPoint = CGPoint(x:0, y:1.0)
        imageNode!.size = size
        imageBgNode!.addChild2(imageNode!)
        
        // checked
        let checkedW = size.width * 0.7
        checkedNode = SKNode()
        // check box frame
        let check1 = SKNodeUtil.createSpriteNode( imageNamed: ImageName.checked3_frame, width: checkedW, height: checkedW)
        check1.name = "bg"
        checkedNode!.addChild2( check1 )
        
        // check box
        let image : UIImage = UResourceManager.getImageWithColor(
            imageName: ImageName.checked2, color: UColor.makeColor(100,100,200))!
        let check2 = SKNodeUtil.createSpriteNode( image: image, width: checkedW, height: checkedW,x: 0, y: 0)
        check2.name = "check"
        check2.isHidden = false
        checkedNode!.addChild2( check2 )

        checkedNode!.position = CGPoint(x: size.width * 0.1, y: size.width * 0.25)
        checkedNode!.zPosition = 0.4
        checkedNode!.isHidden = true
        parentNode.addChild2(checkedNode!)
    }

//    public override func setPos(_ pos : CGPoint) {
//        setPos(pos, true)
//        
//        parentNode.position = pos.convToSK()
//    }
//    
//    override public func setPos(_ x : CGFloat, _ y : CGFloat) {
//        self.setPos( CGPoint(x: x, y: y))
//    }
    
    /**
     * アイコンに表示するタイトル文字列を設定する
     */
    public func setTitle( _ title : String?) {
        if self.title == title {
            return
        }
        self.title = title
        
        if self.titleView != nil {
            self.titleView!.parentNode.removeFromParent()
        }
        
        // タイトルノードを作成
        if title != nil {
            self.titleView = UTextView(
                text: title!, fontSize: UDpi.toPixel(FONT_SIZE), priority: 10, alignment: .CenterX,
                createNode: true, isFit: true, isDrawBG: false, margin: 0,
                x: size.width / 2, y: size.height,
                width: size.width * 1.8, color: UIColor.black, bgColor: nil)
            
            parentNode.addChild2( self.titleView!.parentNode )
        }
    }
    
    /**
     チェック可能状態をセットする
     SKSpriteNodeの表示状態を切り替える
     - parameter checking: 選択可能フラグ  trueならタッチでチェックを入れられる
     */
    public func setChecking( _ checking: Bool) {
        isChecking = checking
        
        if checking {
            checkedNode!.isHidden = false
        } else {
            checkedNode!.isHidden = true
        }
    }
    
    public func setChecked( _ checked : Bool) {
        isChecked = checked
        
        let bgNode = checkedNode!.childNode(withName: "bg")
        let checkNode = checkedNode!.childNode(withName: "check")
        
        if checked {
            bgNode!.isHidden = true
            checkNode!.isHidden = false
        } else {
            bgNode!.isHidden = false
            checkNode!.isHidden = true
        }
    }
    
    override public func setColor(_ color : UIColor) {
        self.color = color
        self.touchedColor = UColor.addBrightness(argb: color, addY : 0.3)
        self.longPressedColor = UColor.addBrightness(argb: color, addY: 0.6)
    }

    public func getType() -> IconType {
        return type
    }


    public func getParentWindow() -> UIconWindow? {
        return parentWindow
    }
    public func setParentWindow(_ parentWindow : UIconWindow) {
        self.parentWindow = parentWindow
    }

    public func click() {
        startAnim()
        if isChecking {
            if isChecked {
                setChecked( false )
            }
            else {
                setChecked( true )
                self.drawPriority = DrawPriority.DragIcon.rawValue
            }
        } else {
            if callbacks != nil {
                callbacks!.iconClicked(icon: self)
            }
        }
    }
    
    public func longClick() {
        if callbacks != nil {
            callbacks!.longClickIcon(icon: self)
        }
    }
    
    public func moving() {
        ULog.printMsg(UIcon.TAG, "moving")
    }
    public func drop() {
        ULog.printMsg(UIcon.TAG, "drop")
        if callbacks != nil {
            callbacks!.iconDroped(icon: self)
        }
    }

    /**
    * Newバッジ作成
    */
    func createNewBadge() {
        newTextView = UTextView.createInstance(
           text: "New", fontSize: UDpi.toPixel(NEW_FONT_SIZE),
           priority: 100, alignment: .Center, createNode: true,
           isFit: false, isDrawBG: true,
           x: size.width / 2, y: size.height / 2 + UDpi.toPixel(10), width: size.width, color: UIColor.white, bgColor: NEW_TEXT_COLOR)
        newTextView!.setFont("HiraKakuProN-W6")
        parentNode.addChild2( newTextView!.parentNode )
        
        // 文字の周りのマージン
        newTextView!.setMargin(UDpi.toPixel(NEW_TEXT_MARGIN), UDpi.toPixel(NEW_TEXT_MARGIN));
    }
    

    /**
     * Newフラグ設定
     */
    public func setNewFlag(isNew : Bool) {
        if let textView = newTextView {
            textView.parentNode.isHidden = !isNew
        }
    }

    /**
    * アイコンのタッチ処理
    * @param tx
    * @param ty
    * @return
    */
    public func checkTouch(tx : CGFloat, ty : CGFloat) -> Bool {
        if pos.x <= tx && tx <= getRight() &&
            pos.y <= ty && ty <= getBottom()
        {
            return true
        }
        return false
    }

     /**
     * クリックのチェックとクリック処理。このメソッドはすでにクリック判定された後の座標が渡される
     * @param clickX
     * @param clickY
     * @return
     */
    public func checkClick(clickX : CGFloat, clickY : CGFloat) -> Bool {
        if (getRect().contains(x: clickX, y: clickY)) {
            click()
            return true
        }
        return false
     }

     /**
     * ドロップをチェックする
     */
    public func checkDrop(x : CGFloat, y : CGFloat) -> Bool {
        if (getRect().contains(x: x, y: y))
        {
            return true
        }
        return false
    }

     /**
     * アイコンを描画
     */
    public override func draw() {
        drawIcon()
        
        if isDraging  || isDroped || isTouched {
            dragedBgNode!.isHidden = false
        } else {
            dragedBgNode!.isHidden = true
        }
    }

    /**
     * 毎フレームの処理(抽象メソッド)
     * サブクラスでオーバーライドして使用する
     * @return true:処理中 / false:処理完了
     */
    public override func doAction() -> DoActionRet{
        return DoActionRet.None
    }

    /**
    * アイコンを描画する
    */
    func drawIcon() {
        // 抽象メソッド
        print("UIcon drawIcon() オーバーライドして使用してください")
    }

    /*
        Drawableインターフェース
    */
    public override func setDrawList(_ drawList : UDrawList?) {
        self.drawList = drawList
    }

    public override func getDrawList() -> UDrawList?{
        return drawList
    }

     // Bitmapで描画1
    public func drawCheckboxImage(x : CGFloat, y : CGFloat,
                                  width : CGFloat, color : UIColor)
    {
        if isChecked {
            // 枠とチェック
//            UDraw.drawImage( image: UResourceManager.getImageWithColor(imageName: ImageName.checked2, color: color)!,
//                              x: x, y: y, width: width, height: width)
        } else {
            // 枠
//            UDraw.drawImage( image: UResourceManager.getImageByName(ImageName.checked3_frame)!,
//                             x: x, y: y, width: width, height: width)
        }
    }

    /**
    * 描画オフセットを取得する
    * @return
    */
    override public func getDrawOffset() -> CGPoint? {
        // 親Windowの座標とスクロール量を取得
        if parentWindow != nil {
            return CGPoint(x: parentWindow!.getPos().x - parentWindow!.getContentTop().x,
                           y: parentWindow!.getPos().y - parentWindow!.getContentTop().y);
        }
        return nil
    }

     /**
     * アニメーション開始
     */
     public func startAnim() {
         isAnimating = true
         animeFrame = 0
         animeFrameMax = ANIME_FRAME
         if parentWindow != nil {
             parentWindow!.setAnimating(true)
         }
     }

     /**
     * アニメーション処理
     * といいつつフレームのカウンタを増やしているだけ
     * @return true:アニメーション中
     */
    override public func animate() -> Bool {
        if !isAnimating {
            return false
        }
        if animeFrame >= animeFrameMax {
            isAnimating = false
            return false
        }

        animeFrame += 1
        return true
    }

     /**
     * アニメーション中かどうか
     * @return
     */
     public func isAnimating() -> Bool {
         return isAnimating
     }

    /**
    * タッチイベント処理
    * 親のUIconWindowで処理するのでここでは何もしない
    * @param vt
    * @return
    */
    public func touchEvent( vt: ViewTouch ) -> Bool {
        return touchEvent(vt: vt, offset: nil)
    }

    override public func touchEvent(vt : ViewTouch, offset : CGPoint? ) -> Bool {
        var done = false

        var offset = offset
        if offset == nil {
            offset = CGPoint()
        }

        if vt.isTouchUp {
            clearFlags()
        }
        switch vt.type {
            case .Touch:
                if (getRect().contains(x: vt.touchX(offset: offset!.x),
                                       y: vt.touchY(offset: offset!.y)))
                {
                    isTouched = true
                    done = true
                }
            case .LongPress:
                if (getRect().contains(x: vt.touchX(offset: offset!.x),
                                       y: vt.touchY(offset: offset!.y)))
                {
                    isLongTouched = true
                    setChecking(true)
                    setChecked(true)
                    done = true
                }
            case .Click:
                if (getRect().contains(x: vt.touchX(offset: offset!.x),
                                       y: vt.touchY(offset: offset!.y)))
                {
                    click()
                    done = true
                }
            case .LongClick:
                break
            case .Moving:
                if vt.isMoveStart {
                    if (getRect().contains(x: vt.touchX(offset: offset!.x),
                                           y: vt.touchY(offset: offset!.y)))
                    {
                        isDraging = true
                        done = true
                    }
                }
                if isDraging {
                    done = true
                }
                break
            case .MoveEnd:
                isDraging = false
                break;
            case .MoveCancel:
                isDraging = false
                break
        default:
            break
        }

        return done
    }

    /**
     * タッチアップ処理(抽象メソッド)
     * @param vt
     * @return
     */
    public override func touchUpEvent(vt: ViewTouch) -> Bool {
        return false
    }


    /**
    * 画像を更新する
    * アイコンの色が変更された際に呼び出す
    */
    public func updateIconImage() {
        if let _image = self.image {
            let _image2 = UUtil.convImageColor(image: _image, newColor: color)
            imageNode!.texture = SKTexture( image: _image2)
        }
    }

     /**
     * Drag & Drop
     */

     /**
     * ドロップ可能かどうか
     * ドラッグ中のアイコンを他のアイコンの上に重ねたときにドロップ可能かを判定してアイコンの色を変えたりする
     * @param dstIcon
     * @return
     */
    public func canDrop( dstIcon: UIcon, x : CGFloat, y : CGFloat) -> Bool {
        // 抽象メソッド
        return false
    }

     /**
     * ドロップして中に入れることができるかどうか？
     * 例: Card -> Book は OK
     *    Book -> Card/Book は NG
     * @return
     */
    public func canDropIn(dstIcon : UIcon, x : CGFloat, y : CGFloat) -> Bool {
        // 抽象メソッド
        return false
    }
    
    public var description: String {
        get {
            let item = getTangoItem()
            if item == nil {
                return "none"
            }
            
            let itemPos = item!.getItemPos()
            if let _itemPos = itemPos {
                return String(format:"iconType:%d title:%@ parentType:%d parentId:%d pos:%d",item!.getItemType().rawValue, item!.getTitle()!, _itemPos.parentType, _itemPos.parentId, _itemPos.pos)
            }
            return ""
        }
    }
}



