extends Control

var word_amount_choosable: int #1034
var wordlist: String
var wordlist_choosable: String
var solution: String = ""
var try: int = 0
var word: String = ""
var score: int = 0
var highscore: int = 0
onready var WordGuesses = $Content/WordGuesses
onready var Letters = $Content/Letters
onready var LabelHighscore = $Content/Highscore

func _ready():
	randomize()
	
	for child in Letters.get_child_count():
		var Child = Letters.get_child(child)
		for letter in Child.get_child_count():
			var Letter = Child.get_child(letter)
			Letter.connect("pressed", self, "letter_pressed", [Letter])

func _unhandled_key_input(event):
	if len(word) == 5 or try > 5: return
	
	#is_pressed does only count pressed letter, not released ones
	if !(event is InputEventKey and event.is_pressed()): return
	
	var valid := false
	var sc = event.get_scancode()
	if sc >= 65 and sc <= 90: #Letters A-Z
		valid = true
	if sc == 196 or sc == 214 or sc == 220: #äöü with German Keyboard Layout
		valid = true
	if sc == 39 or sc == 96 or sc == 59: #äöü with English Keyboard Layout
		valid = true
	if sc == 16777220: #BackSpace-Key
		valid = true
	
	if !valid: return
	
	var letter = OS.get_scancode_string(event.get_scancode())
	
	match event.get_scancode():
		196: letter = "ä"
		214: letter = "ö"
		220: letter = "ü"
	
	match event.get_scancode(): #äöü detection on English Keyboard Layout
		39: letter = "ä"
		96: letter = "ö"
		59: letter = "ü"
	
	if letter == "BackSpace":
		if len(word) != 0:
			word.erase(len(word)-1, 1)
			WordGuesses.get_child(try).get_child(len(word)).text = ""
		return
	
	letter = letter.to_lower()
	word += letter
	
	WordGuesses.get_child(try).get_child(len(word)-1).text = letter
	if len(word) == 5:
		check_word()

func letter_pressed(letter):
	if len(word) == 5 or try > 5: return
	
	if letter.get_name() == "Backspace":
		if len(word) != 0:
			word.erase(len(word)-1, 1)
			WordGuesses.get_child(try).get_child(len(word)).text = ""
		return
	
	letter = letter.get_name().to_lower()
	letter.erase(0, 6)
	word += letter
	
	WordGuesses.get_child(try).get_child(len(word)-1).text = letter
	if len(word) == 5:
		check_word()

func check_word():
	if word in wordlist:
		color_letters()
		if word == solution:
			end_game(true)
		if try >= 5 and not(word == solution):
			end_game(false)
		word = ""
		try += 1
	else:
		WordGuesses.get_child(try).get_child(len(word) - 1).text = ""
		
		#show error
		var highscore_text = LabelHighscore.text
		LabelHighscore.text = word + " ist kein Wort!"
		LabelHighscore.set("custom_colors/font_color", Color(0.75, 0.1, 0.1))
		yield(get_tree().create_timer(2.0), "timeout")
		LabelHighscore.text = highscore_text
		LabelHighscore.set("custom_colors/font_color", Color(1.0, 1.0, 1.0))

		word.erase(len(word)-1, 1)

func color_letters():
	for letter in 5:
		var Letter = WordGuesses.get_child(try).get_child(letter)
		
		if Letter.text in solution:
			var letter_place_guess = letter
			var letter_place_solution = solution.find(Letter.text)
			#in case of solutions with double letters
			var letter_place_solution2 = solution.find_last(Letter.text)
			
			if letter_place_solution == letter_place_guess or letter_place_solution2 == letter_place_guess:
				Letter.get_stylebox("normal").bg_color = Color(0.1, 0.65, 0.06, 1.0)
				color_letter_keyboard(Letter.text, Color(0.1, 0.65, 0.06, 1.0))
			else:
				Letter.get_stylebox("normal").bg_color = Color(0.9, 0.7, 0.27, 1.0)
				color_letter_keyboard(Letter.text, Color(0.9, 0.7, 0.27, 1.0))
		else:
			Letter.get_stylebox("normal").bg_color = Color(0.29, 0.29, 0.29, 1.0)
			color_letter_keyboard(Letter.text, Color(0.29, 0.29, 0.29, 1.0))

func color_letter_keyboard(letter: String, color: Color):
	var found := false
	var row := 0
	letter = letter.to_upper()
	
	while !found:
		if Letters.get_child(row).get_node_or_null("Letter" + letter) != null:
			found = true
			var LetterKey = Letters.get_child(row).get_node("Letter" + letter)
			LetterKey.get_stylebox("normal").bg_color = color
		else:
			row += 1

func end_game(win: bool):
	var label = get_node("Menu/CenterContainer/VBoxContainer/Label")
	if win:
		label.text = tr("word_guessed")
		score += 1
		if score > highscore:
			highscore = score
			LabelHighscore.text = "Score: " + String(score) + "    Highscore: " + String(highscore)
	else:
		score = 0
		label.text = tr("word_not_guessed") % solution
		LabelHighscore.text = "Score: " + String(score) + "    Highscore: " + String(highscore)
	
	get_node("Menu").show()
	get_node("Menu").mouse_filter = MOUSE_FILTER_STOP

func _on_ButtonNewGame_pressed():
	try = 0
	word = ""
	var word_id = (randi() % word_amount_choosable + 1) * 6 #6x, because every word has 6 letters (with space)
	solution = wordlist_choosable.substr(word_id, 5)
	
	#reset WordGuessing Letters
	for row in 6:
		for letter in 5:
			var Letter = WordGuesses.get_child(row).get_child(letter)
			Letter.get_stylebox("normal").bg_color = Color(0, 0, 0, 0)
			
			Letter.text = ""
	
	#reset Keyboard Letters
	for row in 3:
		for letter in 10:
			var Letter = Letters.get_child(row).get_child(letter)
			Letter.get_stylebox("normal").bg_color = Color(0, 0, 0, 0)
	
	get_node("Menu").hide()
	get_node("Menu").mouse_filter = MOUSE_FILTER_IGNORE

func _on_ButtonRules_pressed():
	var SR = get_node("ScreenRules")
	SR.mouse_filter = MOUSE_FILTER_STOP
	SR.show()

func _on_ButtonHideScreenRules_pressed():
	var SR = get_node("ScreenRules")
	SR.mouse_filter = MOUSE_FILTER_IGNORE
	SR.hide()
