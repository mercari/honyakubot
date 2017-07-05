//
//  WebAPI+Ext.swift
//  honyakubot
//
//  Created by teddy on 2017/06/30.
//
//

import Foundation
import ReactiveSwift
import SlackKit
import SKCore

extension WebAPI {
    func channelsList(excludeArchived: Bool = false) -> SignalProducer<[Channel], SlackError> {
        return SignalProducer<[[String: Any]]?, SlackError>.init { [weak self] observer, lifetime in
            self?.channelsList(excludeArchived: excludeArchived, success: {
                observer.send(value: $0)
                observer.sendCompleted()
            }) {
                observer.send(error: $0)
            }
            }.map { channelDicts in
                guard let channelDicts = channelDicts else { return [] }
                return channelDicts.map(Channel.init)
        }
    }

    func usersList() -> SignalProducer<[User], SlackError> {
        return SignalProducer<[[String: Any]]?, SlackError>.init { [weak self] observer, lifetime in
            self?.usersList(success: {
                observer.send(value: $0)
                observer.sendCompleted()
            }) {
                observer.send(error: $0)
            }
            }.map { userDicts in
                guard let userDicts = userDicts else { return [] }
                return userDicts.map(User.init)
        }
    }
}
