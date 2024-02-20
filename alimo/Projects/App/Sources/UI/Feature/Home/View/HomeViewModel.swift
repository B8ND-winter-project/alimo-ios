//
//  HomeViewModel.swift
//  App
//
//  Created by dgsw8th61 on 2/16/24.
//  Copyright © 2024 b8nd. All rights reserved.
//

import Foundation

class HomeViewModel: ObservableObject {
    private let homeService = HomeService.live
    @Published var category : [String] = []

    
    func getcategory() async {
        do {
            let getcategoryResponse = try await homeService.getcategory()
            self.category = getcategoryResponse.data.roles
            print(category)
        } catch {
            print(error)
        }
    }
    
    func notificationspeake() async {
        do {
            let notificationspeakeResponse = try await homeService.notificationspeaker()
            print(notificationspeakeResponse)
        } catch {
            print(error)
        }
    }
}


