//
//  Router.swift
//  SpaceFlightNewsChallenge
//
//  Created by Ivan Cardenas on 27/10/2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class Router<R: Hashable>: ObservableObject {
    @Published var path = NavigationPath()
    @Published var overlayRoute: R?

    func push(_ route: R) {
        print("[Router] push ->", route)
        path.append(route)
        print("[Router] current path count:", path.count)
    }
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
        print("[Router] pop -> count:", path.count)
    }
    func popToRoot() {
        path = .init()
        print("[Router] popToRoot")
    }

    func presentOverlay(_ route: R) {
        print("[Router] presentOverlay ->", route)
        overlayRoute = route
    }

    func dismissOverlay() {
        print("[Router] dismissOverlay")
        overlayRoute = nil
    }
}
