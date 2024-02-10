with open("input.txt") as file:
    output_file = open("output.txt", "w")
    for line in file:
        output_file.write(line.lower())
    output_file.close()