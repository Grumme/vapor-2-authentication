//
//  Role.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import FluentProvider

///Defines the users access levels and restrictions.
final class Role: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///Type as a String
        case type
    }
    
    var type: String
    
    init(row: Row) throws {
        self.type = try row.get(Fields.type)
    }
    
    init(type: String) {
        self.type = type
        
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.type, type)
        
        return row
    }
}

// MARK: Preparation

extension Role: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.type, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Role: JSONConvertible {
    
    convenience init(json: JSON) throws {
        try self.init(type: json.get(Fields.type))
        
        id = try json.get(Fields.id)
    }
    
    //Return Post as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.type, type)
        
        return json
    }
}

extension Role {
    var users: Children<Role, User> {
        return children()
    }
}

extension Role: ResponseRepresentable { }



