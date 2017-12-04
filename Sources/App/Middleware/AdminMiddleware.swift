//
//  AdminMiddleware.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import HTTP

class AdminMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {

        if try request.user().role.get()?.type != "admin" {
            throw Abort.unauthorized
        } else {
            return try next.respond(to: request)
        }
        
    }
}
