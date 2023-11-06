# Salbi Faza Rinaldi

import pandas as pd
from bs4 import BeautifulSoup
import requests
from time import sleep
from datetime import datetime
import logging
import json

def scrape_product_data(url):
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')

            table_body_section = soup.find('section', class_='table-body')
            get_elements = table_body_section.find_all("div", class_="row")

            return get_elements
        else:
            raise requests.exceptions.HTTPError(f"Invalid response code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        error_data = {
            'message': f"Error scraping url: {url}",
            'exception': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }

        with open('datasets/skipped.json', 'a') as error_file:
            json.dump(error_data, error_file)

        return None

def scrape_products(url):
    scrape_data = []
    max_attempt = 3 

    for attempt in range(max_attempt+1):
        get_data = scrape_product_data(url)
        if get_data:
            for element in get_data:
                title = element.find('b').text
                raw_link = element.get('onclick')
                link = 'https://www.fortiguard.com' + raw_link.split('=')[-1].strip().strip("'")

                scrape_data.append({
                    'title': title,
                    'link': link,
                    'scrap_link': url,
                    'scrap_time': datetime.utcnow().isoformat()
                })
            break
        else:
            if attempt < max_attempt:
                logging.info("Retrying scrape attempt: %s url: %s", attempt+1, url)
                sleep(2)
            else:
                logging.error("Failed to scrape url: %s", url)
                with open('datasets/skipped.json', 'a') as error_file:
                    error_data = {
                        'message': f"Error scraping url: {url}",
                        'timestamp': datetime.utcnow().isoformat()
                    }
                    json.dump(error_data, error_file)
                    
    return scrape_data

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    levels = list(range(1, 6))
    max_pages = [7, 34, 170, 385, 245]

    for level in levels:
        data = []
        for i in range(1, max_pages[level -1] + 1):
            url = f"https://www.fortiguard.com/encyclopedia?type=ips&risk={level}&page={i}"
            raw = scrape_products(url)
            data += raw

        data = list(map(dict, data))
        df = pd.DataFrame(data)
        df.to_csv(f'datasets/forti_lists_{level}.csv', index=False)
        print(f'Succes create file forti_lists_{level}.csv')

    print('Finish Scrap Data')