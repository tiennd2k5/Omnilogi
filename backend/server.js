import app from './app.js';

const port = process.env.PORT || 8888;

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});