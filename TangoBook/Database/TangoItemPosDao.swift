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
 * Created by shutaro on 2017/06/14.
 * 単語帳ソートの種類
 */


// 単語帳内のカード数のカウント
public enum BookCountType : Int {
    case OK = 0     // OK Only
    case NG = 1     // NG Only
    case All = 2    // All
}

public class TangoItemPosDao {
     /**
     * Enums
     */
     // 単語帳内のカード数のカウント
    public enum BookCountType : Int{
         case OK     // OK Only
         case NG     // NG Only
         case All     // All
     }

    public static let TAG = "TangoItemPosDao"

    public static var mRealm : Realm?

    // アプリ起動時にRealmオブジェクトを生成したタイミングで呼び出す
    public static func setRealm(_ realm : Realm) {
        mRealm = realm
    }
    
     /**
     * 要素数を取得
     */
     public static func getNum() -> Int {
        let list = selectAll()
        
        return list.count
     }

     /**
     * 全要素取得
     *
     * @return
     */
     public static func selectAll() -> [TangoItemPos] {
        let results = mRealm!.objects(TangoItemPos.self).sorted(byKeyPath: "pos", ascending: true)
        
//        if (UDebug.debugDAO) {
//            print( TAG + "TangoItem selectAll")
//            for item in results {
//                print("TangoItemPosDao: parentType:" + String(item.parentType)
//                         + " parentId:" + item.getParentId()
//                         + " type:" + item.getItemType().description
//                         + " id:" + item.getItemId()
//                         + " pos:" + item.getPos()
//                 );
//             }
//         }
         return Array(results)
     }

     /**
     * 指定の親以下にあるアイテムを全て取得する
     */
    public static func selectByParent(parentType : TangoParentType, parentId : Int)
     -> [TangoItemPos]?
     {
        let results = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND parentId = %d", parentType.rawValue, parentId)
            .sorted(byKeyPath: "pos", ascending: true)
        
        if results.count == 0 {
            return nil
        }
        
         return Array(results)
     }

    /**
     * あるカードの親(ホーム or 単語帳)を検索する
     */
    public static func selectCardParent(cardId : Int) -> TangoItemPos? {
        let result = mRealm!.objects(TangoItemPos.self)
            .filter("itemType = %d AND itemId = %d", TangoItemType.Card.rawValue,
                cardId)
            .first
        
        return result
     }


     /**
     * ホームのアイテムを取得
     *
     * @return
     */
    public static func selectItemsInHome(changeable : Bool) -> [TangoItem]? {
        return selectItemsByParentType(parentType :TangoParentType.Home,
                                       parentId :0,
                                    changeable :changeable)
    }

    public static func selectItemsInTrash(changeable : Bool) -> [TangoItem]? {
        return selectItemsByParentType(parentType: TangoParentType.Trash,
                                       parentId: 0,
                                       changeable: changeable)
    }

     /**
     * 指定の単語帳に含まれるカードのIDを取得する
     */
    public static func getCardIdsByBookId(bookId : Int) -> [Int]? {
        let results = mRealm!.objects(TangoItemPos.self)
        .filter("parentType = %d AND parentId = %d", TangoParentType.Book.rawValue, bookId)
        .sorted(byKeyPath: "pos", ascending: true)

        if results.count == 0 {
            return nil
        }

        // IDのリストを作成
        var ids : [Int] = []
        
        for result in results {
             ids.append( result.getItemId())
        }
        return ids
    }

     /**
     * 指定の単語帳に含まれるカードを取得する
     *
     * @param bookId
     * @return
     */
    public static func selectCardsByBookId(_ bookId : Int) -> [TangoCard]? {
        let results = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND parentId = %d", TangoParentType.Book.rawValue, bookId)
            .sorted(byKeyPath: "pos", ascending: true)
        
        if results.count == 0 {
            return nil
        }

         // IDのリストを作成
        let cards : [TangoCard]? = TangoCardDao.selectByIds(
            itemPoses: Array(results),
            noStar: false,
            changeable: false)
        if cards == nil {
            return nil
        }
        return Array(cards!)
     }

     // オプション付き
     public static func selectCardsByBookIdWithOption(
        bookId : Int, notLearned : Bool) -> [TangoCard]?
     {
        let results = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND parentId = %d", TangoParentType.Book.rawValue, bookId)
            .sorted(byKeyPath: "pos", ascending: true)
        
        if results.count == 0 {
            return nil
        }

        // IDのリストを作成
        let cards = TangoCardDao.selectByIds(itemPoses: Array(results),
                                             noStar: notLearned,
                                             changeable: false)

         return cards
     }


     /**
     * 指定の親の配下にある全てのアイテムを取得する(主にホーム用)
     * アイテムのposでソート済みのリストを返す
     *
     * @param parentType
     * @return
     */
    // itemType が nilなのはありえないので多分使われないメソッド
     public static func selectItemsByParentType(
        parentType : TangoParentType, parentId : Int, changeable : Bool)
        -> [TangoItem]?

     {
         return selectItemsByParentType(
            parentType: parentType,
            parentId: parentId,
            itemType: nil,
            changeable: changeable)
     }

