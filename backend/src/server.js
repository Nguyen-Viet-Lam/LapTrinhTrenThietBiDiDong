import {createApp} from './app.js';
import {openDb} from './db.js';
import {seed} from './seed.js';

const db = openDb();
seed(db);
const port = Number(process.env.PORT ?? 3000);
createApp({db}).listen(port, () => console.log(`LifeQuest API: http://localhost:${port}/api/health`));
