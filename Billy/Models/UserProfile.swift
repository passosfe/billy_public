//
//  UserProfile.swift
//  Billy
//
//  Created by Felipe Passos on 27/12/20.
//

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Codable {
    @DocumentID var id: String?
    var email: String
    var newPermissions: [NewPermission]?
}

struct NewPermission: Codable {
    var fromEmail: String
    var toEmail: String
    var budgetID: String
    var budgetName: String
    var permissionType: PermissionTypes
}
