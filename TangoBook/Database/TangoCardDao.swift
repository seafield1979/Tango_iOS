//
//  TangoCardDao.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * 単語帳のDAO
 */

public class TangoCardDao {
    public static let TAG = "TangoCardDao"
    
    public static var mRealm : Realm?
    
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }

    /**
     * カード数を取得
     * @return カード数
     */
    public static func getNum() -> Int {
        let results = mRealm!.objects(TangoCard.self)
        return results.count
    }
    
    /**
     * 全要素取得
     * @param isCopy: コピーを行うかどうか（※コピーでないと取得先でプロパティを変更できない）
     * @return nameのString[]
     */
    public static func selectAll() -> [TangoCard]{
        // Realmに保存されてるDog型のオブジェクトを全て取得
        let results : Results = mRealm!.objects(TangoCard.self)
        
        //　返すのはコピー。コピーでないと書き換えができない
        return toChangeable(results)
    }
    
    /**
     * 要素を全て表示する
     */
    public static func showAll() {
        let objects = selectAll()
        
        print("TangoCard num: " + objects.count.description)
        
        for obj in objects {
            print(obj.description)
        }
    }

    /**
     * 指定の単語帳に追加されていない単語を取得
     * @return
     */
    public static func selectExceptIds(ids : [Int], changeable : Bool)
        -> [TangoCard]?
    {
        let results : Results = mRealm!.objects(TangoCard.self).filter("NOT (id In %@)", ids)
        
        if results.count == 0 {
            return nil
        }
        
        return toChangeable(results)
    }

    /**
     * wordA,wordBの文字列と部分一致しているものを取得する
     * @param searchStr : WordA,WordBに対する検索文字列
     * @return
     */
    public static func selectByWord(_ searchStr : String?) -> [TangoCard]? {
        if searchStr == nil || searchStr!.utf8.count == 0 {
            return nil
        }
        let results = mRealm!.objects(TangoCard.self).filter("wordA contains %@", searchStr!)
        let results2 = mRealm!.objects(TangoCard.self).filter("wordB contains %@", searchStr!)
        
        //　返すのはコピー。コピーでないと書き換えができない
        var ret : [TangoCard] = []
        for result in results {
            ret.append(result.copy() as! TangoCard)
        }
        for result in results2 {
            ret.append(result.copy() as! TangoCard)
        }

        return ret
    }
    /**
     * アイテムをランダムで取得する
     * @param num 取得件数
     * @param exceptId 除外するID
     * @param bookId 指定の単語帳から取得、0なら全てのカードから取得する
     * @return
     */
    public static func selectAtRandom(num : Int, exceptId : Int, bookId : Int) -> [TangoCard]
    {
        var cards : [TangoCard] = []
        var results : Results<TangoCard>
        
        if bookId == 0 {
            // 全ての項目を取得しているがRealmは遅延ロードでそんなに時間がかからない。
            results = mRealm!.objects(TangoCard.self)
            
            // 最低２件以上のレコードがないと後の処理で無限ループにはまる
            if results.count <= 2 {
                for _ in 0...num-1 {
                    var card : TangoCard? = nil
                    while (true) {
                        // ランダムのIDが除外IDとおなじなら再度ランダム値を取得する
                        let randIndex : Int = Int(arc4random()) % (results.count + 1)
                        card = results[randIndex]
                        if card!.id != exceptId {
                            break
                        }
                    }
                    cards.append(card!.copy() as! TangoCard)
                }
            }
        } else {
            // 単語帳の中からランダム抽出
            var cardsInBook = TangoItemPosDao.selectCardsByBookId(bookId)
            if !(cardsInBook == nil || cardsInBook!.count <= 2) {
                for _ in 0...num-1 {
                    var card : TangoCard! = nil
                    while (true) {
                        // ランダムのIDが除外IDとおなじなら再度ランダム値を取得する
                        let randIndex = Int(arc4random()) % cardsInBook!.count
                        card = cardsInBook![randIndex]
                        if card!.getId() != exceptId {
                            cardsInBook!.remove(at: randIndex)      // 同じカードが抽出されないように削除
                            break
                        }
                    }
                    if card != nil {
                        cards.append(card!.copy() as! TangoCard)
                    }
                }
            }
        }
        // 足りない場合はダミーのカードを追加
        if cards.count < num {
            let card = TangoCard()
            card.id = 0      // dummy
            card.wordA = "dummy"
            card.wordB = "dummy"
            for _ in cards.count...num - 1 {
                cards.append(card.copy() as! TangoCard)
            }
        }
        
        return cards
    }

    /**
     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
     * @param list
     * @return
     */
    public static func toChangeable( _ list : Results<TangoCard>) -> [TangoCard]
    {
        var ret : [TangoCard] = []
        for obj in list {
            ret.append(obj.copy() as! TangoCard)
        }
        return ret
    }

    /**
     * List<TangoCard>を List<TangoItem>に変換する
     * @param cards
     * @return
     */
    public static func toItems( cards : [TangoCard]?) -> [TangoItem]?{
        if cards == nil {
            return nil
        }
        
        var items : [TangoItem] = []
        for card in cards! {
            items.append(card)
        }
        return items
    }

    /**
     * 指定のIDの要素を取得
     * @param itemPoses
     * @return
     */
    public static func selectByIds( itemPoses : [TangoItemPos],
                                    noStar : Bool, changeable : Bool ) -> [TangoCard]?
    {
        if itemPoses.count <= 0 {
            return nil
        }
        
        var results : Results<TangoCard>? = nil
        
        // idのリストを作成する
        var ids : [Int] = []
        for itemPos in itemPoses {
            ids.append(itemPos.getItemId())
        }
        
        results = mRealm!.objects(TangoCard.self)
            .filter("id In %@", ids)
    
        if noStar {
            // 星がついていないもののみ
            results = results!.filter("star = false")
        }
        
        let cards = Array(results!)
        var _cards = Array(cards)
        var sortedList : [TangoCard]? = []
        
        var i : Int
        for item in itemPoses {
            i = 0
            for card in _cards {
                if card.getId() == item.getItemId() {
                    sortedList!.append(card.copy() as! TangoCard)
                    _cards.remove(at: i)
                    break
                }
                i += 1
            }
        }
        return sortedList
    }

    /**
     * 指定のIDの要素を取得(1つ)
     */
    public static func selectById(id : Int) -> TangoCard? {
        let result = mRealm!.objects(TangoCard.self)
            .filter("id = %d", id).first
        
        if result == nil {
            return nil
        }
        
        return result!.copy() as? TangoCard
    }

    /**
     * 学習したカードリストからカードのリストを取得する
     * @param studiedCards
     * @param ok  true:OKのみ取得 false:NGのみ取得
     * @return
     */
    public static func selectByStudiedCards(
        studiedCards : [TangoStudiedCard],
        ok : Bool, changeable : Bool) -> [TangoCard]?
    {
        if (studiedCards.count <= 0) {
            return nil
        }
        
        var ids : [Int] = []
        for studiedCard in studiedCards {
            ids.append(studiedCard.getCardId())
        }
        if ids.count == 0 {
            // idの条件を指定しないと全件取得してしまうので抜ける
            return nil
        }
        
        let results = mRealm!.objects(TangoCard.self)
            .filter("id In %@", ids)
        
        return toChangeable(results)
    }

    /**
     * 要素を追加
     * @param
     * @param
     */
    public static func add1(wordA : String, wordB : String) {
        let card = TangoCard()
        card.id = getNextId()
        card.wordA = wordA
        card.wordB = wordB
        card.comment = "comment"
        let now = Date()
        card.createTime = now
        card.updateTime = now
        
        // データを追加
        try! mRealm!.write() {
            mRealm!.add(card)
        }
    }

    /**
     * 要素を追加 TangoCardオブジェクトをそのまま追加
     * @param card
     * @param addPos カードの追加位置 -1なら最後に追加
     */
    public static func addOne(card : TangoCard,
                              parentType : TangoParentType,
                              parentId : Int,
                              addPos : Int)
    {
        addOneTransaction(card: card, parentType: parentType,
                          parentId: parentId, addPos: addPos,
                          transaction: true)
    }

    // トランザクションを行うかどうかをオプションで与えられるタイプ
    public static func addOneTransaction(card : TangoCard,
                                         parentType : TangoParentType,
                                         parentId : Int,
                                         addPos : Int,
                                         transaction : Bool)
    {
        let now = Date()
        card.id = getNextId()
        card.createTime = now
        card.updateTime = now
        
        if (transaction) {
            // データを追加
            try! mRealm!.write() {
                mRealm!.add(card)
            }
        } else {
            mRealm!.add(card)
        }

        let itemPos = TangoItemPosDao.addOneTransaction(
            item: card,
            parentType: parentType,
            parentId: parentId,
            addPos: addPos,
            transaction: transaction)
        
        // 書き換えられるようにコピーを作成
        let copy = itemPos.copy() as! TangoItemPos
        
        card.setItemPos(itemPos: copy)
    }

    /**
     * カードをコピーする
     */
    public static func copyOne(card : TangoCard) -> TangoCard{
        let newCard = TangoCard.copyCard(card: card)
        
        // データを追加
        try! mRealm!.write() {
            mRealm!.add(newCard)
        }
        
        return newCard
    }

    /**
     * ダミーのデータを一件追加
     */
    public static func addDummy() {
        let newId = getNextId()
        let randVal = String(arc4random() % 1000)
        
        let card = TangoCard()
        card.id = newId
        card.wordA = "hoge" + randVal
        card.wordB = "ほげ" + randVal
        card.comment = "comment:" + randVal
        card.color = Int((UIColor.black).intColor())
        card.star = false
        
        let now = Date()
        card.createTime = now
        card.updateTime = now
        
        // データを追加
        try! mRealm!.write() {
            mRealm!.add(card)
        }
        
        // Posを追加
        _ = TangoItemPosDao.addOne(item: card, parentType: .Home, parentId: 0, addPos: -1)
    }
    
    public static func addPresetCards( parentId: Int, cards : List<PresetCard>) {
        // 大量のデータをまとめて追加するのでトランザクションは外で行う
        try! mRealm!.write() {
            for presetCard in cards {
                let card = TangoCard.createCard()
                card.wordA = presetCard!.mWordA
                card.wordB = presetCard!.mWordB
                card.comment = presetCard!.mComment
                card.isNew = false
                addOneTransaction(card : card, parentType : TangoParentType.Book, parentId : parentId, addPos : -1, transaction : false)
            }
        }
    }

    /**
     * Update:
     */
    /**
     * 要素を更新
     */
    public static func updateOne(id : Int, wordA : String, wordB : String) {
        let updateCard = mRealm!.objects(TangoCard.self).filter("id = %d", id).first
        
        if updateCard == nil {
            return
        }
        
        try! mRealm!.write() {
            updateCard!.wordA = wordA
            updateCard!.wordB = wordB
        }
    }

    /**
     * 指定したIDの項目を更新する
     * @param card
     */
    public static func updateOne(card : TangoCard ) {
        let updateCard = mRealm!.objects(TangoCard.self).filter("id = %d", card.id).first
        if updateCard == nil {
            return
        }
        
        try! mRealm!.write() {
            updateCard!.wordA = card.wordA
            updateCard!.wordB = card.wordB
            updateCard!.comment = card.comment
            updateCard!.color = card.color
            updateCard!.updateTime = Date()
        }
    }


    /**
     * IDのリストに一致する項目を全て更新する
     * @param ids
     * @param wordA  更新するA
     * @param wordB  更新するB
     */
    public static func updateByIds(ids : [Int], wordA : String, wordB : String) {
        let results = mRealm!.objects(TangoCard.self)
            .filter("id In %@", ids)
        
        try! mRealm!.write() {
            for card in results {
                card.wordA = wordA
                card.wordB = wordB
            }
        }
    }

    /**
     * スターのON/OFFを切り替える
     * @param card
     * @return 切り替え後のStarの値
     */
    public static func toggleStar(card : TangoCard) -> Bool {
        let updateCard = mRealm!.objects(TangoCard.self).filter("id = %@", card.getId()).first
        if updateCard == nil {
            return false
        }
        
        let newValue = updateCard!.star ? false : true
        
        try! mRealm!.write() {
            updateCard!.star = newValue
        }
        
        return newValue
    }

    /**
     * NEWフラグを変更する
     */
    public static func updateNewFlag(card : TangoCard, isNew : Bool) {
        let updateCard = mRealm!.objects(TangoCard.self).filter("id = %d", card.getId()).first
        if updateCard == nil {
            return
        }
        
        try! mRealm!.write() {
            updateCard!.isNew = isNew
        }
    }

    /**
     * Delete:
     */
    /**
     * IDのリストに一致する項目を全て削除する
     */
    public static func deleteIds(ids : [Int], transaction : Bool) {
        if ids.count <= 0 {
            return
        }
        
        let results = mRealm!.objects(TangoCard.self).filter("id In %@", ids)
        
        if transaction {
            try! mRealm!.write() {
                mRealm!.delete(results)
            }
        } else {
            mRealm!.delete(results)
        }
    }

    /**
     * 全要素削除
     *
     * @return
     */
    public static func deleteAll() -> Bool {
        let results = mRealm!.objects(TangoCard.self)
        if results.count == 0 {
            return false
        }
        try! mRealm!.write() {
            mRealm!.delete(results)
        }
        return true
    }


    /**
     * カードを削除する
     * @param id
     * @return
     */
    public static func deleteById(_ id : Int) -> Bool {
        let result = mRealm!.objects(TangoCard.self).filter("id = %d", id).first

        if result == nil {
            return false
        }
        
        try! mRealm!.write() {
            mRealm!.delete(result!)
        }
        return true
    }

    /**
     * 学習履歴(OK/NG)を追加する
     */
    public static func addHistory() {
        
    }

    /**
     * 学習日付を更新する
     */
    private static func updateStudyTime() {
        
    }

    /**
     * かぶらないプライマリIDを取得する
     * @return
     */
    public static func getNextId() -> Int{
        // 初期化
        var nextId : Int = 1
        // userIdの最大値を取得
        let lastId = mRealm!.objects(TangoCard.self).max(ofProperty: "id") as Int?
        
        if lastId != nil {
            nextId = lastId! + 1
        }
        return nextId
    }


    /**
     * XMLファイルから読み込んだバックアップ用を追加する
     * @param cards          カード
     * @param transaction   トランザクションを行うかどうか
     */
