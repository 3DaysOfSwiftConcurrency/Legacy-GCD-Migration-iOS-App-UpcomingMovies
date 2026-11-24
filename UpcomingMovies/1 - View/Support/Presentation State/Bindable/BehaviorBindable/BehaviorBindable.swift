//
//  BehaviorBindable.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/10/22.
//  Copyright © 2022 Alonso. All rights reserved.
//

final class BehaviorBindable<T>: BehaviorBindableProtocol {

    typealias Listener = ((T) -> Void)
    private var listener: Listener?

    private var delivery: BindingDelivery = .immediate

    var value: T {
        didSet {
            sendValue()
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(_ listener: @escaping Listener, on delivery: BindingDelivery = .immediate) {
        self.listener = listener
        self.delivery = delivery
    }

    func bindAndFire(_ listener: @escaping Listener, on delivery: BindingDelivery = .immediate) {
        self.listener = listener
        self.delivery = delivery
        sendValue()
    }

    // MARK: - Private

    private func sendValue() {
        delivery.send { self.listener?(self.value) }
    }

}
