# get loan details
money_owed = float(input("How much money do you own, in dollars?\n")) # like $50,000
apr = float(input("What is the annual percentage rate?\n")) # 3%
payment = float(input("What will your monthly payment be, in dollars?\n")) # $1,000
months = int(input("How many months do you want to see results for?\n")) # like 2 years, 24 months

# Divide apr by 100 to make it a percentage, then divide by 12 to make monthly
monthly_rate = apr/100/12

for i in range(months):
    # Add the interest
    interest_paid = money_owed * monthly_rate
    money_owed = money_owed + interest_paid

    if (money_owed - payment < 0):
        print("The last payment is", money_owed)
        print("You pad off the loan in", i+1, "months")
        break 

    # Making the payment 
    money_owed = money_owed - payment

    # Print the results after this month
    print("When you paid", payment, "of which", interest_paid, "was interest,", end=' ')
    print("you now owe", money_owed)

