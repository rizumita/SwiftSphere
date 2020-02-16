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
public class Provider<Item> {
    static func collectGarbage() {
        for (key, value) in providerItems {
            guard let value = value as? WeakRef,
                  value.object == nil
                else { continue }
            providerItems.removeValue(forKey: key)
        }
    }
}

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Provider where Item: AnyObject {
    @discardableResult
    public static func ready(_ item: Item) -> Item {
        if let repository = get() {
            return repository
        }

        store(item)
        return item
    }

    public static func ready<V>(_ item: @autoclosure () -> Item,
                                build: (Item) -> V) -> V {
        if let repository = get() {
            return build(repository)
        }

        let i = item()
        store(i)
        return build(i)
    }

    public static func get() -> Item! {
        restore()
    }
    
    static func store<Item>(_ item: Item, for id: AnyHashable? = .none) where Item: AnyObject {
        run(on: providerQueue) {
            providerItems[id ?? (UUID() as AnyHashable)] = WeakRef(item)
            collectGarbage()
        }
    }

    static func restore<Item>(_ type: Item.Type = Item.self,
                              for id: AnyHashable? = .none) -> Item? where Item: AnyObject {
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
}
