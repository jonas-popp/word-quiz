extends Control

func _ready():
	for child in get_node("Content/VBoxContainer").get_children():
		child.connect("pressed", self, "load_language", [child.name])

func load_language(pressed_button: String):
	var Main = get_parent()
	var language = pressed_button.lstrip("Button")
	var file_wordlist = File.new()
	if file_wordlist.open("res://wordlists/Wordlist" + language + ".txt", File.READ) != OK:
		return
	Main.wordlist = file_wordlist.get_as_text()
	if file_wordlist.open("res://wordlists/Wordlist" + language + "Choosable.txt", File.READ) == OK:
		Main.wordlist_choosable = file_wordlist.get_as_text()
	else:
		Main.wordlist_choosable = Main.wordlist
	
	Main.word_amount_choosable = (Main.wordlist_choosable.length() + 1) / 6

	Main._on_ButtonNewGame_pressed()
	get_node("../ScreenRules").show()
	queue_free()
