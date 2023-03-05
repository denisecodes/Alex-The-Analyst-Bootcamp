from bs4 import BeautifulSoup
import requests
import smtplib
import os
import time
import datetime
import csv
import pandas

def check_price():
    global url
    url = 'https://www.amazon.com/Feelin-Good-Tees-Youre-Shirts/dp/B012XYPNZ2/ref=sr_1_1_sspa?crid=35E1EPHQGT304&keywords=data+analyst+t+shirt&qid=1678029402&sprefix=data+analyst+t+shir%2Caps%2C184&sr=8-1-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUExWERCN0JQUkxQM05YJmVuY3J5cHRlZElkPUEwNTc2MDk4MThWN1dWTFI1R01aTiZlbmNyeXB0ZWRBZElkPUEwODAwMzA3M085VUFXNjI3TUc1RCZ3aWRnZXROYW1lPXNwX2F0ZiZhY3Rpb249Y2xpY2tSZWRpcmVjdCZkb05vdExvZ0NsaWNrPXRydWU='
    headers = {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36",
        "Accept-Language": "en-GB,en-US;q=0.9,en;q=0.8",
    }
    response = requests.get(url=url, headers=headers)
    contents = response.content
    soup = BeautifulSoup(contents, "lxml")

    global title
    title = soup.select_one(selector="#productTitle").getText().strip()
    whole_price = float(soup.select_one(selector=".a-price-whole").getText().strip("."))
    fraction_price = float(soup.select_one(selector=".a-price-fraction").getText()) / 100
    global price
    price = whole_price + fraction_price
    today = datetime.date.today()
    global data
    data = [title, price, today]

check_price()
#New line allows us to have no space between each csv when inserting new data
with open('Amazon Web Scraper Dataset.csv', 'w', newline='', encoding='UTF8') as file:
    writer = csv.writer(file)
    header = ['Title', 'Price', 'Date']
    writer.writerow(header)
    writer.writerow(data)

#Script below checks and add that day's price to tracker every day, I have commented out this code as it would loop forever and
#not actually run the send email script

#while True:
#    check_price()
#    with open('Amazon Web Scraper Dataset.csv', 'a+', encoding='UTF8') as file:
#        writer = csv.writer(file)
#        writer.writerow(data)
#    #Checks every day (60 secs x 60 mins x 24 hours)
#    time.sleep(60*60*24)

df = pandas.read_csv("/Users/denisechan/PycharmProjects/Alex-The-Analyst/Amazon Web Scraping Using Python/Amazon Web Scraper Dataset.csv")
print(df)

# Send email when product's price is below $16
target_price = 16
if price <= target_price:
    my_email = os.environ.get("MY_EMAIL")
    password = os.environ.get("MY_PASSWORD")
    message = f"{title} is now below ${target_price}, selling at ${price}\n{url}"
    with smtplib.SMTP("smtp.gmail.com") as connection:
        #Make connection secure and encrypts email
        connection.starttls()
        connection.login(user=my_email, password=password)
        connection.sendmail(
            from_addr=my_email,
            to_addrs=my_email,
            msg=f"Subject:Amazon Price Alert!\n\n{message}"
            .encode('utf-8')
        )
        print("Email sent")