//
//  Keyword.swift
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

final class Keyword: Model {
  var id: Node?
  var word: String
  var createDate: Int
  
  init(word: String, createDate: Int) {
    self.word = word
    self.createDate = createDate
  }
  
  convenience init(word: String) {
    let date = Date()
    self.init(word: word, createDate: Int(date.timeIntervalSince1970))
  }
  
  init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    word = try node.extract("word")
    createDate = try node.extract("create_date")
  }
  
  func makeNode(context: Context) throws -> Node {
    return try Node(node: [
        "id": id,
        "word": word,
        "create_date": createDate
      ])
  }
  
  static func prepare(_ database: Database) throws {
    try database.create("keywords") { keywords in
      keywords.id()
      keywords.string("word")
      keywords.int("create_date")
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete("keywords")
  }
}
