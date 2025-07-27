
# 🚀 JMeter Taurus React Demo (Dockerized)

This project is a full-stack demo application for load and performance testing using **JMeter** and **Taurus**. It features a modern React frontend and a Node.js/Express backend, both containerized with Docker. The app exposes a variety of API endpoints (GET, POST, PUT, DELETE, with parameters and delays) to simulate real-world scenarios for testing tools.

---

## ✨ Features

- **React Frontend**: Modern UI, endpoint documentation, and live API testing
- **Node.js Backend**: Multiple endpoints for various HTTP methods and scenarios
- **Dockerized**: Easy to build, run, and deploy
- **Ready for JMeter & Taurus**: Designed for load, stress, and functional testing

---

## ⚡ Quick Start

### 1. **Clone the Repository**
```sh
git clone <your-repo-url>
cd jmeter-taurus-react-demo-docker
```

### 2. **Build and Run with Docker Compose**
```sh
docker-compose up --build -d
```
- Frontend: [http://localhost:3000](http://localhost:3000)
- Backend: [http://localhost:5000](http://localhost:5000)

### 3. **Test the Application**
- Open [http://localhost:3000](http://localhost:3000) in your browser.
- Explore the API documentation and test endpoints interactively.

---

## 🛠️ Application Structure

```
jmeter-taurus-react-demo-docker/
├── backend/      # Node.js/Express API
├── frontend/     # React app
├── jmeter/       # JMeter test plan
├── taurus/       # Taurus YAML configs
├── docker-compose.yml
└── README.md
```

---

## 🔗 API Endpoints

| Method | Endpoint             | Description                                 |
|--------|----------------------|---------------------------------------------|
| GET    | /api/message         | Quick response                              |
| GET    | /api/delayed         | Delayed response (customizable delay)       |
| POST   | /api/data            | Accepts JSON body (name, email, message)    |
| GET    | /api/search          | Query params: query, limit, page            |
| PUT    | /api/user/:id        | Update user by ID (JSON body)               |
| DELETE | /api/user/:id        | Delete user by ID                           |
| GET    | /api/health          | Health check/status                         |

See the frontend UI for detailed docs, parameters, and live testing.

---

## 🧪 Running JMeter Tests

1. **Open JMeter GUI** or use CLI.
2. Load the test plan:
   ```
   jmeter/test-plan.jmx
   ```
3. Update the server/port if needed (default: `localhost:3000` for frontend, `localhost:5000` for backend).
4. Run the test and view results in JMeter.

---

## 🐍 Running Taurus Tests

### **A. Run Taurus Natively (if installed):**
```sh
bzt taurus/test.yml
```
Or run any of the specific endpoint tests:
```sh
bzt taurus/get-quick-message.yml
bzt taurus/get-delayed-response.yml
bzt taurus/post-create-data.yml
```

### **B. Run Taurus in a Docker Container (Recommended for Windows/Mac/Linux):**

#### **One-off test (PowerShell syntax):**
```sh
docker run --rm -v "${PWD}:/bzt" -w /bzt blazemeter/taurus bzt taurus/get-quick-message.yml
```
- Replace `get-quick-message.yml` with any other Taurus YAML file as needed.
- On Linux/Mac, you can use `$PWD` instead of `${PWD}`.

#### **Add Taurus as a Service in docker-compose.yml:**
```yaml
  taurus:
    image: blazemeter/taurus
    volumes:
      - ./:/bzt
    working_dir: /bzt
    command: bzt taurus/get-quick-message.yml
```
Then run:
```sh
docker-compose up taurus
```

---

## 📝 How to Extend
- Add new endpoints in `backend/server.js`.
- Update frontend docs in `frontend/src/App.js`.
- Add new test scenarios in `jmeter/test-plan.jmx` or `taurus/*.yml`.

---

## 🧹 Cleaning Up
To stop and remove all containers and images:
```sh
docker-compose down
# Optionally, remove images
# docker system prune -af
```

---

## 🤝 Contributing
Pull requests and suggestions are welcome!

---

## 📄 License
MIT
