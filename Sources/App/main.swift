import Vapor
import VaporMySQL
import HTTP

let mysql = try VaporMySQL.Provider(host: "localhost", user: "root", password: "", database: "chatbot")
let drop = Droplet(preparations: [Sender.self, Message.self], initializedProviders: [mysql])

drop.get { req in
    let lang = req.headers["Accept-Language"]?.string ?? "en"
    return try drop.view.make("welcome", [
    	"message": Node.string(drop.localization[lang, "welcome", "title"])
    ])
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
    throw Abort.custom(status: .badRequest, message: "Fail to parse json message")
  }
  
  sendCTPage(toRecipientID: senderID)
  
  return Response(status: .ok, body: "The request has succeeded.")
}

drop.resource("posts", PostController())

drop.run()
