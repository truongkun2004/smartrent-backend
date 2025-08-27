require("dotenv").config();
const sql = require("mssql/msnodesqlv8");

const config = {
  driver: process.env.DB_DRIVER,
  connectionString: process.env.DB_CONNECTION
};

async function connectDB() {
  try {
    console.log("🔧 DB Config:", config);
    await sql.connect(config);
    console.log("✅ Connected to SQL Server (Windows Auth)");
  } catch (err) {
    console.error("❌ Database connection failed:", err);
  }
}

module.exports = {
  sql,
  connectDB
};
