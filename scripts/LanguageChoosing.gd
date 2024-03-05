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

const keyboard_layouts = {
	"de": ["qwertzuiop", "asdfghjklü", "yxcvbnmöä"],
	"en": ["qwertyuiop", "asdfghjkl", "zxcvbnm"],
	"fr": ["azertyuiop", "qsdfghjklm", "wxcvbn"],
	"it": ["qwertyuiop", "asdfghjkl", "zxcvbnm"]
}

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
	Scores.language = language.to_lower()
	get_parent().load_scores()
	
	TranslationServer.set_locale(language.to_lower())
	load_keyboard_layout(keyboard_layouts[language.to_lower()])

	get_node("../ScreenRules/ColorRect/Rules").bbcode_text = tr("rules")
	Main.word_amount_choosable = (Main.wordlist_choosable.length() + 1) / 6

	Main._on_ButtonNewGame_pressed()
	get_node("../ScreenRules").show()
	hide()

func load_keyboard_layout(layout: Array):
	var Letters = get_node("../Content/Letters")
	var row_id := 0
	for row in layout:
		var RowNode = Letters.get_child(row_id)
		for letter in row:
			var LetterNode = Letters.get_node("Letter" + letter.to_upper())
			Letters.remove_child(LetterNode)
			RowNode.add_child(LetterNode)
			LetterNode.show()
		row_id += 1
	
	var Backspace = Letters.get_node("Backspace")
	Letters.remove_child(Backspace)
	Letters.get_child(2).add_child(Backspace)
	Backspace.show()

func reset_keyboard_layout():
	var Letters = get_node("../Content/Letters")
	for row in range(3):
		var CurrentRow = Letters.get_child(row)
		for Letter in CurrentRow.get_children():
			CurrentRow.remove_child(Letter)
			Letters.add_child(Letter)
			Letter.hide()

