
# Quiet Companion

## Logo
<img width="450" height="400" alt="quiet-companion-logo" src="https://github.com/user-attachments/assets/f8f93cc7-b450-4027-ab51-6392ce38936c" />

## Architecture Diagram
<img width="800" height="550" alt="architecture-diagram" src="https://github.com/user-attachments/assets/18570465-ce23-4702-9873-316f061fe943" />

## Local Setup

### Prerequisites
- Python 3.11 or Higher
- pip

### Installation

1. **Clone the Repo**
   ```bash
   git clone <repository-url>
   cd quiet-companion
   ```

2. **Create a Virtual Environment**
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

3. **Install Python Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

   This will install:
   - dbt-core==1.9.1
   - dbt-postgres==1.9.1
   - sqlfluff==4.2.1
   - sqlfluff-templater-dbt==4.2.1
   - elementary-data[postgres]

