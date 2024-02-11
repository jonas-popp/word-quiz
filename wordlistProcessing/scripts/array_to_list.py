with open("input.txt") as file:
    word_list = file.read()
    word_list = word_list.split(",")

    output_file = open("output.txt", "w")
    for word in word_list:
        word = word.lower().strip()
        word = word.strip("[]'")
        output_file.write(word.lower() + "\n")
    output_file.close()