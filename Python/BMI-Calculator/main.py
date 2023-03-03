name = input("Enter your name: ")
weight = int(input("Enter your weight in pounds: "))
height = int(input("Enter your weight in inches: "))
BMI = (weight * 703) / (height * height)

if BMI >= 40:
    print(f"{name}, you are morbidly obese")
elif BMI >= 35:
    print(f"{name}, you are severely obese")
elif BMI >= 30:
    print(f"{name}, you are obese")
elif BMI >= 25:
    print(f"{name}, you are overweight")
elif BMI >= 18.5:
    print(f"{name}, you are normal weight")
else:
    print(f"{name}, you are underweight")