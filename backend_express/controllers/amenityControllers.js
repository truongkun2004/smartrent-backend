const amenityService = require("../services/amenityServices");

async function getAmenities(req, res) {
  try {
    const amenities = await amenityService.getAmenities();
    res.status(200).json(amenities);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy tiện ích", error: err.message });
  }
}

module.exports = {
  getAmenities
};
