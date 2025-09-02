# postgres-db-automation
postgres-db-automation
# postgres-db-automation

Automation toolkit to **create/init a PostgreSQL database**, **apply schema & objects in a strict order**, **seed data**, and **log every step**.  
Works on **Linux (bash)** and **Windows (batch)**. Includes a **GitHub Actions CI** workflow that boots a Postgres service and validates SQL execution.

---

## ✨ Features
- Deterministic execution using `sql/order.txt`
- Environment-driven config via `.env`
- Separate folders for `tables`, `functions`, `views`, `data`, `grants`, etc.
- Idempotent-safe examples (create-if-not-exists)
- Robust logging to `logs/`
- CI validates SQL against Postgres (Docker) on every push/PR

---

## 📁 Repository Structure