    // itemTypeで取得するアイテムのタイプを指定できるバージョン
    // itemTypeがnullなら全てのタイプを取得
    public static func selectItemsByParentType(
        parentType : TangoParentType,
        parentId : Int,
        itemType : TangoItemType?,
        changeable : Bool) -> [TangoItem]?
    {
         return selectItemsByParentTypeWithSort(
            parentType: parentType,
            parentId: parentId,
            itemType: itemType,
            sortMode: IconSortMode.None,
            changeable: changeable)
    }

    public static func selectItemsByParentTypeWithSort(
        parentType : TangoParentType,
        parentId : Int,
        itemType : TangoItemType?,
        sortMode : IconSortMode,
        changeable : Bool) -> [TangoItem]?
    {
        var _itemPoses : Results<TangoItemPos>? = nil

        if parentType == TangoParentType.Home || parentType == TangoParentType.Trash
        {
            _itemPoses = mRealm!.objects(TangoItemPos.self)
                .filter("parentType = %d", parentType.rawValue)
            if itemType != nil {
                _itemPoses = _itemPoses!.filter("itemType = %d", itemType!.rawValue)
            }
            _itemPoses = _itemPoses!.sorted(byKeyPath: "pos", ascending: true)
         } else {
            _itemPoses = mRealm!.objects(TangoItemPos.self)
                .filter("parentType = %d AND parentId = %d", parentType.rawValue, parentId)
            
            if itemType != nil {
                _itemPoses = _itemPoses!.filter("itemType = %d", itemType!.rawValue)
            }
            _itemPoses = _itemPoses!.sorted(byKeyPath: "pos", ascending: true)
        }
        if _itemPoses!.count == 0{
            return nil
        }

        let itemPoses = Array(_itemPoses!)

        // 格納先
        var items : [TangoItem]? = nil

         // 種類別にItemPosのリストを作成(カード)
        var cardPoses : [TangoItemPos] = []
        var bookPoses : [TangoItemPos] = []

        for item in itemPoses {
            switch TangoItemType.toEnum(item.getItemType()) {
            case .Card:
                cardPoses.append(item)
            case .Book:
                bookPoses.append(item)
            default:
                break
            }
        }

        // 種類別にTangoItemを取得する
        // Card
        var cards : [TangoCard]? = nil
        if cardPoses.count > 0 {
            cards = TangoCardDao.selectByIds(itemPoses: cardPoses, noStar: false, changeable: true)
            if cards == nil {
                cards = []
            }
             // cardsはposでソートされていないので自前でソートする(select sort)
            var sortedCards : [TangoCard] = []
            for itemPos in cardPoses {
                for i in 0...cards!.count - 1 {
                    let card = cards![i]
                    card.itemPos = itemPos
                    if card.id == itemPos.getItemId() {
                        sortedCards.append(card)
                        cards!.remove(at: i)
                    }
                }
            }
            // posが重複していた等の理由でcardsが余っていたらまとめてsortedCardsに追加
            for card in cards! {
                sortedCards.append(card)
            }
            cards = sortedCards
         } else {
             cards = []
         }

         // Book
        var books : [TangoBook]? = nil
        if bookPoses.count > 0 {
            books = TangoBookDao.selectByIds(itemPoses: bookPoses, changeable: changeable)
            if books == nil {
                books = []
            }
             // posが小さい順にソート
            var sortedBooks : [TangoBook] = []
            for itemPos in bookPoses {      // TangoItemPos
                for i in 0...books!.count - 1 {
                    let book = books![i]
                    book.itemPos = itemPos
                    if book.id == itemPos.getItemId() {
                        sortedBooks.append(book)
                        books!.remove(at: i)
                        break
                    }
                }
            }
            books = sortedBooks
         } else {
             books = []
         }

        // posの順にリストを作成
        var sortMode = sortMode
        if sortMode == IconSortMode.None {
            sortMode = IconSortMode.TitleAsc
        }
        items = joinWithSortMode(cards: cards!, books: books!, sortMode: sortMode)

        return items
    }

    public static func selectByCardId(cardId : Int) -> TangoItemPos? {
        let itemPos = mRealm!.objects(TangoItemPos.self)
        .filter("itemType = %d AND itemId = %d", TangoItemType.Card.rawValue, cardId)
        .first
        
        return itemPos
    }

     /**
     * 指定のボックスに含まれるアイテムを取得する
     *
     * @param bookId
     * @param changeable
     * @return カード/単語帳 のアイテムリスト
     */
    public static func selectByBookId(bookId : Int, changeable : Bool) -> [TangoItem]? {
        return selectItemsByParentType(parentType:TangoParentType.Book,
                                       parentId:bookId,
                                       changeable: changeable)
     }

     /**
     * アイテム情報で位置アイテムを取得する
     * @param item
     * @return
     */
    public static func selectByItem(item : TangoItem) -> TangoItemPos? {
        let itemPos = mRealm!.objects(TangoItemPos.self)
            .filter("itemType = %d AND itemId = %d", item.getItemType().rawValue, item.getId())
            .first
         return itemPos;
     }

