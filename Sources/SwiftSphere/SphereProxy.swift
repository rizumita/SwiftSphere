//
//  SphereProxy.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/02.
//

import Foundation
import SwiftUI
#if canImport(Combine)
import Combine
#endif
import CombineAsync

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class SphereProxy<Sphere: SphereProtocol>: ObservableObject {
    @Published public var model: Sphere.Model
    @Published public var error: Error?
    
    private let context: Sphere.Context
    
    private let updateQueue = DispatchQueue(label: "SwiftSphere.SphereProxy.updateQueue")
    
    static func spawn(context: Sphere.Context) -> Async<Sphere.Proxy> {
        async { yield in
            let model = try await(Sphere.makeModel(context: context))
            yield(Sphere.Proxy(context: context, model: model))
        }
    }
    
    init(context: Sphere.Context, model: Sphere.Model) {
        self.context = context
        self.model = model
    }
    
    public func dispatch(_ event: Sphere.Event) {
        let subscriber = Subscribers.Assign<SphereProxy<Sphere>, Sphere.Model>(object: self, keyPath: \.model)
        Sphere.update(event: event, context: context)
            .subscribe(on: updateQueue)
            .receive(on: RunLoop.main)
            .catch { [weak self] error -> Empty<Sphere.Model, Never> in
                self?.error = error
                return Empty<Sphere.Model, Never>(completeImmediately: false)
            }.subscribe(subscriber)
    }
    
    public func binding<Value>(_ event: @escaping (Value) -> Sphere.Event,
                               _ keyPath: KeyPath<Sphere.Model, Value>) -> Binding<Value> {
        Binding(get: { [weak self] in
            guard let this = self else { fatalError() }
            return this.model[keyPath: keyPath]
            }, set: { [weak self] value in self?.dispatch(event(value)) })
    }
}
