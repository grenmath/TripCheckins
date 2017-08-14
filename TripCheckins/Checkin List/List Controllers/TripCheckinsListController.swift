//
//  TripCheckinsListController.swift
//  TripCheckins
//
//  Created by Nataliya  on 8/11/17.
//  Copyright © 2017 Nataliya Patsovska. All rights reserved.
//

import Foundation

class TripCheckinsListController: CheckinListController {
    var onViewModelUpdate: (() -> ())?
    private(set) var currentListViewModel: CheckinListViewModel? {
        didSet {
            guard let updateClosure = onViewModelUpdate else { return }
            updateClosure()
        }
    }
    
    private let checkinsService: CheckinService
    private let tripService: TripService
    private let tripId: String
    private var trip: Trip?
    
    init(checkinsService: CheckinService, tripService: TripService, tripId: String) {
        self.checkinsService = checkinsService
        self.tripService = tripService
        self.tripId = tripId
    }
    
    func reloadListItems() {
        guard !isLoading() else { return }
        
        currentListViewModel = TripCheckinsListController.loadingViewModel(withName: "")
        
        if let trip = trip {
            loadTripCheckins(trip)
        } else {
            tripService.loadTrip(withId: tripId, completionHandler: { (trip) in
                self.trip = trip
                self.reloadListItems()
                loadTripCheckins(trip)
            })
        }
    }
    
    private func loadTripCheckins(_ trip:Trip) {
        self.currentListViewModel = TripCheckinsListController.loadingViewModel(withName: trip.name)
        
        self.checkinsService.loadCheckins(after: nil, before: nil, completionHandler: { (listItems) in
            guard self.currentListViewModel != nil else { return }
            self.currentListViewModel?.populateWithListItems(from: listItems)
        })
    }
    
    static func loadingViewModel(withName name:String) -> CheckinListViewModel {
        return CheckinListViewModel(title: name,
                                    cellsNibName: "CompactCheckinTableViewCell",
                                    cellsHeight: 150,
                                    state: .loadingItems)
    }
}
