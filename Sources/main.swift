import Foundation
import SlackKit
import Alamofire
import ReactiveSwift
import SKCore
import Result

private let kSLACK_TOKEN = "SLACK_TOKEN"
private let kGOOGLE_API_KEY = "GOOGLE_API_KEY"

private enum Route {
    case createChannel(name: String)
    case translateToEN(message: Message)
    case ignore
}

final class HonyakuBot {
    private let bot = SlackKit()
    private let apiService: APIService
    private let googleAPIKey: String

    init(token: String, googleAPIKey: String) {
        self.googleAPIKey = googleAPIKey
        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)

        guard let webAPI = bot.webAPI else { fatalError("missing SlackKit webAPI") }
        self.apiService = APIService(webAPI: webAPI)

        bot.notificationForEvent(EventType.channelCreated) { [weak self] (event, client) in
            guard let channel = event.channel else { return }
            self?.apiService.channelWasCreated(channel)
        }

        bot.notificationForEvent(.message) { [weak self] (event, client) in
            guard let strongSelf = self,
                let message = event.message,
                let botID = client?.authenticatedUser?.id
                else { return }
            let route = strongSelf.routeFor(message: message, botID: botID)
            strongSelf.handleRoute(route)
        }
    }

    private func routeFor(message: Message, botID: String) -> Route {
        guard let text = message.text, let channel = message.channel else { return .ignore }
        // if messaged bot, create new channel with suffix -en
        if text.contains(botID) {
            return .createChannel(name: "z-\(channel)-en")
        }

        // if not messaged bot in regular channel, forward translated message to -en channel
        let lastThreeCharRange = channel.index(channel.endIndex, offsetBy: -3)..<channel.endIndex
        if channel.substring(with: lastThreeCharRange) != "-en" {
            return .translateToEN(message: message)
        }

        // if in -en channel, do nothing
        return .ignore
    }

    private func handleRoute(_ route: Route) {
        switch route {
        case .ignore: return
        case .createChannel(let name):
            let urlString = "https://slack.com/api/channels.create"
            let params: [String: Any] = [
                "token": "token",
                "name": name,
                "validate": true
            ]
            Alamofire
                .request(urlString, method: .post, parameters: params)
                .responseJSON { response in
                    if let json = response.result.value {
                        print(json)
                    }
                }
        case .translateToEN(let message):
            guard let channelID = message.channel, let text = message.text, let userID = message.user else { return }
            translateText(text: text)
                .combineLatest(with: apiService.findENChannelFor(id: channelID).flatMapError { return SignalProducer.init(error: AnyError($0)) })
                .combineLatest(with: apiService.findUserByID(id: userID).flatMapError { return SignalProducer.init(error: AnyError($0)) })
                .startWithResult({ [weak self] result in
                    switch result {
                    case .success(let value):
                        let translatedText = value.0.0
                        guard let enChannelID = value.0.1?.id else {
                            // TODO: create channel
                            return
                        }

                        let username = value.1?.name ?? "user not found"
                        let iconURL = value.1?.profile?.image72
                        self?.apiService.webAPI.sendMessage(
                            channel: enChannelID,
                            text: translatedText,
                            username: username,
                            asUser: false,
                            iconURL: iconURL,
                            success: { ts, channel in
                                print(ts ?? "")
                                print(channel ?? "")

                                self?.apiService.webAPI.sendThreadedMessage(
                                    channel: enChannelID,
                                    thread: ts ?? "",
                                    text: text,
                                    username: username,
                                    asUser: false,
                                    iconURL: iconURL,
                                    success: { ts, channel in
                                        print(ts ?? "")
                                        print(channel ?? "")
                                }, failure: { error in
                                    print("send threaded message error: \(error)")
                                })
                                
                        }, failure: { error in
                            print("send threaded message error: \(error)")
                        })
                    case .failure(let error):
                        print("translate text error: \(error)")
                    }
                })
        }
    }

    private func translateText(text: String) -> SignalProducer<String, AnyError> {
        let baseURL = URL(string: "https://translation.googleapis.com")!
        let translatePath = "/language/translate/v2"
        let keyQ = "?key=\(googleAPIKey)"
        let finalPath = translatePath + keyQ
        let translateURL = URL(string: finalPath, relativeTo: baseURL)!
        var request = URLRequest(url: translateURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params = [
            "target": "en",
            "q": text,
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            return SignalProducer.init(error: AnyError(error))
        }

        let signal =  URLSession.shared.reactive.data(with: request)
            .map { data, response -> String in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                    let dict = jsonObject as? [String: Any] else {
                        return ""
                }
                let translateResponse = GoogleTranslateResponse(dict: dict)
                return translateResponse.translations.first?.translatedText ?? ""
        }
        return signal
    }
}

guard
    let slackToken = ProcessInfo.processInfo.environment[kSLACK_TOKEN],
    let googleAPIKey = ProcessInfo.processInfo.environment[kGOOGLE_API_KEY] else {
        fatalError("need SLACK_TOKEN and GOOGLE_API_KEY")
}
let slackbot = HonyakuBot(token: slackToken, googleAPIKey: googleAPIKey)
RunLoop.main.run()