     /**
     * 指定のParentType配下の TangoItemPos のリストを取得する
     *
     * @param parentType
     * @return
     */
    public static func selectItemPosesByParentType(parentType : TangoParentType)
     -> [TangoItemPos]?
    {
        let results = mRealm!.objects(TangoItemPos.self)
        .filter("parentType = %d", parentType.rawValue)
        
         return Array(results)
     }

     /**
     * 指定のアイテム(TangoItemPos)を除外したアイテムを取得する
     *
     * @param excludeItemPoses
     * @param changeable
     * @return
     */
     public static func selectItemExcludeItemPoses(
        excludeItemPoses : [TangoItemPos],
        changeable : Bool ) -> [TangoItem]?
     {
         // 各type毎に除外IDリストを作成
        var cardIds : [Int] = []
        var bookIds : [Int] = []

         for item in excludeItemPoses {  // TangoItemPos
             switch (TangoItemType.toEnum(item.getItemType())) {
             case .Card:
                 cardIds.append(item.getItemId())
             case .Book:
                 bookIds.append(item.getItemId())
             default:
                break
             }
         }

         // 除外IDを使用して各Typeのリストを取得
         // 種類別にTangoItemを取得する
         // Card
        let cards = TangoCardDao.selectExceptIds(ids: cardIds, changeable: changeable)

         // Book
        let books = TangoBookDao.selectByExceptIds(ids: bookIds, changeable:changeable)

         // posの順にリストを作成
        let items = joinWithSort(cards: cards, books: books)

        return items
     }

     /**
     * ３種類のアイテムリストを結合＆posが小さい順にソートする
     *
     * @param cards
     * @param books
     * @return
     */
    public static func joinWithSort(cards : [TangoCard]?,
                                    books: [TangoBook]?
                                         ) -> [TangoItem]? {
         let minInit = 10000000
        var items : [TangoItem] = []
        
        var cards = cards
        var books = books
        
        if cards == nil {
            cards = []
        }
        if books == nil {
            books = []
        }

         // posの順にリストを作成
         // 各ループでCard,Book,Boxのアイテムの中で一番小さいposのものを出力先のリストに追加する
        var indexs : [Int] = Array(repeating: 0, count: 2)
        var poses : [Int] = Array(repeating: 0, count: 2)

        
         // 各アイテムの先頭のposを取得する
         if indexs[0] < cards!.count {
             poses[0] = cards![indexs[0]].getPos()
         } else {
             poses[0] = minInit
         }

         if indexs[1] < books!.count {
             poses[1] = books![indexs[1]].getPos()
         } else {
             poses[1] = minInit
         }

         let totalCount = cards!.count + books!.count
         var count = 0

         while (true) {
             // 各アイテムリストの先頭のposを取得する
             var posMin = minInit
             var gotTypeIndex = 0
             for i in 0...1 {
                 if posMin > poses[i] {
                     posMin = poses[i]
                     gotTypeIndex = i
                 }
             }
             switch gotTypeIndex {
                 case 0:
                     if indexs[0] < cards!.count {
                         let card = cards![indexs[0]]
                         card.setPos(pos: items.count)
                         items.append(card)

                         // 取得したアイテムを持つリストを１つすすめる
                         indexs[gotTypeIndex] += 1
                         count += 1
                         if indexs[0] < cards!.count {
                             poses[0] = cards![indexs[0]].getPos()
                         } else {
                             poses[0] = minInit
                         }
                     }
                 case 1:
                     if indexs[1] < books!.count {
                         let book = books![indexs[1]]
                        book.setPos(pos: items.count)
                         items.append(book)
                     }

                     indexs[1] += 1
                     count += 1
                     if indexs[1] < books!.count {
                         poses[1] = books![indexs[gotTypeIndex]].getPos()
                     } else {
                         poses[1] = 100000000
                     }
             default:
                break
            }

             // 全ての要素をチェックし終わったら終了
            if count >= totalCount {
                break
            }
         }
         return items
     }

