import platform
from typing import Optional, TypedDict
import requests
from celery import Celery
from bs4 import BeautifulSoup

app = Celery(__name__, config_source="config")

class Result(TypedDict):
    node: str
    title: Optional[str]
    url: str

@app.task
def get_title(url: str) -> Result:
    page = requests.get(url)
    soup = BeautifulSoup(page.text, 'html.parser')
    element = soup.find('title')
    title = None
    if element:
        title = element.get_text()

    return {
        'node': platform.node(),
        'title': title,
        'url': url
    }
