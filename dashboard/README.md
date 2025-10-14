# Operations Dashboard

This directory hosts a lightweight Flask application that surfaces critical
infrastructure signals and exposes buttons for invoking automated workflows.
The UI is intentionally modular so the dashboard can evolve without breaking
the existing control surface used by operators.

## Features

- Overview screen that visualizes the health of message queues, schedulers and
  other services.
- Workflow launcher that can trigger automation handlers registered through
  configuration hooks.
- JSON health endpoint (`/health`) suitable for observability tooling or quick
  status checks.
- Modular templates (via Jinja includes) and static assets for easy reuse.

## Quick start

```bash
# Install Python dependencies
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Run the development server
export FLASK_APP=dashboard.app
flask run --reload
```

The default server listens on `http://127.0.0.1:5000`. Navigate there to view
system health summaries and launch workflows. Flash messages confirm results in
the UI.

## Extending with custom logic

The dashboard discovers workflows and health checks from
`dashboard.config.load_workflows` and `dashboard.config.load_health_checks`. By
default the module returns sample data, but you can override it without touching
the UI:

1. Create a module anywhere on the Python path that defines `WORKFLOWS` and/or
   `HEALTH_CHECKS`. Each entry should expose the same attributes as the
   dataclasses in `dashboard.config` (``name``, ``description``, and a callable
   ``handler`` or ``evaluator``).
2. Point the dashboard at the module using an environment variable before
   launching Flask:

   ```bash
   export DASHBOARD_EXTENSIONS="infra_pipelines.dashboard_overrides"
   flask run --reload
   ```

3. The UI immediately picks up the new definitions, so Codex can ship backend
   updates independently from the operator-facing interface.

For sensitive operations you can also set `DASHBOARD_SECRET_KEY` to control the
Flask session key and integrate your preferred auth and logging middleware.

## Project layout

```
dashboard/
├── app.py                # Flask entrypoint and route registrations
├── config.py             # Extension hooks and default implementations
├── README.md             # This file
├── static/
│   ├── css/style.css     # Dashboard styling
│   └── js/app.js         # Client-side enhancements
└── templates/
    ├── base.html         # Base layout
    ├── index.html        # Dashboard view composed from components
    └── components/       # Reusable UI blocks (health grid, workflows, nav)
```

The structure keeps views, assets, and logic cleanly separated so each team can
own the parts most relevant to them.
