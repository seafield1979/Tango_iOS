//
//  RegExp.swift
//  TangoBook
//      正規表現の処理を行うクラス
//  Created by Shusuke Unno on 2017/08/28.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//

import Foundation

class RegExp {
    let internalRegexp: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        do {
            self.internalRegexp = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        } catch let error as NSError {
            print(error.localizedDescription)
            self.internalRegexp = NSRegularExpression()
        }
    }
    
    func isMatch(input: String) -> Bool {
        let matches = self.internalRegexp.matches( in: input, options: [], range:NSMakeRange(0, input.characters.count) )
        return matches.count > 0
    }
    
    func matches(input: String) -> [String]? {
        let nsInput = input as NSString
        if self.isMatch(input: input) {
            var results = [String]()
            if let matches = internalRegexp.firstMatch(in: nsInput as String, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, input.characters.count))
            {
                for i in 0...matches.numberOfRanges - 1 {
                    results.append(nsInput.substring(with: matches.rangeAt(i)))
                }
            }
            return results
        }
        return nil
    }
}

