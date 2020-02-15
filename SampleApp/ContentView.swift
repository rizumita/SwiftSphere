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
                
                SphereProvider<GitHubSearchSphere>.ready(context: RepositoryProvider.ready(GitHubReposRepository())) { sphere in
                    NavigationLink(destination: GitHubSearchView().environmentObject(sphere),
                                   label: { Text("Search GitHub Repositories") })
                }
                
                Spacer()
                
                SphereProvider<CounterSphere>.ready(context: .init(countRepository: RepositoryProvider.ready(CountRepository()))) { sphere in
                    NavigationLink(destination: CounterView().environmentObject(sphere),
                                   label: { Text("Counter") })
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
