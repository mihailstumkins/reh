import Vapor
import FluentProvider
import HTTP

final class OrderService: Model {
    let storage = Storage()

    var serviceId: Identifier
    var physicianId: Identifier

    var durationEstimate: Int
    var frequency: String
    var ongoing: Bool
    var startEstimateAt: Date
    var startAt: Date
    var endAt: Date
    var comments: String


    var service: Parent<OrderService, Service> {
        return parent(id: serviceId)
    }

    var physician: Parent<OrderService, Physician> {
        return parent(id: physicianId)
    }

    init(serviceId: Identifier, physicianId: Identifier, durationEstimate: Int, frequency: String, ongoing: Bool, startEstimateAt: Date, startAt: Date,endAt: Date, comments: String) {
        self.serviceId = serviceId
        self.physicianId = physicianId
        self.durationEstimate = durationEstimate
        self.frequency = frequency
        self.ongoing = ongoing
        self.startEstimateAt = startEstimateAt
        self.startAt = startAt
        self.endAt = endAt
        self.comments = comments
    }

    init(row: Row) throws {
        serviceId = try row.get("service_id")
        physicianId = try row.get("physician_id")
        durationEstimate = try row.get("duration_estimate")
        frequency = try row.get("frequency")
        ongoing = try row.get("ongoing")
        startEstimateAt = try row.get("start_estimate_at")
        startAt = try row.get("start_at")
        endAt = try row.get("end_at")
        comments = try row.get("comments")

    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("service_id", serviceId)
        try row.set("physician_id", physicianId)
        try row.set("duration_estimate", durationEstimate)
        try row.set("frequency", frequency)
        try row.set("ongoing", ongoing)
        try row.set("start_estimate_at", startEstimateAt)
        try row.set("start_at", startAt)
        try row.set("end_at", endAt)
        try row.set("comments", comments)
        return row
    }
}

extension OrderService: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int("duration_estimate")
            builder.string("frequency")
            builder.bool("ongoing")
            builder.date("start_estimate_at")
            builder.date("start_at")
            builder.date("end_at")
            builder.string("comments")
            builder.foreignId(for: Service.self)
            builder.foreignId(for: Physician.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension OrderService: Timestampable { }
