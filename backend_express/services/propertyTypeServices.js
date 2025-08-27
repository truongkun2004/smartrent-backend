const { sql } = require("../config/database");

async function getPropertyTypes() {
  try {
    const pool = await sql.connect();
    const result = await pool.request().execute("GetPropertyTypes");
    return result.recordset;
  } catch (err) {
    console.error("❌ Error in getPropertyTypes:", err);
    throw err;
  }
}

module.exports = {
  getPropertyTypes
};
