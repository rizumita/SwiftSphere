//
// Created by 和泉田 領一 on 2020/02/02.
//

import Foundation
import Combine

enum GitHubSearchError: Error {
    case urlError(URLError)
    case decodeError(Error)
}

protocol GitHubReposRepositoryProtocol {
    var searchedRepos: [GitHubRepo] { get }
    func search(_ text: String) -> AnyPublisher<[GitHubRepo], GitHubSearchError>
}

class GitHubReposRepository: GitHubReposRepositoryProtocol {
    private(set) var searchedRepos: [GitHubRepo] = []

    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let setterQueue = DispatchQueue(label: "GitHubSearchRepository.setterQueue")

    func search(_ text: String) -> AnyPublisher<[GitHubRepo], GitHubSearchError> {
        let urlString = "https://api.github.com/search/repositories?sort=stars&q=\(text)".trimmingCharacters(in: .whitespaces)
        let url = URL(string: urlString)!
        return URLSession(configuration: URLSessionConfiguration.default)
            .dataTaskPublisher(for: url)
            .mapError(GitHubSearchError.urlError)
            .flatMap { tuple -> AnyPublisher<[GitHubRepo], GitHubSearchError> in
                do {
                    let result = try JSONDecoder().decode(GitHubSearchResult.self, from: tuple.0)
                    return Just(result.items).setFailureType(to: GitHubSearchError.self).eraseToAnyPublisher()
                } catch {
                    return Fail<[GitHubRepo], GitHubSearchError>(error: .decodeError(error)).eraseToAnyPublisher()
                }
            }
            .receive(on: setterQueue)
            .handleEvents(receiveOutput: { [weak self] repos in self?.searchedRepos = repos })
            .eraseToAnyPublisher()
    }
}

struct GitHubSearchResult: Decodable {
    var totalCount: Int
    var items: [GitHubRepo]

    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
