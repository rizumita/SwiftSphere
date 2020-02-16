//
//  Provider.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/02.
//

import SwiftUI

var providerItems: [AnyHashable : Any] = [AnyHashable : Any]()
let providerQueue = DispatchQueue(label: "SwiftSphere.SphereProvider.proxyQueue")

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class Provider {
    public static func ready<V>(_ items: [Any], build: () -> V) -> some View where V: View {
        build()
    }

    @discardableResult
    public static func ready<Item>(_ item: Item) -> Item where Item: AnyObject {
        if let repository = get(Item.self) {
            return repository
        }

        store(item)
        return item
    }

    public static func ready<Item, V>(_ item: @autoclosure () -> Item,
                                      build: (Item) -> V) -> V where Item: AnyObject {
        if let repository = get(Item.self) {
            return build(repository)
        }

        let i = item()
        store(i)
        return build(i)
    }

    public static func get<Item>(_ type: Item.Type = Item.self) -> Item! {
        restore()
    }
    
    static func store<Item>(_ item: Item, for id: AnyHashable? = .none) where Item: AnyObject {
        run(on: providerQueue) {
            providerItems[id ?? (UUID() as AnyHashable)] = WeakRef(item)
            collectGarbage()
        }
    }

    static func restore<Item>(_ type: Item.Type = Item.self,
                              for id: AnyHashable? = .none) -> Item? {
        var result: Item?

        run(on: providerQueue) {
            if let id = id {
                result = providerItems[id] as? Item
            } else {
                result = providerItems.values.first { value in
                    guard let value = value as? WeakRef else { return false }
                    return value.object is Item
                }.flatMap { ($0 as? WeakRef)?.object } as? Item
            }
        }

        return result
    }
    
    static func collectGarbage() {
        for (key, value) in providerItems {
            guard let value = value as? WeakRef,
                  value.object == nil
                else { continue }
            providerItems.removeValue(forKey: key)
        }
    }
}