     /**
     * 指定の方法でCardとBookのリストをソート＆結合する
     * @param cards
     * @param books
     * @return
     */
    public static func joinWithSortMode( cards : [TangoCard],
                                         books : [TangoBook],
                                         sortMode : IconSortMode) -> [TangoItem]? {
        if cards.count == 0 && books.count == 0 {
            return nil
        }

        var items : [TangoItem] = []

        // まずはリストを結合
        for card in cards {
            items.append(card)
        }
        for book in books {
            items.append(book)
        }

         // _icons を SortMode の方法でソートする
//         Arrays.sort(items, new Comparator<TangoItem>() {
//             public int compare(TangoItem item1, TangoItem item2) {
//                 if (item1 == null || item2 == null) {
//                     return 0;
//                 }
//                 switch(sortMode) {
//                     case TitleAsc:       // タイトル文字昇順(カードはWordA,単語帳はName)
//                         return item1.getTitle().compareTo (
//                                 item2.getTitle());
//                     case TitleDesc:      // タイトル文字降順
//                         return item2.getTitle().compareTo(
//                                 item1.getTitle());
//
//                     case CreateTimeAsc:        // 作成 昇順
//                     {
//                         if (item1.getCreateTime() == null || item2.getCreateTime() == null)
//                             break;
//                         return item1.getCreateTime().compareTo(
//                                 item2.getCreateTime());
//                     }
//                     case CreateTimeDesc:       // 作成 降順
//                     {
//                         if (item1.getCreateTime() == null || item2.getCreateTime() == null)
//                             break;
//                         return item2.getCreateTime().compareTo(
//                                 item1.getCreateTime());
//                     }
//                     case StudiedTimeAsc:        // 学習日時 昇順
//                     {
//                         Date date1 = item1.getLastStudiedTime();
//                         Date date2 = item2.getLastStudiedTime();
//                         if (date1 == null && date2 == null) break;
//
//                         if (date1 == null) date1 = getOldDate();
//                         if (date2 == null) date2 = getOldDate();
//                         return date1.compareTo(date2);
//                     }
//                     case StudiedTimeDesc:       // 学習日時 降順
//                     {
//                         Date date1 = item1.getLastStudiedTime();
//                         Date date2 = item2.getLastStudiedTime();
//                         if (date1 == null && date2 == null) break;
//
//                         if (date1 == null) date1 = getOldDate();
//                         if (date2 == null) date2 = getOldDate();
//                         return date2.compareTo(date1);
//                     }
//                 }
//                 return 0;
//             }
//         });
         return items
     }

