//
//  Functions.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/16.
//

import Foundation

func run(on queue: DispatchQueue, _ f: @escaping () -> ()) {
    let label = String(cString: __dispatch_queue_get_label(queue), encoding: .utf8)

    if label == queue.label {
        f()
    } else {
        queue.sync {
            f()
        }
    }
}
