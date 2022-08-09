# lets see if a user's input is a prime number or not

usersnumber = int(input("Please enter an integer number to check for prime:\n"))

if usersnumber % 2 < 0:
    print(usersnumber + ' not divisible by 2')
elif usersnumber // 2 > 0:
    output = usersnumber // 2
    print(output)
