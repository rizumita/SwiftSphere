//
//  RepositoryProvider.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/02.
//

import SwiftUI

@available(OSX 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public class RepositoryProvider {
    public static var repositories: [Any] = []

    @discardableResult
    public static func ready<Repository>(_ repository: Repository) -> Repository {
        repositories.append(repository)
        return repository
    }

    public static func ready<Repository, V>(_ repository: @autoclosure () -> Repository,
                                            build: (Repository) -> V) -> V {
        if let repository = get(Repository.self) {
            return build(repository)
        }

        let repo = repository()
        repositories.append(repo)
        return build(repo)
    }

    public static func get<Repository>(_ type: Repository.Type = Repository.self) -> Repository! {
        repositories.first { $0 is Repository }.map { $0 as! Repository }
    }
}
