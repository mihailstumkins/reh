import Vapor
import FluentProvider
import HTTP
import AuthProvider
import JWTProvider
import JWT

public enum RegistrationError: Error {
    case emailTaken
}

final class User: Model {
    let storage = Storage()

    var name: String
    var surname: String
    var email: String
    var phone: String
    var password: String?

    init(name: String, surname: String, email: String, phone: String, password: String? = nil) {
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
        self.password = password
    }

    init(row: Row) throws {
        name = try row.get("name")
        surname = try row.get("surname")
        email = try row.get("email")
        phone = try row.get("phone")
        password = try row.get("password")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("surname", surname)
        try row.set("email", email)
        try row.set("phone", phone)
        try row.set("password", password)
        return row
    }
}

extension User {
    func physician() throws -> Physician? {
        return try children().first()
    }
}

extension User: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("surname")
            builder.string("email")
            builder.string("phone")
            builder.string("password")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            surname: json.get("surname"),
            email: json.get("email"),
            phone: json.get("phone")
        )
        id = try json.get("id")
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("surname", surname)
        try json.set("phone", phone)
        try json.set("email", email)
        return json
    }
}

extension User: Timestampable { }


extension User: PasswordAuthenticatable {
    static func register(name: String, surname: String, email: String, phone: String, password: String) throws -> User {
        guard try User.makeQuery().filter("email", email).first() == nil else { throw RegistrationError.emailTaken }
        let user = User(name: name, surname: surname, email: email, phone: phone, password: password)
        try user.save()
        return user
    }
}


extension User: TokenAuthenticatable {

    public typealias TokenType = Token

    static func authenticate(_ token: Token) throws -> User {
        let jwt = try JWT(token: token.token)
        try jwt.verifySignature(using: HS256(key: "SIGNING_KEY".makeBytes()))
        let time = ExpirationTimeClaim(date: Date())
        try jwt.verifyClaims([time])
        guard let userId = jwt.payload.object?[SubjectClaim.name]?.string else { throw AuthenticationError.invalidCredentials }
        guard let user = try User.makeQuery().filter("id", userId).first() else { throw AuthenticationError.invalidCredentials }
        return user
    }
}

class Claims: JSONInitializable {
    var subjectClaimValue : String
    var expirationTimeClaimValue : Double
    public required init(json: JSON) throws {
        guard let subjectClaimValue = try json.get(SubjectClaim.name) as String? else {
            throw AuthenticationError.invalidCredentials
        }
        self.subjectClaimValue = subjectClaimValue

        guard let expirationTimeClaimValue = try json.get(ExpirationTimeClaim.name) as String? else {
            throw AuthenticationError.invalidCredentials
        }
        self.expirationTimeClaimValue = Double(expirationTimeClaimValue)!

    }
}

extension User: PayloadAuthenticatable {
    typealias PayloadType = Claims
    static func authenticate(_ payload: Claims) throws -> User {
        if payload.expirationTimeClaimValue < Date().timeIntervalSince1970 {
            throw AuthenticationError.invalidCredentials
        }

        let userId = payload.subjectClaimValue
        guard let user = try User.makeQuery()
            .filter(idKey, userId)
            .first()
            else {
                throw AuthenticationError.invalidCredentials
        }

        return user
    }
}

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}
