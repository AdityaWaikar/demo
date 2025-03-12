import requests
from bs4 import BeautifulSoup

url = 'https://coditas.com/'
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

images = soup.find_all('img')
image_urls = [img['src'] for img in images if 'src' in img.attrs]

for img_url in image_urls:
    print(img_url)
