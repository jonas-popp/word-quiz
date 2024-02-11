words_accepted = []

with open("input.txt") as file:
    for line in file:
        word = line.rstrip()
        print(word)
        if input() == "y":
            words_accepted.append(word)

    output_file = open("output.txt", "w")
    for word in words_accepted:
        output_file.write(word.lower() + "\n")
    output_file.close()