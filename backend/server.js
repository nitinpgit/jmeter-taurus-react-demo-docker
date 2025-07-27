
const express = require('express');
const app = express();
const PORT = 5000;

// Middleware to parse JSON bodies
app.use(express.json());

// Simple GET endpoint
app.get('/api/message', (req, res) => {
  res.json({ message: 'Hello from backend!' });
});

// Delayed GET endpoint
app.get('/api/delayed', async (req, res) => {
  let delay = 5000;
  if (req.query.delay) {
    const parsed = parseInt(req.query.delay, 10);
    if (!isNaN(parsed) && parsed >= 0) {
      delay = parsed;
    }
  }
  await new Promise(resolve => setTimeout(resolve, delay));
  res.json({ message: `This response was delayed by ${delay / 1000} seconds.` });
});

// POST endpoint with JSON body
app.post('/api/data', (req, res) => {
  const { name, email, message } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ 
      error: 'Missing required fields',
      required: ['name', 'email']
    });
  }
  
  res.json({ 
    success: true,
    received: { name, email, message: message || 'No message provided' },
    timestamp: new Date().toISOString()
  });
});

// GET endpoint with query parameters
app.get('/api/search', (req, res) => {
  const { query, limit = 10, page = 1 } = req.query;
  
  if (!query) {
    return res.status(400).json({ 
      error: 'Query parameter is required',
      example: '/api/search?query=test&limit=5&page=1'
    });
  }
  
  // Simulate search results
  const results = Array.from({ length: Math.min(limit, 5) }, (_, i) => ({
    id: i + 1,
    title: `Result ${i + 1} for "${query}"`,
    description: `This is a sample search result for query: ${query}`,
    score: Math.random() * 100
  }));
  
  res.json({
    query,
    page: parseInt(page),
    limit: parseInt(limit),
    total: 25,
    results
  });
});

// PUT endpoint for updating data
app.put('/api/user/:id', (req, res) => {
  const { id } = req.params;
  const { name, email, status } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ 
      error: 'Name and email are required for update'
    });
  }
  
  res.json({
    success: true,
    message: `User ${id} updated successfully`,
    updated: { id, name, email, status: status || 'active' },
    timestamp: new Date().toISOString()
  });
});

// DELETE endpoint
app.delete('/api/user/:id', (req, res) => {
  const { id } = req.params;
  
  res.json({
    success: true,
    message: `User ${id} deleted successfully`,
    deletedId: id,
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
