const express = require('express');
const app = express();

// Root route
app.get('/', (req, res) => {
  res.send('Security Gate Simulator - Node App Running');
});

// Optional health check route (useful later for DevOps)
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'App is healthy' });
});

const PORT = 3000;

// Start server
app.listen(PORT, () => {
  console.log(`App running at: http://localhost:${PORT}`);
});