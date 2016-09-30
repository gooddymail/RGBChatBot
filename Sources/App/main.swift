import Vapor
import VaporMySQL
import HTTP

//mysql://bd7c96252fff35:fd4bfab7@us-cdbr-iron-east-04.cleardb.net/heroku_591c3c553e41e64?reconnect=true

//let mysql = try VaporMySQL.Provider(host: "localhost", user: "root", password: "", database: "chatbot")
let mysql = try VaporMySQL.Provider(host: "localhost", user: "chatbot", password: "oT926cN6bNm8D786", database: "chatbot")
let drop = Droplet(preparations: [Sender.self, Message.self], initializedProviders: [mysql])

drop.get { req in
    let lang = req.headers["Accept-Language"]?.string ?? "en"
    return try drop.view.make("welcome", [
    	"message": Node.string(drop.localization[lang, "welcome", "title"])
    ])
}

drop.post("linewebhook") { request in
  let json = try JSON(bytes: request.body.bytes!)
  print(json)
  let (checked, userID, replyToken) = parseJSONMessageFromLine(json)
  
  guard checked == true else {
    return Response(status: .badRequest, body: "Fail to parse json")
  }
  
  sendCTPage(replyToken!)
  
  return Response(status: .ok, body: "accept")
}

drop.get("webhook") { request in
  
  guard let token = request.data["hub.verify_token"]?.string else {
    throw Abort.badRequest
  }
  
  guard let response = request.data["hub.challenge"]?.string else {
    throw Abort.badRequest
  }
  
  if token == "025713420" {
    return Response(status: .ok, body: response)
  } else {
    return Response(status: .ok, body: "Error, invalid token")
  }
  
}

drop.post("webhook") { request in
  
  guard let entries = request.data["entry"]?.array else {
    throw Abort.custom(status: .badRequest, message: "Entry not found")
  }
  
  print(entries)
  
  guard let contentType = request.headers["Content-Type"], contentType.contains("application/json") else {
    return Response(status: .badRequest, body: "contentType is nill or not json type")
  }
  
  guard let json = request.json else {
    return Response(status: .badRequest, body: "JSON is nil")
  }
  
  let (checked, senderID, action) = parseJSONMessage(request.data)
  
  guard checked == true else {
    if let senderID = senderID {
      sendTextMessage("Just a word plz!", toRecipientID: senderID)
      return Response(status: .ok, body: "The request has succeeded.")
    } else {
      return Response(status: .badRequest, body: "Fail to parse json")
    }
  }
  
  let sender = try getSender(from: senderID!)
  
  switch action! {
  case .message(let text):
    print("recive message \"\(text)\"")
    var message = Message(message: text, senderID: sender.id)
    try message.save()
  case .postback(let text):
    print("recive post back")
  }
  
  sendCTPage(toRecipientID: senderID)
  
  return Response(status: .ok, body: "The request has succeeded.")
}

drop.get("sender", Sender.self, "messages") { request, sender in
  
  let messagesJSON = try sender.messages().all().makeNode().converted(to: JSON.self)
  
  return messagesJSON
}

drop.resource("posts", PostController())

drop.run()
