//
//  CounterView.swift
//  SwiftSphere
//
//  Created by 和泉田 領一 on 2020/02/03.
//
//

import SwiftUI
import SwiftSphere

struct CounterView: View {
    @EnvironmentObject var sphere: CounterSphere.Proxy

    var body: some View {
        VStack {
            Spacer()

            Stepper(onIncrement: { self.sphere.dispatch(.increase) },
                    onDecrement: { self.sphere.dispatch(.decrease) },
                    label: { Text("\(self.sphere.model.count)") }).padding(50.0)

            Spacer()

            HStack {
                Button(action: { self.sphere.dispatch(.increaseAutomatically) },
                       label: { Text("Auto-Increment") })
                Button(action: { self.sphere.dispatch(.stopIncreaseAutomatically) }, label: { Text("Stop") })
            }

            Spacer()
        }.onDisappear { self.sphere.dispatch(.stopIncreaseAutomatically) }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryProvider.ready(CountRepository()) { _ in
            CounterView().environmentObject(CounterSphere.proxy(context: .init(countRepository: CountRepository())))
        }
    }
}
