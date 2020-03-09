//
//  MD5Transformer.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-09.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import SwiftHash

class MD5StringTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if let str = value as? String {
            return MD5(str)
        } else {
            return ""
        }
    }
}
