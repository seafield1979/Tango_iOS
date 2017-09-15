//
//  StudyCardInput.swift
//  TangoBook
//    正解入力学習モードで使用するカード
//
//    正解の文字(ボタン)をタップする
//    正解なら次の文字へ、不正解なら別のボタンをタップする
//    全ての文字をタップしたら次のカードへ
//    １文字でも間違いをタップしたら不正解
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import SpriteKit

public class StudyCardInput : UDrawable, UButtonCallbacks {
    /**
     * Enums
     */
    public enum State {
        case None
        case Appearance         // 出現
        case ShowAnswer         // 正解表示中
        case Disappearance       // 消える
    }

    // 親に対する要求
    public enum RequestToParent {
        case None
        case End
    }

    /**
     * Consts
     */
    public let ANIME_FRAME = 10;

    // layout
    private let MARGIN_H = 17
    private let MARGIN_V = 17
    private let QBUTTON_W = 40
    private let QBUTTON_H = 50
    private static let FONT_SIZE = 23
    private let FONT_SIZE_L = 32
    private let TEXT_COLOR = UIColor.black
    private let FRAME_COLOR = UColor.makeColor(150,150,150)

    private let TEXT_MARGIN_H2 = 10
    private let TEXT_MARGIN_V = 10
    private let ONE_TEXT_WIDTH = FONT_SIZE + 7
    private let ONE_TEXT_HEIGHT = FONT_SIZE + 7

    private let bgNodeName = "bg"
    private let labelNodeName = "label"
    // color
    private let BUTTON_COLOR = UColor.LightGray
    private let NG_BUTTON_COLOR = UColor.LightRed


    /**
     * Member Variables
     */
    // SpriteKit Node
    private var bgNode : SKShapeNode?
    private var clientNode : SKNode?
    private var titleNode : SKLabelNode?
    private var correctNodes : [SKNode] = []     // 正解（未入力も含む)
    
    public var mState : State = .None
    public var mCard : TangoCard?
    private var mWord : String?

    // 正解の文字列を１文字づつStringに分割したもの
    private var mCorrectWords : List<String> = List()
    private var mCorrectFlags : List<Bool> = List()

    // 正解入力用の文字をバラしてランダムに並び替えた配列
    private var mQuestionButtons : List<UButtonText> = List()
    private var isTouching : Bool = false
    private var basePos : CGPoint = CGPoint()

    // 正解入力位置
    private var inputPos : Int = 0

    // １回でも間違えたかどうか
    public var isMistaken : Bool = false

    // 親への通知用
    private var mRequest : RequestToParent = .None

    public func getRequest() -> RequestToParent {
        return mRequest
    }

    // MARK: Accessor
    public func setState( _ state : State) {
        mState = state
    }

    private func getButtonById(_ id : Int) -> UButtonText? {
        for button in mQuestionButtons {
            if button!.getId() == id {
                return button
            }
        }
        return nil
    }

    // MARK: Initializer
    public init( card : TangoCard, canvasW : CGFloat, height : CGFloat, pos: CGPoint)
    {
        super.init(priority: 0, x: 0, y: 0, width: canvasW - UDpi.toPixel(MARGIN_H) * 2, height: height)

        mState = .None
        mCard = card
        mWord = card.wordA
        
        var strArray : [String] = []
        for c in card.wordA!.lowercased().characters {
            strArray.append( String(c) )
        }

        // strArrayの先頭に余分な空文字が入っているので除去
        // 空白も除去
        for c in strArray {
            mCorrectWords.append(c)
            mCorrectFlags.append(true)
        }

        basePos = CGPoint(x: size.width / 2, y: size.height / 2)
        inputPos = 0;

        initSKNode()

        // 出現アニメーション
        startAppearance(frame: ANIME_FRAME)
    }
    
    
    public override func initSKNode() {
        var y : CGFloat = UDpi.toPixel(MARGIN_V)
        
        // BG
        bgNode = SKNodeUtil.createRectNode(
            rect: CGRect(x:-size.width / 2, y:-size.height / 2,
                         width: size.width, height: size.height ),
            color: .white, pos: CGPoint(x: size.width / 2, y: size.height / 2), cornerR: UDpi.toPixel(10))
        bgNode!.strokeColor = FRAME_COLOR
        bgNode!.lineWidth = UDpi.toPixel(3)
        parentNode.addChild2(bgNode!)

        // Client  BG以外のノードの親
        clientNode = SKNode()
        clientNode!.position = CGPoint(x: -size.width / 2, y: -size.height / 2)
        clientNode!.zPosition = 1.0
        bgNode!.addChild2( clientNode! )

        // タイトル(出題の単語)
        titleNode = SKNodeUtil.createLabelNode(text: mCard!.wordB!, fontSize: UDpi.toPixel(StudyCardInput.FONT_SIZE), color: .black, alignment: .CenterX, pos: CGPoint(x: size.width / 2, y: y)).node
        titleNode?.zPosition = 1
        clientNode!.addChild2( titleNode! )
        
        y += titleNode!.frame.size.height + UDpi.toPixel(MARGIN_V)
        
        // 正解（未入力含む）
        y = createCorrectWordNode(y: y)

        // タッチ用の文字
        y = createQuestionNode(y: y)
    }

