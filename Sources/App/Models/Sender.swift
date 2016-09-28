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
  var firstName: String?
  var lastName: String?
  var profilePic: String?
  var gender: String?
  
  init(fbID: String, firstName: String?, lastName: String?, profilePic: String?, gender: String?) {
    self.fbID = fbID
    self.firstName = firstName
    self.lastName = lastName
    self.profilePic = profilePic
    self.gender = gender
  }
  
  init(node: Node, in context: Context) throws {
    self.id = try node.extract("id")
    self.fbID = try node.extract("fb_id")
    self.firstName = try node.extract("first_name")
    self.lastName = try node.extract("last_name")
    self.profilePic = try node.extract("profile_pic")
    self.gender = try node.extract("gender")
  }
  
  public func makeNode(context: Context) throws -> Node {
    return try Node(node: [
        "id": id,
        "fb_id": fbID,
        "first_name": firstName,
        "last_name": lastName,
        "profile_pic": profilePic,
        "gender": gender
      ])
  }
  
  static func prepare(_ database: Database) throws {
    try database.create("senders") { senders in
      senders.id()
      senders.string("fb_id")
      senders.string("first_name")
      senders.string("last_name")
      senders.string("profile_pic")
      senders.string("gender")
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
