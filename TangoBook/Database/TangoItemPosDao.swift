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
// todo あとで適切なファイルに移動する
public enum IconSortMode {
    case None
    case TitleAsc
    case TitleDesc
    case CreateTimeAsc
    case CreateTimeDesc
    case StudiedTimeAsc
    case StudiedTimeDesc
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
        if list == nil {
            return 0
        }
         return list!.count
     }

     /**
     * 全要素取得
     *
     * @return
     */
     public static func selectAll() -> [TangoItemPos]? {
        let results = mRealm!.objects(TangoItemPos.self).sorted(byKeyPath: "pos", ascending: true)
        
        if results.count == 0 {
            return nil
        }

        if (UDebug.debugDAO) {
            print( TAG + "TangoItem selectAll")
            for item in results {
                print("TangoItemPosDao", ""
                   + " parentType:" + TangoParentType.toString(value: item.parentType)
                         + " parentId:" + item.getParentId()
                         + " type:" + item.getItemType().description
                         + " id:" + item.getItemId()
                         + " pos:" + item.getPos()
                 );
             }
         }
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
            .filter("itemType = %d AND itemId = %d", TangoItemType.Card.rawValue, cardId)
            .first
        
        if result == nil {
            return nil
        }
        
        return TangoItemPos(value: result)
     }


     /**
     * ホームのアイテムを取得
     *
     * @return
     */
    public static func selectItemsInHome(changeable : Bool) -> [TangoItem] {
        return selectItemsByParentType(TangoParentType.Home, 0, changeable)
    }

    public static func selectItemsInTrash(changeable : Bool) -> [TangoItem] {
        return selectItemsByParentType(TangoParentType.Trash, 0, changeable)
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
    public static func selectCardsByBookId(bookId : Int) -> [TangoCard]? {
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

         return Array(cards)
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
        let cards = TangoCardDao.selectByIds(itemPoses: results,
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
     public static func selectItemsByParentType(
        parentType : TangoParentType, parentId : Int, changeable : Bool)
        -> [Tangoitem]?

     {
         return selectItemsByParentType(parentType, parentId, null, changeable);
     }

    // itemTypeで取得するアイテムのタイプを指定できるバージョン
    // itemTypeがnullなら全てのタイプを取得
    public static func selectItemsByParentType(
        parentType : TangoParentType,
        parentId : Int,
        itemType : TangoItemType,
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
        itemType : TangoItemType,
        sortMode : IconSortMode,
        changeable : Bool) -> [TangoItem]?
    {
        let _itemPoses : Results<TangoItemPos>? = nil

        if parentType == TangoParentType.Home || parentType == TangoParentType.Trash
        {
            let _itemPoses = mRealm!.objects(TangoItemPos.self)
                .filter("parentType = %d AND itemType = %d", parentType.rawValue, itemType.rawValue)
                .sorted(byKeyPath: "pos", ascending: true)
         } else {
            let _itemPoses = mRealm!.objects(TangoItemPos.self)
                .filter("parentType = %d AND parentId = %d AND itemType = %d",
                        parentType.rawValue, parentId, itemType.rawValue)
                .sorted(byKeyPath: "pos", ascending: true)
        }
        if _itemPoses.count == 0{
            return nil
        }

        let itemPoses = Array(_itemPoses)

        // 格納先
        var items : [TangoItem]? = nil

         // 種類別にItemPosのリストを作成(カード)
        let cardPoses : [TangoItemPos] = []
        let bookPoses : [TangoItemPos] = []

        for item in itemPoses {
            switch item.getItemType() {
                case .Card:
                    cardPoses.add(item)
                    break
                case .Book:
                    bookPoses.add(item)
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
        items = joinWithSortMode(cards: cards, books: books, sortMode: sortMode)

        return items
    }

    public static func selectByCardId(cardId : Int) -> TangoItemPos {
        let itemPos = mRealm!.objects(TangoItemPos.self)
        .filter("itemType = %d AND itemId = %d", TangoItemType.Card.rawValue, cardId)
        .first
        
        return itemPos
    }

//     /**
//     * 指定のボックスに含まれるアイテムを取得する
//     *
//     * @param bookId
//     * @param changeable
//     * @return カード/単語帳 のアイテムリスト
//     */
//     public List<TangoItem> selectByBookId(int bookId, boolean changeable) {
//         return selectItemsByParentType(TangoParentType.Book, bookId, changeable);
//     }

//     /**
//     * アイテム情報で位置アイテムを取得する
//     * @param item
//     * @return
//     */
//     public TangoItemPos selectByItem(TangoItem item) {
//         TangoItemPos itemPos = mRealm.where(TangoItemPos.class)
//                 .equalTo("itemType", item.getItemType().ordinal())
//                 .equalTo("itemId", item.getId())
//                 .findFirst();
//         return itemPos;
//     }

//     /**
//     * 指定のParentType配下の TangoItemPos のリストを取得する
//     *
//     * @param parentType
//     * @return
//     */
//     public List<TangoItemPos> selectItemPosesByParentType(TangoParentType parentType) {
//         RealmResults<TangoItemPos> results = mRealm.where(TangoItemPos.class)
//                 .equalTo("parentType", parentType.ordinal())
//                 .findAll();
//         return results;
//     }

//     /**
//     * 指定のアイテム(TangoItemPos)を除外したアイテムを取得する
//     *
//     * @param excludeItemPoses
//     * @param changeable
//     * @return
//     */
//     public List<TangoItem> selectItemExcludeItemPoses(
//             List<TangoItemPos> excludeItemPoses,
//             boolean changeable) {
//         // 各type毎に除外IDリストを作成
//         LinkedList<Integer> cardIds = new LinkedList<>();
//         LinkedList<Integer> bookIds = new LinkedList<>();
//         LinkedList<Integer> boxIds = new LinkedList<>();

//         for (TangoItemPos item : excludeItemPoses) {
//             switch (TangoItemType.toEnum(item.getItemType())) {
//                 case Card:
//                     cardIds.add(item.getItemId());
//                     break;
//                 case Book:
//                     bookIds.add(item.getItemId());
//                     break;
//             }
//         }

//         // 除外IDを使用して各Typeのリストを取得
//         // 種類別にTangoItemを取得する
//         // Card
//         List<TangoCard> cards;
//         cards = RealmManager.getCardDao()
//                 .selectExceptIds(cardIds, changeable);

//         // Book
//         List<TangoBook> books;
//         books = RealmManager.getBookDao()
//                 .selectByExceptIds(bookIds, changeable);

//         // posの順にリストを作成
//         List<TangoItem> items = joinWithSort(cards, books);

//         return items;
//     }

//     /**
//     * ３種類のアイテムリストを結合＆posが小さい順にソートする
//     *
//     * @param cards
//     * @param books
//     * @return
//     */
//     public List<TangoItem> joinWithSort(List<TangoCard> cards,
//                                         List<TangoBook> books
//                                         ) {
//         final int minInit = 10000000;
//         LinkedList<TangoItem> items = new LinkedList<>();

//         // posの順にリストを作成
//         // 各ループでCard,Book,Boxのアイテムの中で一番小さいposのものを出力先のリストに追加する
//         int[] indexs = new int[2];
//         int[] poses = new int[2];

//         for (int i = 0; i < 2; i++) {
//             indexs[i] = 0;
//         }

//         // 各アイテムの先頭のposを取得する
//         if (indexs[0] < cards.size()) {
//             poses[0] = cards.get(indexs[0]).getPos();
//         } else {
//             poses[0] = minInit;
//         }

//         if (indexs[1] < books.size()) {
//             poses[1] = books.get(indexs[1]).getPos();
//         } else {
//             poses[1] = minInit;
//         }

//         int totalCount = cards.size() + books.size();
//         int count = 0;

//         while (true) {
//             // 各アイテムリストの先頭のposを取得する
//             int posMin = minInit;
//             int gotTypeIndex = 0;
//             for (int i = 0; i < 2; i++) {
//                 if (posMin > poses[i]) {
//                     posMin = poses[i];
//                     gotTypeIndex = i;
//                 }
//             }
//             switch (gotTypeIndex) {
//                 case 0:
//                     if (indexs[0] < cards.size()) {
//                         TangoCard card = cards.get(indexs[0]);
//                         card.setPos(items.size());
//                         items.add(card);

//                         // 取得したアイテムを持つリストを１つすすめる
//                         indexs[gotTypeIndex]++;
//                         count++;
//                         if (indexs[0] < cards.size()) {
//                             poses[0] = cards.get(indexs[0]).getPos();
//                         } else {
//                             poses[0] = minInit;
//                         }
//                     }
//                     break;
//                 case 1:
//                     if (indexs[1] < books.size()) {
//                         TangoBook book = books.get(indexs[1]);
//                         book.setPos(items.size());
//                         items.add(book);
//                     }

//                     indexs[1]++;
//                     count++;
//                     if (indexs[1] < books.size()) {
//                         poses[1] = books.get(indexs[gotTypeIndex]).getPos();
//                     } else {
//                         poses[1] = 100000000;
//                     }
//                     break;
//             }

//             // 全ての要素をチェックし終わったら終了
//             if (count >= totalCount) break;
//         }
//         return items;
//     }

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
            items.append(card!)
        }
        for book in books {
            items.append(book!)
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
         return array
     }

//     /**
//     * アプリを使用していて出てこないような古い日時を取得する
//     * @return
//     */
//     static Date _oldDate = null;
//     private Date getOldDate() {
//         if (_oldDate != null) {
//             return _oldDate;
//         }
//         DateFormat df = new SimpleDateFormat("yyy-MM-dd hh:mm:ss");
//         try {
//             _oldDate = df.parse("2000-01-01 00:00:00");
//             return _oldDate;
//         } catch (ParseException e) {
//         }
//         return null;
//     }

//     public static List<Integer> listToIds(List<TangoCard> list) {
//         LinkedList<Integer> ids = new LinkedList<>();

//         for (TangoCard obj : list) {
//             ids.add(obj.getId());
//         }
//         return ids;
//     }

//     /**
//     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
//     * TangoItemPos
//     *
//     * @param list
//     * @return
//     */
//     public List<TangoItemPos> toChangeableItemPos(List<TangoItemPos> list) {
//         LinkedList<TangoItemPos> newList = new LinkedList<TangoItemPos>();
//         for (TangoItemPos item : list) {
//             TangoItemPos newItem = mRealm.copyFromRealm(item);
//             newList.add(newItem);
//         }
//         return newList;
//     }

//     /**
//     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
//     * TangoItem
//     *
//     * @param list
//     * @return
//     */
//     public LinkedList<TangoItem> toChangeableItem(List<TangoItem> list) {
//         LinkedList<TangoItem> newList = new LinkedList<>();
//         for (TangoItem item : list) {
//             // TangoItemのインスタンス別に処理する
//             if (item instanceof TangoCard) {
//                 TangoCard _item = (TangoCard) item;
//                 newList.add((mRealm.copyFromRealm(_item)));
//             } else if (item instanceof TangoBook) {
//                 TangoBook _item = (TangoBook) item;
//                 newList.add((mRealm.copyFromRealm(_item)));
//             }
//         }
//         return newList;
//     }

//     /**
//     * 全要素削除
//     *
//     * @return
//     */
//     public boolean deleteAll() {
//         RealmResults<TangoItemPos> results = mRealm.where(TangoItemPos.class).findAll();
//         mRealm.beginTransaction();
//         boolean ret = results.deleteAllFromRealm();
//         mRealm.commitTransaction();
//         return ret;
//     }

//     /**
//     * IDの位置リストに一致する項目を全て削除する
//     */
//     public void deletePositions(Integer[] positions) {
//         if (positions.length <= 0) return;

//         mRealm.beginTransaction();

//         RealmQuery<TangoItemPos> query = mRealm.where(TangoItemPos.class);

//         // Add query conditions:
//         boolean isFirst = true;
//         for (int pos : positions) {
//             if (isFirst) {
//                 isFirst = false;
//             } else {
//                 query.or();
//             }
//             query.equalTo("pos", pos);
//         }
//         // Execute the query:
//         RealmResults<TangoItemPos> results = query.findAll();

//         results.deleteAllFromRealm();
//         mRealm.commitTransaction();
//     }

//     /**
//     * 指定の単語帳に含まれるカードを削除する
//     *
//     * @param bookId
//     * @param ids    単語IDの配列
//     */
//     public void deteteCardsInBook(int bookId, Integer[] ids) {
//         if (ids.length <= 0) return;

//         RealmQuery<TangoItemPos> query = mRealm.where(TangoItemPos.class);

//         // Add query conditions:
//         query.equalTo("parentType", TangoParentType.Book.ordinal())
//                 .equalTo("parentId", bookId)
//                 .equalTo("itemType", TangoItemType.Card.ordinal());

//         boolean isFirst = true;
//         for (int id : ids) {
//             if (isFirst) {
//                 isFirst = false;
//             } else {
//                 query.or();
//             }
//             query.equalTo("itemId", id);
//         }

//         RealmResults<TangoItemPos> results = query.findAll();

//         mRealm.beginTransaction();
//         results.deleteAllFromRealm();
//         mRealm.commitTransaction();
//     }

//     /**
//     * １件削除
//     * @param item
//     */
//     public boolean deleteItem(TangoItem item) {
//         TangoItemPos result = mRealm.where(TangoItemPos.class)
//                 .equalTo("itemType", item.getItemType().ordinal())
//                 .equalTo("itemId", item.getId())
//                 .findFirst();
//         if (result == null) return false;

//         mRealm.beginTransaction();
//         result.deleteFromRealm();
//         mRealm.commitTransaction();
//         return true;
//     }

//     /**
//     * 指定のParentType,ParentIdの要素を削除する
//     * @param parentType
//     * @param parentId
//     * @return
//     */
//     public boolean deleteItemsByParentType(int parentType, int parentId, boolean transaction) {
//         RealmResults<TangoItemPos> results = mRealm.where(TangoItemPos.class)
//                 .equalTo("parentType", parentType)
//                 .equalTo("parentId", parentId)
//                 .findAll();
//         if (results == null) return false;

//         // Card/BookのIdリストを作成する
//         LinkedList<Integer> cardIds = new LinkedList<>();
//         LinkedList<Integer> bookIds = new LinkedList<>();
//         for (TangoItemPos itemPos : results) {
//             switch(TangoItemType.toEnum(itemPos.getItemType())) {
//                 case Card:
//                     cardIds.add(itemPos.getItemId());
//                     break;
//                 case Book:
//                     bookIds.add(itemPos.getItemId());
//                     break;
//             }
//         }

//         if (transaction) {
//             mRealm.beginTransaction();
//         }

//         // Card/Book本体を削除
//         RealmManager.getCardDao().deleteIds(cardIds, false);
//         RealmManager.getBookDao().deleteIds(bookIds, false);

//         // Posを削除
//         results.deleteAllFromRealm();

//         if (transaction) {
//             mRealm.commitTransaction();
//         }

//         return true;
//     }

//     /**
//     * ゴミ箱配下にあるアイテムを１件削除する
//     * @return
//     */
//     public boolean deleteItemInTrash(TangoItem item) {
//         TangoItemPos itemPos = mRealm.where(TangoItemPos.class)
//                 .equalTo("parentType", TangoParentType.Trash.ordinal())
//                 .equalTo("itemType", item.getItemType().ordinal())
//                 .equalTo("itemId", item.getId())
//                 .findFirst();
//         if (itemPos == null) return false;

//         mRealm.beginTransaction();

//         // アイテムを削除
//         switch( TangoItemType.toEnum(itemPos.getItemType())) {
//             case Card:
//                 RealmManager.getCardDao().deleteById(item.getId());
//                 break;
//             case Book:
//                 RealmManager.getBookDao().deleteById(item.getId());
//                 // 削除するのがBookなら配下のアイテムを全て削除
//                 deleteItemsByParentType(TangoParentType.Book.ordinal(), itemPos.getItemId(), false);
//                 break;
//         }

//         // Posを削除
//         itemPos.deleteFromRealm();

//         mRealm.commitTransaction();

//         return true;
//     }

//     /**
//     * ゴミ箱配下にあるアイテムを全て削除する
//     * Book内のカードも全て削除する
//     * @return
//     */
//     public boolean deleteItemsInTrash() {
//         RealmResults<TangoItemPos> results = mRealm.where(TangoItemPos.class)
//                 .equalTo("parentType", TangoParentType.Trash.ordinal())
//                 .findAll();
//         if (results == null) return false;


//         mRealm.beginTransaction();

//         LinkedList<Integer> cardIds = new LinkedList<>();
//         LinkedList<Integer> bookIds = new LinkedList<>();

//         for (TangoItemPos itemPos : results) {
//             if (TangoItemType.toEnum(itemPos.getItemType()) == TangoItemType.Book) {
//                 // Bookなら子要素をまとめて削除
//                 deleteItemsByParentType(TangoParentType.Book.ordinal(), itemPos.getItemId(), false);
//             }

//             switch(TangoItemType.toEnum(itemPos.getItemType())) {
//                 case Card:
//                     cardIds.add(itemPos.getItemId());
//                     break;
//                 case Book:
//                     bookIds.add(itemPos.getItemId());
//                     break;
//             }
//         }

//         // ゴミ箱直下の要素を削除
//         RealmManager.getCardDao().deleteIds(cardIds, false);
//         RealmManager.getBookDao().deleteIds(bookIds, false);

//         // Posを削除
//         results.deleteAllFromRealm();

//         mRealm.commitTransaction();

//         return true;
//     }

//     /**
//     * １アイテムを追加する
//     * 追加位置はコピー元のコンテナ(ホーム、単語帳）の中の末尾
//     * @param item
//     * @param parentType
//     * @param parentId
//     */
//     public TangoItemPos addOne(TangoItem item, TangoParentType parentType, int parentId, int
//             addPos) {
//         TangoItemPos itemPos = new TangoItemPos();
//         itemPos.setParentType(parentType.ordinal());
//         itemPos.setParentId(parentId);
//         itemPos.setItemType(item.getItemType().ordinal());
//         itemPos.setItemId(item.getId());
//         if (addPos == -1) {
//             itemPos.setPos(getNextPos(parentType.ordinal(), parentId));
//         } else {
//             itemPos.setPos(addPos + 1);
//             // 挿入位置以下の位置を１つづつずらす
//             slideItemPos(parentType, parentId, addPos);
//         }

//         mRealm.beginTransaction();
//         mRealm.copyToRealm(itemPos);
//         mRealm.commitTransaction();

//         return itemPos;
//     }

//     public TangoItemPos addOneTransaction(TangoItem item, TangoParentType parentType,
//                                           int parentId, int addPos, boolean transaction)
//     {
//         TangoItemPos itemPos = new TangoItemPos();
//         itemPos.setParentType(parentType.ordinal());
//         itemPos.setParentId(parentId);
//         itemPos.setItemType(item.getItemType().ordinal());
//         itemPos.setItemId(item.getId());
//         if (addPos == -1) {
//             itemPos.setPos(getNextPos(parentType.ordinal(), parentId));
//         } else {
//             itemPos.setPos(addPos + 1);
//             // 挿入位置以下の位置を１つづつずらす
//             slideItemPos(parentType, parentId, addPos);
//         }

//         if (transaction) {
//             mRealm.beginTransaction();
//         }
//         mRealm.copyToRealm(itemPos);

//         if (transaction) {
//             mRealm.commitTransaction();
//         }

//         return itemPos;
//     }

//     /**
//     * 指定位置以降のアイテムを１つづつスライドする
//     * @param pos
//     */
//     public void slideItemPos(TangoParentType parentType, int parentId, int pos) {
//         RealmQuery<TangoItemPos> query = mRealm.where(TangoItemPos.class);
//         query.equalTo("parentType", parentType.ordinal());
//         if (parentType == TangoParentType.Book) {
//             query.equalTo("parentId", parentId);
//         }

//         RealmResults<TangoItemPos> results = query.greaterThanOrEqualTo("pos", pos)
//                 .findAllSorted("pos", Sort.ASCENDING);

//         if (results == null || results.size() == 0) {
//             return;
//         }

//         List<TangoItemPos> list = toChangeableItemPos(results);
//         mRealm.beginTransaction();
//         for (TangoItemPos itemPos : list) {
//             itemPos.setPos(itemPos.getPos() + 1);
//             //mRealm.copyToRealm(itemPos);
//         }
//         mRealm.commitTransaction();
//     }

//     /**
//     * 単語帳にカードを追加する
//     *
//     * @param bookId
//     * @param cardIds
//     */
//     public void addCardsInBook(int bookId, Integer[] cardIds) {
//         int pos = 0;

//         for (int id : cardIds) {
//             TangoItemPos itemPos = new TangoItemPos();
//             itemPos.setParentType(TangoParentType.Book.ordinal());
//             itemPos.setParentId(bookId);
//             itemPos.setItemType(TangoItemType.Card.ordinal());
//             itemPos.setItemId(id);
//             itemPos.setPos(getNextPosInBook(bookId));

//             mRealm.beginTransaction();
//             mRealm.copyToRealm(itemPos);
//             mRealm.commitTransaction();
//             pos++;
//         }
//     }

//     /**
//     * ボックスに要素の追加情報(TangoItemPos)を追加
//     *
//     * @param itemPoses
//     */
//     public void addItemPoses(List<TangoItemPos> itemPoses) {

//         mRealm.beginTransaction();
//         for (TangoItemPos itemPos : itemPoses) {
//             int pos = getNextPos(itemPos.getParentType(), itemPos.getParentId());
//             itemPos.setPos(pos);

//             mRealm.copyToRealm(itemPos);
//         }
//         mRealm.commitTransaction();
//     }

//     /**
//     * 追加先の親のタイプにあった最大posを取得する
//     * @param parentType
//     * @param parentId
//     * @return
//     */
//     public int getNextPos(int parentType, int parentId) {
//         switch (TangoParentType.toEnum(parentType)) {
//             case Home:
//                 return getNextPos(TangoParentType.Home.ordinal());
//             case Book:
//                 return getNextPosInBook(parentId);
//             case Trash:
//                 return getNextPos(TangoParentType.Trash.ordinal());
//         }
//         return 0;
//     }

//     /**
//     * アイテムの位置(pos)を変更する
//     *
//     * @param oldPos
//     * @param newPos
//     */
//     public void updatePos(int oldPos, int newPos) {
//         TangoItemPos item = mRealm.where(TangoItemPos.class).equalTo("pos", oldPos).findFirst();
//         if (item == null) return;

//         mRealm.beginTransaction();
//         item.setPos(newPos);
//         mRealm.commitTransaction();
//     }

//     /**
//     * 指定位置以降のアイコンの保持するアイテムのposを更新
//     * @param icons
//     * @param startPos
//     */
//     public void updatePoses(List<UIcon> icons, int startPos )
//     {
//         int pos = startPos;

//         mRealm.beginTransaction();

//         //for (UIcon icon : icons) {
//         for (int i=startPos; i<icons.size(); i++) {
//             UIcon icon = icons.get(i);

//             TangoItem tangoItem = icon.getTangoItem();
//             int itemType;
//             int itemId;

//             if (tangoItem == null && icon.getType() == IconType.Trash) {
//                 // ゴミ箱はアイコンにTangoItemを持たないので直接値を設定
//                 itemType = TangoItemType.Trash.ordinal();
//                 itemId = 0;
//             } else {
//                 itemType = tangoItem.getItemType().ordinal();
//                 itemId = tangoItem.getId();
//             }

//             TangoItemPos result = mRealm.where(TangoItemPos.class)
//                     .equalTo("itemType", itemType)
//                     .equalTo("itemId", itemId)
//                     .findFirst();
//             if (result == null) continue;

//             result.setPos(pos);
//             tangoItem.setPos(pos);
//             pos++;
//         }

//         mRealm.commitTransaction();
//     }

//     /**
//     * ２つのアイテムの位置(pos)を入れ替える
//     *
//     * @param item1
//     * @param item2
//     */
//     public void changePos(TangoItem item1, TangoItem item2) {
//         int itemType1 = item1.getItemPos().getItemType();
//         int itemId1 = item1.getItemPos().getItemId();
//         int itemType2 = item2.getItemPos().getItemType();
//         int itemId2 = item2.getItemPos().getItemId();

//         // ２つのアイテムに紐付けされたItemPosのアイテムの部分を書き換える
//         TangoItemPos itemPos1 = mRealm.where(TangoItemPos.class)
//                 .equalTo("itemType", itemType1)
//                 .equalTo("itemId", itemId1)
//                 .findFirst();
//         TangoItemPos itemPos2 = mRealm.where(TangoItemPos.class)
//                 .equalTo("itemType", itemType2)
//                 .equalTo("itemId", itemId2)
//                 .findFirst();

//         if (itemPos1 == null || itemPos2 == null) {
//             return;
//         }

//         // DB更新
//         mRealm.beginTransaction();
//         itemPos1.setItemType(itemType2);
//         itemPos1.setItemId(itemId2);
//         itemPos2.setItemType(itemType1);
//         itemPos2.setItemId(itemId1);
//         mRealm.commitTransaction();

//         // 元の値を更新
//         item1.getItemPos().setItemType(itemType2);
//         item1.getItemPos().setItemId(itemId2);
//         item2.getItemPos().setItemType(itemType1);
//         item2.getItemPos().setItemId(itemId1);
//     }

//     /**
//     * 指定のParent以下のリストの全要素を現在の並び順で更新する
//     *
//     * @param items アイコンのリスト
//     */
//     public void updateAll(List<TangoItem> items,
//                           TangoParentType parentType, int parentId) {

//         RealmResults<TangoItemPos> results;
//         if (parentType == TangoParentType.Home || parentType == TangoParentType.Trash) {
//             results = mRealm.where(TangoItemPos.class)
//                     .equalTo("parentType", parentType.ordinal())
//                     .findAll();
//         } else {
//             results = mRealm.where(TangoItemPos.class)
//                     .equalTo("parentType", parentType.ordinal())
//                     .equalTo("parentId", parentId)
//                     .findAll();
//         }

//         if (results == null) return;

//         mRealm.beginTransaction();

//         // いったんクリア
//         results.deleteAllFromRealm();

//         // 全要素を追加
//         for (TangoItem item : items) {
//             mRealm.copyToRealm(item.getItemPos());
//         }

//         mRealm.commitTransaction();
//     }

//     /**
//     * かぶらないposを取得する
//     *
//     * @return
//     */
//     public int getNextPos(int parentType) {
//         // 初期化
//         int nextPos = 1;
//         // 最大値を取得
//         Number maxPos = mRealm.where(TangoItemPos.class)
//                 .equalTo("parentType", parentType)
//                 .max("pos");
//         // 1度もデータが作成されていない場合はNULLが返ってくるため、NULLチェックをする
//         if (maxPos != null) {
//             nextPos = maxPos.intValue() + 1;
//         }
//         return nextPos;
//     }


//     public int getNextPosInBook(int bookId) {
//         int nextPos = 1;
//         Number maxPos = mRealm.where(TangoItemPos.class)
//                 .equalTo("parentType", TangoParentType.Book.ordinal())
//                 .equalTo("parentId", bookId)
//                 .max("pos");
//         if (maxPos != null) {
//             nextPos = maxPos.intValue() + 1;
//         }
//         return nextPos;
//     }

//     /**
//     * 移動系
//     */
//     /**
//     * １アイテムを移動する
//     *
//     * @param item       移動元アイテム
//     * @param parentType 移動先のType
//     * @param parentId   移動先のId
//     * @return
//     */
//     public boolean moveItem(TangoItem item, int parentType, int parentId) {
//         TangoItemPos result = mRealm.where(TangoItemPos.class)
//                 .equalTo("itemType", item.getItemType().ordinal())
//                 .equalTo("itemId", item.getId())
//                 .findFirst();
//         if (result == null) return false;

//         mRealm.beginTransaction();
//         result.setParentType(parentType);
//         result.setParentId(parentId);
//         mRealm.commitTransaction();

//         return true;
//     }

//     /**
//     * 複数のアイテムを移動する
//     *
//     * @param items
//     * @param parentType 移動先のType
//     * @param parentId   移動先のId
//     * @return
//     */
//     public boolean moveItems(Iterable<TangoItem> items, int parentType, int parentId) {
//         RealmQuery<TangoItemPos> query = mRealm.where(TangoItemPos.class);

//         boolean isFirst = true;

//         for (TangoItem item : items) {
//             if (isFirst) {
//                 isFirst = false;
//             } else {
//                 query.or();
//             }
//             query.equalTo("itemType", item.getItemType().ordinal())
//                     .equalTo("itemId", item.getId());
//         }

//         RealmResults<TangoItemPos> results = query.findAll();
//         if (results == null) return false;

//         // update
//         mRealm.beginTransaction();
//         for (TangoItemPos itemPos : results) {
//             itemPos.setParentType(parentType);
//             itemPos.setParentId(parentId);
//         }
//         mRealm.commitTransaction();
//         return true;
//     }

//     /**
//     * 複数のアイテムを移動する
//     *
//     * @param items
//     * @param parentType 移動先のType
//     * @param parentId   移動先のId
//     * @return
//     */
//     public void moveNoParentItems(Iterable<TangoItem> items, int parentType, int parentId) {
//         mRealm.beginTransaction();
//         for (TangoItem item : items) {
//             TangoItemPos itemPos = new TangoItemPos();
//             itemPos.setParentType(parentType);
//             itemPos.setParentId(parentId);
//             itemPos.setItemType(item.getItemType().ordinal());
//             itemPos.setItemId(item.getId());

//             mRealm.copyToRealm(itemPos);
//         }
//         mRealm.commitTransaction();
//     }

//     /**
//     * １アイテムを削除（ゴミ箱に移動）
//     * @param item
//     * @return
//     */
//     public boolean moveItemToTrash(TangoItem item) {
//         return moveItem(item, TangoParentType.Trash.ordinal(), 0);
//     }

//     /**
//     * 複数のアイテムを削除（ゴミ箱に移動）
//     * @param items
//     * @return
//     */
//     public boolean moveItemsToTrash(Iterable<TangoItem> items) {
//         return moveItems(items, TangoParentType.Trash.ordinal(), 0);
//     }

//     /**
//     * アイテムをホームに移動
//     * @param item
//     * @return
//     */
//     public boolean moveItemToHome(TangoItem item) {
//         return moveItem(item, TangoParentType.Home.ordinal(), 0);
//     }

//     /**
//     * カード１つを移動する (Home->Book, Book->Box等の移動で使用可能)
//     *
//     * @param card       移動元のCard
//     * @param parentType 移動先のParentType
//     * @param parentId   移動先のParentId
//     */
//     public boolean moveCard(TangoCard card, int parentType, int parentId) {
//         return moveItem(card, parentType, parentId);
//     }

//     /**
//     * アイコンリストに含まれるアイテムを保存
//     * 並び順はアイコンリストと同じ
//     * @param icons
//     * @param parentType
//     * @param parentId
//     */
//     public void saveIcons(List<UIcon> icons, TangoParentType parentType,
//                               int parentId)
//     {
//         LinkedList<TangoItem> items = new LinkedList<>();

//         int pos = 0;
//         for (UIcon icon : icons) {
//             TangoItem item = icon.getTangoItem();
//             if (item == null && icon.getType() == IconType.Trash) {

//             } else {
//                 items.add(item);
//                 icon.getTangoItem().getItemPos().setPos(pos);
//             }
//             pos++;
//         }

//         RealmManager.getItemPosDao().updateAll(items, parentType, parentId);
//     }

//     /**
//     * Homeのアイコン情報を元にTangoItemPosを更新
//     * @param icons
//     */
//     public void saveHomeIcons(List<UIcon> icons) {
//         saveIcons(icons, TangoParentType.Home, 0);
//     }


//     /**
//     * 指定のParentType、ParentIdの要素数を取得
//     * @param parentType
//     * @param parentId
//     * @return
//     */
//     public int countInParentType(TangoParentType parentType, int parentId)
//     {
//         RealmQuery query = mRealm.where(TangoItemPos.class)
//                 .equalTo("parentType", parentType.ordinal());
//         if (parentId > 0) {
//             query = query.equalTo("parentId", parentId);
//         }
//         return (int)query.count();
//     }

//     /**
//     * 指定のParentType, ParentId, ItemType の要素数を取得
//     * @param parentType
//     * @param parentId
//     * @param itemType
//     * @return
//     */
//     public int countInParentType(TangoParentType parentType, int parentId, TangoItemType itemType) {
//         RealmQuery query = mRealm.where(TangoItemPos.class)
//                 .equalTo("itemType", itemType.ordinal())
//                 .equalTo("parentType", parentType.ordinal());
//         if (parentId > 0) {
//             query = query.equalTo("parentId", parentId);
//         }
//         return (int)query.count();
//     }

//     /**
//     * 指定のBook以下のカード数を取得する
//     * @param bookId
//     * @param countType
//     * @return
//     */
//     public int countCardInBook(int bookId, BookCountType countType) {
//         List<TangoItem> items = selectByBookId( bookId, false);

//         int count = 0;
//         switch( countType) {
//             case OK:
//             case NG:
//             {
//                 for (TangoItem item : items) {
//                     if (!(item instanceof TangoCard)) continue;
//                     TangoCard card = (TangoCard)item;
//                     if(card.getStar()) {
//                         if (countType == BookCountType.OK) count++;
//                     } else {
//                         if (countType == BookCountType.NG) count++;
//                     }
//                 }
//             }
//                 break;
//             case All:
//                 count = items.size();
//         }
//         return count;
//     }

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
