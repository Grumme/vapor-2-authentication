//
//  Droplet+Setup.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

@_exported import Vapor
import AuthProvider

weak var drop: Droplet!

extension Droplet {
    
    public func setup() throws {
        drop = self
        
        
        try setupRoutes()
        seedData()
    }
    
    func seedData() {
        guard (try? User.count()) == 0 else { return }
        guard (try? Role.count()) == 0 else { return }
        
        let roleAdmin = Role(type: "admin")
        let roleUser = Role(type: "user")
        
        try? roleAdmin.save()
        try? roleUser.save()
        
        let user1 = try? User.register(email: "admin@admin.dk", password: "123456")
        user1?.roleId = roleAdmin.id
        
        try? user1?.save()
        
        if let user1Id = user1?.id {
            let accessToken1 = AccessToken(token: "u1 token", userId: user1Id)
            try? accessToken1.save() }
    }
}
