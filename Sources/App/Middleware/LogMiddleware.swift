//
//  Middleware.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import HTTP

class LogMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let log = Log(ip: request.peerHostname!, type: request.method.description, route: request.uri.lastPathComponent!)
        try log.save()
        
        return try next.respond(to: request)
    }
    
}
