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
    associatedtype Coordinator = ()

    static func update(event: Event, context: Context<Model, Coordinator>) -> Async<Model>
    static func makeModel(coordinator: Coordinator) -> Async<Model>
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SphereProtocol {
    typealias Proxy = SphereProxy<Self>
    typealias Context<Model, Coordinator> = SphereContext<Model, Coordinator>
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SphereProtocol {
    static func proxy(coordinator: Coordinator) -> Async<SphereProxy<Self>> { SphereProxy<Self>.spawn(coordinator: coordinator) }
}
