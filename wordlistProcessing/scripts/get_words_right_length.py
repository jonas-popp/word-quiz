with open("input.txt") as file:
    output_file = open("output.txt", "w")
    for line in file:
        if len(line.rstrip()) == 5:
            output_file.write(line.rstrip().lower() + "\n")
    output_file.close()

# without ae oe ue
# with open("input.txt") as file:
#     output_file = open("output.txt", "w")
#     for line in file:
#         word = line.rstrip()
#         if len(word) == 5:
#             if not (("ae" in word) or ("oe" in word) or ("ue" in word)):
#                 output_file.write(word.lower() + "\n")
#     output_file.close()