//
//  CheckinListViewModel.swift
//  TripCheckins
//
//  Created by Nataliya  on 8/10/17.
//  Copyright © 2017 Nataliya Patsovska. All rights reserved.
//

import Foundation

enum ListViewModelState {
    case loadingItems
    case error(String)
    case loadedListItemViewModels([CompactCheckinCellModel])
}

struct CheckinListViewModel {
    let title: String
    let cellsNibName: String
    let cellsHeight: CGFloat
    var state: ListViewModelState
    
    func listItemsCount() -> Int {
        switch state {
        case .loadedListItemViewModels(let itemsViewModels):
            return itemsViewModels.count
        default:
            return 0
        }
    }
    
    func listItemViewModel(at index:Int) -> CompactCheckinCellModel? {
        switch state {
        case .loadedListItemViewModels(let itemsViewModels):
            return itemsViewModels[index]
        default:
            return nil
        }
    }
    
    mutating func populateWithListItems(from checkinItems:[CheckinItem]) {
        state = .loadedListItemViewModels(checkinItems.map( {CompactCheckinCellModel(checkinItem: $0)} ))
    }
}
