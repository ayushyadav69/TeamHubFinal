//
//  EmployeeEntity.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation
import SwiftData

@Model
final class EmployeeEntity {

    @Attribute(.unique)
    var id: String

    var name: String
    
    //old
    var roleName: String
    var departmentName: String
    
    // new
    var department: DepartmentEntity?
    var role: RoleEntity?
    
    var isActive: Bool
    var imageURL: String
    var email: String
    var city: String
    var country: String
    var joiningDate: Date

    
    init(
        id: String,
        name: String,
        role: String,
        department: String,
        isActive: Bool,
        imageURL: String,
        email: String,
        city: String,
        country: String,
        joiningDate: Date
    ) {
        self.id = id
        self.name = name
        self.roleName = role
        self.departmentName = department
        self.isActive = isActive
        self.imageURL = imageURL
        self.email = email
        self.city = city
        self.country = country
        self.joiningDate = joiningDate
    }
}

extension EmployeeEntity {
    
    static func fromDomain(_ employee: Employee) -> EmployeeEntity {
        EmployeeEntity(
            id: employee.id,
            name: employee.name,
            role: employee.role,
            department: employee.department,
            isActive: employee.isActive,
            imageURL: employee.imageURL?.absoluteString ?? "",
            email: employee.email,
            city: employee.city,
            country: employee.country,
            joiningDate: employee.joiningDate
        )
    }
    
    func toDomain() -> Employee {
        Employee(
            id: id,
            name: name,
            role: role?.name ?? roleName,
            department: department?.name ?? departmentName,
            isActive: isActive,
            imageURL: URL(string: imageURL),
            email: email,
            city: city,
            country: country,
            joiningDate: joiningDate
        )
    }
}
