//
//  RefDictionary.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/07/10.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//

import Foundation


// 参照型の辞書型
class RefDictionary<K : Hashable, V> {
    private var dict : Dictionary<K, V> = Dictionary()
    subscript(key : K) -> V? {
        get {
            return dict[key]
        }
        set(newValue) {
            dict[key] = newValue
        }
    }
    
    // keysを実装
    // 元々のDictionaryのkeysと同じように使用出来る
    var keys : [K] {
        get {
            return Array(dict.keys)
        }
    }
    
    // valuesを実装
    // 元々のDictionaryのvaluesと同じように使用出来る
    var values : [V] {
        get {
            return Array(dict.values)
        }
    }
    
    func getDict() -> Dictionary<K,V> {
        return dict
    }
    
    // 全要素を削除する
    func removeAll() {
        dict.removeAll()
    }
    func clear() {
        dict.removeAll()
    }
    
    // 指定したキーの要素を削除する
    func removeValue(forKey key: K) {
        dict.removeValue(forKey: key)
    }
}