    /**
     * Methods
     */
    /**
     * 出現時の拡大処理
     */
    private func startAppearance(frame : Int) {
        mScale = 0
        mState = State.Appearance
        startMovingScale(dstScale: 1.0, frame: frame)
        
//        clientNode!.isHidden = true
    }

    /**
     * 消えるときの縮小処理
     * @param frame
     */
    private func startDisappearange( frame : Int) {
        mScale = 1.0
        mState = State.Disappearance
        startMovingScale(dstScale: 0, frame: frame)
    }

    /**
     * 正解を表示する
     * 強制的に表示したのでNG判定
     * @param mistaken  強制的に正解を表示させた場合にtrueになる
     */
    public func showCorrect(mistaken : Bool) {
        mState = State.ShowAnswer
        inputPos = mWord!.characters.count
        if mistaken {
            isMistaken = mistaken
        }

        // 正解を全表示
        
        for i in 0..<correctNodes.count {
            let node = correctNodes[i]
            if mCorrectFlags[i] {
                if let bgN = node.childNode(withName: bgNodeName) as? SKShapeNode {
                    bgN.fillColor = .clear
                }
            }
            if let labelN = node.childNode(withName: labelNodeName) as? SKLabelNode {
                labelN.text = mCorrectWords[i]
            }
        }
        
        // ボタンの色を元に戻す
        for _button in mQuestionButtons {
            _button!.setColor(BUTTON_COLOR)
        }
        // ○×
        if isMistaken {
            let n = SKNodeUtil.createCrossPoint(type: .Type2, pos: CGPoint(x: size.width / 2, y: size.height / 2), length: UDpi.toPixel(50), lineWidth: UDpi.toPixel(10), color: UColor.makeColor(a: 0.6, rgb: .red), zPos: 1)
            clientNode!.addChild2(n)
        } else {
            let n = SKNodeUtil.createCircleNode(pos: CGPoint(x: size.width / 2, y: size.height / 2), radius: UDpi.toPixel(50), lineWidth: UDpi.toPixel(10), color: UColor.makeColor(a: 0.6, rgb: UColor.DarkGreen))
            n.zPosition = 1
            clientNode!.addChild2(n)
        }
        
        // 背景色
        var bgColor : UIColor = .white
        if (mState == State.ShowAnswer) {
            // 解答表示時
            if (isMistaken) {
                bgColor = UColor.LightRed
            } else {
                bgColor = UColor.LightGreen
            }
            bgNode!.strokeColor = UColor.addBrightness(argb: bgColor, addY: -0.3)
        }
        bgNode!.fillColor = bgColor
    }

    /**
     * 自動で実行される何かしらの処理
     * @return
     */
    public override func doAction() -> DoActionRet {
        switch mState {
        case .Appearance:
            fallthrough
        case .Disappearance:
            _ = autoMoving()
            // bgNodeのスケールだけ変えたいのでparentNodeのスケールを戻す
            parentNode.setScale(1.0)
            bgNode!.setScale(mScale)
            break
        case .None:
            for button in mQuestionButtons {
                if button!.doAction() != .None {
                    return .Redraw
                }
            }
            break
        default:
            break
        }
        return .None
    }

