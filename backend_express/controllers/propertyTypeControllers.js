const propertyTypeService = require("../services/propertyTypeServices");

async function getPropertyTypes(req, res) {
  try {
    const types = await propertyTypeService.getPropertyTypes();
    res.status(200).json(types);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy loại bất động sản", error: err.message });
  }
}

module.exports = {
  getPropertyTypes
};
