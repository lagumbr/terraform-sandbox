// app.js
const express = require('express');
const app = express();

app.get('*', (req, res) => {
  res.status(500).send('Internal Server Error (Test)');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Test app listening on port ${port}`);
});