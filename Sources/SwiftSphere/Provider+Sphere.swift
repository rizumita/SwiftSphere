//
//  Provider+Sphere.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/16.
//

import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Provider where Item: SphereProtocol {
    public static func ready(context: Item.Context) -> Item.Proxy {
        if let sphereProxy = restore(Item.Proxy.self) {
            return sphereProxy
        }

        let proxy = createProxy(context: context)
        store(proxy)
        return proxy
    }

    @discardableResult
    public static func ready<ID>(context: Item.Context, id: ID) -> Item.Proxy where ID: Hashable {
        if let sphereProxy: Item.Proxy = restore(Item.Proxy.self, for: id) {
            return sphereProxy
        }

        let proxy = createProxy(context: context)
        store(proxy, for: id)
        return proxy
    }
    
    public static func ready<V>(context: Item.Context, build: (Item.Proxy) -> V) -> some View where V: View {
        if let sphereProxy = restore(Item.Proxy.self) {
            return build(sphereProxy)
        }

        return build(ready(context: context))
    }

    public static func ready<V, ID>(context: Item.Context,
                                    id: ID,
                                    build: (Item.Proxy) -> V) -> some View where ID: Hashable, V: View {
        if let sphereProxy: Item.Proxy = restore(Item.Proxy.self, for: id) {
            return build(sphereProxy)
        }

        return build(ready(context: context, id: id))
    }

    public static func get() -> Item.Proxy! {
        restore()
    }

    public static func get<ID>(id: ID) -> Item.Proxy! where ID: Hashable {
        restore(for: id)
    }

    private static func createProxy(context: Item.Context) -> Item.Proxy {
        do {
            return try Item.proxy(context: context).await()
        } catch {
            fatalError("Provider can't ready \(String(describing: type(of: Item.Proxy.self))): \(error.localizedDescription)")
        }
    }

    private static func store<Proxy>(_ proxy: Proxy, for id: AnyHashable? = .none) where Proxy: AnyObject {
        run(on: providerQueue) {
            providerItems[id ?? (UUID() as AnyHashable)] = WeakRef(proxy)
            self.collectGarbage()
        }
    }

    private static func restore<Proxy>(_ type: Proxy.Type = Proxy.self,
                                       for id: AnyHashable? = .none) -> Proxy? where Proxy: AnyObject {
        var result: Proxy?

        run(on: providerQueue) {
            if let id = id {
                result = providerItems[id] as? Proxy
            } else {
                result = providerItems.values.first { value in
                    guard let value = value as? WeakRef else { return false }
                    return value.object is Proxy
                }.flatMap { ($0 as? WeakRef)?.object } as? Proxy
            }
        }

        return result
    }
}
