import Vapor
import FluentProvider
import HTTP

final class Order: Model {
    let storage = Storage()

    var customerId: Identifier
    var identifier: String
    var applicant: String
    var address: String

    var customer: Parent<Order, Customer> {
        return parent(id: customerId)
    }

    init(customerId: Identifier, identifier: String, applicant: String, address: String) {
        self.customerId = customerId
        self.identifier = identifier
        self.applicant = applicant
        self.address = address
    }

    init(row: Row) throws {
        identifier = try row.get("identifier")
        applicant = try row.get("applicant")
        address = try row.get("address")
        customerId = try row.get("customer_id")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("customer_id", customerId)
        try row.set("identifier", identifier)
        try row.set("applicant", applicant)
        try row.set("address", address)
        return row
    }
}

extension Order: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("identifier")
            builder.string("applicant")
            builder.string("address")
            builder.foreignId(for: Customer.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Order {
    var services: Siblings<Order, OrderService, Pivot<Order, OrderService>> {
        return siblings()
    }
}

extension Order: Timestampable { }
