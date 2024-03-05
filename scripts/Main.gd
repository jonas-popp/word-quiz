# This file is part of Word Quiz
# Copyright (C) 2024  Jonas Popp
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses.

extends Control

var word_amount_choosable: int
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
onready var TimerShowScores = $TimerShowScores

func _ready():
	randomize()
	
	for Letter in Letters.get_children():
		if !Letter.get_name().begins_with("HBox"):
			Letter.connect("pressed", self, "letter_pressed", [Letter])

	if Scores.language != "":
		load_scores()
		get_node("MenuChooseLanguage").load_language(Scores.language.capitalize())
		get_node("ScreenRules").hide()

func _unhandled_key_input(event):
	if len(word) == 5 or try > 5: return
	
	#is_pressed does only count pressed letter, not released ones
	if !(event is InputEventKey and event.is_pressed()):
		return
	
	var letter = OS.get_scancode_string(event.get_scancode()).to_lower()
	
	if letter == "backspace":
		if len(word) != 0:
			word.erase(len(word)-1, 1)
			WordGuesses.get_child(try).get_child(len(word)).text = ""
		return
	
	# windows
	if letter == "apostrophe":
		letter = "ä"
	elif letter == "quoteleft":
		letter = "ö"
	elif letter == "semicolon":
		letter = "ü"

	# browser
	elif letter == "adiaeresis":
		letter = "ä"
	elif letter == "odiaeresis":
		letter = "ö"
	elif letter == "udiaeresis":
		letter = "ü"

	if !(letter in "abcdefghijklmnopqrstuvwxyzäöü"):
		return

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
		LabelHighscore.text = tr("not_a_word") % word
		LabelHighscore.set("custom_colors/font_color", Color(0.75, 0.1, 0.1))
		TimerShowScores.start()

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

func show_scores():
	LabelHighscore.set("custom_colors/font_color", Color(1.0, 1.0, 1.0))
	LabelHighscore.text = "Score: " + String(score) + "    Highscore: " + String(highscore)

func end_game(win: bool):
	var label = get_node("Menu/CenterContainer/VBoxContainer/Label")
	if win:
		label.text = tr("word_guessed")
		score += 1
		if score > highscore:
			highscore = score
	else:
		score = 0
		label.text = tr("word_not_guessed") % solution
	show_scores()
	Scores.save_scores(score, highscore)
	
	get_node("Menu").show()
	get_node("Menu").mouse_filter = MOUSE_FILTER_STOP

func load_scores():
	var scores = Scores.get_scores()
	score = scores[0]
	highscore = scores[1]
	show_scores()

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
		for letter in get_node("Content/Letters").get_child(row).get_child_count():
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

func _on_ButtonChangeLanguage_pressed():
	get_node("ScreenRules").hide()
	get_node("MenuChooseLanguage").reset_keyboard_layout()
	get_node("MenuChooseLanguage").show()
