//
//  MultiProvider.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/15.
//

import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class MultiProvider {
    public static func ready<V>(_ items: [Any], build: () -> V) -> some View where V: View {
        build()
    }
}
