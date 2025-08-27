const express = require("express");
const router = express.Router();
const propertyTypeController = require("../controllers/propertyTypeControllers");

router.get("/", propertyTypeController.getPropertyTypes);

module.exports = router;
