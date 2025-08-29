const { sql } = require("../config/database");

// 1. Thêm user mới
async function addUser({ name, phone, email, password, firebase_id }) {
  try {
    const pool = await sql.connect();
    const result = await pool
      .request()
      .input("name", sql.NVarChar(100), name)
      .input("phone", sql.NVarChar(20), phone || null)
      .input("email", sql.NVarChar(255), email || null)
      .input("password", sql.NVarChar(255), password || null)
      .input("firebase_id", sql.NVarChar(255), firebase_id || null)
      .execute("AddUser");

    return result.recordset[0]; // { NewUserID: ... }
  } catch (err) {
    throw err;
  }
}

// 2. Cập nhật user
async function updateUser({ id, name, phone, email }) {
  try {
    const pool = await sql.connect();
    await pool
      .request()
      .input("id", sql.Int, id)
      .input("name", sql.NVarChar(100), name || null)
      .input("phone", sql.NVarChar(20), phone || null)
      .input("email", sql.NVarChar(255), email || null)
      .execute("UpdateUser");

    return true;
  } catch (err) {
    throw err;
  }
}

// 3. Xóa user
async function deleteUser(id) {
  try {
    const pool = await sql.connect();
    await pool
      .request()
      .input("id", sql.Int, id)
      .execute("DeleteUser");
    return true;
  } catch (err) {
    throw err;
  }
}

// 4. Tìm user
async function findUser({ firebase_id, account }) {
  try {
    const pool = await sql.connect();
    const request = pool.request();

    if (firebase_id) {
      request.input("firebase_id", sql.NVarChar(255), firebase_id);
      request.input("account", sql.NVarChar(255), null);
    } else if (account) {
      request.input("firebase_id", sql.NVarChar(255), null);
      request.input("account", sql.NVarChar(255), account);
    } else {
      request.input("firebase_id", sql.NVarChar(255), null);
      request.input("account", sql.NVarChar(255), null);
    }

    const result = await request.execute("FindUser");
    return result.recordset;
  } catch (err) {
    throw err;
  }
}

const toggleUserFavorite = async (userId, propertyId) => {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("UserId", sql.Int, userId)
    .input("PropertyId", sql.Int, propertyId)
    .execute("ToggleUserFavorite");
  
  return result.recordset[0].action; // 'added' hoặc 'removed'
};

const getUserFavorites = async (userId) => {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("UserId", sql.Int, userId)
    .execute("GetUserFavorites");
  return result.recordset;
};

async function addPropertyReview(propertyId, userId, rating, comment) {
    const pool = await sql.connect();
    await pool.request()
        .input('PropertyId', sql.Int, propertyId)
        .input('UserId', sql.Int, userId)
        .input('Rating', sql.Int, rating)
        .input('Comment', sql.NVarChar(500), comment)
        .execute('AddPropertyReview');
}

module.exports = {
  addUser,
  updateUser,
  deleteUser,
  findUser,
  toggleUserFavorite,
  getUserFavorites,
  addPropertyReview,
};
