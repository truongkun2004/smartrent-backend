const { sql } = require("../config/database");

async function getAmenities() {
  try {
    const pool = await sql.connect();
    const result = await pool.request().execute("GetAmenities");
    return result.recordset;
  } catch (err) {
    console.error("❌ Error in getAmenities:", err);
    throw err;
  }
}

module.exports = {
  getAmenities
};
