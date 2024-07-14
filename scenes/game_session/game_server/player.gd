class_name Player extends Object

var username:String
var title:String

func from_userdata(userdata:Dictionary) -> void:
	if userdata.has("username"): username = userdata["username"]
	if userdata.has("title"): title = userdata["title"]
func to_userdata() -> Dictionary:
	return {
		"username":username,
		"title":title
	}
