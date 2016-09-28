//
//  Sender.swift
//  RGBChatBot
//
//  Created by Katchapon Poolpipat on 9/26/2559 BE.
//
//

import Foundation
import Vapor
import Fluent


final class Sender: Model {
  var id: Node?
  var fbID: String
  
  init(fbID: String) {
    self.fbID = fbID
  }
  
  init(node: Node, in context: Context) throws {
    self.id = try node.extract("id")
    self.fbID = try node.extract("fb_id")
  }
  
  public func makeNode(context: Context) throws -> Node {
    return try Node(node: [
        "id": id,
        "fbID": fbID
      ])
  }
  
  static func prepare(_ database: Database) throws {
    try database.create("senders") { senders in
      senders.id()
      senders.string("fb_id")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete("senders")
  }
}

extension Sender {
  func messages() -> Children<Message> {
    return children()
  }
}
