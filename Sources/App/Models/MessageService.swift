//
//  MessageService.swift
//  RGBChatBot
//
//  Created by Katchapon Poolpipat on 9/26/2559 BE.
//
//

import Foundation
import Vapor
import HTTP

let accessToken = "EAAWlKpmeq08BAEk0YES9nshToaWM95w7HGTtqVYzzKLbcMZACIJH1eVYr4qUMzm264fnr2JaLrItqbJT7Q9gARB6AkbDxDA1MQr6JhZCnGm2ADIof5eatPc9VpV3P0AZAFJGLZCkroNbFytSmdRQMPwMr1P6CrEcJdLFihLnIAZDZD"
let lineAccessToken = "ZxPaAP0dqfALNp+9mB2+a3sgGSaVFy03LzvJURtcKwcJFjk0DPiGFy+fDICr3kdOxCjJpBu4MipKANsgqU7DNV86yWKUazRCJ3d1Fgx1eg854/d7moGhwCjuFSKR5QEh5RV14oNtH9pKE6DyX3qRHgdB04t89/1O/w1cDnyilFU="

enum FacebookAction {
  case message(String)
  case postback(String)
}

typealias ParserMessageService = (
  pass: Bool,
  senderID: String?,
  action: FacebookAction?
)

typealias LineParserMessageService = (
  pass: Bool,
  userID: String?,
  replyToken: String?
)

func parseJSONMessageFromLine(_ json: JSON) -> LineParserMessageService {
  guard let events = json["events"]?.array else {
    return (false, nil, nil)
  }
  
  guard let event = events[0] as? JSON else {
    return (false, nil, nil)
  }
  
  guard let replyToken = event["replyToken"]?.string else {
    return (false, nil, nil)
  }
  
  guard let source = event["source"]?.object else {
    return (false ,nil ,nil)
  }
  
  guard let userID = source["userId"]?.string else {
    return (false, nil, nil)
  }
  
  return(true, userID, replyToken)
  
}

func parseJSONMessage(_ data: Content) -> ParserMessageService {
  guard let entries = data["entry"]?.array else {
    return (false, nil, nil)
  }
  
  guard let entry = entries[0] as? JSON else{
    return (false, nil, nil)
  }
  
  if entry["messaging"] != nil {
    guard let messaging = entry["messaging"]?.array else {
      return (false, nil, nil)
    }
    
    guard let messageNode = messaging[0] as? JSON else {
      return (false, nil, nil)
    }
    
    guard let senderJSON = messageNode["sender"]?.object else {
      return (false, nil, nil)
    }
    
    guard let senderID = senderJSON["id"]?.string else {
      return (false, nil, nil)
    }
    
    var action: FacebookAction?
    
    if let senderMsg =  messageNode["message"] {
      guard let message = senderMsg["text"]?.string else {
        return (false, senderID, nil)
      }
      action = .message(message)
    }
    
    if let postBackJSON = messageNode["postback"] {
      guard let payload = postBackJSON["payload"]?.string else {
        return (false, senderID, nil)
      }
      action = .postback(payload)
    }
    
    if let action = action {
      return (true, senderID, action)
    }
    return (false, nil, nil)
  }
  
  return (false, nil, nil)
  
}

func sendTextMessage(_ messageText: String?, toRecipientID: String?) {
  guard let recipentID = toRecipientID, let messageText = messageText else {
    print("recipientID or messageText is nil")
    return
  }
  
  let id = ["id": recipentID]
  let message = ["text": messageText]
  
  let botMessage = ["recipient": id,
                    "message": message]
  
  sendMesssage(withJSONObject: botMessage)
}

func sendMessageToLine(withJSONObject obj:[String: Any]) {
  let url = "https://api.line.me/v2/bot/message/reply"
  
  let jsonData = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
  
  var urlRequest = URLRequest(url: URL(string: url)!)
  urlRequest.httpMethod = "POST"
  urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  urlRequest.setValue("Bearer " + lineAccessToken, forHTTPHeaderField: "Authorization")
  urlRequest.httpBody = jsonData
  
  let session = URLSession.shared
  
  let task = session.dataTask(with: urlRequest) { (data, response, error) in
    
    let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
    
    print(json)
    
    if let err = error {
      print(err)
      return
    }
  }
  
  task.resume()
}

