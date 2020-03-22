//
// Created by 和泉田 領一 on 2020/02/02.
//

import Foundation
import Combine
import SwiftSphere
import CombineAsync

enum GitHubSearchSphere: SphereProtocol {
    struct Model {
        var repos: [GitHubRepo] = []
        var selectedRepo: GitHubRepo? = .none
        var error: String? = .none
    }
    
    enum Event {
        case search(String)
        case selectRepo(GitHubRepo?)
    }
    
    static func update(event: Event, context: Context<Model, GitHubReposRepositoryProtocol>) -> Async<Model> {
        async { yield in
            switch event {
            case .search(let text):
                if text.isEmpty {
                    yield(Model(repos: []))
                } else {
                    yield(context
                        .coordinator
                        .search(text.trimmingCharacters(in: .whitespaces))
                        .map { Model(repos: $0) }
                        .catch { Just(Model(error: $0.localizedDescription)) })
                }
                
            case .selectRepo(let repo):
                yield(Model(repos: context.coordinator.searchedRepos, selectedRepo: repo))
            }
        }
    }
    
    static func makeModel(coordinator: GitHubReposRepositoryProtocol) -> Async<Model> {
        async { yield in
            yield(Model())
        }
    }
}
