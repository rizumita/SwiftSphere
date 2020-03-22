//
// Created by 和泉田 領一 on 2020/02/03.
//

import Foundation
import Combine
import SwiftSphere
import CombineAsync

struct CounterSphere: SphereProtocol {
    struct Model {
        var count: Int
        var history: [Step]
    }
    
    enum Event {
        case increase
        case increaseAutomatically
        case stopIncreaseAutomatically
        case decrease
    }
    
    static func update(event: Event, context: Context<Model, Coordinator>) -> Async<Model> {
        async { yield in
            switch event {
            case .increase:
                context.coordinator.countRepository.increase()
                
            case .increaseAutomatically:
                yield(context.coordinator.countRepository.increaseAutomatically(interval: 2.0, until: context.coordinator.until)
                    .setFailureType(to: Error.self).flatMap { self.makeModel(coordinator: context.coordinator) })
                
            case .stopIncreaseAutomatically:
                context.coordinator.until.send(())
                
            case .decrease:
                context.coordinator.countRepository.decrease()
            }
        
            yield(makeModel(coordinator: context.coordinator))
        }
    }
    
    static func makeModel(coordinator: Coordinator) -> Async<Model> {
        async { yield in
            let history = try await(coordinator.countRepository.historyPublisher)
            yield(Model(count: coordinator.countRepository.count, history: history))
        }
    }
    
    struct Coordinator {
        let countRepository: CountRepositoryProtocol
        let until = PassthroughSubject<(), Never>()
    }
}
