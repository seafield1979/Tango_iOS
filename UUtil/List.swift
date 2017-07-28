//
//  List.swift
//  TangoBook
//

//  Created koher
//  https://github.com/koher/Swift-List/blob/master/List.swift
//  上記のソースをSwift3でコンパイル時にエラーになった箇所を幾つか修正しています

import Foundation

public class List<T> : Sequence, Hashable{
    final var elements: Array<T>
    
    init(_ elements: Array<T>) {
        self.elements = elements
    }
    
    convenience init() {
        self.init([])
    }
    
    convenience init(_ list: List<T>) {
        self.init(list)
    }
    
    convenience init(_ elements: T...) {
        self.init(elements)
    }
    
    // [index] で要素を参照するためのサブスクリプト
    subscript(index: Int) -> T {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
        }
    }
    
    // 配列形式で取得する
    func toArray() -> [T] {
        return elements
    }
    
    // リストに要素を追加する
    func append(_ newElement: T) {
        elements.append(newElement)
    }
    
    // リストの先頭に要素を追加する
    // JavaのLinkedListの仕様と合わせる
    func push(_ newElement: T) {
        insert(newElement, atIndex: 0)
    }
    
    // リストの指定位置に要素を追加する
    func insert(_ newElement: T, atIndex index: Int) {
        elements.insert(newElement, at: index)
    }
        
    // リストの指定位置の要素を削除する
    func remove(at index: Int) -> T {
        return elements.remove(at: index)
    }
    
    // リストの最後の要素を削除する
    func removeLast() -> T {
        return elements.removeLast()
    }
    
    // リストの全要素を削除する
    func removeAll(keepCapacity: Bool = false) {
        elements.removeAll(keepingCapacity: keepCapacity)
    }
    
    func reserveCapacity(minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }
    
    var count: Int {
        get {
            return elements.count
        }
    }
    
    func first() -> T? {
        return elements.first
    }
    
    func last() -> T? {
        return elements.last
    }
    
    var isEmpty: Bool {
        get {
            return elements.isEmpty
        }
    }
    
    var capacity: Int {
        get {
            return elements.capacity
        }
    }
    
    /**
     ソート結果を返す
     使用例： ageのプロパティを持つオブジェクトのリストをソート
        let list2 = list1.sort({ $0.age < $1.age })
     　　let list2 = list1.sort((left, right) in { left.age < right.age })
     */
    func sort(isOrderedBefore: (T, T) -> Bool) -> Array<T> {
        return elements.sorted(by: isOrderedBefore)
    }
    
    func reverse() -> Array<T> {
        return elements.reversed()
    }
    
    func filter(includeElement: (T) -> Bool) -> List<T> {
        return List(elements.filter(includeElement))
    }
    
    func map<U>(transform: (T) -> U) -> List<U> {
        return List<U>(elements.map(transform))
    }
    
    func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
        return elements.reduce(initial, combine)
    }
    
    public func makeIterator() -> AnyIterator<T?> {
        var count = 0
        return AnyIterator {
            if self.elements.count <= count {
                // nilを返したら終了
                return nil
            }
            let element = self.elements[count]
            count += 1
            
            return element
        }
    }
    
    // Hashable
    // ハッシュ値を返す
    public var hashValue: Int {
        return self.elements.description.hashValue
    }
    
    // ハッシュ値を比較する
    public static func == (lhs: List, rhs: List) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


// containsは T がクラスのオブジェクト型のときのだけ使用できる
public extension List where T: AnyObject {
    // リストに含まれているかをチェック
    func contains(_ element : T) -> Bool {
        return elements.contains(where: {$0 === element})
    }
    
    /**
     オブジェクトの位置を取得する
     - parameter obj: インデックスを取得したいオブジェクト
     - returns: オブジェクトの位置。リストにオブジェクトがなかったら -1 を返す
     */
    func indexOf(obj: T) -> Int {
        var i = 0
        for _obj in elements {
            if obj === _obj {
                return i
            }
            i += 1
        }
        return -1
    }
    
    // リストを追加する
    func append(objs: [T]) {
        for obj in objs {
            elements.append(obj)
        }
    }
    
    // リストにあるオブジェクトを削除する
    func remove(obj: T) {
        if elements.count <= 0 {
            return
        }
        for i in 0...elements.count - 1 {
            let element = elements[i]
            if obj === element {
                elements.remove(at: i)
                break
            }
        }
    }
    
    // 引数で渡されたリストを削除する
    func remove(objs: [T]) {
        for obj in objs {
            remove(obj: obj)
        }
    }
}


