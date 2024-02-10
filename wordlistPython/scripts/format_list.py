with open("input.txt") as file:
    output_file = open("output.txt", "w")
    words = file.read().replace("\n", " ")
    output_file.write(words.lower() + "\n")
    output_file.close()