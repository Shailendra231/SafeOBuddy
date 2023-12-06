//
//  String.swift
//  safeobuddyttlock
//
//  Created by Never Mind on 01/12/23.
//

import Foundation
import CommonCrypto

extension String
{
    func replaceTTLockData(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: String.CompareOptions.literal, range: nil)
    }
}

