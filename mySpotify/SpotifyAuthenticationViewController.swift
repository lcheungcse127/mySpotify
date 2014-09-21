//
//  SpotifyAuthenticationViewController.swift
//  mySpotify
//
//  Created by Louis Cheung on 9/21/14.
//  Copyright (c) 2014 Louis Cheung. All rights reserved.
//

import AVFoundation
import UIKit

class SpotifyAuthenticationViewController: UITabBarController {

    // Spotify OAuth
    let kClientId = "02e882e54f34457481270fe96b0ff1b9"
    let kCallbackUrl = "myspotify://callback"
    let kTokenSwapUrl = "http://localhost:1234/swap"

    var spotifySession: SPTSession?

// --------------------------------------------------------------------------------------------------- MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Give the app delegate a reference to this class so that it can forward Spotify's authentication callback.
        (UIApplication.sharedApplication().delegate as AppDelegate).spotifyAuthenticationViewController = self

        // Open Spotify authentication URL in Safari.
        let url = SPTAuth.defaultInstance().loginURLForClientId(kClientId,
            declaredRedirectURL: NSURL.URLWithString(kCallbackUrl),
            scopes: [SPTAuthStreamingScope])

        UIApplication.sharedApplication().openURL(url)
    }

// ---------------------------------------------------------------------------------------------- MARK: - User Interface

    func configureUserInterface() {

    }

// ----------------------------------------------------------------------------------------------------- MARK: - Network

    func spotifyAuthenticationCallbackUrl(url: NSURL) -> Bool {
        // Ask SPTAuth if the URL given is a Spotify authentication callback.
        if SPTAuth.defaultInstance().canHandleURL(url, withDeclaredRedirectURL: NSURL.URLWithString(kCallbackUrl)) {
            // Call the token swap service to get a logged in session.
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url,
                tokenSwapServiceEndpointAtURL: NSURL.URLWithString(kTokenSwapUrl),
                callback: { (error: NSError!, session: SPTSession!) -> Void in
                    if error != nil {
                        NSLog("<%@:%d> %@", __FILE__.lastPathComponent, __LINE__, error)
                    }
                    else {
                        self.spotifySession = session
                        self.configureUserInterface()
                    }
                }
            )
            return true
        }
        else {
            return false
        }
    }
}
