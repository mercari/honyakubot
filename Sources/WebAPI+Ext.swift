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
    func sendMessage(
        channel: String,
        text: String,
        username: String? = nil,
        asUser: Bool? = nil,
        linkNames: Bool? = nil,
        attachments: [Attachment?]? = nil,
        unfurlLinks: Bool? = nil,
        unfurlMedia: Bool? = nil,
        iconURL: String? = nil,
        iconEmoji: String? = nil
    ) -> SignalProducer<(ts: String?, channel: String?), SlackError> {
        return SignalProducer<(ts: String?, channel: String?), SlackError>.init { [weak self] observer, lifetime in
            self?.sendMessage(channel: channel, text: text, username: username, asUser: asUser, linkNames: linkNames, attachments: attachments, unfurlLinks: unfurlLinks, unfurlMedia: unfurlMedia, iconURL: iconURL, iconEmoji: iconEmoji,
                              success: {
                                observer.send(value: $0)
                                observer.sendCompleted()
            }, failure: {
                observer.send(error: $0)
            })
        }
    }

    func sendThreadedMessage(
        channel: String,
        thread: String,
        text: String,
        username: String? = nil,
        asUser: Bool? = nil,
        linkNames: Bool? = nil,
        attachments: [Attachment?]? = nil,
        unfurlLinks: Bool? = nil,
        unfurlMedia: Bool? = nil,
        iconURL: String? = nil,
        iconEmoji: String? = nil
    ) -> SignalProducer<(ts: String?, channel: String?), SlackError> {
        return SignalProducer<(ts: String?, channel: String?), SlackError>.init { [weak self] observer, lifetime in
            self?.sendThreadedMessage(channel: channel, thread: thread, text: text, username: username, asUser: asUser, linkNames: linkNames, attachments: attachments, unfurlLinks: unfurlLinks, unfurlMedia: unfurlMedia, iconURL: iconURL, iconEmoji: iconEmoji,
                              success: {
                                observer.send(value: $0)
                                observer.sendCompleted()
            }, failure: {
                observer.send(error: $0)
            })
        }
    }

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
