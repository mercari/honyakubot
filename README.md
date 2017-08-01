# Honyaku Bot

### Requirements:

Swift 3.1
Xcode 8+

### Usage:
Set environment variables for SLACK_TOKEN and GOOGLE_API_KEY

```
export SLACK_TOKEN=foo && export GOOGLE_API_KEY=bar
```
 
Generate executable and run:

```
swift build && ./.build/debug/honyakubot
```

### Development:
  ```
  swift package generate-xcodeproj
  open honyakubot.xcodeproj
  Edit Scheme -> Run -> Arguments -> Environment Variables -> (set `SLACK_TOKEN` and `GOOGLE_API_KEY`)
  ```

### TODO:
* don't translate events, e.g. user has joined channel
* style original text differently
* logs: add date
* add greeting
* allow stop listening
* create -en channel
* en to jp translation
* deploy to cloud or another machine


### References:
* https://github.com/SlackKit/SlackKit
* https://api.slack.com/methods
* https://api.slack.com/rtm
* https://cloud.google.com/translate/docs/translating-text
