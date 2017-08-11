//
//  AppCoordicator.swift
//  TripCheckins
//
//  Created by Nataliya  on 8/8/17.
//  Copyright © 2017 Nataliya Patsovska. All rights reserved.
//

import UIKit

class AppCoordinator {
    
    let navigationController: UINavigationController
    let authorizationTokenKeeper: AuthorizationTokenKeeper?
    var foursquareAuthorizer: FoursquareAuthorizer?
    
    init(navigationController: UINavigationController, authorizationTokenKeeper: AuthorizationTokenKeeper? = nil) {
        self.navigationController = navigationController
        self.authorizationTokenKeeper = authorizationTokenKeeper
        
        if let token = authorizationTokenKeeper?.authorizationToken() {
            showCheckinsList(authorizationToken: token)
        } else {
            showAuthorizationViewController()
        }
    }

    func processURL(_ url:URL) -> Bool {
        // TODO: redirect to child coordinators
        guard let foursquareAuthorizer = foursquareAuthorizer else { return false }
        return foursquareAuthorizer.requestAccessCode(forURL: url)
    }
    
    // MARK: - Private
    private func showAuthorizationViewController() {
        // TODO: move to a child coordinator
        let foursquareAuthorizer = FoursquareAuthorizer()
        let viewController = FoursquareAuthorizationViewController(foursquareAuthorizer: foursquareAuthorizer)
        viewController.delegate = self
        pushViewController(viewController)
        self.foursquareAuthorizer = foursquareAuthorizer
    }
    
    private func showCheckinsList(authorizationToken token:String) {
        let checkinsService = FoursquareCheckinService(fetcher: FoursquareCheckinFetcher(authorizationToken: token), parser: FoursquareCheckinItemParser())
//        let controller = AllCheckinsListController(checkinsService: checkinsService)
        let controller = TripCheckinsListController(checkinsService: checkinsService, tripService: PredefinedTripService(), tripId: "test")
        let viewController = CheckinListViewController(controller: controller)
        viewController.delegate = self
        pushViewController(viewController)
    }
    
    private func pushViewController(_ viewController:UIViewController) {
        let animated = navigationController.viewControllers.count > 0
        navigationController.pushViewController(viewController, animated: animated)
    }
}

extension AppCoordinator: FoursquareAuthorizationViewControllerDelegate {
    func didFinishAuthorizationFlow(_ token: String) {
        authorizationTokenKeeper?.persistAuthorizationToken(token)
        showCheckinsList(authorizationToken: token)
    }
}

extension AppCoordinator: CheckinListViewControllerDelegate {
    func listViewControllerDidTriggerAddAction(_ controller: CheckinListViewController) {
        // TODO: implement adding
        print("add trigerred")
    }
}
