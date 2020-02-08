//
// Created by 和泉田 領一 on 2020/02/03.
//

import Foundation
import Combine
import SwiftSphere

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

    static func update(event: Event, context: Context) -> AnyPublisher<Model, Never> {
        switch event {
        case .increase:
            context.countRepository.increase()

        case .increaseAutomatically:
            return context.countRepository.increaseAutomatically(interval: 2.0, until: context.until)
                                          .flatMap { self.makeModelAsync(context: context) }.eraseToAnyPublisher()

        case .stopIncreaseAutomatically:
            context.until.send(())

        case .decrease:
            context.countRepository.decrease()
        }

        return makeModelAsync(context: context)
    }

    static func makeModel(context: Context) -> Model {
        Model(count: context.countRepository.count, history: context.countRepository.history)
    }

    static func makeModelAsync(context: Context) -> AnyPublisher<Model, Never> {
        context.countRepository.historyPublisher.map { Model(count: context.countRepository.count, history: $0) }
                                                .prefix(1).eraseToAnyPublisher()
    }

    struct Context {
        let countRepository: CountRepositoryProtocol
        let until = PassthroughSubject<(), Never>()
    }
}
