//
//  StudyCardsManager.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/07.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation


/**
 * Created by shutaro on 2016/12/07.
 *
 * 学習画面のカードを管理するクラス
 * これから出題するカード、学習済みのカード等をリスト管理する
 */

public class StudyCardsManager {
    /**
     * Enums
     */
    public enum BoxType : Int {
        case OK
        case NG
    }

    /**
     * Consts
     */
    public let TAG = "StudyCardsManager";


    /**
     * Member Variables
     */
    // 学習単語帳のId
    private var mBookId : Int = 0

    // 学習するカードのリスト
    private var mCards : List<TangoCard> = List()

    // 学習済みのカードのリスト
    private var mNgCards : List<TangoCard> = List()
    private var mOkCards : List<TangoCard> = List()

    // Options
    private var mStudyMode : StudyMode = .SlideOne

    /**
     * Get/Set
     */
    public func getCards() -> List<TangoCard> { return mCards; }
    public func getStudyMode() -> StudyMode {
        return mStudyMode
    }
    public func getBookId() -> Int { return mBookId; }
    public func getCardCount() -> Int {
        return mCards.count
    }

    public func getNgCards() -> List<TangoCard> {
        return mNgCards
    }

    public func getOkCards() -> List<TangoCard> {
        return mOkCards
    }

    public func addOkCard( _ card : TangoCard) { mOkCards.append(card)}
    public func addNgCard( _ card : TangoCard) { mNgCards.append(card)}

    /**
     * Constructor
     */
    public static func createInstance(bookId : Int, cards : [TangoCard] ) -> StudyCardsManager
    {
        let instance = StudyCardsManager(bookId: bookId, cards: cards)
        return instance
    }

    public static func createInstance( book : TangoBook) -> StudyCardsManager {
        let notLearned = StudyFilter.toEnum(MySharedPref.readInt(MySharedPref.StudyFilterKey)
        ) == StudyFilter.NotLearned;

        let _cards = TangoItemPosDao.selectCardsByBookIdWithOption(bookId: book.getId(), notLearned: notLearned)
        let instance = StudyCardsManager(bookId: book.getId(), cards: _cards)
        return instance
    }

    public init( bookId : Int, cards : [TangoCard]?) {
        mBookId = bookId;
        mStudyMode = StudyMode.toEnum(MySharedPref.readInt(MySharedPref.StudyModeKey));
        let studyOrder = StudyOrder.toEnum(MySharedPref.readInt(MySharedPref
                .StudyOrderKey))

        if cards != nil {
            for card in cards! {
                mCards.append(card)
            }

            // ランダムに並び替える
            if studyOrder == StudyOrder.Random {
//                Collections.shuffle(mCards)
            }
        }
    }

    /**
     * Methods
     */
    /**
     * 出題するカードを１枚抜き出す
     * 抜き出したカードはリストから削除
     * @return
     */
    public func popCard() -> TangoCard? {
        return mCards.pop()
    }

    public func putCardIntoBox( card : TangoCard, boxType : BoxType) {
        if boxType == .OK {
            mOkCards.append(card)
        } else {
            mNgCards.append(card)
        }
    }
}

