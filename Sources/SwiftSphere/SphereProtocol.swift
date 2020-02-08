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

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol SphereProtocol {
    associatedtype Model
    associatedtype Event
    associatedtype Context = ()

    static func proxy(context: Context) -> SphereProxy<Self>

    static func update(event: Event, context: Context) -> AnyPublisher<Model, Never>
    static func makeModel(context: Context) -> Model
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SphereProtocol {
    typealias Proxy = SphereProxy<Self>

    static func proxy(context: Context) -> SphereProxy<Self> { SphereProxy<Self>(context: context) }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension SphereProtocol where Context == () {
    static func makeContext() -> () { () }
}
