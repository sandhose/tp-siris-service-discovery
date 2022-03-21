from typing import Optional
import requests
from celery import Celery
from bs4 import BeautifulSoup

app = Celery(__name__, config_source="config")

@app.task
def get_title(url: str) -> Optional[str]:
    page = requests.get(url)
    soup = BeautifulSoup(page.text, 'html.parser')
    title = soup.find('title')
    if title:
        return title.get_text()
    return None
