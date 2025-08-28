const postingServices = require("../services/postingServices");

async function getAllServices(req, res) {
  try {
    const data = await postingServices.getAllServices();
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy dịch vụ", error: err.message });
  }
}

async function getServicesByProperty(req, res) {
  try {
    const { propertyId } = req.params;
    const data = await postingServices.getServicesByProperty(propertyId);
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy dịch vụ theo property", error: err.message });
  }
}

async function createContract(req, res) {
  try {
    const { propertyId, hostId, serviceId, quantity } = req.body;
    const data = await postingServices.createContract({ propertyId, hostId, serviceId, quantity });
    res.status(201).json({ message: "Tạo hợp đồng thành công", contractId: data.NewContractId });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi tạo hợp đồng", error: err.message });
  }
}

async function payContract(req, res) {
  try {
    const { contractId } = req.body;
    await postingServices.payContract(contractId);
    res.json({ message: "Thanh toán hợp đồng thành công" });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi thanh toán hợp đồng", error: err.message });
  }
}

async function getContractById(req, res) {
  try {
    const { contractId } = req.params;
    const data = await postingServices.getContractById(contractId);
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy hợp đồng", error: err.message });
  }
}

async function getContractsByProperty(req, res) {
  try {
    const { propertyId } = req.params;
    const data = await postingServices.getContractsByProperty(propertyId);
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy hợp đồng theo property", error: err.message });
  }
}

async function getTransactionsByHost(req, res) {
  try {
    const { hostId } = req.params;
    const data = await postingServices.getTransactionsByHost(hostId);
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy giao dịch host", error: err.message });
  }
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
