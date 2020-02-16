//
//  Provider+Sphere.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/16.
//

import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Provider {
    public static func ready<Item>(_ type: Item.Type = Item.self, context: Item.Context) -> Item.Proxy where Item: SphereProtocol {
        if let sphereProxy = restore(Item.Proxy.self) {
            return sphereProxy
        }

        let proxy = createProxy(Item.self, context: context)
        store(proxy)
        return proxy
    }

    @discardableResult
    public static func ready<Item, ID>(_ type: Item.Type = Item.self, context: Item.Context, id: ID) -> Item.Proxy where Item: SphereProtocol, ID: Hashable {
        if let sphereProxy: Item.Proxy = restore(Item.Proxy.self, for: id) {
            return sphereProxy
        }

        let proxy = createProxy(Item.self, context: context)
        store(proxy, for: id)
        return proxy
    }
    
    public static func ready<Item, V>(_ type: Item.Type = Item.self, context: Item.Context, build: (Item.Proxy) -> V) -> some View where Item: SphereProtocol, V: View {
        if let sphereProxy = restore(Item.Proxy.self) {
            return build(sphereProxy)
        }

        return build(ready(context: context))
    }

    public static func ready<Item, V, ID>(_ type: Item.Type = Item.self,
                                          context: Item.Context,
                                          id: ID,
                                          build: (Item.Proxy) -> V) -> some View where Item: SphereProtocol, ID: Hashable, V: View {
        if let sphereProxy: Item.Proxy = restore(Item.Proxy.self, for: id) {
            return build(sphereProxy)
        }

        return build(ready(context: context, id: id))
    }

    public static func get<Item>(_ type: Item.Type = Item.self) -> Item.Proxy! where Item: SphereProtocol {
        restore()
    }

    public static func get<Item, ID>(_ type: Item.Type = Item.self, id: ID) -> Item.Proxy! where Item: SphereProtocol, ID: Hashable {
        restore(for: id)
    }

    private static func createProxy<Item>(_ type: Item.Type = Item.self, context: Item.Context) -> Item.Proxy where Item: SphereProtocol {
        do {
            return try Item.proxy(context: context).await()
        } catch {
            fatalError("Provider can't ready \(String(describing: Swift.type(of: Item.Proxy.self))): \(error.localizedDescription)")
        }
    }

    private static func store<Item>(_ type: Item.Type = Item.self, _ proxy: Item.Proxy, for id: AnyHashable? = .none) where Item: SphereProtocol {
        run(on: providerQueue) {
            providerItems[id ?? (UUID() as AnyHashable)] = WeakRef(proxy)
            self.collectGarbage()
        }
    }

    private static func restore<Item>(_ type: Item.Type = Item.self,
                                      for id: AnyHashable? = .none) -> Item.Proxy? where Item: SphereProtocol {
        var result: Item.Proxy?

        run(on: providerQueue) {
            if let id = id {
                result = providerItems[id] as? Item.Proxy
            } else {
                result = providerItems.values.first { value in
                    guard let value = value as? WeakRef else { return false }
                    return value.object is Item.Proxy
                }.flatMap { ($0 as? WeakRef)?.object } as? Item.Proxy
            }
        }

        return result
    }
}
