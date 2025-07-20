const sql = require("mssql");
require("dotenv").config();

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  port: parseInt(process.env.DB_PORT) || 1433,
  options: {
    encrypt: false, // Use true if using Azure
    trustServerCertificate: true, // Allow self-signed
  },
};

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    console.log("✅ Connected to MSSQL");
    return pool;
  })
  .catch(err => console.error("❌ DB Connection Failed:", err));

module.exports = {
  sql,
  poolPromise,
};