     /**
     * アプリを使用していて出てこないような古い日時を取得する
     * @return
     */
    static var _oldDate : Date? = nil
    private static func getOldDate() -> Date {
         if _oldDate != nil {
             return _oldDate!
         }

        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))
        
        return date!
     }

    /**
     TangoCardの配列のidを配列として取得する
     - parameter <#name#>: <##>
     - throws: <#throw detail#>
     - returns: <#return value#>
     */
    public static func listToIds(list : [TangoCard]) -> [Int] {
        var ids : [Int] = []

        for obj in list {
            ids.append(obj.getId())
        }
        return ids
    }

    /**
     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
     * TangoItemPos
     *
     * @param list
     * @return
     */
    public static func toChangeableItemPos(list : [TangoItemPos]) -> [TangoItemPos] {
        return Array(list)
    }

    /**
     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
     * TangoItem
     *
     * @param list
     * @return
     */
    public static func toChangeableItem(list : [TangoItem]) -> [TangoItem] {
        return Array(list)
    }

     /**
     * 全要素削除
     *
     * @return
     */
     public static func deleteAll() -> Bool {
        let results = mRealm!.objects(TangoItemPos.self)
        if results.count == 0 {
            return false
        }
        
        try! mRealm!.write() {
            mRealm!.delete(results)
        }
        
        return true
     }

     /**
     * IDの位置リストに一致する項目を全て削除する
     */
    public static func deletePositions(positions : [Int]) {
        if positions.count <= 0 {
            return
        }

        let results = mRealm!.objects(TangoItemPos.self).filter("pos In %@", positions)
        
        try! mRealm!.write() {
            mRealm!.delete(results)
        }
     }

     /**
     * 指定の単語帳に含まれるカードを削除する
     *
     * @param bookId
     * @param ids    単語IDの配列
     */
    public static func deteteCardsInBook(bookId : Int, ids : [Int]) {
        if ids.count <= 0 {
            return
        }

        var results = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND parentId = %d AND itemType = %d",
                    TangoParentType.Book.rawValue,
                    bookId,
                    TangoItemType.Card.rawValue )
        results = results.filter("itemId In %@", ids)
        
        if results.count == 0 {
            return
        }

        try! mRealm!.write() {
            mRealm!.delete(results)
        }
    }

     /**
     * １件削除
     * @param item
     */
    public static func deleteItem(item : TangoItem) {
        let result = mRealm!.objects(TangoItemPos.self)
            .filter("itemType = %d AND itemId = %d", item.getItemType().rawValue,
                item.getId())
            .first
        if result == nil {
            return
        }

        try! mRealm!.write() {
            mRealm!.delete(result!)
        }
     }
    
    /**
      指定IDのオブジェクトを削除する
     parameter id : 削除オブジェクトのID
     */
    public static func deleteOne(parentType: Int, parentId: Int, pos: Int) {
        let result = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND parentId = %d AND pos = %d",
                    parentType, parentId, pos )
            .first
        if result == nil {
            return
        }        
        try! mRealm!.write() {
            mRealm!.delete(result!)
        }
    }

     /**
     * 指定のParentType,ParentIdの要素を削除する
     * @param parentType
     * @param parentId
     * @param transaction trueならトランザクションを行う
     * @return
     */
    public static func deleteItemsByParentType(parentType : Int,
                                               parentId : Int,
                                               transaction : Bool ) -> Bool {
        let results = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND parentId = %d", parentType, parentId)
        if results.count == 0 {
            return false
        }

        // Card/BookのIdリストを作成する
        var cardIds : [Int] = []
        var bookIds : [Int] = []
        for itemPos in results {
            switch TangoItemType.toEnum(itemPos.getItemType()) {
            case .Card:
                cardIds.append(itemPos.getItemId())
            
            case .Book:
                bookIds.append(itemPos.getItemId())
            default:
                break
            }
        }

        if transaction {
            try! mRealm!.write() {
                // Card/Book本体を削除
                TangoCardDao.deleteIds(ids: cardIds, transaction: false)
                TangoBookDao.deleteIds(ids: bookIds, transaction: false)
                // Posを削除
                mRealm!.delete(results)
            }
        } else {
            // Card/Book本体を削除
            TangoCardDao.deleteIds(ids: cardIds, transaction: false)
            TangoBookDao.deleteIds(ids: bookIds, transaction: false)
            // Posを削除
            mRealm!.delete(results)
        }

        return true
    }

    /**
     * ゴミ箱配下にあるアイテムを１件削除する
     * @return
     */
    public static func deleteItemInTrash(item : TangoItem) -> Bool{
        let itemPos = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND itemType = %d AND itemId = %d",
                    TangoParentType.Trash.rawValue,
                    item.getItemType().rawValue,
                    item.getId())
        .first
        if itemPos == nil {
            return false
        }

        // アイテムを削除
        switch TangoItemType.toEnum(itemPos!.getItemType()) {
            case .Card:
                _ = TangoCardDao.deleteById(id: item.getId())
            case .Book:
                _ = TangoBookDao.deleteById(id: item.getId())
                 
                // 削除するのがBookなら配下のアイテムを全て削除
                _ = deleteItemsByParentType(parentType: TangoParentType.Book.rawValue,
                                        parentId: itemPos!.getItemId(),
                                        transaction: false)
        default:
           break
        }

        // Posを削除
        try! mRealm!.write() {
            mRealm!.delete(itemPos!)
        }
        return true
     }

     /**
     * ゴミ箱配下にあるアイテムを全て削除する
     * Book内のカードも全て削除する
     * @return
     */
     public static func deleteItemsInTrash() -> Bool {
         let results = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d", TangoParentType.Trash.rawValue)
        
        if results.count == 0 {
            return false
        }
 
        var cardIds : [Int] = []
        var bookIds : [Int] = []

        for itemPos in results {
            if TangoItemType.toEnum(itemPos.getItemType()) == TangoItemType.Book {
                 // Bookなら子要素をまとめて削除
                _ = deleteItemsByParentType(parentType: TangoParentType.Book.rawValue,
                                        parentId: itemPos.getItemId(),
                                        transaction: false)
             }

             switch TangoItemType.toEnum(itemPos.getItemType()) {
                 case .Card:
                     cardIds.append(itemPos.getItemId())
                 case .Book:
                     bookIds.append(itemPos.getItemId())
                 default:
                    break
             }
         }

        try! mRealm!.write() {
            // ゴミ箱直下の要素を削除
            TangoCardDao.deleteIds(ids: cardIds, transaction: false)
            TangoBookDao.deleteIds(ids: bookIds, transaction: false)

            // Posを削除
            mRealm!.delete(results)
        }

         return true
     }

     /**
     * １アイテムを追加する
     * 追加位置はコピー元のコンテナ(ホーム、単語帳）の中の末尾
     * @param item
     * @param parentType
     * @param parentId
     */
    public static func addOne(item : TangoItem, parentType : TangoParentType,
                              parentId : Int, addPos : Int) -> TangoItemPos
    {
         let itemPos = TangoItemPos()
         itemPos.parentType = parentType.rawValue
         itemPos.parentId = parentId
         itemPos.itemType = item.getItemType().rawValue
         itemPos.itemId = item.getId()
         if addPos == -1 {
            itemPos.pos = getNextPos(
                parentType: parentType.rawValue,
                parentId: parentId)
         } else {
             itemPos.pos = addPos + 1
             // 挿入位置以下の位置を１つづつずらす
             slideItemPos(parentType: parentType, parentId: parentId, pos: addPos);
         }

        try! mRealm!.write() {
            mRealm!.add(itemPos)
        }
        return itemPos;
    }

     public static func addOneTransaction(
        item : TangoItem, parentType : TangoParentType,
        parentId : Int, addPos : Int, transaction : Bool) -> TangoItemPos
     {
        let itemPos = TangoItemPos();
        itemPos.parentType = parentType.rawValue
        itemPos.parentId = parentId
        itemPos.itemType = item.getItemType().rawValue
        itemPos.itemId = item.getId()
        
        if addPos == -1 {
            itemPos.pos = getNextPos(
                parentType:parentType.rawValue,
                parentId: parentId)
        } else {
             itemPos.pos = addPos + 1
             // 挿入位置以下の位置を１つづつずらす
             slideItemPos(parentType: parentType, parentId: parentId, pos: addPos);
        }

        if transaction {
            try! mRealm!.write() {
                mRealm!.add(itemPos)
            }
        } else {
            mRealm!.add(itemPos)
        }

        return itemPos
    }
    
    /**
     ダミーのオブジェクトを１件追加
     - returns: 追加したオブジェクト
     */
    public static func addDummy() {
        let itemPos = TangoItemPos()
        itemPos.parentType = TangoParentType.Home.rawValue
        itemPos.parentId = 0
        itemPos.itemType = TangoItemType.Card.rawValue
        itemPos.itemId = 1      // dummy
        itemPos.pos = getNextPos(
                parentType: TangoParentType.Home.rawValue,
                parentId: 0)
        
        try! mRealm!.write() {
            mRealm!.add(itemPos)
        }
    }

     /**
     * 指定位置以降のアイテムを１つづつスライドする
     * @param pos
     */
    public static func slideItemPos(parentType : TangoParentType,
                                    parentId : Int,
                                    pos : Int)
    {
        var results = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d", parentType.rawValue)
        
        if parentType == TangoParentType.Book {
            results = results.filter("parentId = %d", parentId)
        }

        results = results.filter("pos >= %d", pos)
            .sorted(byKeyPath: "pos", ascending: true)
        
        if results.count == 0 {
            return
        }

        let list = Array(results)
        
        try! mRealm!.write() {
            for itemPos in list {
                itemPos.pos = itemPos.getPos() + 1
            }
        }
    }

     /**
     * 単語帳にカードを追加する
     *
     * @param bookId
     * @param cardIds
     */
    public static func addCardsInBook(bookId : Int, cardIds : [Int]) {
        var pos = 0

        for id in cardIds {
            let itemPos = TangoItemPos()
            itemPos.parentType = TangoParentType.Book.rawValue
            itemPos.parentId = bookId
            itemPos.itemType = TangoItemType.Card.rawValue
            itemPos.itemId = id
            itemPos.pos = getNextPosInBook(bookId: bookId)

            try! mRealm!.write() {
                mRealm!.add(itemPos)
            }
            pos += 1
        }
    }

    /**
     * ボックスに要素の追加情報(TangoItemPos)を追加
     *
     * @param itemPoses
     */
    public static func addItemPoses(itemPoses: [TangoItemPos]) {

        try! mRealm!.write() {
            for itemPos in itemPoses {
                let pos = getNextPos(parentType: itemPos.parentType,
                                     parentId: itemPos.getParentId())
                itemPos.pos = pos

                mRealm!.add(itemPos)
            }
        }
    }

     /**
     * 追加先の親のタイプにあった最大posを取得する
     * @param parentType
     * @param parentId
     * @return
     */
    public static func getNextPos(parentType : Int, parentId : Int) -> Int{
         switch TangoParentType.toEnum(parentType) {
            case .Home:
                 return getNextPos(parentType: TangoParentType.Home.rawValue)
            case .Book:
                return getNextPosInBook(bookId: parentId)
            case .Trash:
                return getNextPos(parentType: TangoParentType.Trash.rawValue)
        }
    }

    /**
     * アイテムの位置(pos)を変更する
     *
     * @param oldPos
     * @param newPos
     */
    public static func updatePos(oldPos : Int, newPos : Int) {
        let result = mRealm!.objects(TangoItemPos.self)
            .filter("pos = %d", oldPos)
            .first
        if result == nil {
            return
        }

        try! mRealm!.write() {
            result!.pos = newPos
        }
    }
    
    /**
     １件更新（デバッグ用）
     */
    public static func updateOne(oldParentType: Int, newParentType: Int,
                                 oldParentId: Int, newParentId: Int,
                                 oldPos: Int, newPos : Int)
    {
        let result = mRealm!.objects(TangoItemPos.self)
        .filter("parentType = %d AND parentId = %d AND pos = %d",
                oldParentType, oldParentId, oldPos)
        .first
        
        if result == nil {
            return
        }
        
        try! mRealm!.write() {
            result!.parentType = newParentType
            result!.parentId = newParentId
            result!.pos = newPos
        }
    }

     /**
     * 指定位置以降のアイコンの保持するアイテムのposを更新
     * @param icons
     * @param startPos
     */
    // todo UIconを実装してから