    /**
     * 自動移動完了
     */
    public override func endMoving() {
        if mState == State.Disappearance {
            // 親に非表示完了を通知する
            mRequest = RequestToParent.End
        }
        else {
            mState = State.None
        }
    }

    /**
     * 指定の1文字が、ユーザーの入力が必要でないかどうかを判定する
     * @param str
     * @return
     */
    private func isIgnoreStr( _ str : String ) -> Bool{
        if RegExp("[0-9a-zA-Z]+").isMatch(input: str) {
            return false
        }
        return true
    }


    /**
     * Drawable methods
     */
    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
    }

    /**
     * 正解文字列を１文字づつ表示する
     *
     * @param x   描画先頭座標x
     * @param y   描画先頭座標y
     */
    private func createCorrectWordNode(y : CGFloat) -> CGFloat {
        var x : CGFloat = 0
        var y = y
        var width : CGFloat
        
        // 一行に表示できる文字数
        let lineTexts : Int = Int((size.width - UDpi.toPixel(MARGIN_H) * 2) / UDpi.toPixel(ONE_TEXT_WIDTH))
        
        var lineTextCnt = 0

        if lineTexts < mCorrectWords.count {
            // １行に収まりきらない場合
            width = size.width - UDpi.toPixel(MARGIN_H) * 2
        } else {
            width = CGFloat(mCorrectWords.count) * UDpi.toPixel(ONE_TEXT_WIDTH)
        }

        x = (size.width - width) / 2
        let topX : CGFloat = x
        var text : String = "_"

        let textW : CGFloat = UDpi.toPixel(ONE_TEXT_WIDTH)
        let fontSize = UDpi.toPixel(StudyCardInput.FONT_SIZE)
        let margin = UDpi.toPixel(8)
        let labelPos = CGPoint(x: margin, y: margin + UDpi.toPixel(StudyCardInput.FONT_SIZE))
        let radius = UDpi.toPixel(0)
        
        for i in 0 ..< mCorrectWords.count {
            text = mCorrectWords[i]
            if isIgnoreStr(text) {
            } else if (text == "\n") {
                // 改行
                x = topX
                y += textW
                lineTextCnt = 0
                continue
            } else {
                text = "_"
            }

            // SpriteKit Node
            let pNode = SKNode()
            pNode.position = CGPoint(x: x, y: y)
            
            // Label
            let result = SKNodeUtil.createLabelNode(text: text, fontSize: fontSize, color: .black, alignment: .Bottom, pos: labelPos)
            result.node.name = labelNodeName
            pNode.addChild2( result.node )
            
            // BG
            let bgN = SKNodeUtil.createRectNode(rect: CGRect(x:0, y:0, width: result.size.width + margin * 2, height: result.size.width * 2 + margin * 2),
                                                color: .clear, pos: CGPoint(), cornerR: radius)
            if i == 0 {
                bgN.fillColor = UColor.LightGreen
            }
            
            bgN.name = bgNodeName
            pNode.addChild2( bgN )
            correctNodes.append( pNode )
            clientNode!.addChild2( pNode )

            x += textW
            lineTextCnt += 1
            
            if lineTextCnt > lineTexts {
                x = topX
                y += textW
                lineTextCnt = 0
            }
        }
        y += textW + UDpi.toPixel(MARGIN_V * 2)
        
        return y
    }

    /**
     * 正解タッチ用のTextViewを表示する
     * @param canvas
     * @param paint
     * @param offset
     * @param y
     * @return
     */
    private func createQuestionNode( y : CGFloat ) -> CGFloat {
        var lineButtons = Int((size.width - UDpi.toPixel(TEXT_MARGIN_H2)) / UDpi.toPixel(QBUTTON_W + TEXT_MARGIN_H2))
        
        var width : CGFloat
        let questions : List<String> = List()
        
        // 出題文字化どうかの判定を行う（記号や数字使用しない）
        for word in mCorrectWords {
            if !isIgnoreStr(word!) {
                questions.append(word!)
            }
        }
        
        if lineButtons > mCorrectWords.count {
            lineButtons = mCorrectWords.count
        }
        
        if MySharedPref.readBool(MySharedPref.StudyMode4OptionKey) {
            // ランダムに並び替える
            // リストの並びをシャッフルします。
            questions.shuffled()
        } else {
            // アルファベット順に並び替える
            questions.sorted( isOrderedBefore: {$0 < $1} )
        }
        
        width = CGFloat(lineButtons) * UDpi.toPixel(QBUTTON_W + TEXT_MARGIN_H2) - UDpi.toPixel(TEXT_MARGIN_H2)
        
        let topX = (size.width - width) / 2
        var x = topX
        var y = y
        
        var i : Int = 0
        for str in questions {
            let button = UButtonText(
                callbacks : self, type : UButtonType.BGColor, id : i, priority : 0,
                text : str!, createNode : true, x : x, y : y,
                width : UDpi.toPixel(QBUTTON_W), height : UDpi.toPixel(QBUTTON_H),
                fontSize : UDpi.toPixel(FONT_SIZE_L),
                textColor : TEXT_COLOR, bgColor : BUTTON_COLOR)
            clientNode!.addChild2( button.parentNode )
            mQuestionButtons.append(button)
            
            x += UDpi.toPixel(QBUTTON_H + TEXT_MARGIN_H2);
            
            // 改行判定
            if x + button.getWidth() + UDpi.toPixel(TEXT_MARGIN_H2) > size.width {
                x = topX
                y += button.getHeight() + UDpi.toPixel(TEXT_MARGIN_V)
            }
            i += 1
        }
        
        return y
    }

    /**
     * タッチ処理
     * @param vt
     * @return
     */
    public func touchEvent( vt : ViewTouch) -> Bool{
        return self.touchEvent(vt: vt, offset: nil)
    }

    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool{
        var done = false

        // アニメーションや移動中はタッチ受付しない
        if isMovingSize {
            return false
        }

        // 問題ボタン
        for button in mQuestionButtons {
            if button!.touchUpEvent(vt: vt) {
                done = true
            }
        }
        for button in mQuestionButtons {
            if button!.touchEvent(vt: vt, offset: offset) {
                return true
            }
        }

        switch vt.type {
        case .Touch:        // タッチ開始
            break
        case .Click:
            if mState == State.ShowAnswer {
                startDisappearange(frame: ANIME_FRAME)
                done = true
            }
            break
        default:
            break
        }

        return done
    }

    public override func endAnimation() {
        mRequest = RequestToParent.End
    }

    // MARK: Callbacks
    /**
     * UButtonCallbacks
     */
    public func UButtonClicked(id : Int, pressedOn : Bool) -> Bool{
        // 判定を行う
        let button = getButtonById(id)
        let text1 = mCorrectWords[inputPos]
        let text2 = button!.getmText()
        if text1 == text2 {
            // 正解のボタンをタップ
            // すでに正解用として使用したので使えなくする
            button!.setEnabled(false)
            button!.setColor(.darkGray)
 
            if mCorrectFlags[inputPos] {
                if let bgN = correctNodes[inputPos].childNode(withName: bgNodeName) as? SKShapeNode {
                    bgN.fillColor = .clear
                }
            }
            if let labelN = correctNodes[inputPos].childNode(withName: labelNodeName) as? SKLabelNode {
                labelN.text = mCorrectWords[inputPos]
            }
            inputPos += 1
            // スペースや改行をスキップする
            for i in inputPos ..< mCorrectWords.count {
                if isIgnoreStr( mCorrectWords[i] ) {
                    inputPos += 1
                } else {
                    break
                }
            }
            
            if inputPos >= mWord!.characters.count {
                // 終了
                showCorrect(mistaken : false)
            } else {
                if let bgN = correctNodes[inputPos].childNode(withName: bgNodeName) as? SKShapeNode
                {
                    bgN.fillColor = UColor.LightGreen
                }
            }
            // 色を元に戻す
            for _button in mQuestionButtons {
                if _button!.getEnabled() == true && _button!.getColor() == NG_BUTTON_COLOR {
                    _button!.setColor(BUTTON_COLOR)
                }
            }
        } else {
            // 不正解のボタンをタップ
            isMistaken = true
            button!.setColor( NG_BUTTON_COLOR )
            mCorrectFlags[inputPos] = false
            
            if let bgN = correctNodes[inputPos].childNode(withName: bgNodeName) as? SKShapeNode {
                bgN.fillColor = UColor.LightRed
            }

            return true
        }
        
        return true
    }
}

