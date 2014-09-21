//
//  SpotifyAuthenticationViewController.swift
//  mySpotify
//
//  Created by Louis Cheung on 9/21/14.
//  Copyright (c) 2014 Louis Cheung. All rights reserved.
//

import AVFoundation
import UIKit

class SpotifyAuthenticationViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    // Spotify OAuth
    let kClientId = "02e882e54f34457481270fe96b0ff1b9"
    let kCallbackUrl = "myspotify://callback"
    let kTokenSwapUrl = "http://localhost:1234/swap"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.scrollView.scrollEnabled = false

        // Give the app delegate a reference to this class so that it can forward Spotify's authentication callback.
        (UIApplication.sharedApplication().delegate as AppDelegate).spotifyAuthenticationViewController = self

        let url = SPTAuth.defaultInstance().loginURLForClientId(kClientId,
            declaredRedirectURL: NSURL.URLWithString(kCallbackUrl),
            scopes: [SPTAuthStreamingScope])
        self.webView.loadRequest(NSURLRequest(URL: url))
    }

    func spotifyAuthenticationCallbackUrl(url: NSURL) -> Bool {
        return true
    }
}