//    public static func updatePoses(icons : [UIcon], startPos : Int )
//     {
//         int pos = startPos;
//
//         mRealm.beginTransaction();
//
//         //for (UIcon icon : icons) {
//         for (int i=startPos; i<icons.size(); i++) {
//             UIcon icon = icons.get(i);
//
//             TangoItem tangoItem = icon.getTangoItem();
//             int itemType;
//             int itemId;
//
//             if (tangoItem == null && icon.getType() == IconType.Trash) {
//                 // ゴミ箱はアイコンにTangoItemを持たないので直接値を設定
//                 itemType = TangoItemType.Trash.ordinal();
//                 itemId = 0;
//             } else {
//                 itemType = tangoItem.getItemType().ordinal();
//                 itemId = tangoItem.getId();
//             }
//
//             TangoItemPos result = mRealm.where(TangoItemPos.class)
//                     .equalTo("itemType", itemType)
//                     .equalTo("itemId", itemId)
//                     .findFirst();
//             if (result == null) continue;
//
//             result.setPos(pos);
//             tangoItem.setPos(pos);
//             pos++;
//         }
//
//         mRealm.commitTransaction();
//     }

     /**
     * ２つのアイテムの位置(pos)を入れ替える
     *
     * @param item1
     * @param item2
     */
    public static func changePos(item1 : TangoItem, item2 : TangoItem) {
         let itemType1 = item1.getItemPos()?.getItemType()
         let itemId1 = item1.getItemPos()?.getItemId()
         let itemType2 = item2.getItemPos()?.getItemType()
         let itemId2 = item2.getItemPos()?.getItemId()

        if itemType1 == nil || itemType2 == nil
            || itemId1 == nil || itemId2 == nil
        {
            return
        }
        
        // ２つのアイテムに紐付けされたItemPosのアイテムの部分を書き換える
        let itemPos1 = mRealm!.objects(TangoItemPos.self)
           .filter("itemType = %d AND itemId = %d", itemType1!, itemId1!)
        .first
        
        let itemPos2 = mRealm!.objects(TangoItemPos.self)
            .filter("itemType = %d AND itemId = %d", itemType2!, itemId2!)
            .first

         if itemPos1 == nil || itemPos2 == nil {
             return
         }

         // DB更新
        try! mRealm!.write() {
            itemPos1!.itemType = itemType2!
            itemPos1!.itemId = itemId2!
            itemPos2!.itemType = itemType1!
            itemPos2!.itemId = itemId1!
        }
        
        // 元の値を更新
        item1.getItemPos()?.itemType = itemType2!
        item1.getItemPos()?.itemId = itemId2!
        item2.getItemPos()?.itemType = itemType1!
        item2.getItemPos()?.itemId = itemId1!
    }

     /**
     * 指定のParent以下のリストの全要素を現在の並び順で更新する
     *
     * @param items アイコンのリスト
     */
    public static func updateAll( items : [TangoItem],
                                  parentType : TangoParentType,
                                  parentId : Int)
    {
        var results = mRealm!.objects(TangoItemPos.self)
           .filter("parentType = %d", parentType.rawValue)
       
        if (parentType == TangoParentType.Home || parentType == TangoParentType.Trash)
        {
            // ホームとゴミ箱は１つしか存在しないため、parentIdを指定する必要はない
        } else {
            results = results.filter("parentId = %d", parentId)
        }
       

        if results.count == 0 {
            return
        }

        
        try! mRealm!.write() {
            // いったんクリア
            mRealm!.delete(results)
            
            // 全要素を追加
            for item in items {
                if item.getItemPos() != nil {
                    mRealm!.add(item.getItemPos()!)
                }
            }
        }
     }

     /**
     * かぶらないposを取得する
     *
     * @return
     */
    public static func getNextPos(parentType : Int) -> Int {
        // 初期化
        var nextPos = 1
        // 最大値を取得
        let maxPos = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d", parentType)
            .max(ofProperty: "pos") as Int!
        
        // 1度もデータが作成されていない場合はNULLが返ってくるため、NULLチェックをする
        if maxPos != nil {
            nextPos = maxPos! + 1;
        }
        
        return nextPos
     }

    public static func getNextPosInBook(bookId : Int) -> Int{
        // 初期化
        var nextPos = 1
        // 最大値を取得
        let maxPos = mRealm!.objects(TangoItemPos.self)
            .filter("parentType = %d AND parentId = %d", TangoParentType.Book.rawValue, bookId)
            .max(ofProperty: "pos") as Int!
        
        // 1度もデータが作成されていない場合はNULLが返ってくるため、NULLチェックをする
        if maxPos != nil {
            nextPos = maxPos! + 1;
        }
        
        return nextPos
    }

     /**
     * 移動系
     */
     /**
     * １アイテムを移動する
     *
     * @param item       移動元アイテム
     * @param parentType 移動先のType
     * @param parentId   移動先のId
     * @return
     */
    public static func moveItem(item : TangoItem, parentType : Int,
                                parentId : Int) -> Bool
    {
        let result = mRealm!.objects(TangoItemPos.self)
            .filter("itemType = %d AND itemId = %d", item.getItemType().rawValue, item.getId())
            .first
        if result == nil {
            return false
        }

        try! mRealm!.write() {
            result!.parentType = parentType
            result!.parentId = parentId
        }
         return true
     }

     /**
     * 複数のアイテムを移動する
     *
     * @param items
     * @param parentType 移動先のType
     * @param parentId   移動先のId
     * @return
     */
    public static func moveItems( items : [TangoItem], parentType : Int, parentId : Int) -> Bool
    {
        var isFirst = true

        var filterStr = ""
        for item in items {
            if isFirst {
                isFirst = false
            } else {
                filterStr += " OR "
            }
            filterStr += String(format: "itemType = %d AND itemId = %d",
                                item.getItemType().rawValue,
                                item.getId())
        }

        let results = mRealm!.objects(TangoItemPos.self).filter(filterStr)
        if results.count == 0 {
            return false
        }

        // update
        try! mRealm!.write() {
            for itemPos in results {
                 itemPos.parentType = parentType
                 itemPos.parentId = parentId
            }
        }
        return true
     }

     /**
     * 複数のアイテムを移動する
     *
     * @param items
     * @param parentType 移動先のType
     * @param parentId   移動先のId
     * @return
     */
    public static func moveNoParentItems( items : [TangoItem],
                                          parentType : Int,
                                          parentId : Int)
    {
        try! mRealm!.write() {
            for item in items {
                let itemPos = TangoItemPos()
                itemPos.parentType = parentType
                itemPos.parentId = parentId
                itemPos.itemType = item.getItemType().rawValue
                itemPos.itemId = item.getId()

                mRealm!.add(itemPos)
            }
        }
     }

     /**
     * １アイテムを削除（ゴミ箱に移動）
     * @param item
     * @return
     */
    public static func moveItemToTrash(item : TangoItem) -> Bool {
        return moveItem(item: item,
                        parentType: TangoParentType.Trash.rawValue,
                        parentId: 0)
    }

     /**
     * 複数のアイテムを削除（ゴミ箱に移動）
     * @param items
     * @return
     */
    public static func moveItemsToTrash( items : [TangoItem]) -> Bool {
        return moveItems(items: items,
                         parentType: TangoParentType.Trash.rawValue,
                         parentId: 0)
     }

     /**
     * アイテムをホームに移動
     * @param item
     * @return
     */
    public static func moveItemToHome(item : TangoItem) -> Bool {
        return moveItem(item: item,
                        parentType: TangoParentType.Home.rawValue,
                        parentId: 0)
    }

     /**
     * カード１つを移動する (Home->Book, Book->Box等の移動で使用可能)
     *
     * @param card       移動元のCard
     * @param parentType 移動先のParentType
     * @param parentId   移動先のParentId
     */
    public static func moveCard(card : TangoCard, parentType : Int, parentId : Int) ->   Bool
    {
        return moveItem(item: card,
                        parentType: parentType,
                        parentId: parentId)
    }

     /**
     * アイコンリストに含まれるアイテムを保存
     * 並び順はアイコンリストと同じ
     * @param icons
     * @param parentType
     * @param parentId
     */
    // todo UIconを実装後に対応
