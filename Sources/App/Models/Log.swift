//
//  Log.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import FluentProvider

///Model which contains information about the User
final class Log: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///Title as a String
        case ip
        ///Content as a String
        case type
        ///Location as a Double
        case route
    }
    
    var ip: String
    var type: String
    let route: String
    
    init(row: Row) throws {
        self.ip = try row.get(Fields.ip)
        self.type = try row.get(Fields.type)
        self.route = try row.get(Fields.route)
    }
    
    
    init(ip: String, type: String, route: String) {
        self.ip = ip
        self.type = type
        self.route = route
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.ip, ip)
        try row.set(Fields.type, type)
        try row.set(Fields.route, route)
        
        return row
    }
}

// MARK: Preparation

extension Log: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.ip, optional: false)
            table.string(Fields.type, optional: false)
            table.string(Fields.route, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Log: JSONConvertible {
    
    convenience init(json: JSON) throws {
        try self.init(ip: json.get(Fields.ip),
                      type: json.get(Fields.type),
                      route: json.get(Fields.route))
        
        id = try json.get(Fields.id)
    }
    
    //Return Post as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.ip, ip)
        try json.set(Fields.type, type)
        try json.set(Fields.route, route)
        
        return json
    }
}

extension Log: Timestampable { }
extension Log: ResponseRepresentable { }



