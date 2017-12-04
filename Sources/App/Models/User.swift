//
//  User
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import FluentProvider
import AuthProvider

///Model which contains information about the User
final class User: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///E-mail as a String
        case email
        ///Password as a String
        case password
        ///Name as a String
        case name
        ///Admin status as a Bool
        case role_id
    }
    
    let email: String
    var password: String?
    var name: String
    var roleId: Identifier?
    
    init(row: Row) throws {
        self.email = try row.get(Fields.email)
        self.password = try row.get(Fields.password)
        self.name = try row.get(Fields.name)
        self.roleId = try row.get(Fields.role_id)
    }
    
    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.email, email)
        try row.set(Fields.password, password)
        try row.set(Fields.name, name)
        try row.set(Fields.role_id, roleId)
        
        return row
    }
}

// MARK: Preparation

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.email, optional: false, unique: true)
            table.string(Fields.password, optional: false)
            table.string(Fields.name, optional: false)
            table.string(Fields.role_id, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension User: JSONConvertible {
    
    convenience init(json: JSON) throws {
        
        
        
        try self.init(email: json.get(Fields.email),
                      name: json.get(Fields.name))
        id = try json.get(Fields.id)
    }
    
    //Return User as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.email, email)
        try json.set(Fields.name, name)

        return json
    }
}

extension User {
    
    var posts: Children<User, Post> {
        return children()
    }
    
    var role: Parent<User, Role> {
        return parent(id: roleId)
    }
    
    class func register(email: String, password: String, name: String = "No name") throws -> User {
        
        let user = User(email: email, name: name)
        user.password = try drop.hash.make(password.makeBytes()).makeString()
        
        guard let role = try Role.makeQuery().filter("type" == "user").first() else {
            throw Abort(.badRequest, reason: "Couldn't find a role with the given ID.")
        }
        
        user.roleId = role.id
        
        guard try User.makeQuery().filter(Fields.email, user.email).first() == nil else {
            throw Abort(.badRequest, reason: "A user with that username already exists.")
        }
        
        try user.save()
        return user
    }
}

// MARK: Auth

extension User: TokenAuthenticatable {
    public typealias TokenType = AccessToken
}

extension User: PasswordAuthenticatable {
    
    static var usernameKey: String { return Fields.email.rawValue }
    static var passwordVerifier: PasswordVerifier? { return drop.hash as? PasswordVerifier }
    var hashedPassword: String? { return password }
}

// MARK: Helpers

extension Request {
    
    ///Returns the user, if authenticated
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
    
}

extension User: Timestampable { }
extension User: ResponseRepresentable { }