//    public static func saveIcons( icons: [UIcon], parentType : TangoParentType,
//                                  parentId : Int)
//     {
//         LinkedList<TangoItem> items = new LinkedList<>();
//
//         int pos = 0;
//         for (UIcon icon : icons) {
//             TangoItem item = icon.getTangoItem();
//             if (item == null && icon.getType() == IconType.Trash) {
//
//             } else {
//                 items.add(item);
//                 icon.getTangoItem().getItemPos().setPos(pos);
//             }
//             pos++;
//         }
//
//         RealmManager.getItemPosDao().updateAll(items, parentType, parentId);
//     }

//     /**
//     * Homeのアイコン情報を元にTangoItemPosを更新
//     * @param icons
//     */
//     public void saveHomeIcons(List<UIcon> icons) {
//         saveIcons(icons, TangoParentType.Home, 0);
//     }


     /**
     * 指定のParentType、ParentIdの要素数を取得
     * @param parentType
     * @param parentId
     * @return
     */
    public static func countInParentType(
        parentType : TangoParentType,
        parentId : Int) -> Int
    {
        var results = mRealm!.objects(TangoItemPos.self)
                .filter("parentType = %d", parentType.rawValue)
        
        if parentId > 0 {
            results = results.filter("parentId = %d", parentId)
        }
        return results.count
    }

     /**
     * 指定のParentType, ParentId, ItemType の要素数を取得
     * @param parentType
     * @param parentId
     * @param itemType
     * @return
     */
     public static func countInParentType(
        parentType : TangoParentType,
        parentId : Int,
        itemType : TangoItemType) -> Int
     {
         var results = mRealm!.objects(TangoItemPos.self)
            .filter("itemType = %d AND parentType = %d",
                    itemType.rawValue, parentType.rawValue)
         if parentId > 0 {
             results = results.filter("parentId = %d", parentId)
         }
         return results.count
     }

     /**
     * 指定のBook以下のカード数を取得する
     * @param bookId
     * @param countType
     * @return
     */
    public static func countCardInBook(bookId : Int, countType : BookCountType) -> Int
    {
        let items = selectByBookId(bookId: bookId, changeable: false)
        if items == nil {
            return 0
        }

        var count = 0;
        switch countType {
            case .OK:
                fallthrough
            case .NG:
                for item in items! {
                    if !(item is TangoCard) {
                        continue
                    }
                    let card : TangoCard = item as! TangoCard
                    if card.star {
                        if countType == BookCountType.OK {
                            count += 1
                        }
                    } else {
                        if countType == BookCountType.NG {
                            count += 1
                        }
                    }
                }
            case .All:
                count = items!.count
        }
        return count
     }

//     /**
//     * XMLファイルから読み込んだItemPosを追加する
//     * @param poses
//     */
//     public void addXmlPos(List<Pos> poses, boolean transaction) {
//         if (poses == null || poses.size() == 0) {
//             return;
//         }
//         if (transaction) {
//             mRealm.beginTransaction();
//         }
//         for (Pos _pos : poses) {
//             TangoItemPos pos = new TangoItemPos();
//             pos.setParentType( _pos.getParentType());
//             pos.setParentId( _pos.getParentId());
//             pos.setPos( _pos.getPos());
//             pos.setItemType( _pos.getItemType());
//             pos.setItemId( _pos.getItemId());
//             mRealm.copyToRealm(pos);
//         }
//         if (transaction) {
//             mRealm.commitTransaction();
//         }
//     }
// }
}
