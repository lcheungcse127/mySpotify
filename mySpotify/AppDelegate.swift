//
//  AppDelegate.swift
//  mySpotify
//
//  Created by Louis Cheung on 9/19/14.
//  Copyright (c) 2014 Louis Cheung. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // ------------------------------------------------------------------------------------------------- MARK: - Spotify

    // OAuth Properties
    let kClientId = "02e882e54f34457481270fe96b0ff1b9"
    let kCallbackUrl = "mySpotify://callback"
    let kTokenSwapUrl = "http://localhost:1234/swap"

    var session: SPTSession?
    var player: SPTAudioStreamingController?

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String,
        annotation: AnyObject?) -> Bool
    {
        // Handle auth callback.
        if SPTAuth.defaultInstance().canHandleURL(url, withDeclaredRedirectURL: NSURL.URLWithString(kCallbackUrl)) {
            // Call the token swap service to get a logged in session.
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url,
                tokenSwapServiceEndpointAtURL: NSURL.URLWithString(kTokenSwapUrl),
                callback: { (error: NSError!, session: SPTSession!) -> Void in
                    if error != nil {
                        NSLog("*** Auth error: %@", error)
                        return
                    }

                    // Call the -playUsingSession: method to play a track.
                    self.playUsingSession(session)
                }
            )
            return true
        }

        return false
    }

    func playUsingSession(session: SPTSession) {
        // Create a new player if needed.
        if self.player == nil {
            self.player = SPTAudioStreamingController()
        }

        self.player?.loginWithSession(session, callback: { (error: NSError!) -> Void in
            if error != nil {
                NSLog("*** Enabling playback got error: %@", error)
                return
            }

            SPTRequest.requestItemAtURI(NSURL.URLWithString("spotify:album:4L1HDyfdGIkACuygktO7T7"),
                withSession: nil, callback: { (error: NSError!, album: AnyObject!) -> Void in
                    if error !=  nil {
                        NSLog("*** Album lookup got error %@", error)
                        return
                    }

                    self.player?.playTrackProvider(album as SPTAlbum, callback: nil)
                }
            )
        })
    }

    // ----------------------------------------------------------------------------------- MARK: - Application Lifecycle

    var window: UIWindow?

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Create SPTAuth instance; create login URL and open it.
        let auth = SPTAuth.defaultInstance()
        let loginURL: NSURL = auth.loginURLForClientId(kClientId,
            declaredRedirectURL: NSURL.URLWithString(kCallbackUrl),
            scopes: [SPTAuthStreamingScope])
        application.openURL(loginURL)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of 
        // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the 
        // application and it begins the transition to the background state. Use this method to pause ongoing tasks, 
        // disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application 
        // state information to restore your application to its current state in case it is terminated later. If your 
        // application supports background execution, this method is called instead of applicationWillTerminate: when 
        // the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the 
        // changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the 
        // application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also 
        // applicationDidEnterBackground:. Saves changes in the application's managed object context before the 
        // application terminates.
        self.saveContext()
    }

    // ----------------------------------------------------------------------------------------- MARK: - Core Data Stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named 
        // "io.LouisCheung.mySpotify" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the 
        // application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("mySpotify", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, 
        // having added the store for the application to it. This property is optional since there are legitimate error 
        // conditions that could cause the creation of the store to fail.

        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("mySpotify.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in 
            // a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store 
        // coordinator for the application.) This property is optional since there are legitimate error conditions that 
        // could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // -------------------------------------------------------------------------------- MARK: - Core Data Saving Support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this 
                // function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}
