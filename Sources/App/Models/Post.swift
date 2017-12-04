//
//  Post.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import FluentProvider

///Model which contains information about the User
final class Post: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///Title as a String
        case title
        ///Content as a String
        case content
        ///Location as a Double
        case location
        ///UserId as an Int
        case user_id
    }
    
    var title: String
    var content: String
    let location: Double
    var userId: Identifier
    
    init(row: Row) throws {
        self.title = try row.get(Fields.title)
        self.content = try row.get(Fields.content)
        self.location = try row.get(Fields.location)
        self.userId = try row.get(Fields.user_id)
    }
   
    
    init(title: String, content: String, location: Double, userId: Identifier) {
        self.title = title
        self.content = content
        self.location = location
        self.userId = userId
        
        
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.title, title)
        try row.set(Fields.content, content)
        try row.set(Fields.location, location)
        try row.set(Fields.user_id, userId)
        
        return row
    }
}

// MARK: Preparation

extension Post: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.title, optional: false)
            table.string(Fields.content, optional: false)
            table.string(Fields.location, optional: false)
            table.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Post: JSONConvertible {
    
    convenience init(json: JSON) throws {
        try self.init(title: json.get(Fields.title),
                      content: json.get(Fields.content),
                      location: json.get(Fields.location),
                      userId: json.get(Fields.user_id))
        
        id = try json.get(Fields.id)
    }
    
    //Return Post as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.title, title)
        try json.set(Fields.content, content)
        try json.set(Fields.location, location)
        try json.set(Fields.user_id, userId)
        
        return json
    }
}

extension Post {
    var owner: Parent<Post, User> {
        return parent(id: userId)
    }
}

extension Post: Timestampable { }
extension Post: ResponseRepresentable { }


