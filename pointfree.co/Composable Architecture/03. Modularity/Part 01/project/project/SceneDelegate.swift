//
//  SceneDelegate.swift
//  project
//
//  Created by Choi SeungHyuk on 2020/11/02.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: ContentView(store: Store(initialValue: AppState(), reducer: logging(activityFeed(appReducer))))
          )
      self.window = window
      window.makeKeyAndVisible()
    }
  }
}


