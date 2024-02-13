with open("input.txt") as file: # encoding="latin-1" for french wordlist
    output_file = open("output.txt", "w")
    for line in file:
        word = line.strip().lower()

        word = word.replace("é", "e")
        word = word.replace("è", "e")
        word = word.replace("ê", "e")
        word = word.replace("ë", "e")
        word = word.replace("â", "a")
        word = word.replace("à", "a")
        word = word.replace("û", "u")
        word = word.replace("î", "i")
        word = word.replace("ï", "i")
        word = word.replace("í", "i")
        word = word.replace("ì", "i")
        word = word.replace("ô", "o")
        word = word.replace("ò", "o")
        word = word.replace("ç", "c")
        
        output_file.write(word + "\n")
    
    output_file.close()