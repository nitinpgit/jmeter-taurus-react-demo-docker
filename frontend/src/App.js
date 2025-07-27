import React, { useState } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState('');
  const [delayedMessage, setDelayedMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [delayParam, setDelayParam] = useState('5000'); // default 5000ms
  const [postData, setPostData] = useState({ name: '', email: '', message: '' });
  const [postResponse, setPostResponse] = useState('');
  const [searchQuery, setSearchQuery] = useState('test');
  const [searchResponse, setSearchResponse] = useState('');
  const [putData, setPutData] = useState({ name: '', email: '', status: 'active' });
  const [putResponse, setPutResponse] = useState('');
  const [deleteId, setDeleteId] = useState('1');
  const [deleteResponse, setDeleteResponse] = useState('');
  const [healthResponse, setHealthResponse] = useState('');

  const fetchMessage = async () => {
    try {
      const response = await fetch('/api/message');
      const data = await response.json();
      setMessage(data.message);
    } catch (error) {
      setMessage('Error fetching message: ' + error.message);
    }
  };

  // Updated fetchDelayedMessage to use delayParam
  const fetchDelayedMessage = async () => {
    setLoading(true);
    setDelayedMessage('');
    try {
      const url = `/api/delayed?delay=${encodeURIComponent(delayParam)}`;
      const response = await fetch(url);
      const data = await response.json();
      setDelayedMessage(data.message);
    } catch (error) {
      setDelayedMessage('Error fetching delayed message: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const testPostData = async () => {
    try {
      const response = await fetch('/api/data', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(postData),
      });
      const data = await response.json();
      setPostResponse(JSON.stringify(data, null, 2));
    } catch (error) {
      setPostResponse('Error: ' + error.message);
    }
  };

  const testSearch = async () => {
    try {
      const response = await fetch(`/api/search?query=${encodeURIComponent(searchQuery)}&limit=5&page=1`);
      const data = await response.json();
      setSearchResponse(JSON.stringify(data, null, 2));
    } catch (error) {
      setSearchResponse('Error: ' + error.message);
    }
  };

  const testPutUser = async () => {
    try {
      const response = await fetch('/api/user/1', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(putData),
      });
      const data = await response.json();
      setPutResponse(JSON.stringify(data, null, 2));
    } catch (error) {
      setPutResponse('Error: ' + error.message);
    }
  };

  const testDeleteUser = async () => {
    try {
      const response = await fetch(`/api/user/${deleteId}`, {
        method: 'DELETE',
      });
      const data = await response.json();
      setDeleteResponse(JSON.stringify(data, null, 2));
    } catch (error) {
      setDeleteResponse('Error: ' + error.message);
    }
  };

  const testHealth = async () => {
    try {
      const response = await fetch('/api/health');
      const data = await response.json();
      setHealthResponse(JSON.stringify(data, null, 2));
    } catch (error) {
      setHealthResponse('Error: ' + error.message);
    }
  };

  const apiEndpoints = [
    {
      name: 'Quick Message',
      method: 'GET',
      url: '/api/message',
      description: 'Returns a simple message immediately',
      parameters: 'None',
      responseExample: {
        message: 'Hello from backend!'
      },
      jmeterPath: '/api/message',
      taurusPath: '/api/message',
      testFunction: fetchMessage,
      testResponse: message
    },
    {
      name: 'Delayed Response',
      method: 'GET',
      url: '/api/delayed',
      description: 'Returns a message after a specified delay (in milliseconds). Pass a delay parameter as a query string, e.g., ?delay=3000. The response will reflect the actual delay used.',
      parameters: 'Optional Query: ?delay=milliseconds (default: 5000)',
      responseExample: {
        message: 'This response was delayed by 3 seconds.'
      },
      jmeterPath: '/api/delayed?delay=3000',
      taurusPath: '/api/delayed?delay=3000',
      testFunction: fetchDelayedMessage,
      testResponse: delayedMessage,
      isLoading: loading,
      hasDelayInput: true
    },
    {
      name: 'Create Data (POST)',
      method: 'POST',
      url: '/api/data',
      description: 'Creates new data with JSON body (name, email, message)',
      parameters: 'JSON Body: { "name": "string", "email": "string", "message": "string" }',
      responseExample: {
        success: true,
        received: { name: "John Doe", email: "john@example.com", message: "Hello" },
        timestamp: "2024-01-01T00:00:00.000Z"
      },
      jmeterPath: '/api/data',
      taurusPath: '/api/data',
      testFunction: testPostData,
      testResponse: postResponse,
      hasForm: true,
      formData: postData,
      setFormData: setPostData
    },
    {
      name: 'Search with Parameters',
      method: 'GET',
      url: '/api/search',
      description: 'Search endpoint with query parameters (query, limit, page)',
      parameters: 'Query: ?query=string&limit=number&page=number',
      responseExample: {
        query: "test",
        page: 1,
        limit: 10,
        total: 25,
        results: [{ id: 1, title: "Result 1", description: "Sample result", score: 85.5 }]
      },
      jmeterPath: '/api/search?query=${query}&limit=${limit}&page=${page}',
      taurusPath: '/api/search?query=${query}&limit=${limit}&page=${page}',
      testFunction: testSearch,
      testResponse: searchResponse,
      hasForm: true,
      formData: { query: searchQuery },
      setFormData: (data) => setSearchQuery(data.query)
    },
    {
      name: 'Update User (PUT)',
      method: 'PUT',
      url: '/api/user/:id',
      description: 'Updates user data with path parameter and JSON body',
      parameters: 'Path: /api/user/{id}, Body: { "name": "string", "email": "string", "status": "string" }',
      responseExample: {
        success: true,
        message: "User 1 updated successfully",
        updated: { id: "1", name: "John Doe", email: "john@example.com", status: "active" },
        timestamp: "2024-01-01T00:00:00.000Z"
      },
      jmeterPath: '/api/user/${userId}',
      taurusPath: '/api/user/${userId}',
      testFunction: testPutUser,
      testResponse: putResponse,
      hasForm: true,
      formData: putData,
      setFormData: setPutData
    },
    {
      name: 'Delete User',
      method: 'DELETE',
      url: '/api/user/:id',
      description: 'Deletes a user by ID using path parameter',
      parameters: 'Path: /api/user/{id}',
      responseExample: {
        success: true,
        message: "User 1 deleted successfully",
        deletedId: "1",
        timestamp: "2024-01-01T00:00:00.000Z"
      },
      jmeterPath: '/api/user/${userId}',
      taurusPath: '/api/user/${userId}',
      testFunction: testDeleteUser,
      testResponse: deleteResponse,
      hasForm: true,
      formData: { id: deleteId },
      setFormData: (data) => setDeleteId(data.id)
    },
    {
      name: 'Health Check',
      method: 'GET',
      url: '/api/health',
      description: 'Returns system health status and metrics',
      parameters: 'None',
      responseExample: {
        status: "healthy",
        timestamp: "2024-01-01T00:00:00.000Z",
        uptime: 123.45,
        memory: { rss: 12345678, heapTotal: 9876543, heapUsed: 5432109 }
      },
      jmeterPath: '/api/health',
      taurusPath: '/api/health',
      testFunction: testHealth,
      testResponse: healthResponse
    }
  ];

  return (
    <div className="App">
      <header className="App-header">
        <h1>JMeter Taurus React Demo</h1>
        <p>Comprehensive API Endpoints for Load Testing with JMeter and Taurus</p>
        
        <div className="api-documentation">
          <h2>API Endpoints Documentation</h2>
          <p className="description">
            Below are the available API endpoints with detailed information for JMeter test plans and Taurus configuration.
          </p>
          
          {apiEndpoints.map((endpoint, index) => (
            <div key={index} className="endpoint-card">
              <div className="endpoint-header">
                <span className={`method ${endpoint.method.toLowerCase()}`}>
                  {endpoint.method}
                </span>
                <h3>{endpoint.name}</h3>
              </div>
              
              <div className="endpoint-details">
                <div className="detail-row">
                  <strong>URL:</strong>
                  <code className="url">{endpoint.url}</code>
                </div>
                
                <div className="detail-row">
                  <strong>Description:</strong>
                  <span>{endpoint.description}</span>
                </div>
                
                <div className="detail-row">
                  <strong>Parameters:</strong>
                  <span>{endpoint.parameters}</span>
                </div>
                
                <div className="detail-row">
                  <strong>JMeter Path:</strong>
                  <code>{endpoint.jmeterPath}</code>
                </div>
                
                <div className="detail-row">
                  <strong>Taurus Path:</strong>
                  <code>{endpoint.taurusPath}</code>
                </div>
                
                <div className="detail-row">
                  <strong>Response Example:</strong>
                  <pre className="response-example">
                    {JSON.stringify(endpoint.responseExample, null, 2)}
                  </pre>
                </div>
              </div>
              
              <div className="endpoint-actions">
                {/* Add delay input for Delayed Response endpoint only */}
                {endpoint.hasDelayInput && (
                  <div className="form-section">
                    <label htmlFor="delay-input">Delay (ms): </label>
                    <input
                      id="delay-input"
                      type="number"
                      min="0"
                      step="100"
                      value={delayParam}
                      onChange={e => setDelayParam(e.target.value)}
                      style={{ width: '120px', marginLeft: '8px' }}
                    />
                  </div>
                )}
                {endpoint.hasForm && (
                  <div className="form-section">
                    <h4>Test Parameters:</h4>
                    {endpoint.name === 'Create Data (POST)' && (
                      <div className="form-grid">
                        <input
                          type="text"
                          placeholder="Name"
                          value={endpoint.formData.name}
                          onChange={(e) => endpoint.setFormData({...endpoint.formData, name: e.target.value})}
                        />
                        <input
                          type="email"
                          placeholder="Email"
                          value={endpoint.formData.email}
                          onChange={(e) => endpoint.setFormData({...endpoint.formData, email: e.target.value})}
                        />
                        <input
                          type="text"
                          placeholder="Message"
                          value={endpoint.formData.message}
                          onChange={(e) => endpoint.setFormData({...endpoint.formData, message: e.target.value})}
                        />
                      </div>
                    )}
                    {endpoint.name === 'Search with Parameters' && (
                      <input
                        type="text"
                        placeholder="Search query"
                        value={endpoint.formData.query}
                        onChange={(e) => endpoint.setFormData({query: e.target.value})}
                      />
                    )}
                    {endpoint.name === 'Update User (PUT)' && (
                      <div className="form-grid">
                        <input
                          type="text"
                          placeholder="Name"
                          value={endpoint.formData.name}
                          onChange={(e) => endpoint.setFormData({...endpoint.formData, name: e.target.value})}
                        />
                        <input
                          type="email"
                          placeholder="Email"
                          value={endpoint.formData.email}
                          onChange={(e) => endpoint.setFormData({...endpoint.formData, email: e.target.value})}
                        />
                        <input
                          type="text"
                          placeholder="Status"
                          value={endpoint.formData.status}
                          onChange={(e) => endpoint.setFormData({...endpoint.formData, status: e.target.value})}
                        />
                      </div>
                    )}
                    {endpoint.name === 'Delete User' && (
                      <input
                        type="text"
                        placeholder="User ID"
                        value={endpoint.formData.id}
                        onChange={(e) => endpoint.setFormData({id: e.target.value})}
                      />
                    )}
                  </div>
                )}
                
                <button 
                  onClick={endpoint.testFunction}
                  disabled={endpoint.isLoading}
                  className="test-button"
                >
                  {endpoint.isLoading ? 'Testing...' : 'Test Endpoint'}
                </button>
                
                {endpoint.testResponse && (
                  <div className="live-response">
                    <strong>Live Response:</strong>
                    <pre>{endpoint.testResponse}</pre>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
        
        <div className="testing-info">
          <h2>Testing Information</h2>
          <div className="info-grid">
            <div className="info-card">
              <h3>JMeter Test Plan</h3>
              <p>Use these endpoints in your JMeter test plan:</p>
              <ul>
                <li><code>/api/message</code> - Quick response testing</li>
                <li><code>/api/delayed</code> - Timeout testing (5s delay)</li>
                <li><code>/api/data</code> - POST with JSON body</li>
                <li><code>/api/search?query=test</code> - GET with parameters</li>
                <li><code>/api/user/:id</code> - PUT/DELETE with path params</li>
                <li><code>/api/health</code> - Health monitoring</li>
              </ul>
            </div>
            
            <div className="info-card">
              <h3>Taurus Configuration</h3>
              <p>Configure these URLs in your Taurus YAML:</p>
              <ul>
                <li><code>/api/message</code> - Fast endpoint</li>
                <li><code>/api/delayed</code> - Slow endpoint (5s delay)</li>
                <li><code>/api/data</code> - POST endpoint</li>
                <li><code>/api/search</code> - Parameterized GET</li>
                <li><code>/api/user/:id</code> - Path parameters</li>
                <li><code>/api/health</code> - Monitoring endpoint</li>
              </ul>
            </div>
          </div>
        </div>
      </header>
    </div>
  );
}

export default App; 