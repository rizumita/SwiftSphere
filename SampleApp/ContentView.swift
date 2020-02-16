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
                
                NavigationLink(destination: GitHubSearchView(),
                               label: { Text("Search GitHub Repositories") })

                Spacer()
                
                NavigationLink(destination: CounterView(),
                               label: { Text("Counter") })

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
