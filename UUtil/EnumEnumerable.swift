//
//  EnumEnumeration.swift
//  UGui
//
//  Created by Shusuke Unno on 2017/07/12.
//  Copyright © 2017年 Shusuke Unno. All rights reserved.
//
/**
 enumの機能を拡張してforループで全要素を回したり、要素数を取得したり、インデックスで要素を指定できるようにする。
 
*/
import Foundation

public protocol EnumEnumerable {
    associatedtype Case = Self
}

public extension EnumEnumerable where Case: Hashable {
    private static var iterator: AnyIterator<Case> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            
            let next = withUnsafePointer(to: &n) {
                UnsafeRawPointer($0).assumingMemoryBound(to: Case.self).pointee
            }
            return next.hashValue == n ? next : nil
        }
    }
    
    public static func enumerate() -> EnumeratedSequence<AnySequence<Case>> {
        return AnySequence(self.iterator).enumerated()
    }
    
    public static var cases: [Case] {
        return Array(self.iterator)
    }
    
    public static var count: Int {
        return self.cases.count
    }
}
