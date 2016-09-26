import Vapor
import VaporMySQL

let mysql = try VaporMySQL.Provider(host: "localhost", user: "root", password: "", database: "chatbot")
let drop = Droplet()

drop.get { req in
    let lang = req.headers["Accept-Language"]?.string ?? "en"
    return try drop.view.make("welcome", [
    	"message": Node.string(drop.localization[lang, "welcome", "title"])
    ])
}

drop.resource("posts", PostController())

drop.run()
