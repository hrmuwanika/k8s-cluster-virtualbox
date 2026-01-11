const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// In-memory data store
let items = [];

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', hostname: os.hostname() });
});

// Root
app.get('/', (req, res) => {
  res.json({
    message: 'Node.js REST API Cluster',
    hostname: os.hostname(),
    endpoints: {
      'GET /health': 'Health check',
      'GET /api/items': 'Get all items',
      'GET /api/items/:id': 'Get item by ID',
      'POST /api/items': 'Create item',
      'PUT /api/items/:id': 'Update item',
      'DELETE /api/items/:id': 'Delete item'
    }
  });
});

// Get all items
app.get('/api/items', (req, res) => {
  res.json({
    success: true,
    count: items.length,
    data: items,
    hostname: os.hostname()
  });
});

// Get item by ID
app.get('/api/items/:id', (req, res) => {
  const item = items.find(i => i.id === req.params.id);
  if (!item) {
    return res.status(404).json({ success: false, message: 'Item not found' });
  }
  res.json({ success: true, data: item, hostname: os.hostname() });
});

// Create item
app.post('/api/items', (req, res) => {
  const { name, description } = req.body;
  if (!name) {
    return res.status(400).json({ success: false, message: 'Name is required' });
  }
  
  const newItem = {
    id: Date.now().toString(),
    name,
    description: description || '',
    createdAt: new Date().toISOString(),
    createdBy: os.hostname()
  };
  
  items.push(newItem);
  res.status(201).json({ success: true, data: newItem, hostname: os.hostname() });
});

// Update item
app.put('/api/items/:id', (req, res) => {
  const index = items.findIndex(i => i.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Item not found' });
  }
  
  const { name, description } = req.body;
  items[index] = {
    ...items[index],
    name: name || items[index].name,
    description: description !== undefined ? description : items[index].description,
    updatedAt: new Date().toISOString(),
    updatedBy: os.hostname()
  };
  
  res.json({ success: true, data: items[index], hostname: os.hostname() });
});

// Delete item
app.delete('/api/items/:id', (req, res) => {
  const index = items.findIndex(i => i.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Item not found' });
  }
  
  const deletedItem = items.splice(index, 1)[0];
  res.json({ success: true, message: 'Item deleted', data: deletedItem, hostname: os.hostname() });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Hostname: ${os.hostname()}`);
});
