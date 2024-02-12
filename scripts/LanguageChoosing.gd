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
	
	TranslationServer.set_locale(language.to_lower())
	if language == "De":
		show_mutated_vowels()
		exchange_yz()

	get_node("../ScreenRules/ColorRect/Rules").bbcode_text = tr("rules")
	Main.word_amount_choosable = (Main.wordlist_choosable.length() + 1) / 6

	Main._on_ButtonNewGame_pressed()
	get_node("../ScreenRules").show()
	queue_free()

func exchange_yz():
	var row1 = get_node("../Content/Letters/HBoxContainer1")
	var row3 = get_node("../Content/Letters/HBoxContainer3")
	var letter_y = get_node("../Content/Letters/HBoxContainer1/LetterY")
	var letter_z = get_node("../Content/Letters/HBoxContainer3/LetterZ")
	row1.remove_child(letter_y)
	row3.remove_child(letter_z)
	row1.add_child(letter_z)
	row1.move_child(letter_z, 5)
	row3.add_child(letter_y)
	row3.move_child(letter_y, 0)

func show_mutated_vowels():
	get_node("../Content/Letters/HBoxContainer2/LetterÜ").show()
	get_node("../Content/Letters/HBoxContainer3/LetterÖ").show()
	get_node("../Content/Letters/HBoxContainer3/LetterÄ").show()