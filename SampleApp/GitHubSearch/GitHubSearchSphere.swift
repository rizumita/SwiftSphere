//
// Created by 和泉田 領一 on 2020/02/02.
//

import Foundation
import Combine
import SwiftSphere

struct GitHubSearchSphere: SphereProtocol {
    struct Model {
        var repos: [GitHubRepo] = []
        var selectedRepo: GitHubRepo? = .none
        var error: String? = .none
    }

    enum Event {
        case search(String)
        case selectRepo(GitHubRepo?)
    }

    static func update(event: Event, context: GitHubReposRepositoryProtocol) -> AnyPublisher<Model, Never> {
        switch event {
        case .search(let text):
            if text.isEmpty {
                return Just(Model(repos: [])).eraseToAnyPublisher()
            } else {
                return context
                    .search(text)
                    .map { Model(repos: $0) }
                    .catch { Just(Model(error: $0.localizedDescription)) }
                    .eraseToAnyPublisher()
            }

        case .selectRepo(let repo):
            return Just(Model(repos: context.searchedRepos, selectedRepo: repo)).eraseToAnyPublisher()
        }
    }

    static func makeModel(context: GitHubReposRepositoryProtocol) -> Model { Model() }
}
