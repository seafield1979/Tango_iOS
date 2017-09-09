//
//  StudyCardStackSelect.swift
//  TangoBook
//      4択学習用のカードスタック
//      正解を含む４枚のカードを表示して、ユーザーはそこから正解を選べる
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import UIKit

/**
 * Created by shutaro on 2016/12/27.
 *
 */

public class StudyCardStackSelect : UDrawable {
    // MARK: Enums
    enum State : Int, EnumEnumerable {
        case Starting           // 開始時の演出
        case Main               // 学習中のメイン状態
        case ShowCorrect        // 正解判定後
        case ShowCorrectEnd     // 正解表示終了
        case End                // すべての問題を学習終了
    }

    // MARK: Cnstants
    
    // layout
    public let MARGIN_V = 10;
    private let MOVING_FRAME = 10;
    private static let STUDY_CARD_NUM : Int = 4
    private let FONT_SIZE = 17;
    private let FONT_SIZE_L = 20;
    private let CARD_MARGIN_V = 7;

    private let DRAW_PRIORITY = 100;

    // color
    private let TEXT_COLOR : UIColor = .black

    /**
     * Member Variables
     */
    private var mCardManager : StudyCardsManager
    private var cardsStackCallbacks : CardsStackCallbacks?
    private var mScreenW : CGFloat = 0
    private var mStudyMode : StudyMode = .Choice4
    private var mStudyType : StudyType = .EtoJ

    private var mStudyCards : [StudyCardSelect?] = Array(repeating: nil, count: StudyCardStackSelect.STUDY_CARD_NUM)
    private var mState : State = State.Main

    private var mQuestionView : UTextView?

    // 学習中するカードリスト。出題ごとに１つづつ減っていく
    private var mCards : List<TangoCard> = List()

    // MARK: Accessor
    /**
     * 残りのカード枚数を取得する
     * @return
     */
    public func getCardCount() -> Int {
        return mCards.count
    }

    // MARK: Initializer
    public init(cardManager : StudyCardsManager,
                cardsStackCallbacks : CardsStackCallbacks,
                x : CGFloat, y : CGFloat, screenW : CGFloat,
                width : CGFloat, height : CGFloat)
    {
        mCardManager = cardManager
        self.cardsStackCallbacks = cardsStackCallbacks
        
        super.init(priority: 90, x: x, y: y, width: width, height: height )

        mScreenW = screenW
        mStudyMode = MySharedPref.getStudyMode()
        mStudyType = MySharedPref.getStudyType()

        // カードマネージャーのカードリストをコピー
        for card in mCardManager.getCards() {
            mCards.append(card!)
        }

        setStudyCard()
    }

    // MARK: Mathods
    /**
     * １解答分のカードを準備する
     * １枚の正解と３枚の不正解をランダムで配置する
     */
    private func setStudyCard() {
        let okCard : TangoCard = mCards.pop()!
        var ngCards : [TangoCard]

        let isEnglish : Bool = (mStudyType == StudyType.EtoJ)

        // 描画ノードを全削除
        parentNode.removeAllChildren()
        
        // 問題(英語 or 日本語)
        let questionStr = isEnglish ? okCard.wordA : okCard.wordB
        
        // 出題 TextView
        mQuestionView = UTextView.createInstance(
            text : questionStr!, fontSize : UDpi.toPixel(FONT_SIZE_L),
            priority : DRAW_PRIORITY, alignment : UAlignment.CenterX,
            createNode : true, isFit : true, isDrawBG : false,
            x : 0, y : 0, width : size.width, color : TEXT_COLOR, bgColor : nil)
        
        parentNode.addChild2( mQuestionView!.parentNode )

        // 不正解用のカードを取得
        var bookId : Int
        if MySharedPref.readBool( MySharedPref.StudyMode3OptionKey ) {
            // 全てのカードから抽出
            bookId = 0
        } else {
            bookId = mCardManager.getBookId()
        }
        ngCards = TangoCardDao.selectAtRandom( num: StudyCardStackSelect.STUDY_CARD_NUM - 1,
                                               exceptId: okCard.getId(),
                                               bookId: bookId)

        var card : StudyCardSelect
        let cardH : CGFloat = (size.height - UDpi.toPixel(MARGIN_V) * 2 - mQuestionView!.getHeight()) / CGFloat(StudyCardStackSelect.STUDY_CARD_NUM)

        // 出題カードの配置
        let y = mQuestionView!.getHeight() + UDpi.toPixel(MARGIN_V) + cardH / 2

        let correctIndex : Int = Int(arc4random() % UInt32(StudyCardStackSelect.STUDY_CARD_NUM))
        var ngIndex = 0
        for i in 0 ..< StudyCardStackSelect.STUDY_CARD_NUM {
            let pos = CGPoint(x: 0, y: y + CGFloat(i) * cardH)
            if i == correctIndex {
                card = StudyCardSelect(
                    card : okCard, isCorrect : true, isEnglish : !isEnglish,
                    screenW : mScreenW, height : cardH - UDpi.toPixel(CARD_MARGIN_V),
                    pos: pos)
            } else {
                card = StudyCardSelect(
                    card : ngCards[ngIndex], isCorrect : false,
                    isEnglish : !isEnglish,
                    screenW : mScreenW, height : cardH - UDpi.toPixel(CARD_MARGIN_V),
                    pos: pos)
                ngIndex += 1
            }
            
            parentNode.addChild2(card.parentNode)
            mStudyCards[i] = card

            // 初期座標設定
            // 座標はエリアの中心を指定する
            card.startAppearance(frame: MOVING_FRAME)
        }
    }

