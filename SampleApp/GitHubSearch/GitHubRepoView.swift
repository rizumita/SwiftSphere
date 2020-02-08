//
//  GitHubRepoView.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/02.
//
//

import SwiftUI

struct GitHubRepoView: View {
    @EnvironmentObject private var sphere: GitHubSearchSphere.Proxy

    var body: some View {
        VStack {
            Spacer()
            Text(sphere.model.selectedRepo?.name ?? "")
            Spacer()
            Text(sphere.model.selectedRepo?.description ?? "")
            Spacer()
            Text("Star: " + String(sphere.model.selectedRepo?.stargazersCount ?? 0))
            Spacer()
        }.padding()
    }
}

struct GitHubRepoView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubRepoView()
    }
}
