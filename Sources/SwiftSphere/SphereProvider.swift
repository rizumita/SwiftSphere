//
//  SphereProvider.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/02.
//

import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class SphereProvider {
    private static var sphereProxies: [AnyHashable: Any] = [AnyHashable: Any]()
    private static let proxyQueue = DispatchQueue(label: "SwiftSphere.SphereProvider.proxyQueue")

    @discardableResult
    public static func ready<Sphere>(_ sphereType: Sphere.Type = Sphere.self,
                                     context: Sphere.Context) -> Sphere.Proxy where Sphere: SphereProtocol {
        let proxy = sphereType.proxy(context: context)
        store(proxy)
        return proxy
    }

    @discardableResult
    public static func ready<Sphere, ID>(_ sphereType: Sphere.Type = Sphere.self,
                                         context: Sphere.Context,
                                         id: ID) -> Sphere.Proxy where Sphere: SphereProtocol, ID: Hashable {
        let proxy = sphereType.proxy(context: context)
        store(proxy, for: id)
        return proxy
    }

    public static func ready<Sphere, V>(_ sphereType: Sphere.Type = Sphere.self,
                                        context: Sphere.Context,
                                        build: (Sphere.Proxy) -> V) -> V where Sphere: SphereProtocol {
        if let sphereProxy = restore(Sphere.Proxy.self) {
            return build(sphereProxy)
        }

        return build(ready(context: context))
    }

    public static func ready<Sphere, V, ID>(_ sphereType: Sphere.Type = Sphere.self,
                                            context: Sphere.Context,
                                            id: ID,
                                            build: (Sphere.Proxy) -> V) -> V where Sphere: SphereProtocol, ID: Hashable {
        if let sphereProxy: Sphere.Proxy = restore(Sphere.Proxy.self, for: id) {
            return build(sphereProxy)
        }

        return build(ready(context: context, id: id))
    }

    public static func get<Sphere>(_ type: Sphere.Type = Sphere.self) -> Sphere.Proxy! where Sphere: SphereProtocol {
        restore()
    }

    public static func get<Sphere, ID>(_ type: Sphere.Type = Sphere.self,
                                       id: ID) -> Sphere.Proxy! where Sphere: SphereProtocol, ID: Hashable {
        restore(for: id)
    }

    private static func store<Proxy>(_ proxy: Proxy, for id: AnyHashable? = .none) where Proxy: AnyObject {
        run(on: proxyQueue) {
            sphereProxies[id ?? (UUID() as AnyHashable)] = WeakRef(proxy)
            collectGarbage()
        }
    }

    private static func restore<Proxy>(_ type: Proxy.Type = Proxy.self,
                                       for id: AnyHashable? = .none) -> Proxy? where Proxy: AnyObject {
        var result: Proxy?

        run(on: proxyQueue) {
            if let id = id {
                result = sphereProxies[id] as? Proxy
            } else {
                result = sphereProxies.values.first { value in
                    guard let value = value as? WeakRef else { return false }
                    return value.object is Proxy
                } as? Proxy
            }
        }

        return result
    }

    private static func collectGarbage() {
        for (key, value) in sphereProxies {
            guard let value = value as? WeakRef,
                  value.object == nil
                else { continue }
            self.sphereProxies.removeValue(forKey: key)
        }
    }
}

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
