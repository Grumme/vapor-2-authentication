//
//  UserController.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import HTTP
import AuthProvider
import Foundation

///RESTful interactions with our Users table
final class UserController {
    
    private let droplet: Droplet
    
    init(droplet: Droplet) {
        self.droplet = droplet
    }
    
    /**
     Add routes
     */
    func addRoutes() {

        droplet.adminAuthed.get("hello") { request in
                return "You have accessed a protected route"
        }
        
        droplet.post("register", handler: register)
        
        droplet.passwordAuthed.post("login", handler: login)
        
        droplet.tokenAuthed.get("user", Int.parameter,  handler: getUser)
        droplet.tokenAuthed.get("users", handler: getAllUsers)
        droplet.tokenAuthed.get("me", handler: getLoggedInUser)
        droplet.tokenAuthed.put("user", handler: updateUser)
        droplet.tokenAuthed.post("logout", handler: logout)

    }
    
    /**
     When consumers call 'POST' on '/register' with valid JSON
     construct and save the user.
     ```
     {
         "email": "test@test.dk",
         "password": "123456",
         "name": "Your name"
     }
     */
    func register(request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string else {
            throw Abort(.badRequest, reason: "Please provide e-mail")
        }
        
        if !isValidEmail(testStr: email) {
            throw Abort(.badRequest, reason: "E-mail is invalid")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort(.badRequest, reason: "Plese provide password")
        }
        
        guard let name = request.data["name"]?.string else {
            throw Abort(.badRequest, reason: "Plese provide name")
        }
        
        let user = try User.register(email: email, password: password, name: name)
        
        let token = try AccessToken.generate(for: user)
        try token.save()
        
        return try JSON(node: ["token" : token.token, "user" : try user.makeJSON()])
    }
    
    
    
    private  func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /**
     When consumers call 'POST' on '/login' with valid Basic Auth information
     the user will be provided with a token.
     */
    func login(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let token = try AccessToken.generate(for: user)
        try token.save()
        
        return try JSON(node: ["token" : token.token, "user" : try user.makeJSON()])
    }
    
    /**
     When consumers call 'POST' on 'logout' the current token will be deleted.
     Only available with valid token.
     */
    func logout(request: Request) throws -> ResponseRepresentable {
        guard let tokenStr = request.auth.header?.bearer?.string,
              let token = try AccessToken.makeQuery().filter(AccessToken.Fields.token, tokenStr).first() else {
                throw Abort.badRequest
        }
        
        try token.delete()
        
        return Response(status: .ok)
    }
    
    /**
     When the consumer calls 'GET' on a specific resource, ie:
     '/user/2' we should show that specific user.
     Only available with valid token.
     */
    func getUser(request: Request) throws -> ResponseRepresentable {
        let userId = try request.parameters.next(Int.self)
        
        guard let user = try User.find(userId) else {
            throw Abort(.badRequest, reason: "Couldn't find any user with that ID")
        }
        
        return user
    }
    
    /**
     When users call 'GET' on '/users'
     it should return an index of all available users.
     Only available with valid token.
     */
    func getAllUsers(request: Request) throws -> ResponseRepresentable {
        return try User.makeQuery().all().makeJSON()//.filter({ $0.id != userId }).makeJSON()
    }
    
    /**
     When users call 'PUT' on '/user'
     it should return an index of all available users.
     Only available with valid token.
     ```
     {
         "name": "Your name"
     }
     */
    func updateUser(request: Request) throws -> ResponseRepresentable {
        guard let name = request.json?["name"]?.string else {
            throw Abort(.badRequest, reason: "Please provide a name")
        }
        
        let user = try request.user()
        user.name = name
        
        try user.save()
        
        return user
    }
    
    /**
     When users call 'GET' on '/me'
     it should return information about the logged in user.
     Only available with valid token.
     */
    func getLoggedInUser(request: Request) throws -> ResponseRepresentable {
        return try request.user().makeJSON()
    }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count)) != nil
    }
}


