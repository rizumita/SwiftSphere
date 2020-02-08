//
// Created by 和泉田 領一 on 2020/02/03.
//

import Foundation
import Combine

protocol CountRepositoryProtocol {
    var count: Int { get }
    var history: [Step] { get }
    var historyPublisher: AnyPublisher<[Step], Never> { get }

    func increase()
    func increaseAutomatically<P>(interval: TimeInterval, until: P) -> AnyPublisher<(), Never> where P: Publisher
    func decrease()
}

class CountRepository: CountRepositoryProtocol {
    private(set) var count: Int = 0
    @Published private(set) var history: [Step] = []
    var historyPublisher: AnyPublisher<[Step], Never> { $history.eraseToAnyPublisher() }

    func increase() {
        count += 1
        history.append(.increase)
    }

    func increaseAutomatically<P>(interval: TimeInterval, until: P) -> AnyPublisher<(), Never> where P: Publisher {
        Timer.publish(every: interval, on: RunLoop.main, in: .default)
             .autoconnect()
             .prefix(untilOutputFrom: until)
             .handleEvents(receiveOutput: { [weak self] _ in self?.increase() })
             .map { _ in () }
             .eraseToAnyPublisher()
    }

    func decrease() {
        count -= 1
        history.append(.decrease)
    }
}
