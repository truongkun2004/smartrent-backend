const { sql } = require("../config/database");

async function addHost({ name, gender, dob, address, phone, email, password, firebase_id }) {
  try {
    const pool = await sql.connect();
    const result = await pool.request()
      .input("name", sql.NVarChar(100), name)
      .input("gender", sql.NVarChar(10), gender)
      .input("dob", sql.Date, dob)
      .input("address", sql.NVarChar(255), address)
      .input("phone", sql.NVarChar(20), phone)
      .input("email", sql.NVarChar(255), email)
      .input("password", sql.NVarChar(255), password)
      .input("firebase_id", sql.NVarChar(255), firebase_id)
      .execute("AddHost");
    return result.recordset[0]; // { NewHostID: ... }
  } catch (err) {
    console.error("❌ Error in addHost:", err);
    throw err;
  }
}

async function updateHost({ id, name, gender, dob, address, phone, email }) {
  try {
    const pool = await sql.connect();
    await pool.request()
      .input("id", sql.Int, id)
      .input("name", sql.NVarChar(100), name)
      .input("gender", sql.NVarChar(10), gender)
      .input("dob", sql.Date, dob)
      .input("address", sql.NVarChar(255), address)
      .input("phone", sql.NVarChar(20), phone)
      .input("email", sql.NVarChar(255), email)
      .execute("UpdateHost");
  } catch (err) {
    console.error("❌ Error in updateHost:", err);
    throw err;
  }
}

async function deleteHost(id) {
  try {
    const pool = await sql.connect();
    await pool.request()
      .input("id", sql.Int, id)
      .execute("DeleteHost");
  } catch (err) {
    console.error("❌ Error in deleteHost:", err);
    throw err;
  }
}

async function findHost({ firebase_id, account }) {
  try {
    const pool = await sql.connect();
    const result = await pool.request()
      .input("firebase_id", sql.NVarChar(255), firebase_id)
      .input("account", sql.NVarChar(255), account)
      .execute("FindHost");

    if (!result || !result.recordset || result.recordset.length === 0) {
      return null;
    }

    return result.recordset[0];
  } catch (err) {
    console.error("❌ Error in findHost:", err);
    throw err;
  }
}

async function getHostProperties(hostId) {
  const pool = await sql.connect();
  const result = await pool
    .request()
    .input("HostId", sql.Int, hostId)
    .execute("GetHostProperties");

  if (result.recordset.length === 0) return [];

  // lấy đúng cột json_result
  const raw = result.recordset[0].json_result;
  return raw ? JSON.parse(raw) : [];
}

async function depositToHost({ hostId, amount }) {
  try {
    const pool = await sql.connect();
    const result = await pool.request()
      .input("HostId", sql.Int, hostId)
      .input("Amount", sql.Decimal(18,0), amount)
      .execute("DepositToHost");
    return result.rowsAffected[0]; // trả về số row update
  } catch (err) {
    console.error("❌ Error in depositToHost:", err);
    throw err;
  }
}

module.exports = {
  addHost,
  updateHost,
  deleteHost,
  findHost,
  getHostProperties,
  depositToHost,
};