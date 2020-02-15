//
//  SphereProtocol.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/02.
//

import Foundation
#if canImport(Combine)
import Combine
#endif
import CombineAsync

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol SphereProtocol {
    associatedtype Model
    associatedtype Event
    associatedtype Context = ()

    static func update(event: Event, context: Context) -> Async<Model>
    static func makeModel(context: Context) -> Async<Model>
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SphereProtocol {
    typealias Proxy = SphereProxy<Self>
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SphereProtocol where Context == () {
    static func makeContext() -> () { () }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SphereProtocol {
    static func proxy(context: Context) -> Async<SphereProxy<Self>> { SphereProxy<Self>.spawn(context: context) }
}