func sendMesssage(withJSONObject obj:[String: Any]) {
  let url = "https://graph.facebook.com/v2.6/me/messages?access_token=" + accessToken
  
  let jsonData = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
  
  var urlRequest = URLRequest(url: URL(string: url)!)
  urlRequest.httpMethod = "POST"
  urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  urlRequest.httpBody = jsonData
  
  let session = URLSession.shared
  
  let task = session.dataTask(with: urlRequest) { (data, response, error) in
    
    let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
    
    print(json)
    
    if let err = error {
      print(err)
      return
    }
  }
  
  task.resume()
}

func sendCTPage(_ replyToken: String) {
  
  let messages = [
    [
      "type": "text",
      "text": "Here somethig about creative talk"
    ],
    [
      "type": "template",
      "altText": "this is a buttons template",
      "template": [
        "type": "buttons",
        "thumbnailImageUrl": "https://09188ffa.ngrok.io/images/Cover.jpg",
        "title":"Welcome to Creative talk\'s Page",
        "text": "Creative talk live by geng sitipong",
        "actions": [
          [
            "type": "uri",
            "label": "View detail",
            "uri": "http://example.com/page/123"
          ],
          [
            "type": "postback",
            "label": "Great",
            "data": "action=buy&itemid=123"
          ]
        ]
      ]
    ]
  ]
  
  let payloads = [
    "replyToken": replyToken,
    "messages": messages
  ] as [String : Any]
  
  sendMessageToLine(withJSONObject: payloads)
  
}

func sendCTPage(toRecipientID: String?) {
  
  guard let recipentID = toRecipientID else {
    print("RecipientID is nil")
    return
  }
  
  let id = ["id": recipentID]
  let elements = [["title":"Welcome to Creative talk\'s Page",
                   "item_url":"https://www.facebook.com/creativetalklive/",
                   "image_url":"https://09188ffa.ngrok.io/images/Cover.jpg",
                   "subtitle":"Creative talk live by geng sitipong",
                   "buttons":[["type":"web_url",
                               "url":"https://www.facebook.com/creativetalklive/",
                               "title":"View Website"
                    ],
                              ["type":"postback",
                               "title":"Great",
                               "payload":"Great"]
    ]
    ],["title":"Welcome to Creative talk\'s Page",
       "item_url":"https://www.facebook.com/creativetalklive/",
       "image_url":"https://09188ffa.ngrok.io/images/Cover.jpg",
       "subtitle":"Creative talk live by geng sitipong",
       "buttons":[["type":"web_url",
                   "url":"https://www.facebook.com/creativetalklive/",
                   "title":"View Website"
        ]]]
  ]
  let attachment = ["type": "template",
                    "payload": ["template_type": "generic",
                                "elements": elements
    ]] as [String : Any]
  let messageAttachment = [
    "attachment": attachment] as [String : Any]
  
  let botMessage = ["recipient": id,
                    "message": messageAttachment]
  
  sendMesssage(withJSONObject: botMessage)
}

func getSender(from id:String) throws -> Sender {
  print("find sender")
  let response = try drop.client.get("https://graph.facebook.com/v2.6/\(id)?fields=first_name,last_name,profile_pic,locale,timezone,gender&access_token=\(accessToken)")
  let json = try JSON(bytes: response.body.bytes!)
  print(json)
  if var sender = try! Sender.query().filter("fb_id", id).first() {
    if let firstName = json["first_name"]?.string {
      sender.firstName = firstName
    }
    if let lastName = json["last_name"]?.string {
      sender.lastName = lastName
    }
    if let profilePic = json["profile_pic"]?.string {
      sender.profilePic = profilePic
    }
    if let gender = json["gender"]?.string {
      sender.gender = gender
    }
    
    try sender.save()
    return sender
  } else {
    print("create new sender and save")
    var sender = Sender(fbID: id, firstName: json["first_name"]?.string, lastName: json["last_name"]?.string, profilePic: json["profile_pic"]?.string, gender: json["gender"]?.string)
    try sender.save()
    return sender
  }
}

