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

let accessToken = "EAAWk3EyUa60BAK2BXg6vLZCUpxscMupNAiZAKHm4b0OuvuLGIfmSdHyEH7ZBAl58aZALZBBQ7WVTqtV8iGhAxRmkll9uGlyft5189uoD5Kyt8vmG9wZBiz4hh6HOZCys63BH3ffeZBus7RqYbk84bpPAJUtMEAIOLdAjRtfQkB07hAZDZD"

enum FacebookAction {
  case message(String)
  case postback(String)
}

typealias ParserMessageService = (
  pass: Bool,
  senderID: String?,
  action: FacebookAction?
)

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

func sendCTPage(toRecipientID: String?) {
  
  guard let recipentID = toRecipientID else {
    print("RecipientID is nil")
    return
  }
  
  let id = ["id": recipentID]
  let elements = [["title":"Welcome to Creative talk\'s Page",
                   "item_url":"https://www.facebook.com/creativetalklive/",
                   "image_url":"https://98cfaff1.ngrok.io/images/Cover.jpg",
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
       "image_url":"https://98cfaff1.ngrok.io/images/Cover.jpg",
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

