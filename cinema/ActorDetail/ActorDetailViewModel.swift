//
//  ActorDetailViewModel.swift
//  cinema
//
//  Created by NSFuntik on 28.06.2023.
//

import Foundation
import Combine

final class ActorDetailViewModel: ObservableObject {
    let actorID: Int
    @Published var actor: Person
    let client: Service
    @Published var actorCast = [CastData]()
    
    init(actorID: Int, client: Service) {
        self.actorID = actorID
        self.client = client
        self.actor = .init()
        getActorDetails()
        getActorCast()
    }
    
   private func getActorDetails() {
        self.client.personDetails(person_id: self.actorID) { (personRes: Person) in
            DispatchQueue.main.async {
                self.actor = personRes
            }
        }
    }
    
    private func getActorCast() {
        self.client.personMovieCredits(personID: self.actorID) { (personCredit:PeopleCredits) in
            DispatchQueue.main.async {
                self.actorCast = personCredit.cast!
            }
        }
    }
}
