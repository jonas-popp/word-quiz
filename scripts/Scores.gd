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

extends Node

var language := "" 
var scores := { # [score, highscore]
	"de": [0, 0],
	"en": [0, 0],
	"fr": [0, 0],
	"it": [0, 0]
}

func _ready():
	var file = File.new()
	if file.open("user://scores", File.READ) == OK:
		var file_data = file.get_var()
		file.close()
		if typeof(file_data) == TYPE_DICTIONARY:
			language = file_data.language
			scores = file_data.scores

func save_scores(score: int, highscore: int):
	var file = File.new()
	if file.open("user://scores", File.WRITE) == OK:
		scores[language][0] = score
		scores[language][1] = highscore
		file.store_var({"language": language, "scores": scores})
		file.close()

func get_scores():
	return scores[language]
