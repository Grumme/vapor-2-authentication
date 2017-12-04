//
//  Config+Setup.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import FluentProvider
import MySQLProvider
import AuthProvider

weak var config: Config!

extension Config {
    
    public func setup() throws {
        config = self
        
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        try setupPreparations()
    }
    
    private func setupProviders() throws {
        addConfigurable(middleware: LogMiddleware(), name: "log")
        
        try addProvider(AuthProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
    }
    
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(AccessToken.self)
        preparations.append(Post.self)
        preparations.append(Role.self)
        preparations.append(Log.self)
    }
}
