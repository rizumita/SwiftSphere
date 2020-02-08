//
// Created by 和泉田 領一 on 2020/02/07.
//

import Foundation

final class WeakRef {
    weak var object: AnyObject?

    init(_ object: AnyObject) {
        self.object = object
    }
}
