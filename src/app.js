import express from 'express';
import cors from 'cors';
import routes from './routes/index.js';
import errorHandler from './middleware/errorHandle.js';

const app = express();
app.use(cors());
app.use(express.json());

//routes
app.use('/api', routes);

app.use(errorHandler);

app.get('/', (req, res) => {
    res.send('Welcome to the Omnilogi API');
});

export default app;