//    public static func addBackupCards(cards : [Card], transaction : Bool) {
//        if cards.count == 0 {
//            return
//        }
//        if (transaction) {
//            mRealm.beginTransaction();
//        }
//        for (Card _card : cards) {
//            TangoCard card = new TangoCard();
//            card.setId( _card.getId() );
//            card.setWordA( _card.getWordA() );
//            card.setWordB( _card.getWordB() );
//            card.setComment( _card.getComment());
//            card.setCreateTime( _card.getCreateTime());
//            card.setColor( _card.getColor());
//            card.setStar( _card.isStar());
//            card.setNewFlag( _card.isNewFlag());
//            
//            mRealm.copyToRealm(card);
//        }
//        if (transaction) {
//            mRealm.commitTransaction();
//        }
//    }
//
    /**
     * NGカードを追加する
     * すでにNG単語帳に同じ名前のカードがあったら追加しない。
     * @param cards
     */
//public void addNgCards(List<TangoCard> cards) {
//    if (cards == null || cards.size() == 0) return;
//    
//    LinkedList<TangoCard> _cards = new LinkedList<>(toChangeable(cards));
//    // NG単語帳内のカードを取得
//    List<TangoCard> ngCards = RealmManager.getItemPosDao().selectCardsByBookId(TangoBookDao
//        .NGBookId);
//    
//    // 追加するカードからNG単語帳のカードを除去
//    if (ngCards != null && ngCards.size() > 0) {
//        for (TangoCard ngCard : ngCards) {
//            for (TangoCard card : _cards) {
//                if (card.getId() == ngCard.getOriginalId()) {
//                    _cards.remove(card);
//                    break;
//                }
//            }
//        }
//    }
//    
//    // 追加する
//    for (TangoCard card : _cards) {
//        card.setOriginalId(card.getId());
//        RealmManager.getCardDao().addOne(card, TangoParentType.Book, TangoBookDao.NGBookId,
//                                         -1);
//    }
//}
//}
}
