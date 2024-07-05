

# def init():   
#     with open("t.txt", "r") as f:
#         lines = f.readlines()
#     return lines

# def reverse_all(lines):
#     u = []
#     #print(lines)
#     for i in lines:
#         m = i.split()
#         #print(m)
#         for j in m:
#             u.append(j[::-1])
#     print(u)    
#     return u

# def find_digits(stringg):
#     for j in stringg:
#         if filter(str.isdigit, j):
#             stringg.remove(j)
#     print(stringg)
#     return stringg
    
# def lengthd(stringg):
#     for j in stringg:
#         if len(j) > 3:
#             stringg.remove(j)
#     print (stringg)
#     return stringg
    
# def back(xsg):
#     for j in xsg:
#         print(j)
#         s = ''.join(j)
#     print(s)

# def check_any(f):
    
#     print( any(f.isdigit()))
           
            
    
    
        
# if __name__ == "__main__":
#     lines = init()
#     check_any(lines)
    # rev = reverse_all(lines)
    # no_digitd = find_digits(rev)
    # xs = lengthd(no_digitd)
    # back(xs)
    
# Open the file for reading
# with open('t.txt', 'r') as file:
#     lines = file.readlines()

# # Remove strings containing digits
# cleaned_lines = [line.strip() for line in lines if not any(char.isdigit() for char in line)]



# # Open the file for writing
# with open('t.txt', 'w') as file:
#     file.write('\n'.join(cleaned_lines))
    
    

import os
# Function to reverse a single word
def reverse_word(word):
    return word[::-1]

# Open the file for reading
with open(os.path.join(os.getcwd(),'t.txt'), 'r') as file:
    lines = file.readlines()

# Reverse all words in each line
reversed_lines = []
for line in lines:
    words = line.split()
    reversed_words = [reverse_word(word) for word in words]
    reversed_lines.append(' '.join(reversed_words))

# Open the file for writing
with open(os.path.join(os.getcwd(),'reveresed.txt'), 'w') as file:
    file.write('\n'.join(reversed_lines))
        