    /**
     * 毎フレームの処理
     * @return true:処理中
     */
    public override func doAction() -> DoActionRet{

        switch mState {
        case .Main:
            // カードがタッチされたら正解判定を行う
            for card in mStudyCards {
                if card!.getRequest() == StudyCardSelect.RequestToParent.Touch {
                    mState = State.ShowCorrect

                    // 全てのカードを正解表示状態にする
                    for _card in mStudyCards {
                        card!.setRequest( StudyCardSelect.RequestToParent.None )
                        _card!.setShowCorrect( _card!.isCorrect )
                    }
                    card!.setShowCorrect( true )
                    if card!.isCorrect {
                        // 正解
                        if let addCard = card!.getTangoCard() {
                            mCardManager.addOkCard( addCard )
                        }
                    } else {
                        // 不正解
                        // 不正解でもNGリストに追加するのは正解のカード
                        for _card in mStudyCards {
                            if _card!.isCorrect {
                                if let addCard = _card!.getTangoCard() {
                                    mCardManager.addNgCard( addCard )
                                }
                                break
                            }
                        }
                    }
                    break
                }
            }
            break
        case .ShowCorrect:
            // タッチされたらカードが消えるアニメーション開始
            var isTouched = false
            for card in mStudyCards {
                if card!.getRequest() == .Touch {
                    isTouched = true
                }
            }
            if isTouched {
                mState = .ShowCorrectEnd
                for card in mStudyCards {
                    card!.startDisappearange(frame: MOVING_FRAME)
                }
            }
            break
        case .ShowCorrectEnd:
            // 全てのカードが非表示になるまで待つ
            var isAllFinished = true
            for card in mStudyCards {
                if card!.getRequest() != StudyCardSelect.RequestToParent.End {
                    isAllFinished = false
                }
            }
            if isAllFinished {
                if mCards.count == 0 {
                    mState = State.End
                    if cardsStackCallbacks != nil {
                        cardsStackCallbacks!.CardsStackFinished()
                    }
                } else {
                    // 次の問題を準備
                    mState = State.Main
                    setStudyCard()
                    if cardsStackCallbacks != nil {
                        cardsStackCallbacks!.CardsStackChangedCardNum(cardNum: mCards.count)
                    }
                }
            }
            break
        default:
            break
        }

        // カードの移動等の処理
        var ret = DoActionRet.None
        for card in mStudyCards {
            if card!.doAction() != DoActionRet.None {
                ret = DoActionRet.Redraw
            }
        }
        return ret
    }


    /**
     * 描画処理
     * @param canvas
     * @param paint
     * @param offset 独自の座標系を持つオブジェクトをスクリーン座標系に変換するためのオフセット値
     */
    public override func draw() {
        // 問題
        mQuestionView!.draw()
        
        // 配下のカードを描画する
        for card in mStudyCards {
            card!.draw()
        }
    }

    /**
     * タッチ処理
     * @param vt
     * @return true:処理中
     */
    public override func touchEvent( vt : ViewTouch, offset : CGPoint?) -> Bool {
        for card in mStudyCards {
            if card!.touchEvent(vt: vt, offset: pos) {
                return true
            }
        }
        return false
    }
}
