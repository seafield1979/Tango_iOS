//
//  Date+ex.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/08/29.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

extension Date {
    /**
     * 比較対象の日付(date)が未来なら true を返す
     * self < date
     */
    public func after(_ date : Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedDescending
    }
    /**
     * 比較対象の日付(date)が過去なら true を返す
     * self > date
     */
    public func before(_ date : Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedAscending
    }

}
