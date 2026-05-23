const express = require('express');
const app = express();
app.get('/users', (req, res) => {
    res.json([{ id: 1, name: "Khai" }, { id: 2, name: "Admin" }]);
});
app.listen(3001, () => console.log('User service running on port 3001'));