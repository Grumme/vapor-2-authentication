//
//  PostController.swift
//  Vapor 2 Authentication
//
//  Created by Jakob Grumsen on 26/09/2017.
//

import Vapor
import HTTP
import AuthProvider

///RESTful interactions with our Users table
final class PostController {
    
    private let droplet: Droplet

    init(droplet: Droplet) {
        self.droplet = droplet
    }
    
    /**
     Add routes
     */
    func addRoutes() {
        
        droplet.tokenAuthed.get("posts", handler: getAllPosts)
        droplet.tokenAuthed.get("posts", Int.parameter, handler: getPost)
        droplet.tokenAuthed.put("posts", Int.parameter, handler: updatePost)
        droplet.tokenAuthed.delete("posts", Int.parameter, handler: deletePost)
        
        droplet.tokenAuthed.group("posts") { posts in
            posts.post("create", handler: createPost)
        }
    }
    
    /**
     When consumers call 'POST' on '/posts/create' with valid JSON
     construct and save the post.
     Only available with valid token.
     ```
     {
         "title": "Your title",
         "content: "Your content",
         "location": "Your name"
     }
     */
    func createPost(request: Request) throws -> ResponseRepresentable {
        
        guard let title = request.data["title"]?.string else {
            throw Abort(.badRequest, reason: "Please provide a title")
        }
        
        guard let content = request.data["content"]?.string else {
            throw Abort(.badRequest, reason: "Please provide some content")
        }
        
        guard let userId = try request.user().id else {
            throw Abort(.badRequest, reason: "Could not find any User")
        }
        
        let post = Post(title: title,
                        content: content,
                        location: 10.2,
                        userId: userId)
        
        try post.save()
        
        return try post.makeJSON()
    }
    
    /**
     When the consumer calls 'GET' on a specific resource, ie:
     '/posts/2' we should show that specific post.
     Only available with valid token.
     */
    func getPost(request: Request) throws -> ResponseRepresentable {
        let postId = try request.parameters.next(Int.self)
        
        guard let post = try Post.find(postId) else {
            throw Abort(.badRequest, reason: "Could'nt find any post with that ID")
        }
        
        return post
    }
    
    /**
     When users call 'GET' on '/posts'
     it should return an index of all available posts.
     Only available with valid token.
     */
    func getAllPosts(request: Request) throws -> ResponseRepresentable {
        return try Post.makeQuery().all().makeJSON()
    }
    
    /**
     When users call 'PUT' on '/posts/2'
     they should be able to edit the selected post, if they are the owner.
     Only available with valid token.
     ```
     {
         "title": "Your name",
         "content": "Content"
     }
     */
    func updatePost(request: Request) throws -> ResponseRepresentable {
        let postId = try request.parameters.next(Int.self)
        
        guard let title = request.json?["title"]?.string else {
            throw Abort(.badRequest, reason: "You must provide a title")
        }
        
        guard let content = request.json?["content"]?.string else {
            throw Abort(.badRequest, reason: "You must provide content")
        }

        guard let post = try Post.find(postId) else {
            throw Abort(.badRequest, reason: "Could'nt find any post with that ID")
        }
        
        guard let userId = try request.user().id else {
            throw Abort(.badRequest, reason: "No user id")
        }
        
        if post.userId != userId {
            throw Abort(.badRequest, reason: "You can only edit your own posts")
        }
        
        post.title = title
        post.content = content
        
        try post.save()
        
        return try post.makeJSON()
    }
    
    /**
     When users call 'DELETE' on '/posts/2'
     they should be able to delete the selected post, if they are the owner.
     Only available with valid token.
     */
    func deletePost(request: Request) throws -> ResponseRepresentable {
        let postId = try request.parameters.next(Int.self)

        guard let post = try Post.find(postId) else {
            throw Abort(.badRequest, reason: "Could'nt find any post with that ID")
        }
        
        guard let userId = try request.user().id else {
            throw Abort(.badRequest, reason: "No user id")
        }
        
        if post.userId != userId {
            throw Abort(.badRequest, reason: "You can only delete your own posts")
        }
        
        //Instead of delete, we should just set the post as inactive/deactivated
        
        try post.delete()
        
        return try JSON(node :["success": true])
    }
}
