//
//  TangoBookDao.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/19.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation
//import UIKit
import RealmSwift

/**
 * 単語帳(TangoBook)のDAO
 */
public class TangoBookDao {
    /**
     * Constract
     */
    public static let TAG = "TangoBookDao";
    
    public static let NGBookId = 100000;
    
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
     * @return nameのString[]
     */
    public static func selectAll() -> [TangoBook] {
        let results = mRealm!.objects(TangoBook.self)
        
        return toChangeable(results)
    }
    
    /**
     * 要素を全て表示する
     */
    public static func showAll() {
        let objects = selectAll()
        
        print("TangoBook num: " + objects.count.description)
        
        for obj in objects {
            print(obj.description)
        }
    }

    /**
     * 変更不可なRealmのオブジェクトを変更可能なリストに変換する
     * @param list
     * @return
     */
    public static func toChangeable(_ list : Results<TangoBook>) -> [TangoBook] {
        var ret : [TangoBook] = []

        for obj in list {
            ret.append(obj.copy() as! TangoBook)
        }
        return ret
    }

    /**
     * 複数のIDの要素を取得
     * @param itemPoses
     * @return
     */
    public static func selectByIds(itemPoses : [TangoItemPos],
                                   changeable : Bool) -> [TangoBook]?
    {
        if itemPoses.count <= 0 {
            return nil
        }
        
        var ids : [Int] = []
        for item in itemPoses {
            ids.append(item.getItemId())
        }
        
        let results = mRealm!.objects(TangoBook.self).filter("id In %@", ids)
        if results.count == 0 {
            return nil
        }
        
        return toChangeable(results)
    }

    /**
     * 指定のIDの要素を取得(1つ)
     */
    public static func selectById(id : Int) -> TangoBook? {
        let result = mRealm!.objects(TangoBook.self).filter("id = %d", id).first
        if result == nil {
            return nil
        }
        
        return result!.copy() as? TangoBook
    }

    /**
     * 指定の単語帳に追加されていない単語を取得
     * @return
     */
    public static func selectByExceptIds(ids : [Int], changeable : Bool)
        -> [TangoBook]?
    {
        let results = mRealm!.objects(TangoBook.self).filter("NOT (id IN %@)", ids)
        
        if results.count == 0 {
            return nil
        }
        
        return toChangeable(results)
    }

    /**
     * 要素を追加 TangoBookオブジェクトをそのまま追加
     * @param book
     */
    public static func addOne(book : TangoBook, addPos : Int) {
        book.id = getNextId()
        
        try! mRealm!.write() {
            mRealm!.add(book)
        }
        
        // 位置情報を追加（単語帳はホームにしか作れないので作成場所にホームを指定）
        let itemPos = TangoItemPosDao.addOne(item: book, parentType: TangoParentType
            .Home, parentId: 0, addPos: addPos)
        
        // 書き換えられるようにコピーを作成
        let copy = itemPos.copy() as! TangoItemPos
        
        book.itemPos = copy
    }

    /**
     * ダミーのデータを一件追加
     */
    public static func addDummy() {
        let newId = getNextId()
        let randVal = String(arc4random() % 1000)
        
        let book = TangoBook()
        book.id = newId
        book.name = "book" + randVal
        book.color = 0xffffff
        book.comment = "comment:" + randVal
        
        let now = Date()
        book.createTime = now
        book.updateTime = now
        
        try! mRealm!.write() {
            mRealm!.add(book)
        }
        
        _ = TangoItemPosDao.addOne(item: book, parentType: .Home, parentId: 0, addPos: -1)
    }

    /**
     * 一件更新  ユーザーが設定するデータ全て
     * @param book このオブジェクトと同じIDのオブジェクトを置き換える
     */
    public static func updateOne(book : TangoBook) {
        
        let updateBook = mRealm!.objects(TangoBook.self)
            .filter("id=%d", book.getId())
            .first
        if updateBook == nil {
            return
        }
        
        try! mRealm!.write() {
            updateBook!.setName(name: book.name)
            updateBook!.setColor(color: book.getColor())
            updateBook!.setComment(comment: book.getComment())
            updateBook!.setUpdateTime(updateTime: Date())
            updateBook!.setLastStudiedTime(time: book.getLastStudiedTime())
        }
    }

    /**
     1件更新
     - parameter id: 更新するオブジェクトのID
     - parameter name: 新しい名前
     */
    public static func updateOne(id : Int, name : String) {
        let updateBook = mRealm!.objects(TangoBook.self)
            .filter("id=%d", id)
            .first
        if updateBook == nil {
            return
        }
        
        try! mRealm!.write() {
            updateBook!.setName(name: name)
            updateBook!.setUpdateTime(updateTime: Date())
        }
    }
    
    /**
     * IDのリストに一致する項目を全て削除する
     */
    public static func deleteIds(ids : [Int], transaction : Bool ) {
        if (ids.count <= 0) {
            return
        }
        
        let results = mRealm!.objects(TangoBook.self).filter("id In %@", ids)

        if results.count == 0 {
            return
        }
        if (transaction) {
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
        let results = mRealm!.objects(TangoBook.self)

        if results.count <= 0 {
            return false
        }
        try! mRealm!.write() {
            mRealm!.delete(results)
        }
        return true
    }

    /**
     * １件削除する
     * @param id
     * @return
     */
    public static func deleteById(_ id : Int) -> Bool {
        let result = mRealm!.objects(TangoBook.self).filter("id = %d", id).first
        if result == nil {
            return false
        }
        
        try! mRealm!.write() {
            mRealm!.delete(result!)
        }
        
        return true
    }

    /**
     * かぶらないプライマリIDを取得する
     * @return
     */
    public static func getNextId() -> Int {
        // 初期化
        var nextId : Int = 1
        // userIdの最大値を取得
        let lastId = mRealm!.objects(TangoBook.self).max(ofProperty: "id") as Int?
        
        if lastId != nil {
            nextId = lastId! + 1
        }
        return nextId
    }

    /**
     * NEWフラグを変更する
     */
    public static func updateNewFlag(book : TangoBook, isNew : Bool) {
        let result = mRealm!.objects(TangoBook.self).filter("id = %d", book.getId()).first
        if result == nil {
            return
        }
        
        try! mRealm!.write() {
            result!.isNew = isNew
        }
    }
//  todo
///**
// * XMLファイルから読み込んだBookを追加する
// * @param books
// */
//public void addBackupBooks(List<Book> books, boolean transaction) {
//    if (books == null || books.size() == 0) {
//        return;
//    }
//    if (transaction) {
//        mRealm.beginTransaction();
//    }
//    for (Book _book : books) {
//        TangoBook book = new TangoBook();
//        book.setId( _book.getId());
//        book.setName( _book.getName());
//        book.setComment( _book.getComment());
//        book.setColor( _book.getColor());
//        book.setCreateTime( _book.getCreatedDate());
//        book.setNewFlag( _book.isNewFlag());
//        
//        mRealm.copyToRealm(book);
//    }
//    if (transaction) {
//        mRealm.commitTransaction();
//    }
//}
//}
}
