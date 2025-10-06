import { Client } from 'pg';
import path from 'path';
import { fileURLToPath } from 'url';
import jwt from 'jsonwebtoken';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// import dotenv from 'dotenv';
// dotenv.config({ path: path.join(__dirname, '../.env') });

export const handler = async (event) => {

  try {

      let cpf = event.cpf;
      cpf = cpf.replace(/\s+/g, '').replace(/\D/g, '');

      if (!cpf) {
        return { statusCode: 400, body: JSON.stringify({ error: 'CPF é obrigatório' }) };
      }

      let conObj = {
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASS,
        database: process.env.DB_NAME,
        port: 5432,
        ssl: {
          rejectUnauthorized: false
        }
      }
      
      const client = new Client(conObj);
      await client.connect();

      // console.log('apresentacao')
      const res = await client.query('SELECT * FROM customer WHERE cpf = $1', [cpf]);

      

      let customer = null;

      if (res.rows.length === 0) {
        const now = new Date().toISOString();
        const insertRes = await client.query(
          'INSERT INTO customer (name, cpf) VALUES ($1, $2) RETURNING *',
          [now, cpf]
        );

        customer = insertRes.rows[0];

      }else{
        customer = res.rows[0];
      }



      await client.end();

      const expiresIn = '1h'

      return new Promise((resolve, reject) => {
        jwt.sign(customer, process.env.JWT_SECRET, { expiresIn }, (err, token) => {
                  if (err) {
                      reject({
                          status: 500,
                          message: "Erro ao gerar token"
                      })
                  } else {
                      resolve({
                          status: 200,
                          token: token
                      })
                  }
              })
      })




  } catch (err) {
    console.error(err);
    return { statusCode: 500, body: JSON.stringify({ error: 'Erro interno' }) };
  }

};


// console.log(await handler({"cpf": "02165680301"}'));