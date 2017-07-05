//
//  APIService.swift
//  honyakubot
//
//  Created by teddy on 2017/06/30.
//
//

import Foundation
import SlackKit
import Alamofire
import ReactiveSwift
import SKCore
import Result

final class APIService {
    let webAPI: WebAPI // TODO: make private and wrap functions
    private var _channels: [Channel]? = nil
    private var _users: [User]? = nil

    init(webAPI: WebAPI) {
        self.webAPI = webAPI
    }

    // MARK: Channels
    var allChannels: SignalProducer<[Channel], SlackError> {
        if let channels = _channels {
            return SignalProducer(value: channels)
        } else {
            return webAPI.channelsList()
                .on(value: { [weak self] channels in
                    self?._channels = channels
                })
        }
    }

    func findChannelByID(id: String) -> SignalProducer<Channel?, SlackError> {
        return allChannels
            .map { channels in
                guard let channel = channels.filter({ channel in channel.id == id }).first else {
                    return nil
                }
                return channel
        }
    }

    func findENChannelFor(id: String) -> SignalProducer<Channel?, SlackError> {
        return allChannels.combineLatest(with: findChannelByID(id: id)).map { allChannels, channel in
            guard
                let channel = channel,
                let name = channel.name else { return nil }
                return allChannels
                    .filter({ channel in
                        return channel.name == "z-\(name)-en" }).first
        }
    }


    // MARK: Users
    var allUsers: SignalProducer<[User], SlackError> {
        if let users = _users {
            return SignalProducer(value: users)
        } else {
            return webAPI.usersList()
                .on(value: { [weak self] users in
                    self?._users = users
                })
        }
    }

    func findUserByID(id: String) -> SignalProducer<User?, SlackError> {
        return allUsers
            .map { users in
                guard let user = users.filter({ channel in channel.id == id }).first else {
                    return nil
                }
                return user
        }
    }
}

