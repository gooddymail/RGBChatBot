//
//  Message.swift
//  RGBChatBot
//
//  Created by Katchapon Poolpipat on 9/26/2559 BE.
//
//

import Foundation
import Vapor
import FluentMySQL
import HTTP
import Fluent

final class Message: Model {
  var id: Node?
  var message: String
  var time: Int
  var senderID: Node?
  
  init(message: String, time: Int, senderID: Node?) {
    self.message = message
    self.time = time
    self.senderID = senderID
  }
  
  convenience init(message: String, senderID: Node?) {
    let date = Date()
    self.init(message: message, time: Int(date.timeIntervalSince1970), senderID: senderID)
  }
  
  init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    message = try node.extract("message")
    time = try node.extract("time")
    senderID = try node.extract("sender_id")
  }
  
  func makeNode(context: Context) throws -> Node {
    return try Node(node: [
        "id": id,
        "message": message,
        "time": time,
        "sender_id": senderID
      ])
  }
  
  static func prepare(_ database: Database) throws {
    try database.create("messages") { messages in
      messages.id()
      messages.string("message")
      messages.int("time")
      messages.int("sender_id")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete("messages")
  }
}

extension Message {
  func sender() throws -> Parent<Sender> {
    return try parent(senderID)
  }
}
