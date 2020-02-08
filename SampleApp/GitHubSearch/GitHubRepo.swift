//
// Created by 和泉田 領一 on 2020/02/02.
//

import Foundation

struct GitHubRepo: Decodable, Hashable {
    var id: Int
    var nodeID: String
    var name: String
    var fullName: String
    var htmlURL: String
    var description: String
    var stargazersCount: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case nodeID = "node_id"
        case name
        case fullName = "full_name"
        case htmlURL = "html_url"
        case description
        case stargazersCount = "stargazers_count"
    }
}
