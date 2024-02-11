known_words = []

with open("input.txt") as file:
    output_file = open("output.txt", "w")
    for line in file:
        word = line.strip()
        if not (word in known_words):
            output_file.write(word.lower() + "\n")
            known_words.append(word)
    output_file.close()