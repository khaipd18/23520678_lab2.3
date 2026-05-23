const express = require('express');
const app = express();
app.get('/products', (req, res) => {
    res.json([{ id: 101, item: "Laptop" }, { id: 102, item: "Keyboard" }]);
});
app.listen(3002, () => console.log('Product service running on port 3002'));