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
    
    guard let senderMsg = messageNode["message"]?.object else {
      return (false, nil, nil)
    }
    
    guard let senderID = senderJSON["id"]?.string else {
      return (false, nil, nil)
    }
    
    guard let message = senderMsg["text"]?.string else {
      return (false, nil, nil)
    }
    
    return (true, senderID, .message(message))
    
  }
  
  return (false, nil, nil)
  
}

func sendCTPage(toRecipientID: String?) {
//  sendTextMessage("Here\'s something about Creative Talk", toRecipientID: toRecipientID)
  let url = "https://graph.facebook.com/v2.6/me/messages?access_token=" + accessToken
  
  guard let recipentID = toRecipientID else {
    print("RecipientID is nil")
    return
  }
  
  let id = ["id": recipentID]
  let elements = [["title":"Welcome to Creative talk\'s Page",
                   "item_url":"https://www.facebook.com/creativetalklive/",
                   "image_url":"https://b0876abe.ngrok.io/images/Cover.jpg",
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
  
  let jsonData = try! JSONSerialization.data(withJSONObject: botMessage, options: .prettyPrinted)
  
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

