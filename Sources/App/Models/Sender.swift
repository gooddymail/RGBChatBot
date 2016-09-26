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
  var name: String
  var fbID: String
  
  init(name: String, fbID: String) {
    self.name = name
    self.fbID = fbID
  }
  
  init(node: Node, in context: Context) throws {
    self.id = try node.extract("id")
    self.name = try node.extract("name")
    self.fbID = try node.extract("fbID")
  }
  
  public func makeNode(context: Context) throws -> Node {
    return try Node(node: [
        "id": id,
        "name": name,
        "fbID": fbID
      ])
  }
  
  static func prepare(_ database: Database) throws {
    try database.create("senders") { senders in
      senders.id()
      senders.string("name")
      senders.string("fbID")
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
