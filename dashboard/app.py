"""Minimal Flask application for infrastructure operations dashboards."""
from __future__ import annotations

import os
from datetime import datetime
from typing import Dict

from flask import Flask, flash, jsonify, redirect, render_template, url_for

from . import config


def create_app() -> Flask:
    app = Flask(__name__, template_folder="templates", static_folder="static")
    app.config["SECRET_KEY"] = os.getenv("DASHBOARD_SECRET_KEY", "development-key")

    workflows = config.load_workflows()
    health_checks = config.load_health_checks()

    @app.route("/")
    def index():
        statuses: Dict[str, Dict[str, str]] = {
            check.name: check.evaluator() for check in health_checks
        }
        return render_template(
            "index.html",
            workflows=workflows,
            health_checks=health_checks,
            statuses=statuses,
            last_updated=datetime.utcnow(),
        )

    @app.post("/workflows/<workflow_name>")
    def run_workflow(workflow_name: str):
        for workflow in workflows:
            if workflow.name == workflow_name:
                message = workflow.handler()
                flash(message or f"Workflow '{workflow_name}' executed.")
                break
        else:
            flash(f"Workflow '{workflow_name}' not found.", "error")
        return redirect(url_for("index"))

    @app.get("/health")
    def health_status():
        payload = {
            check.name: check.evaluator()
            for check in health_checks
        }
        return jsonify({"updated": datetime.utcnow().isoformat(), "checks": payload})

    return app


app = create_app()

if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port, debug=os.getenv("FLASK_ENV") == "development")
