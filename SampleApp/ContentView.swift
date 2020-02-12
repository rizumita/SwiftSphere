//
//  ContentView.swift
//  SampleApp
//
//  Created by 和泉田 領一 on 2020/02/02.
//

import SwiftUI
import SwiftSphere

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                RepositoryProvider.ready(GitHubReposRepository()) { repository in
                    SphereProvider<GitHubSearchSphere>.ready(context: repository) { sphere in
                        NavigationLink(destination: GitHubSearchView().environmentObject(sphere),
                                       label: { Text("Search GitHub Repositories") })
                    }
                }

                Spacer()

                RepositoryProvider.ready(CountRepository()) { repository in
                    SphereProvider<CounterSphere>.ready(context: .init(countRepository: repository)) { sphere in
                        NavigationLink(destination: CounterView().environmentObject(sphere),
                                       label: { Text("Counter") })
                    }
                }

                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
