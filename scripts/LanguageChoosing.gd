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
	if language == "Fr":
		keyboard_layout_azerty()

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

func keyboard_layout_azerty():
	var row1 = get_node("../Content/Letters/HBoxContainer1")
	var row2 = get_node("../Content/Letters/HBoxContainer2")
	var row3 = get_node("../Content/Letters/HBoxContainer3")

	var letter_q = row1.get_node("LetterQ")
	var letter_w = row1.get_node("LetterW")
	row1.remove_child(letter_q)
	row1.remove_child(letter_w)

	var letter_a = row2.get_node("LetterA")
	letter_a.replace_by(letter_q)

	var letter_z = row3.get_node("LetterZ")
	var letter_m = row3.get_node("LetterM")
	letter_z.replace_by(letter_w)
	row3.remove_child(letter_m)

	row1.add_child(letter_a)
	row1.move_child(letter_a, 0)
	row1.add_child(letter_z)
	row1.move_child(letter_z, 1)
	row2.add_child(letter_m)
