const { sql } = require("../config/database");

// Lấy tất cả dịch vụ
async function getAllServices() {
  const pool = await sql.connect();
  const result = await pool.request().execute("GetAllServices");
  return result.recordset;
}

// Lấy dịch vụ theo property
async function getServicesByProperty(propertyId) {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("PropertyId", sql.Int, propertyId)
    .execute("GetServicesByProperty");
  return result.recordset;
}

// Tạo hợp đồng nháp
async function createContract({ propertyId, hostId, serviceId, quantity }) {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("PropertyId", sql.Int, propertyId)
    .input("HostId", sql.Int, hostId)
    .input("ServiceId", sql.Int, serviceId)
    .input("Quantity", sql.Int, quantity)
    .execute("CreateContract");
  return result.recordset[0];
}

// Thanh toán hợp đồng
async function payContract(contractId) {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("ContractId", sql.Int, contractId)
    .execute("PayContract");
  return result.rowsAffected[0];
}

// Lấy hợp đồng theo Id
async function getContractById(contractId) {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("ContractId", sql.Int, contractId)
    .execute("GetContractById");
  return result.recordset[0];
}

// Lấy hợp đồng theo property
async function getContractsByProperty(propertyId) {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("PropertyId", sql.Int, propertyId)
    .execute("GetContractsByProperty");
  return result.recordset;
}

// Lấy giao dịch theo host
async function getTransactionsByHost(hostId) {
  const pool = await sql.connect();
  const result = await pool.request()
    .input("HostId", sql.Int, hostId)
    .execute("GetTransactionsByHost");
  return result.recordset;
}

module.exports = {
  getAllServices,
  getServicesByProperty,
  createContract,
  payContract,
  getContractById,
  getContractsByProperty,
  getTransactionsByHost,
};
