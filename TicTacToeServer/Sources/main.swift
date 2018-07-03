//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectWebSockets
import PerfectLib

func makeRoutes() -> Routes {
    var routes = Routes()
    
    // Add the endpoint for the WebSocket example system
    routes.add(method: .get, uri: "/game", handler: {
        request, response in
        
        // To add a WebSocket service, set the handler to WebSocketHandler.
        // Provide your closure which will return your service handler.
        WebSocketHandler(handlerProducer: {
            (request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
            
            // Return our service handler.
            return GameHandler()
        }).handleRequest(request: request, response: response)
    })
    
    return routes
}

do {
    // Launch the HTTP server on port 8181
    try HTTPServer.launch(name: "localhost", port: 8181, routes: makeRoutes())
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
