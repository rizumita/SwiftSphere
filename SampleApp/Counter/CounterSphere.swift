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
    
    static func update(event: Event, context: Context) -> Async<Model> {
        async { yield in
            switch event {
            case .increase:
                context.countRepository.increase()
                
            case .increaseAutomatically:
                yield(context.countRepository.increaseAutomatically(interval: 2.0, until: context.until)
                    .setFailureType(to: Error.self).flatMap { self.makeModel(context: context) })
                
            case .stopIncreaseAutomatically:
                context.until.send(())
                
            case .decrease:
                context.countRepository.decrease()
            }
        
            yield(makeModel(context: context))
        }
    }
    
    static func makeModel(context: Context) -> Async<Model> {
        async { yield in
            let history = try await(context.countRepository.historyPublisher)
            yield(Model(count: context.countRepository.count, history: history))
        }
    }
    
    struct Context {
        let countRepository: CountRepositoryProtocol
        let until = PassthroughSubject<(), Never>()
    }
}
