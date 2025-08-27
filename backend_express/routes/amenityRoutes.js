const express = require("express");
const router = express.Router();
const amenityController = require("../controllers/amenityControllers");

router.get("/", amenityController.getAmenities);

module.exports = router;
