//
//  GitHubSearchView.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/02.
//
//

import SwiftUI
import SwiftSphere

struct GitHubSearchView: View {
    @EnvironmentObject private var sphere: GitHubSearchSphere.Proxy
    @State private var searchText = ""
    @State private var showsCancelButton = false

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")

                    TextField("search",
                              text: $searchText,
                              onEditingChanged: { isEditing in
                                  self.showsCancelButton = true
                              },
                              onCommit: {
                                  self.showsCancelButton = false
                                  self.sphere.dispatch(.search(self.searchText))
                              })
                        .foregroundColor(.primary)
                }.padding(EdgeInsets(top: 8.0, leading: 6.0, bottom: 8.0, trailing: 6.0))
                 .foregroundColor(.secondary)
                 .background(Color(.secondarySystemBackground))
                 .cornerRadius(10.0)

                if showsCancelButton {
                    Button(action: {
                        self.hideKeyboard()
                        self.showsCancelButton = false
                        self.searchText = ""
                        self.sphere.dispatch(.search(self.searchText))
                    }, label: { Image(systemName: "xmark.circle") })
                        .foregroundColor(.secondary)
                }
            }.padding(.horizontal)
             .navigationBarHidden(showsCancelButton)

            List {
                ForEach(sphere.model.repos, id: \.self) { repo in
                    NavigationLink(destination: GitHubRepoView(),
                                   tag: repo,
                                   selection: self.sphere.binding(GitHubSearchSphere.Event.selectRepo, \.selectedRepo),
                                   label: { Text(repo.name) })
                }
            }.gesture(DragGesture().onChanged { _ in self.hideKeyboard() })
        }.navigationBarTitle(Text("Search"))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: .none,
                                        from: .none,
                                        for: .none)
    }
}

struct GitHubSearchView_Previews: PreviewProvider {
    static var previews: some View {
        GitHubSearchView().environmentObject(Provider.ready(GitHubSearchSphere.self, context: GitHubReposRepository()))
    }
}
