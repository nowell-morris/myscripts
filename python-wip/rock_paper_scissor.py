import random

computer_choice = random.choice(['rock', 'paper', 'scissors'])


user_choice = input('Do you want - rock, paper, or scissors?\n')

if computer_choice == user_choice:
    print('TIE')
elif user_choice == 'rock' and computer_choice == 'scissors':
    print('You WIN. Computer chose: ' + computer_choice)
elif user_choice == 'paper' and computer_choice == 'rock':
    print('You WIN. Computer chose: ' + computer_choice)
elif user_choice == 'scissors' and computer_choice == 'paper':
    print('You WIN. Computer chose: ' + computer_choice)
else:
    print('Computer chose: ' + computer_choice + ' You lost, Computer wins')

