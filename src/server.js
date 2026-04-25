require('dotenv').config();
const express = require('express');
const configViewEngine = require('./config/viewEngine');
const webRoutes = require('./routes/web');
const connection = require('./config/database');

const app = express(); //app express
const port = process.env.PORT || 8888;
const hostName = process.env.HOST_NAME || 'localhost';

//config view engine and static file
configViewEngine(app);

//routes
app.use('/', webRoutes);




app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});