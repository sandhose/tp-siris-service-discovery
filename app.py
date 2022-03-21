import platform
from typing import List
from flask import Flask, request
from flask.templating import render_template
from celery import group

import tasks

def create_app():
    """App factory"""

    app = Flask(__name__)

    @app.route("/")
    def index():
        """Renders the home page"""
        return render_template("index.html", hostname=platform.node())

    @app.route("/api/titles", methods=["POST"])
    def titles():
        """API which crawls web pages and extract their title"""
        # Parse the incoming JSON body
        req = request.get_json()
        if req is None:
            return {"error": "JSON body is required"}, 400

        # Check that the body is a list of strings
        if not isinstance(req, list) or any(not isinstance(element, str) for element in req):
            return {"error": "Body must be a list of strings"}, 400

        urls: List[str] = req
        # Asynchronously call the `get_title` method for each URL
        result = group(tasks.get_title.s(url) for url in urls)()
        return {
            'node': platform.node(),
            'result': result.get(timeout=1)
        }

    @app.route("/health")
    def health():
        """Simple healtcheck route to check the service is running properly"""
        return "ok"

    return app


if __name__ == "__main__":
    # When the scripts is being run standalone, start the Flask debug server
    app = create_app()
    app.run(host="0.0.0.0", port=8080, debug=True, use_reloader=False)
