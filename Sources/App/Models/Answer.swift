//
//  Answer.swift
//  RGBChatBot
//
//  Created by Katchapon Poolpipat on 9/29/2559 BE.
//
//

import Foundation
import Vapor
import FluentMySQL
import HTTP
import Fluent

final class Answer: Model {
  var id: Node?
  var time: Int
  
  init(time: Int) {
    self.time = time
  }
  
  init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    time = try node.extract("time")
  }
  
  func makeNode(context: Context) throws -> Node {
    return try Node(node: [
        "id": id,
        "time": time
      ])
  }
  
  static func prepare(_ database: Database) throws {
    try database.create("answer") { answer in
      answer.id()
      answer.int("time")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete("answer")
  }
}
